import com.Components.WindowComponentContent;

import flash.geom.Point;
import flash.geom.Rectangle;
import gfx.controls.ScrollingList;
import gfx.controls.ScrollBar;
import com.GameInterface.DistributedValue;

import com.ElTorqiro.UITweaks.App;
import com.ElTorqiro.UITweaks.Plugins.Plugin;
import com.ElTorqiro.UITweaks.AddonUtils.Preferences;
import com.ElTorqiro.UITweaks.AddonUtils.UI.PanelBuilder;
import com.ElTorqiro.UITweaks.AddonUtils.MovieClipHelper;


import com.GameInterface.UtilsBase;

/**
 * 
 * 
 */
class com.ElTorqiro.UITweaks.ConfigWindow.WindowContent extends WindowComponentContent {

	public function WindowContent() {
		
	}

	private function configUI() : Void {
		super.configUI();

		// titlebar button
		var def:Object = {
			layout: [
				{	type: "button",
					text: "Visit forum thread",
					tooltip: "Click to open the in-game browser and visit the forum thread for the addon.",
					onClick: function() {
						DistributedValue.SetDValue("web_browser", false);
						DistributedValue.SetDValue("WebBrowserStartURL", "https://forums.thesecretworld.com/showthread.php?81645-MOD-ElTorqiro_UITweaks");
						DistributedValue.SetDValue("web_browser", true);
					}
				}
			]
		};
		
		var panel:PanelBuilder = PanelBuilder( MovieClipHelper.createMovieWithClass( PanelBuilder, "m_TitleBarPanel", this, this.getNextHighestDepth() ) );
		panel.build( def );
		
		panel._x = Math.round( _parent.m_Title.textWidth + 10 );
		panel._y -= Math.round( _y - _parent.m_Title._y + 1);
		
		// plugin enabled panel
		var def:Object = {
			
			data: { prefs: undefined },
			
			// panel default load/save handlers
			load: componentLoadHandler,
			save: componentSaveHandler,
			
			layout: [
				{	id: "plugin.enabled",
					type: "checkbox",
					label: "Plugin Enabled",
					tooltip: "Enables the Plugin.",
					data: { pref: "plugin.enabled" }
				}
			]
		};

		enabledPanel = PanelBuilder( MovieClipHelper.createMovieWithClass( PanelBuilder, "m_EnabledPanel", this, this.getNextHighestDepth() ) );
		enabledPanel.build( def );

		// plugin details elements
		name.autoSize = "left";
		name.hitTestDisable = true;
		
		author.autoSize = "left";
		author.hitTestDisable = true;
		
		description.verticalAutoSize = "top";
		description.hitTestDisable = true;
		
		// plugin list
		MovieClipHelper.attachMovieWithRegister( "eltorqiro.uitweaks.pluginlist", ScrollingList, "pluginList", this, this.getNextHighestDepth(),
			{ margin: 6 }
		);

		// config panel scrollbar
		MovieClipHelper.attachMovieWithRegister( "eltorqiro.uitweaks.scrollbar", ScrollBar, "configPanelScrollBar", this, this.getNextHighestDepth() );
		configPanelScrollBar.trackMode = "scrollToCursor";
		configPanelScrollBar.addEventListener( "scroll", this, "configPanelScrollHandler" );
		configPanelScrollBar.addEventListener( "focusIn", PanelBuilder, "clearFocus" );

		pluginList.itemRenderer = 'eltorqiro.uitweaks.pluginlist.item';
		//pluginList.scrollBar = 'eltorqiro.uitweaks.scrollbar';
		
		pluginList.labelField = "name";
		pluginList.dataProvider = App.plugins;
		
		pluginList.rowCount = pluginList.dataProvider.length;
		
		pluginList.addEventListener( 'focusIn', PanelBuilder, 'clearFocus' );
		pluginList.addEventListener( 'change', this, 'pluginListChangeHandler' );
		pluginList.addEventListener( 'itemDoubleClick', this, 'togglePlugin' );
		
		// select last selected plugin index
		var selectedPluginIndex:Number = App.prefs.getVal( "configWindow.lastSelectedPluginIndex" );
		if ( selectedPluginIndex == undefined || selectedPluginIndex < 0 || selectedPluginIndex > pluginList.dataProvider.length - 1 ) {
			selectedPluginIndex = 0;
		}

		pluginList.selectedIndex = selectedPluginIndex;

	}

	private function draw():Void {

		if ( sizeIsInvalid ) {
			layout();
		}

	}
	
