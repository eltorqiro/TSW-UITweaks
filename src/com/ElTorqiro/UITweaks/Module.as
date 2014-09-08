import com.ElTorqiro.UITweaks.AddonUtils.AddonUtils;
import com.ElTorqiro.UITweaks.AddonInfo;
import com.Utils.Archive;
import XML;
import com.GameInterface.GUIUtils.XmlParser;
import com.ElTorqiro.UITweaks.Plugin;

import com.ElTorqiro.UITweaks.AddonUtils.Module;

import mx.utils.Delegate;

import com.ElTorqiro.UITweaks.AddonUtils.Window;
import com.GameInterface.DistributedValue;
import flash.geom.Point;
import com.GameInterface.UtilsBase;


// config window
var g_configWindow:Window;

// internal distributed value listeners
var g_showConfig:DistributedValue;

// config settings
var g_settings:Object;
var g_Module:Module;

var g_XML:XML;
var g_Plugins:Array;
var g_XMLLoaded:Boolean;

/**
 * onLoad
 * 
 * GMF_DONT_UNLOAD is enabled in Modules.xml
 */
function onLoad():Void {

	// default config related settings
	g_settings = {
		configWindowPosition: new Point( 200, 200 ),
		configWindowSize: new Point( 600, 400 ),
		iconPosition: new Point( (Stage.visibleRect.width - g_icon._width) / 2, (Stage.visibleRect.height - g_icon._width) / 4 ),
		iconScale: 100
	};

	// load module settings
	var loadData = DistributedValue.GetDValue(AddonInfo.Author + '_' + AddonInfo.Name + '_Data');
	for ( var i:String in g_settings ) {
		g_settings[i] = loadData.FindEntry( i, g_settings[i] );
	}

	// initialise module
	g_Module = new Module( this, AddonInfo.Name, AddonInfo.Author, AddonInfo.Version, 'ElTorqiro_UITweaks_ShowConfig' );
	g_Module.attachIcon( undefined, g_settings.iconPosition, g_settings.iconScale );
	
	
	// config window toggle listener
	g_showConfig = DistributedValue.Create(AddonInfo.Author + '_' + AddonInfo.Name + '_ShowConfig');
	g_showConfig.SignalChanged.Connect(ToggleConfigWindow, this);

	g_Plugins = new Array();
	
	g_XML = new XML();
	g_XML.onLoad = onXMLLoaded;
	g_XML.ignoreWhite = true;
	g_XML.load( g_Module.modulePath + '/plugins.xml' );
}

function OnModuleActivated():Void {
	g_Module.iconClip.m_Movie._visible = true;
	
	PluginsReady();
}

function OnModuleDeactivated():Void {
	g_Module.iconClip.m_Movie._visible = false;
	
	// destroy config window
	g_showConfig.SetValue(false);
	
	// deactivate all plugins
	var settings:Archive = new Archive();
	
	for ( var i:Number = 0; i < g_Plugins.length; i++ ) {
		var plugin:Plugin = Plugin(g_Plugins[i]);
		var pluginSettings:Archive = new Archive();
		
		pluginSettings.AddEntry( 'enabled', plugin.enabled );
		plugin.Unload();
		pluginSettings.AddEntry( 'settings', plugin.settings );
		
		settings.AddEntry( plugin.name, pluginSettings );
	}
	
	DistributedValue.SetDValue(AddonInfo.Author + '_' + AddonInfo.Name + '_AccountPluginSettings', settings);
	

	// save module settings
	var saveData = new Archive();
	for(var i:String in g_settings) {
		saveData.AddEntry( i, g_settings[i] );
	}
	
	DistributedValue.SetDValue(AddonInfo.Author + '_' + AddonInfo.Name + '_Data', saveData);
}

function OnUnload():Void {
	
	// TODO: this causes a crash on reloadui, need some way to remove icon clip safely
	//g_Module.detachIcon();
	
}

function onXMLLoaded(success:Boolean):Void {
	// TODO: if status is 0, xml could not be parsed successfully, some user friendly message needed
	//UtilsBase.PrintChatText('loaded:' + success + ', status:' + _xml.status);
	
	var pluginsNode = g_XML.firstChild;
	// TODO: check if pluginsNode is actually the <plugins> node
	//UtilsBase.PrintChatText('pluginsNode:' + pluginsNode.nodeName );

	for (var aNode:XMLNode = pluginsNode.firstChild; aNode != null; aNode = aNode.nextSibling) {

		var plugin:Plugin = new Plugin( g_Module.modulePath.toLowerCase() + '_' + aNode.attributes.location, aNode.attributes.name, g_Module.modulePath + '/plugins/' + aNode.attributes.location, aNode.attributes.depth, aNode.attributes['sub-depth']);
		plugin.description = aNode.attributes.description;
		plugin.author = aNode.attributes.author;
		plugin.contactURL = aNode.attributes['contact-url'];
		
		g_Plugins.push( plugin );
	}
	
	// sort the array alphabetically
	g_Plugins.sortOn( 'name', Array.CASEINSENSITIVE );
	
	g_XML = null;
	g_XMLLoaded = true;
	PluginsReady();
}

function PluginsReady():Void {
	if ( !g_XMLLoaded ) return;

	var accountSettings:Archive = DistributedValue.GetDValue(AddonInfo.Author + '_' + AddonInfo.Name + '_AccountPluginSettings');
	
	for ( var i:Number = 0; i < g_Plugins.length; i++ ) {
		var plugin:Plugin = Plugin(g_Plugins[i]);
		
		// load if saved enabled
		var pluginSettings:Archive = accountSettings.FindEntry( plugin.name );
		plugin.settings = pluginSettings.FindEntry( 'settings' );

		if ( pluginSettings.FindEntry('enabled', false) ) plugin.Load();
	}
}


function ToggleConfigWindow():Void {
	g_showConfig.GetValue() ? CreateConfigWindow() : DestroyConfigWindow();
}

function CreateConfigWindow():Void {
	
	// do nothing if window already open
	if ( g_configWindow )  return;
	
	g_configWindow = Window(attachMovie( "com.ElTorqiro.UITweaks.Config.WindowComponent", "m_ConfigWindow", getNextHighestDepth() ));
	
	g_configWindow.title = AddonInfo.Name + " v" + AddonInfo.Version;
	g_configWindow.showHelpButton = false;
	g_configWindow.showFooter = false;
	g_configWindow.minWidth = 600;
	g_configWindow.minHeight = 400;

	g_configWindow.SignalContentLoaded.Connect( function() {
		g_configWindow.SetSize( g_settings.configWindowSize.x, g_settings.configWindowSize.y );
	}, this );
	
	// load the content panel
	g_configWindow.SetContent( "com.ElTorqiro.UITweaks.Config.WindowContent" );

	// set position -- rounding of the values is critical here, else it will not reposition reliably
	g_configWindow._x = Math.round(g_settings.configWindowPosition.x);
	g_configWindow._y = Math.round(g_settings.configWindowPosition.y);
	
	// wire up close button
	g_configWindow.SignalClose.Connect( function() {
		g_showConfig.SetValue(false);
	}, this);
}

function DestroyConfigWindow():Void {
	
	if ( g_configWindow ) {
		g_configWindow.GetContent().Destroy();
		
		g_settings.configWindowPosition.x = g_configWindow._x;
		g_settings.configWindowPosition.y = g_configWindow._y;
		
		g_settings.configWindowSize = g_configWindow.GetSize();
		
		g_configWindow.removeMovieClip();
	}
}