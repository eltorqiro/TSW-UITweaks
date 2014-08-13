import com.ElTorqiro.UITweaks.AddonUtils.AddonUtils;
import com.ElTorqiro.UITweaks.Plugins.SuppressCharacterSheetScaling;
import com.ElTorqiro.UITweaks.Plugins.SuppressMaxAPSPNotifications;
import com.ElTorqiro.UITweaks.Plugins.AbilityBarDeFX;
import com.ElTorqiro.UITweaks.Plugins.InspectionStats;
import com.ElTorqiro.UITweaks.Plugins.ResizeAlteredStates;
import com.ElTorqiro.UITweaks.Plugins.MoveAnyHUD;
import com.ElTorqiro.UITweaks.AddonInfo;
import GUIFramework.ClipNode;
import XML;
import com.GameInterface.GUIUtils.XmlParser;

import mx.utils.Delegate;

import flash.filters.DropShadowFilter;

import com.GameInterface.Tooltip.*;
import com.ElTorqiro.UITweaks.AddonUtils.Window;
import com.GameInterface.DistributedValue;
import flash.geom.Point;
import com.GameInterface.UtilsBase;

import GUIFramework.SFClipLoader;

// config window
var g_configWindow:Window;

// internal distributed value listeners
var g_showConfig:DistributedValue;

// Viper's Top Bar Information Overload (VTIO) integration
var g_VTIOIsLoadedMonitor:DistributedValue;
var g_isRegisteredWithVTIO:Boolean = false;

// icon objects
var g_icon:MovieClip;
var g_iconTooltipData:TooltipData;
var g_tooltip:TooltipInterface;

var clipNode:ClipNode;

// config settings
var g_settings:Object;

// holder for all plugins
var g_plugins:Array = [];


/**
 * OnLoad
 * 
 * This has GMF_DONT_UNLOAD in Modules.xml so TSW module manager will not unload it during teleports etc.
 * Thus, all the global variables will persist, like settings and icon etc, only needing to be refreshed during onLoad() and saved during onUnLoad().
 */
function onLoad():Void {

	// default config module settings
	g_settings = {
		configWindowPosition: new Point( 200, 200 ),
		iconPosition: new Point( (Stage.visibleRect.width - g_icon._width) / 2, (Stage.visibleRect.height - g_icon._width) / 4 ),
		iconScale: 100
	};

	// load module settings
	var loadData = DistributedValue.GetDValue(AddonInfo.Name + "_Config_Data");
	for ( var i:String in g_settings )
	{
		g_settings[i] = loadData.FindEntry( i, g_settings[i] );
	}

	CreateIcon();
	
	// VTIO integration, but don't try to reregister
	if ( !g_isRegisteredWithVTIO )
	{
		g_VTIOIsLoadedMonitor = DistributedValue.Create("VTIO_IsLoaded");
		g_VTIOIsLoadedMonitor.SignalChanged.Connect(CheckVTIOIsLoaded, this);

		// handle race condition for DV already having been set before our listener was connected
		CheckVTIOIsLoaded();
	}

	// config window toggle listener
	g_showConfig = DistributedValue.Create(AddonInfo.Name + "_ShowConfig");
	g_showConfig.SignalChanged.Connect(ToggleConfigWindow, this);


	// attach plugins
/*
	g_plugins.push( new SuppressCharacterSheetScaling() );
	g_plugins.push( new SuppressMaxAPSPNotifications() );
	g_plugins.push( new AbilityBarDeFX() );
	g_plugins.push( new InspectionStats() );
	g_plugins.push( new ResizeAlteredStates() );
	g_plugins.push( new MoveAnyHUD() );
*/	
	LoadPluginData();
}