	private function layout() : Void {
		
		var detailsOffset:Number = 200;
		
		//title block
		name._x = detailsOffset;
		author._x = name._x + name.textWidth + 5;
		description._x = detailsOffset;
		description._width = __width - description._x;
		
		line1._x = detailsOffset;
		line1._y = Math.round( description._y + description.textHeight + 10 );
		line1._width = __width - line1._x;
		
		enabledPanel._x = detailsOffset;
		enabledPanel._y = line1._y + line1._height + 5;
		
		line2._x = detailsOffset;
		line2._y = Math.round( enabledPanel._y + enabledPanel.height + 5 );
		line2._width = __width - line2._x;

		configPanel._x = detailsOffset;
		configPanel._y = Math.round( line2._y + line2._height + 8 );
		
		// setup config panel scrollable area
		var rect:Rectangle = new Rectangle( 0, 0, configPanel.width, __height - configPanel._y );
		if ( configPanel.height > rect.height ) {

			configPanelScrollBar._x = __width - configPanelScrollBar._width;
			
			configPanel.scrollRect = rect;

			// set scrollbar
			configPanelScrollBar._y = configPanel._y;
			configPanelScrollBar.height = rect.height;

			var maxScroll:Number = configPanel.height - rect.height;
			var viewportHeightPercent:Number = rect.height / configPanel.height;
			
			configPanelScrollBar.setScrollProperties( rect.height * viewportHeightPercent, 0, maxScroll );
			configPanelScrollBar.position = 0;
			
			configPanelScrollBar._visible = true;
		}
		
		else {
			configPanelScrollBar._visible = false;
		}

		configPanel._visible = true;
		
	}
	
	private function pluginListChangeHandler( event:Object ) : Void {

		var plugin:Plugin = pluginList.dataProvider[ pluginList.selectedIndex ];
		
		name.text = plugin.name;
		author.text = "by " + plugin.author;
		description.text = plugin.description;
		
		enabledPanel.data.prefs = plugin.prefs;
		enabledPanel.components[ "plugin.enabled" ].api.load();
		
		// destroy old config panel
		pluginPrefs.SignalValueChanged.Disconnect( prefListener, this );
		configPanel.removeMovieClip();

		// create new configuration panel
		pluginPrefs = plugin.prefs;
		pluginPrefs.SignalValueChanged.Connect( prefListener, this );
		
		// define the config panel to be built
		var pluginLayout:Array = plugin.getConfigPanelLayout();
		if ( pluginLayout == undefined ) {
			pluginLayout = [
				{	type: "text",
					text: "This plugin provides no user configurable options."
				}
			];
		}
		
		var def:Object = {
			
			data: { prefs: pluginPrefs },
			
			// panel default load/save handlers
			load: componentLoadHandler,
			save: componentSaveHandler,
			
			layout: pluginLayout
		};
		
		// build the panel based on definition
		configPanel = PanelBuilder( MovieClipHelper.createMovieWithClass( PanelBuilder, "m_Panel", this, this.getNextHighestDepth(), { _visible: false } ) );
		configPanel.build( def );

		// update the saved pref for selected plugin index
		App.prefs.setVal( "configWindow.lastSelectedPluginIndex", pluginList.selectedIndex );
		
		sizeIsInvalid = true;
		invalidate();
		
	}

	private function configPanelScrollHandler( event:Object ) : Void {
		
		var rect:Rectangle = Rectangle( configPanel.scrollRect );
		configPanel.scrollRect = new Rectangle( 0, event.position, rect.width, rect.height );
		
	}
	
	/**
	 * listener for pref value changes, to update the config ui
	 * 
	 * @param	name
	 * @param	newValue
	 * @param	oldValue
	 */
	private function prefListener( name:String, newValue, oldValue ) : Void {
		
		if ( name == "plugin.enabled" ) {
			// trigger visual updates of enabled state indicators
			enabledPanel.components[ "plugin.enabled" ].api.load();
			pluginList.invalidateData();
		}

		else {
			var component = configPanel.components[ name ];
			
			// only update controls that are using the pref shortcuts
			if ( component.api.data.pref ) {
				component.api.load();
			}
		}
	}
	
	private function componentLoadHandler() : Void {
		this.setValue( this.panel.data.prefs.getVal( this.data.pref ) );
	}

	private function componentSaveHandler() : Void {
		this.panel.data.prefs.setVal( this.data.pref, this.getValue() );
	}

	public function GetSize():Point {
		return new Point( __width, __height );
	}
	
	/**
	 * this is the all-important override that makes window resizing work properly
	 */
    public function SetSize(width:Number, height:Number) {		
		setSize( width, height );
		
		SignalSizeChanged.Emit();	// must fire this signal, else the parent WinComp container never gets resized, only the inner content does
	}	
	
	/**
	 * internal variables
	 */
	
	private var pluginPrefs:Preferences;

	 
	/**
	 * properties
	 */
	
	public var name:TextField;
	public var author:TextField;
	public var description:TextField
	public var line1:MovieClip;
	public var line2:MovieClip;

	public var enabledPanel:PanelBuilder;
	
	public var pluginList:ScrollingList;
	
	public var configPanel:PanelBuilder;
	public var configPanelScrollBar:ScrollBar;
}