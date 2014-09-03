import com.Components.WindowComponentContent;
import com.Utils.Archive;
import flash.geom.Point;
import gfx.controls.CheckBox;
import mx.utils.Delegate;
import com.GameInterface.UtilsBase;
import com.GameInterface.DistributedValue;
import com.ElTorqiro.UITweaks.AddonUtils.ScrollingList;

import com.ElTorqiro.UITweaks.AddonUtils.AddonUtils;

import com.ElTorqiro.UITweaks.AddonUtils.ConfigPanelBuilder;
import com.ElTorqiro.UITweaks.PluginHost;


class com.ElTorqiro.UITweaks.Config.WindowContent extends WindowComponentContent
{
	private var _hudData:DistributedValue;
	private var _uiControls:Object = {};
	private var _uiInitialised:Boolean = false;
	
	private var m_ContentSize:MovieClip;
	private var m_Content:MovieClip;
	
	private var m_PluginTitle:CheckBox;
	private var m_PluginTitleBackground:MovieClip;
	
	private var m_DescriptionText:TextField;
	
	private var m_ConfigPanel:MovieClip;
	private var m_ConfigPanelBackground:MovieClip;
	
	private var panel:MovieClip;
	
	private var pluginList:ScrollingList;
	private var m_PluginListBackground:MovieClip;
	
	public function WindowContent() {
		
		var Configuration:Object = {
			title: 'test',
			
			onOpen: { context: this, fn: function() {
				ConfigOverlay( true );
			}},
			
			onClose: { context: this, fn: function() {
				ConfigOverlay( false );
			}},
			
			elements: [
				{ type: 'checkbox', label: 'Remove button reflections', data: { module: 'aaa_test' }, initial: true,
					onChange: { context: this, fn: function(state:Boolean, data:Object) {
						UtilsBase.PrintChatText('checkbox state:' + state + ', data:' + data);
					}}
				},
				{ type: 'checkbox', label: 'Hide button gloss effect', data: { module: 'aaa_test' }, initial: true,
					onChange: { context: this, fn: function(state:Boolean, data:Object) {
						UtilsBase.PrintChatText('checkbox state:' + state + ', data:' + data);
					}}
				}
			]
		};
		
		
		m_TitlePanel = createEmptyMovieClip( 'm_TitlePanel', getNextHighestDepth() );
		m_TitlePanel._x = 210;

		m_PluginTitleBackground = attachMovie( 'PanelBackground', 'm_PluginTitleBackground', getNextHighestDepth() );
		m_PluginTitleBackground.hitTestDisable = true;
		m_PluginTitleBackground._x = 210;
		
		m_PluginTitle = CheckBox(attachMovie( 'PluginTitleCheckbox', 'm_PluginTitle', getNextHighestDepth(), { autoSize: 'left' } ));
		m_PluginTitle.disableFocus = true;
		m_PluginTitle._x = m_PluginTitleBackground._x + 5;
		m_PluginTitle._y = m_PluginTitleBackground._y + 5;
		
		m_PluginTitleBackground._height = m_PluginTitle._height + 10;
		
		m_DescriptionText = createTextField( 'm_DescriptionText', getNextHighestDepth(), m_PluginTitle._x, Math.round(m_PluginTitleBackground._y + m_PluginTitleBackground._height + 5), 200, 20 );
		var descriptionTextFormat:TextFormat = new TextFormat();
		descriptionTextFormat.font = 'Futura Md';
		descriptionTextFormat.size = 12;
		descriptionTextFormat.color = 0xdddddd;

		m_DescriptionText.embedFonts = true;
		m_DescriptionText.multiline = true;
		m_DescriptionText.wordWrap = true;
		m_DescriptionText.verticalAutoSize = 'top';
		m_DescriptionText.setNewTextFormat( descriptionTextFormat );
		
		m_ConfigPanel = createEmptyMovieClip( 'm_ConfigPanel', getNextHighestDepth() );
		m_ConfigPanel._x = m_PluginTitle._x;
		m_ConfigPanel._y = Math.round( m_DescriptionText._y + m_DescriptionText._height + 10 );
		var configPanelBuilder:ConfigPanelBuilder = new ConfigPanelBuilder( m_ConfigPanel, Configuration );
		
		m_PluginListBackground = attachMovie( 'PanelBackground', 'm_PluginListBackground', getNextHighestDepth() );
		m_PluginListBackground.hitTestDisable = true;
		m_PluginListBackground._width = 200;
		m_PluginListBackground._height = 400;
		
		pluginList = ScrollingList( attachMovie( 'ScrollingListEnableDisableDark', 'm_PluginList', getNextHighestDepth(), { margin: 5 } ) );
		pluginList.rowHeight = 22;
		pluginList.itemRenderer = 'ScrollingListEnableDisableDarkListItemRenderer';
		pluginList.scrollBar = 'ScrollBar';
		
		var data:Array = [];
		for ( var i:Number = 0; i < PluginHost.plugins.length; i++ ) {
			data.push( {label: PluginHost.plugins[i].name, enabled: PluginHost.plugins[i].enabled, data: PluginHost.plugins[i] } );
		}
		
		pluginList.dataProvider = data;
		
		pluginList.width = 200;
		pluginList.height = 400;
		
		pluginList.addEventListener( 'focusIn', this, 'removeFocus' );
		pluginList.addEventListener( 'renderComplete', this, 'listrenderdone' );
		pluginList.addEventListener( 'change', this, 'pluginListItemSelected' );
		
		pluginList.selectedIndex = 0;
		
	}

