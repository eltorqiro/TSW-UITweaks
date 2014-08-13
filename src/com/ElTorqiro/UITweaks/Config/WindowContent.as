import com.Components.WindowComponentContent;
import com.Utils.Archive;
import flash.geom.Point;
import mx.utils.Delegate;
import com.GameInterface.UtilsBase;
import com.GameInterface.DistributedValue;
import com.ElTorqiro.UITweaks.AddonUtils.ScrollingList;

import com.ElTorqiro.UITweaks.AddonUtils.AddonUtils;

import com.ElTorqiro.UITweaks.AddonUtils.ConfigPanelBuilder;

class com.ElTorqiro.UITweaks.Config.WindowContent extends WindowComponentContent
{
	private var _hudData:DistributedValue;
	private var _uiControls:Object = {};
	private var _uiInitialised:Boolean = false;
	
	private var m_ContentSize:MovieClip;
	private var m_Content:MovieClip;
	
	private var m_PluginListBackground:MovieClip;
	
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

		//m_Content = createEmptyMovieClip("m_Content", getNextHighestDepth() );
		//m_ContentSize = attachMovie( 'ConfigWindowContentSize', 'm_ContentSize', getNextHighestDepth() );
		//m_ContentSize._visible = false;
		//m_ContentSize.hitTestDisable = true;
		
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
		
		
		panel = createEmptyMovieClip( 'm_ConfigPanel', getNextHighestDepth() );
		
		var configPanelBuilder:ConfigPanelBuilder = new ConfigPanelBuilder( panel, Configuration );
		
		
		pluginList = ScrollingList( attachMovie( 'ScrollingListEnableDisableDark', 'm_PluginList', getNextHighestDepth(), { margin: 5 } ) );
		//pluginList.rowHeight = 28;
		pluginList.itemRenderer = 'ScrollingListEnableDisableDarkListItemRenderer';
		pluginList.scrollBar = 'ScrollBar';
		
		var data:Array = [];
		for ( var i:Number = 0; i < g_plugins.length; i++ ) {
			data.push( {label: 'i:' + i, enabled: true, data: { plugin: g_plugins[i] } } );
			
		}
		
		pluginList.dataProvider = data;
		
		pluginList.dataProvider = [
			{ label: 'item 1', enabled: true },
			{ label: 'item 2', enabled: true },
			{ label: 'item 3', enabled: false },
			{ label: 'item 4', enabled: false },
			{ label: 'item 5', enabled: true },
			{ label: 'item 6', enabled: false },
			{ label: 'item 7', enabled: false },
			{ label: 'item 8', enabled: true },
			{ label: 'item 9', enabled: true },
			{ label: 'item 10', enabled: true },
			{ label: 'item 11', enabled: false },
			{ label: 'item 12', enabled: true },
			{ label: 'item 13', enabled: true },
			{ label: 'item 14', enabled: true },
			{ label: 'item 15', enabled: false },
			{ label: 'item 16', enabled: false },
			{ label: 'item 17', enabled: true },
			{ label: 'item 18', enabled: true },
			{ label: 'item 19', enabled: false }
		];
		
		
		pluginList.height = 240;
		pluginList.width = 200;
		pluginList.rowHeight = 22;
		
		panel._x = pluginList.width + 10;
		
		pluginList.addEventListener( 'focusIn', this, 'removeFocus' );
		
		pluginList.addEventListener( 'renderComplete', this, 'listrenderdone' );
		
		m_PluginListBackground._height = pluginList.height;
		m_PluginListBackground._width = pluginList.width;		
		
		SignalSizeChanged.Emit();
		//SetSize( this._width, this._height );
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
		return new Point( _width, _height );
	}
	
	/**
	 * 
	 * this is the all-important override that makes window resizing work properly
	 */
    public function SetSize(width:Number, height:Number) {	
		super.SetSize( width, height );

		// this seems to happen asynchronously as if enabled it can finish rendering *after* the following commands have happened (and even the parent window layout)
		// which causes the interior content to be the 'right size', but the parent window to be too large, especially on vertical size reduction
		
		//pluginList.height = 10;
		//m_PluginListBackground._height = 10;
		
		pluginList.height = height;
		m_PluginListBackground._height = pluginList.height;
		m_PluginListBackground._width = pluginList.width;
        
		UtilsBase.PrintChatText('w:' + width + ', h:' + height);
		
		SignalSizeChanged.Emit();	// must fire this signal, else the parent WinComp container never gets resized, only the inner content does
	}	
	
}