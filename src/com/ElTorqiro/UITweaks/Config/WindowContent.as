import com.Components.WindowComponentContent;
import com.ElTorqiro.UITweaks.Plugin;
import com.Utils.Archive;
import com.Utils.Slot;
import flash.geom.Point;
import gfx.controls.CheckBox;
import mx.utils.Delegate;
import com.GameInterface.UtilsBase;
import com.GameInterface.DistributedValue;
import com.ElTorqiro.UITweaks.AddonUtils.ScrollingList;

import com.ElTorqiro.UITweaks.AddonUtils.AddonUtils;

import com.ElTorqiro.UITweaks.AddonUtils.ConfigPanelBuilder;
import com.ElTorqiro.UITweaks.PluginHost;


class com.ElTorqiro.UITweaks.Config.WindowContent extends WindowComponentContent {

	private var _uiControls:Object = {};
	private var _uiInitialised:Boolean = false;
	
	private var m_ContentSize:MovieClip;
	private var m_Content:MovieClip;
	
	private var m_PluginTitle:CheckBox;
	private var m_PluginAuthor:TextField;
	private var m_PluginTitleBackground:MovieClip;
	
	private var m_DescriptionText:TextField;
	private var m_PluginConfigText:TextField;
	
	private var m_ConfigPanel:MovieClip;
	private var _configPanelBuilder:ConfigPanelBuilder;
	
	private var m_PluginList:ScrollingList;
	private var m_PluginListBackground:MovieClip;
	
	private var _togglePluginLoadSlot:Slot;
	private var _togglePluginUnloadSlot:Slot;
	
	public function WindowContent() {
		
		m_PluginTitleBackground = attachMovie( 'PanelBackground', 'm_PluginTitleBackground', getNextHighestDepth() );
		m_PluginTitleBackground.hitTestDisable = true;
		m_PluginTitleBackground._x = 210;
		m_PluginTitleBackground._width = 400;
		
		m_PluginTitle = CheckBox(attachMovie( 'PluginTitleCheckbox', 'm_PluginTitle', getNextHighestDepth(), { autoSize: 'left' } ));
		m_PluginTitle.disableFocus = true;
		m_PluginTitle._x = m_PluginTitleBackground._x + 5;
		m_PluginTitle._y = m_PluginTitleBackground._y + 5;
		
		m_PluginTitleBackground._height = m_PluginTitle._height + 10;
		m_PluginTitle.addEventListener( 'click', this, 'togglePlugin' );
		
		m_PluginAuthor = addTextField( 'm_PluginAuthor', 11 );
		m_PluginAuthor._x = m_PluginTitle._x + m_PluginTitle.textField._x;
		m_PluginAuthor._y = m_PluginTitle._y + m_PluginTitle._height - 3;
		
		m_PluginAuthor.text = ' ';
		m_PluginTitleBackground._height = m_PluginAuthor._y + m_PluginAuthor._height + 5;
		
		m_DescriptionText = addTextField( 'm_DescriptionText' );
		m_PluginConfigText = addTextField( 'm_PluginConfigText' );
		
		m_DescriptionText._x = m_PluginConfigText._x = m_PluginTitle._x;
		m_DescriptionText._y = Math.round(m_PluginTitleBackground._y + m_PluginTitleBackground._height + 5);
		
		m_ConfigPanel = createEmptyMovieClip( 'm_ConfigPanel', getNextHighestDepth() );
		m_ConfigPanel._x = m_PluginTitle._x;
		m_ConfigPanel._y = Math.round( m_DescriptionText._y + m_DescriptionText._height + 10 );
		_configPanelBuilder = new ConfigPanelBuilder( m_ConfigPanel );
		
		m_PluginListBackground = attachMovie( 'PanelBackground', 'm_PluginListBackground', getNextHighestDepth() );
		m_PluginListBackground.hitTestDisable = true;
		m_PluginListBackground._width = 200;
		m_PluginListBackground._height = 400;
		
		m_PluginList = ScrollingList( attachMovie( 'ScrollingListEnableDisableDark', 'm_PluginList', getNextHighestDepth() ) );
		m_PluginList.rowHeight = 22;
		m_PluginList.itemRenderer = 'ScrollingListEnableDisableDarkListItemRenderer';
		m_PluginList.scrollBar = 'ScrollBar';
		
		var data:Array = [];
		for ( var i:Number = 0; i < g_Plugins.length; i++ ) {
			data.push( {label: g_Plugins[i].name, plugin: g_Plugins[i] } );
		}
		
		m_PluginList.dataProvider = data;
		
		m_PluginList.width = m_PluginListBackground._width - 10;
		m_PluginList.height = m_PluginListBackground._height - 10;
		m_PluginList._x = 5;
		m_PluginList._y = 5;
		
		m_PluginList.addEventListener( 'focusIn', this, 'removeFocus' );
		m_PluginList.addEventListener( 'change', this, 'pluginListItemSelected' );
		m_PluginList.addEventListener( 'itemDoubleClick', this, 'togglePlugin' );
		m_PluginList.addEventListener( 'itemClick', this, 'pluginListItemClicked' );
		
		m_PluginList.selectedIndex = 0;
	}