function LoadPluginData():Void {
	
	var xml:XML = new XML();
	xml.onLoad = function(success:Boolean) {
		// TODO: if status is 0, xml could not be parsed successfully, some user friendly message needed
		UtilsBase.PrintChatText('loaded:' + success + ', status:' + this.status);
		
		var pluginsNode = this.firstChild;
		// TODO: check if pluginsNode is actually the <plugins> node
		UtilsBase.PrintChatText('pluginsNode:' + pluginsNode.nodeName );
		
		for (var aNode:XMLNode = pluginsNode.firstChild; aNode != null; aNode = aNode.nextSibling) {
			UtilsBase.PrintChatText('n:' +  aNode.attributes.name );

			var plugin:Object = {
				name: aNode.attributes.name,
				author: aNode.attributes.author,
				contactURL: aNode.attributes['contact-url'],
				location: aNode.attributes.location,
				depth: aNode.attributes.depth,
				subDepth: aNode.attributes['sub-depth'],
				clipNode: undefined
				
				/* settings: TODO: fetch settings from archive */
			};
			
			g_plugins.push( plugin );

			plugin.clipNode = SFClipLoader.LoadClip( 'ElTorqiro_UITweaks/plugins/' + plugin.location + '/plugin.swf', AddonInfo.Name.toLowerCase() + ' ' + plugin.location, false, plugin.depth, plugin.subDepth);
			plugin.clipNode.SignalLoaded.Connect( function() {
				UtilsBase.PrintChatText('s:' + this.clipNode.m_Movie );
				this.mc = this.clipNode.m_Movie;
				this.plugin = new this.mc.plugin( this );
				this.plugin.Activate();
			}
			, plugin );
		}
		
	};
	
	xml.ignoreWhite = true;
	xml.load( 'ElTorqiro_UITweaks/plugins.xml' );
}

function OnModuleActivated():Void {
	
	// activate all plugins
	for (var i:Number = 0; i < g_plugins.length; i++)
	{
		g_plugins[i].active = true;
	}

	// show config icon
//	g_icon._visible = true;
	clipNode.m_Movie._visible = true;
}

function OnModuleDeactivated():Void {

	// destroy config window
	g_showConfig.SetValue(false);
	
	// deactivate all plugins
	for (var i:Number = 0; i < g_plugins.length; i++)
	{
		g_plugins[i].active = false;
	}
	
//	g_icon._visible = false;	
	clipNode.m_Movie._visible = false;
}

function OnUnload():Void
{
	g_VTIOIsLoadedMonitor.SignalChanged.Disconnect(CheckVTIOIsLoaded, this);
	
	// save module settings
	var saveData = new Archive();
	for(var i:String in g_settings)
	{
		saveData.AddEntry( i, g_settings[i] );
	}
	
	// becaues LoginPrefs.xml has a reference to this DValue, the contents will be saved whenever the game thinks it is necessary (e.g. closing the game, reloadui etc)
	DistributedValue.SetDValue(AddonInfo.Name + "_Config_Data", saveData);
}

function CheckVTIOIsLoaded()
{
	// don't re-register with VTIO
	if ( !g_isRegisteredWithVTIO && g_VTIOIsLoadedMonitor.GetValue() )
	{
		if ( g_icon == undefined ) return;
		
		// register with VTIO
		DistributedValue.SetDValue("VTIO_RegisterAddon", 
			AddonInfo.Name + "|" + AddonInfo.Author + "|" + AddonInfo.Version + "|" + AddonInfo.Name + "_ShowConfig|" + g_icon
		);
		
		g_isRegisteredWithVTIO = true;
		
		// recreate icon tooltip info to remove the icon handling instructions
		CreateTooltipData();
	}
}

