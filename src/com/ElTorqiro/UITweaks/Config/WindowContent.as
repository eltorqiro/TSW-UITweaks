import com.Components.FCSlider;
import com.Components.WindowComponentContent;
import com.ElTorqiro.Utils;
import com.Utils.Archive;
import gfx.controls.CheckBox;
import gfx.controls.DropdownMenu;
import gfx.controls.Button;
import gfx.controls.Slider;
import mx.utils.Delegate;
import com.GameInterface.UtilsBase;
import com.GameInterface.DistributedValue;

import com.ElTorqiro.UITweaks.AddonUtils.ConfigPanelBuilder;

class com.ElTorqiro.UITweaks.Config.WindowContent extends WindowComponentContent
{
	private var _hudData:DistributedValue;
	private var _uiControls:Object = {};
	private var _uiInitialised:Boolean = false;
	
	private var m_ContentSize:MovieClip;
	private var m_Content:MovieClip;
	
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
	
	// HUD settings have changed
	function HUDDataChanged():Void
	{
		LoadValues();
	}	
	
	private function configUI():Void
	{
		super.configUI();

		m_Content = createEmptyMovieClip("m_Content", getNextHighestDepth() );
		
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
					onClick: { context: this, fn: function(state:Boolean, data:Object) {
						UtilsBase.PrintChatText('clicked state:' + state + ', data:' + data);
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
		
		
		var panel:MovieClip = this.createEmptyMovieClip( 'm_ConfigPanel', this.getNextHighestDepth() );
		
		var panel:ConfigPanelBuilder = new ConfigPanelBuilder( panel, Configuration );
		
		
		// add options section
/*
		AddHeading("Options");
		_uiControls.hideDefaultSwapButtons = {
			control:	AddCheckbox( "hideDefaultSwapButtons", "Hide default AEGIS swap buttons" ),
			event:		"click",
			type:		"setting"
		};
		_uiControls.lockBars = {
			control:	AddCheckbox( "lockBars", "Lock bar position and scale" ),
			event:		"click",
			type:		"setting"
		};
*/
/*
		// add visuals section
		AddHeading("Visuals");
		_uiControls.showWeapons = {
			control:	AddCheckbox( "showWeapons", "Show weapon slots" ),
			event:		"click",
			type:		"setting"
		};
		_uiControls.primaryWeaponFirst = {
			control:	AddCheckbox( "primaryWeaponFirst", "On Primary bar, show weapon first" ),
			event:		"click",
			type:		"setting"
		};
		_uiControls.secondaryWeaponFirst = {
			control:	AddCheckbox( "secondaryWeaponFirst", "On Secondary bar, show weapon first" ),
			event:		"click",
			type:		"setting"
		};
		_uiControls.showWeaponHighlight = {
			control:	AddCheckbox( "showWeaponHighlight", "Show slotted weapon highlight" ),
			event:		"click",
			type:		"setting"
		};
		_uiControls.showBarBackground = {
			control:	AddCheckbox( "showBarBackground", "Show bar background" ),
			event:		"click",
			type:		"setting"
		};
		//AddCheckbox( "m_ShowXPBars", "Show AEGIS XP progress on slots", g_HUD.showXPBars ).addEventListener("click", this, "ShowXPBarsClickHandler");
		//AddCheckbox( "m_ShowTooltips", "Show Tooltips", g_HUD.showTooltips ).addEventListener("click", this, "ShowTooltipsClickHandler");

		// add layout section
		AddHeading("Bar Style");
		_uiControls.barStyle = {
			control:	AddDropdown( "barStyle", "Bar Style", ["Horizontal", "Vertical"] ),
			event:		"change",
			type:		"setting"
		}
		
		// positioning section
		AddHeading("Position");
		_uiControls.SetDefaultPosition = {
			control:	AddButton("SetDefaultPosition", "Reset to default position"),
			event:		"click",
			type:		"command"
		}
*/		
		SetSize( Math.round(Math.max(m_Content._width, 200)), Math.round(Math.max(m_Content._height, 200)) );
		
		// wire up event handlers for ui controls
		for (var s:String in _uiControls)
		{
			_uiControls[s].control.addEventListener( _uiControls[s].event, this, "ControlHandler" );

			/* this will be useful when/if different types of interactions are needed */
			/*
			var fName:String = s + _uiControls[s].event + "Handler";

			this[fName] = function(e:Object) {
				var rpcArchive:Archive = new Archive();
				var eventValue = eval(e.target.eventValue + "");

				// always invalidate previous value
				rpcArchive.AddEntry( "_setTime", new Date().valueOf() );
				rpcArchive.AddEntry( e.target.controlName, ( eventValue == undefined ? true : eventValue ) );

				DistributedValue.SetDValue(AddonInfo.Name + "_RPC", rpcArchive);
			};
			_uiControls[s].control.addEventListener( _uiControls[s].event, this, fName );
			*/
		}

		// load initial values
		LoadValues();
	}

	
	// universal control interaction handler
	private function ControlHandler(e:Object)
	{
		if ( !_uiInitialised ) return;
		
		var rpcArchive:Archive = new Archive();
		var eventValue = eval(e.target.eventValue + "");

		// invalidate previous value to make sure the change signal is triggered
		rpcArchive.AddEntry( "_setTime", new Date().valueOf() );
		rpcArchive.AddEntry( e.target.controlName, ( eventValue == undefined ? true : eventValue ) );

		DistributedValue.SetDValue(AddonInfo.Name + "_RPC", rpcArchive);
	}
	

	// populate the states of the config ui controls based on the hud module's published data
	private function LoadValues():Void
	{
		_uiInitialised = false;
		var hudValues = _hudData.GetValue();
		
		for ( var s:String in _uiControls )
		{
			var control = _uiControls[s].control;
			var value = hudValues.FindEntry( s, 0 );
			
			if ( control instanceof DropdownMenu )
			{
				if( control.selectedIndex != value )  control.selectedIndex = value;
			}
			
			else if ( control instanceof CheckBox )
			{
				if( control.selected != value )  control.selected = value;				
			}
		}
		
		_uiInitialised = true;
	}

	
	// add and return a new checkbox, layed out vertically
	private function AddCheckbox(name:String, text:String):CheckBox
	{
		var y:Number = m_Content._height;
		
		var o:CheckBox = CheckBox(m_Content.attachMovie( "Checkbox", "m_" + name, m_Content.getNextHighestDepth() ));
		o["controlName"] = name;
		o["eventValue"] = "e.target.selected";
		with ( o )
		{
			disableFocus = true;
			textField.autoSize = true;
			textField.text = text;
			_y = y;
		}
		
		return o;
	}

	// add and return a new button, layed out vertically
	private function AddButton(name:String, text:String):Button
	{
		var y:Number = m_Content._height;
		
		var o:Button = Button(m_Content.attachMovie( "Button", "m_" + name, m_Content.getNextHighestDepth() ));
		o["controlName"] = name;
		o["eventValue"] = "e.target.selected";
		o.label = text;
		o.autoSize = "center";
		o.disableFocus = true;
		o._y = y;
		
		return o;
	}
	
	
	// add and return a dropdown
	private function AddDropdown(name:String, label:String, values:Array):DropdownMenu
	{
		var y:Number = m_Content._height;

		var o:DropdownMenu = DropdownMenu(m_Content.attachMovie( "Dropdown", "m_" + name, m_Content.getNextHighestDepth() ));
		o["controlName"] = name;
		o["eventValue"] = "e.index";
		with ( o )
		{
			disableFocus = true;
			dropdown = "ScrollingList";
			itemRenderer = "ListItemRenderer";
			dataProvider = values;
		}
		o.dropdown.addEventListener("focusIn", this, "RemoveFocus");
		o._y = y;
		
		return o;
	}
	
	// add a group heading, layed out vertically
	private function AddHeading(text:String):Void
	{
		var y:Number = m_Content._height;
		if ( y != 0) y += 10;
		
		var o:MovieClip = m_Content.attachMovie( "ConfigGroupHeading", "m_Heading", m_Content.getNextHighestDepth() );
		o.textField.text = text;
		o._y = y;
	}
	
	private function AddSlider(name:String, label:String, minValue:Number, maxValue:Number):FCSlider
	{
		var y:Number = m_Content._height;

		var o:FCSlider = FCSlider(m_Content.attachMovie( "Slider", "m_" + name, m_Content.getNextHighestDepth() ));
		o["controlName"] = name;
		o["eventValue"] = "e.value";
		o.width = 200;
		o._x = 100;
		
		o.minimum = minValue;
		o.maximum = maxValue;
		o.snapInterval = 1;
		o.snapping = true;
		o.liveDragging = true;
		o._y = y;
		
		return o;
	}
	
    //Remove Focus
    private function RemoveFocus():Void
    {
        Selection.setFocus(null);
    }
	
	public function Close():Void
	{
		super.Close();
	}

	
	/**
	 * 
	 * this is the all-important override that makes window resizing work properly
	 * the SignalSizeChanged signal is monitored by the host window, which resizes accordingly
	 * the underlying WindowComponentContent.SetSize() is just a stub, since it doesn't know what Instance Name you've given your content wrapper in Flash
	 */
    public function SetSize(width:Number, height:Number)
    {	
        m_ContentSize._width = width;
        m_ContentSize._height = height;
        
		SignalSizeChanged.Emit();	// must fire this signal, else the parent WinComp container never gets resized, only the inner content does
    }	
	
}