	private function configUI():Void {
		super.configUI();
		
		//SignalSizeChanged.Emit();
	}

	private function draw():Void {

		m_ConfigPanel._y = Math.round( m_DescriptionText._y + m_DescriptionText._height + 10 );
		m_PluginConfigText._y = Math.round( m_DescriptionText._y + m_DescriptionText._height + 10 );
		
		//SignalSizeChanged.Emit();
	}
	
	public function Destroy():Void {
		_configPanelBuilder.Destroy();
	}
	
	private function pluginListItemSelected(event:Object):Void {
		
		_configPanelBuilder.Destroy();
		
		var plugin:Plugin = m_PluginList.dataProvider[ m_PluginList.selectedIndex ].plugin;
		
		m_PluginTitle.label = m_PluginList.dataProvider[ m_PluginList.selectedIndex ].label;
		m_PluginTitle.selected = plugin.enabled;
		
		m_PluginAuthor.text = 'by ' + plugin.author;

		m_DescriptionText.text = plugin.description;
		
		updateEnabledIndicators( plugin );
	}

	private function pluginListItemClicked(event:Object):Void {
		if ( event.renderer.icon.hitTest() ) {
			//UtilsBase.PrintChatText('item icon clicked');
		}
	}
	
	private function togglePlugin():Void {
		
		var plugin:Plugin = g_Plugins[m_PluginList.selectedIndex];

		_togglePluginLoadSlot = plugin.SignalLoaded.Connect( updateEnabledIndicators, this );
		_togglePluginUnloadSlot = plugin.SignalUnloaded.Connect( updateEnabledIndicators, this );
		
		plugin.enabled ? _configPanelBuilder.Destroy() || plugin.Unload() : plugin.Load();
	}
	
	private function updateEnabledIndicators(plugin:Plugin):Void {
		
		plugin.SignalLoaded.DisconnectSlot( _togglePluginLoadSlot );
		plugin.SignalUnloaded.DisconnectSlot( _togglePluginUnloadSlot );
		
		m_PluginTitle.selected = plugin.enabled;
		m_PluginList['renderers'][m_PluginList.selectedIndex].icon.gotoAndStop( plugin.enabled ? 'enabled' : 'disabled' );
		
		if ( plugin.enabled ) {
			var pluginConfig:Object = plugin.mc.getPluginConfiguration();
			if ( pluginConfig == undefined || pluginConfig == { } ) {
				m_PluginConfigText.text = 'No configurable options available.';
			}
			
			else {
				m_PluginConfigText.text = '';
			}
			
			_configPanelBuilder.Build( pluginConfig );
		}
		
		else {
			_configPanelBuilder.Clear();
			m_PluginConfigText.text = 'Enable plugin to show configuration options.';	
		}
		
		invalidate();
	}

	private function addTextField(name:String, fontSize:Number):TextField {
		var textField:TextField = createTextField( name, getNextHighestDepth(), 0, 0, 200, 20 );

		var textFormat:TextFormat = new TextFormat();
		textFormat.font = 'Futura Md';
		textFormat.size = fontSize != undefined ? fontSize : 12;
		textFormat.color = 0xdddddd;

		textField.embedFonts = true;
		textField.multiline = true;
		textField.wordWrap = true;
		textField.verticalAutoSize = 'top';
		textField.setNewTextFormat( textFormat );
		
		return textField;
	}
	
	
    // universally remove focus
    private function removeFocus():Void {
        Selection.setFocus(null);
    }	

	public function Close():Void {
		super.Close();
	}

	public function GetSize():Point {
		return new Point( _width, m_PluginListBackground._height );
	}
	
	/**
	 * 
	 * this is the all-important override that makes window resizing work properly
	 */
    public function SetSize(width:Number, height:Number) {	

		m_PluginList.height = height - 10;
		
		m_PluginListBackground._height = height;// - 5;
		m_PluginTitleBackground._width = width - m_PluginTitleBackground._x;
		
		m_DescriptionText._width = m_PluginConfigText._width = m_PluginTitleBackground._width - 10;
		
		draw();
		
		SignalSizeChanged.Emit();	// must fire this signal, else the parent WinComp container never gets resized, only the inner content does
	}	
	
}