function blah(clipNode, loaded) {
	g_icon = clipNode.m_Movie.m_Icon;
	
	// restore location
	g_icon._x = g_settings.iconPosition.x;
	g_icon._y = g_settings.iconPosition.y;
	g_icon._xscale = g_icon._yscale = g_settings.iconScale;
	// check for position sanity -- visible rect may have changed between sessions, don't want the icon to be positioned off screen
	PositionIcon();
	
	// add icon mouse event handlers
	g_icon.onMousePress = function(buttonID) {
		
		// dragging icon with CTRL held down, only if VTIO not present
		if ( !g_isRegisteredWithVTIO && buttonID == 1 && Key.isDown(Key.CONTROL) ) {
			CloseTooltip();
			g_icon.startDrag();
		}
		
		// left mouse click, toggle config window
		else if ( buttonID == 1 ) {
			CloseTooltip();
			DistributedValue.SetDValue(AddonInfo.Name + "_ShowConfig",	!DistributedValue.GetDValue(AddonInfo.Name + "_ShowConfig"));
		}
		
		// reset icon scale, only if VTIO not present
		else if (!g_isRegisteredWithVTIO && buttonID == 2 && Key.isDown(Key.CONTROL)) {
			ScaleIcon(100);
		}
	};
	
	// stop dragging icon
	g_icon.onRelease = g_icon.onReleaseOutside = function() {
		if ( !g_isRegisteredWithVTIO )  g_icon.stopDrag();
		PositionIcon();
	};
	
	// resize icon with CTRL mousewheel
	g_icon.onMouseWheel = function(delta) {
		if ( !g_isRegisteredWithVTIO && Key.isDown(Key.CONTROL))
		{
			CloseTooltip();
			
			// determine scale
			var scaleTo:Number = g_icon._xscale + (delta * 5);
			scaleTo = Math.max(scaleTo, 35);
			scaleTo = Math.min(scaleTo, 100);
			ScaleIcon(scaleTo);
		}
	};
	
	// mouse hover, show tooltip
	g_icon.onRollOver = function()
	{
		CloseTooltip();
		g_tooltip = TooltipManager.GetInstance().ShowTooltip(g_Icon,com.GameInterface.Tooltip.TooltipInterface.e_OrientationVertical,0,g_iconTooltipData);
	};

	// mouse out, hide tooltip
	g_icon.onRollOut = function()
	{
		CloseTooltip();
	};
	

	CheckVTIOIsLoaded();
}

function CreateIcon():Void
{
	// don't recreate if already there
	if ( g_icon != undefined )  return;
	
	// load config icon & tooltip
	// depth 3 = "top"
	//var depthClip:MovieClip = SFClipLoader.CreateEmptyMovieClip( AddonInfo.Name + '_IconContainer', 3, 2);
	
	clipNode = SFClipLoader.LoadClip( 'ElTorqiro_UITweaks/Icon.swf', AddonInfo.Name.toLowerCase() + '_icon', false, 3, 2);
	clipNode.SignalLoaded.Connect( blah, this );
	
	var depthClip = clipNode.m_Movie;
	
	depthClip.lineStyle( 2, 0xffffff, 100 );
	AddonUtils.DrawRectangle( depthClip, 0, 0, 200, 200, 6, 6, 6, 6 );

	//g_icon = depthClip;
	
	//g_icon = depthClip.attachMovie("com.ElTorqiro.UITweaks.Config.Icon", "m_Icon", depthClip.getNextHighestDepth() );
	
	CreateTooltipData();

}

function CreateTooltipData():Void
{
	// create icon tooltip data
	g_iconTooltipData = new com.GameInterface.Tooltip.TooltipData();
	g_iconTooltipData.AddAttribute("", "<font face=\'_StandardFont\' size=\'14\' color=\'#00ccff\'><b>" + AddonInfo.Name + " v" + AddonInfo.Version + "</b></font>");
	g_iconTooltipData.AddAttributeSplitter();
	g_iconTooltipData.AddAttribute("","");
	g_iconTooltipData.AddAttribute("", "<font face=\'_StandardFont\' size=\'11\' color=\'#BFBFBF\'><b>Left Click</b> Open/Close configuration window.</font>");
	
	// show icon handling control instructions if VTIO has not hijacked the icon
	if ( !g_isRegisteredWithVTIO )
	{
		g_iconTooltipData.AddAttributeSplitter();
		g_iconTooltipData.AddAttribute("","");		
		g_iconTooltipData.AddAttribute("", "<font face=\'_StandardFont\' size=\'12\' color=\'#FFFFFF\'><b>Icon</b>\n</font><font face=\'_StandardFont\' size=\'11\' color=\'#BFBFBF\'><b>CTRL + Left Drag</b> Move icon.\n<b>CTRL + Roll Mousewheel</b> Resize icon.\n<b>CTRL + Right Click</b> Reset icon size to 100%.</font>");
	}
/*
	g_iconTooltipData.AddAttributeSplitter();
	g_iconTooltipData.AddAttribute("","");	
	g_iconTooltipData.AddAttribute("", "<font face=\'_StandardFont\' size=\'12\' color=\'#FFFFFF\'><b>HUD Bars</b>\n<font face=\'_StandardFont\' size=\'11\' color=\'#BFBFBF\'><b>CTRL + Left Drag</b> Move both HUD bars at once.\n<b>CTRL + Right Drag</b> Move an individual bar.\n<b>CTRL + Mouse Wheel roll</b> Scale HUD bars.</font>");
	g_iconTooltipData.m_Padding = 8;
	g_iconTooltipData.m_MaxWidth = 256;	
*/
}

