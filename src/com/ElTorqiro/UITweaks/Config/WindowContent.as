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
	
	private var m_PluginTitle:MovieClip;
	private var m_PluginEnabled:CheckBox;
	
	private var m_TitlePanel:MovieClip;
	private var panel:MovieClip;
	
	private var pluginList:ScrollingList;
	
	public function WindowContent()
	{
		super();
		
		// hud data listener
		_hudData = DistributedValue.Create(AddonInfo.Name + "_Data");
		_hudData.SignalChanged.Connect(HUDDataChanged, this);
	}

	// cleanup operations
	public function Destroy():Void
	{
		// disconnnect from signals
		_hudData.SignalChanged.Disconnect(HUDDataChanged, this);
	}
	
	private function configUI():Void
	{
		super.configUI();

		/*
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
		*/
		
		var titleConfig:Object = {
			title: 'title panel',
			
			onOpen: { context: this, fn: function() {
				ConfigOverlay( true );
			}},
			
			onClose: { context: this, fn: function() {
				ConfigOverlay( false );
			}},
			
			elements: [
				{ id: 'm_PluginTitle', type: 'section', label: 'PluginTitle', color: 0x00ccff },
				{ id: 'm_PluginEnabled', type: 'checkbox', label: 'Enabled', data: { module: 'aaa_test' }, initial: true,
					onChange: { context: this, fn: function(state:Boolean, data:Object) {
						UtilsBase.PrintChatText('plugin state:' + state + ', data:' + data);
					}}
				}
			]
		};
		
		m_TitlePanel = createEmptyMovieClip( 'm_TitlePanel', getNextHighestDepth() );
		m_TitlePanel._x = 210;
		var titlePanelBuilder:ConfigPanelBuilder = new ConfigPanelBuilder( m_TitlePanel, titleConfig );
		/*
		lineStyle( 2, 0x666666, 0.8, true );
		moveTo( 0, m_TitlePanel._height );
		lineTo( m_TitlePanel._width, m_TitlePanel._height );
		*/
		panel = createEmptyMovieClip( 'm_ConfigPanel', getNextHighestDepth() );
		panel._x = m_TitlePanel._x;
		panel._y = Math.round( m_TitlePanel._y + m_TitlePanel._height + 20 );
		var configPanelBuilder:ConfigPanelBuilder = new ConfigPanelBuilder( panel, Configuration );
		
		
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
		
		panel._x = pluginList.width + 10;
		panel._y = m_PluginEnabled._y + m_PluginEnabled._height + 10;
		
		pluginList.addEventListener( 'focusIn', this, 'removeFocus' );
		pluginList.addEventListener( 'renderComplete', this, 'listrenderdone' );
		pluginList.addEventListener( 'change', this, 'pluginListItemSelected' );
		
		pluginList.selectedIndex = 0;
		
		SignalSizeChanged.Emit();
		//SetSize( this._width, this._height );
	}

	private function pluginListItemSelected(event:Object) {
		m_TitlePanel.m_Column_0.m_PluginTitle.textField.text = pluginList.dataProvider[ pluginList.selectedIndex ].label;
		m_TitlePanel.m_Column_0.m_PluginEnabled.selected = pluginList.dataProvider[ pluginList.selectedIndex ].enabled;
		
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
		//return new Point( m_ContentSize._width, m_ContentSize._height );
		
		//return new Point( _width, _height );
		
		
		var bounds:Object = this.getBounds( _parent );
		
		return new Point( bounds.xMax - bounds.xMin, bounds.yMax - bounds.yMin );
	}
	
	/**
	 * 
	 * this is the all-important override that makes window resizing work properly
	 */
    public function SetSize(width:Number, height:Number) {	

		// this seems to happen asynchronously as if enabled it can finish rendering *after* the following commands have happened (and even the parent window layout)
		// which causes the interior content to be the 'right size', but the parent window to be too large, especially on vertical size reduction
		
		pluginList.height = height;
		
		SignalSizeChanged.Emit();	// must fire this signal, else the parent WinComp container never gets resized, only the inner content does
	}	
	
}