	// cleanup operations
	public function Destroy():Void {
		// disconnnect from signals
		_hudData.SignalChanged.Disconnect(HUDDataChanged, this);
	}
	
	private function configUI():Void {

		super.configUI();
		
		var Configuration:Object = {
			title: 'test',
			
			onOpen: { context: this, fn: function() {
				ConfigOverlay( true );
			}},
			
			onClose: { context: this, fn: function() {
				ConfigOverlay( false );
			}},
			
			elements: [
				{ type: 'section', label: 'Override Modules', color: 0xff8800 },
				{ type: 'checkbox', label: 'checkbox test', data: { module: 'aaa_test' }, initial: true,
					onChange: { context: this, fn: function(state:Boolean, data:Object) {
						UtilsBase.PrintChatText('checkbox state:' + state + ', data:' + data);
					}}
				},
				{ type: 'dropdown', label: 'dropdown test', data: {}, items: [
						{ label: 'Item 1', data: { module: 'item1data' } },
						{ label: 'Item 2', data: { module: 'item2data' } },
						{ label: 'Item 3', data: { module: 'item3data' } }
					], initial: 1,
					onChange: { context: this, fn: function(selectedIndex:Number, selectedData:Object, data:Object) {
						UtilsBase.PrintChatText('selected:' + selectedIndex + ', selectedData:' + selectedData + ', data:' + data);
					}}
				},
				{ type: 'slider', label: 'slider test', min: 0, max: 100, initial: 25, snap: 1, data: { module: 'slider' },
					onChange: { context: this, fn: function(value:Number, data:Object) {
						UtilsBase.PrintChatText('value:' + value + ', data:' + data);
					}}
				}
			]
		};
		

		SignalSizeChanged.Emit();
		//SetSize( this._width, this._height );
	}

	private function draw():Void {
		m_ConfigPanel._y = Math.round( m_DescriptionText._y + m_DescriptionText._height + 10 );
	}
	
	private function pluginListItemSelected(event:Object) {
		m_PluginTitle.label = pluginList.dataProvider[ pluginList.selectedIndex ].label;
		m_DescriptionText.text = pluginList.dataProvider[ pluginList.selectedIndex ].data.description;
		m_PluginTitle.selected = pluginList.dataProvider[ pluginList.selectedIndex ].enabled;
		
		invalidate();
		
		panel.clear();
	}
	
	private function listrenderdone():Void {
		UtilsBase.PrintChatText('listrenderdone');
		SignalSizeChanged.Emit();
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

		// this seems to happen asynchronously as if enabled it can finish rendering *after* the following commands have happened (and even the parent window layout)
		// which causes the interior content to be the 'right size', but the parent window to be too large, especially on vertical size reduction
		
		pluginList.height = height;

		m_PluginListBackground._height = height;
		m_PluginTitleBackground._width = width - m_PluginTitleBackground._x;
		m_DescriptionText._width = width - m_DescriptionText._x;
		
		invalidate();
		
		SignalSizeChanged.Emit();	// must fire this signal, else the parent WinComp container never gets resized, only the inner content does
	}	
	
}