function CloseTooltip():Void
{
	if( g_tooltip != undefined )  g_tooltip.Close();
}

function ScaleIcon(scale:Number):Void
{
	if ( g_icon != undefined && !g_isRegisteredWithVTIO )
	{
		var oldWidth:Number = g_icon._width;
		var oldHeight:Number = g_icon._height;

		g_icon._xscale = g_icon._yscale = scale;
		
		// scale around centre of icon
		PositionIcon( g_icon._x - (g_icon._width - oldWidth) / 2, g_icon._y - (g_icon._height - oldHeight) / 2 );

		g_settings.iconScale = scale;
	}
}

function PositionIcon(x:Number, y:Number)
{ 
	if ( g_icon != undefined && !g_isRegisteredWithVTIO )
	{
		if ( x != undefined )  g_icon._x = x;
		if ( y != undefined )  g_icon._y = y;
		
		var onScreenPos:Point = Utils.OnScreen( g_icon );
		
		g_icon._x = onScreenPos.x;
		g_icon._y = onScreenPos.y;
		
		g_settings.iconPosition = new Point(g_icon._x, g_icon._y);
	}
}


function ToggleConfigWindow():Void
{
	g_showConfig.GetValue() ? CreateConfigWindow() : DestroyConfigWindow();
}

function CreateConfigWindow():Void
{
	// do nothing if window already open
	if ( g_configWindow )  return;
	
	g_configWindow = Window(attachMovie( "com.ElTorqiro.UITweaks.Config.WindowComponent", "m_ConfigWindow", getNextHighestDepth() ));
	//g_configWindow.SetTitle(AddonInfo.Name + " v" + AddonInfo.Version);
	//g_configWindow['m_Title'].embedFonts = true;
	//g_configWindow['m_Title'].html = false;
	//var textFormat:TextFormat = new TextFormat();
	//textFormat.bold = false;
	//textFormat.color = 0x00ccff;
	//g_configWindow['m_Title'].setNewTextFormat( textFormat );
	//g_configWindow['m_Title'].text = AddonInfo.Name + " v" + AddonInfo.Version;
	//g_configWindow['m_Title'].filters = [ new DropShadowFilter( 60, 90, 0x000000, 0.8, 8, 8, 3, 3, false, false, false ) ];
	
	//g_configWindow['m_CloseButton'].filters = [ new DropShadowFilter( 60, 90, 0x000000, 0.8, 8, 8, 3, 3, false, false, false ) ];
	//g_configWindow['m_ResizeButton'].filters = [ new DropShadowFilter( 90, -90, 0x000000, 0.8, 8, 8, 2, 3, false, false, false ) ];
	
	//g_configWindow.ShowFooter(false);
	//g_configWindow.ShowResizeButton(true);
	//g_configWindow.SetMinHeight( 300 );
	//g_configWindow.SetMinWidth( 400 );
	
	g_configWindow.title = AddonInfo.Name + " v" + AddonInfo.Version;
	g_configWindow.showHelpButton = false;
	g_configWindow.showFooter = false;
	
	g_configWindow.SetSize( 300, 400 );

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

function DestroyConfigWindow():Void
{
	if ( g_configWindow )
	{	
		g_configWindow.GetContent().Destroy();
		
		g_settings.configWindowPosition.x = g_configWindow._x;
		g_settings.configWindowPosition.y = g_configWindow._y;
		
		g_configWindow.removeMovieClip();
	}
}