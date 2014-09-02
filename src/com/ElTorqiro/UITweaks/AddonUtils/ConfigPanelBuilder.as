import flash.filters.DropShadowFilter;
import flash.geom.Point;
import com.GameInterface.UtilsBase;
import gfx.controls.CheckBox;
import mx.utils.Delegate;
import gfx.controls.DropdownMenu;
import gfx.controls.Slider;

import com.ElTorqiro.UITweaks.AddonUtils.AddonUtils;

class com.ElTorqiro.UITweaks.AddonUtils.ConfigPanelBuilder {

	private var _columns;
	private var _currentColumn:Object;

	private var _sectionSpacing:Number;
	private var _sectionLabelDropShadow:DropShadowFilter;
	private var _sectionLabelColor:Number;
	
	private var _onOpen:Object;
	private var _onClose:Object;

	private var _panelMC:MovieClip;
	
	public function ConfigPanelBuilder(panelMC:MovieClip, configuration:Object) {

		// parameters
		_panelMC = panelMC;

		if( configuration != undefined ) Build( configuration );
	}
	
	public function Clear():Void {
		_columns = [];
		addColumn();
		_currentColumn = _columns[0];

		// default values for global properties
		_sectionSpacing = 10;
		_sectionLabelDropShadow = new DropShadowFilter( 60, 90, 0x000000, 0.8, 8, 8, 3, 3, false, false, false );
		_sectionLabelColor = 0x00cc99;
		_onOpen = undefined;
		_onClose = undefined;
		
		if ( _panelMC != undefined ) _panelMC.clear();
	}
	
	public function Build(conf:Object):Void {

		// set panel to initial empty state
		Clear();		
		
		// set global properties
		if ( conf.section.spacing != undefined ) _sectionSpacing = conf.section.spacing;

		if ( conf.section.label.shadow != undefined ) {
			
		}
		
		if ( conf.onOpen != undefined ) _onOpen = conf.onOpen;
		if ( conf.onClose != undefined ) _onClose = conf.onClose;

		
		// walk the configuration and place elements
		var elements:Array = conf.elements;
		
		for ( var i:Number = 0; i < elements.length; i++ ) {
			
			var el:Object = elements[i];
			var id:String = el.id == undefined ? 'm_el_' + _currentColumn.elements.length : el.id;
			
			switch( el.type ) {
				
				// new section, with or without label
				case 'section':
					addSection( id, el.label, el.color );
				break;
				
				case 'checkbox':
					addCheckbox( id, el.label, el.data, el.initial, el.onChange );
				break;
				
				case 'dropdown':
					addDropdown( id, el.label, el.data, el.items, el.initial, el.onChange );
				break;
				
				case 'slider':
					addSlider( id, el.label, el.data, el.min, el.max, el.initial, el.snap, el.onChange );
				break;
			}
			
		}
		
		// fire onOpen event
		if ( _onOpen != undefined ) {
			UtilsBase.PrintChatText('openHandler');		
			Delegate.create( _onOpen.context, _onOpen.fn )();
		}
	}
	
	// run when removing/closing the panel, so the onClose event can fire
	public function Destroy():Void {
		UtilsBase.PrintChatText('destroy');
		
		// fire onClose event
		if ( _onClose != undefined ) {
			UtilsBase.PrintChatText('closeHandler');		
			Delegate.create( _onClose.context, _onClose.fn )();
		}
	}
	
	private function addColumn(left:Number, top:Number, width:Number, height:Number, cursor:Point):Void {
		_columns.push( {
			left: left == undefined ? 0 : left,
			top: top == undefined ? 0 : top,
			width: width == undefined ? 0 : width,
			height: height == undefined ? 0 : height,
			cursor: cursor == undefined || !(cursor instanceof Point) ? new Point( 0, 0 ) : cursor,
			mc: _panelMC.createEmptyMovieClip( 'm_Column_' + _columns.length, _panelMC.getNextHighestDepth() ),
			elements: []
		});
	}
	
	private function addSection(id:String, label:String, color:Number):Void {
		UtilsBase.PrintChatText('addSection');
		// reposition section if not at top of column
		if ( _currentColumn.cursor.y > 0 ) {
			_currentColumn.cursor.y += _sectionSpacing;
		}
		
		// new section implies reset to start of line
		_currentColumn.cursor.x = 0;
		
		if( label.length > 0 ) {
			var el:MovieClip = _currentColumn.mc.attachMovie( 'SectionLabel', id, _currentColumn.mc.getNextHighestDepth() );
			_currentColumn.elements.push( el );
			
			var textFormat:TextFormat = new TextFormat();
			textFormat.color = AddonUtils.isRGB(color) ? color : _sectionLabelColor;

			el.filters = [ _sectionLabelDropShadow ];
			
			el.textField.setNewTextFormat( textFormat );
			el.textField.autoSize = 'left';
			el.textField.text = label;
			
			el._x = _currentColumn.cursor.x;
			el._y = _currentColumn.cursor.y;
			
			_currentColumn.cursor.y += el.textField.textHeight;
		}
	}
	
	private function addCheckbox(id:String, label:String, data:Object, initial:Boolean, onChange:Object ):Void {
		UtilsBase.PrintChatText('addCheckbox');
		
		var el:CheckBox = _currentColumn.mc.attachMovie( 'CheckboxDark', id, _currentColumn.mc.getNextHighestDepth() );
		_currentColumn.elements.push( el );

		el.label = label;
		el.selected = initial != undefined ? initial : false;
		
		el.disableFocus = true;
		
		if ( onChange != undefined ) {
			el['changeHandler'] = onChange;
			el.addEventListener( 'select', this, "checkboxChangeHandler" );
		}
		
		el.data = data;
		
		el._x = _currentColumn.cursor.x;
		el._y = _currentColumn.cursor.y;

		_currentColumn.cursor.y += el._height;
	}

	private function addDropdown(id:String, label:String, data:Object, items:Array, initial:Number, onChange:Object ):Void {
		UtilsBase.PrintChatText('addDropdown');
		
		var el:DropdownMenu = _currentColumn.mc.attachMovie( 'DropdownGray', id, _currentColumn.mc.getNextHighestDepth() );
		_currentColumn.elements.push( el );

		// TODO: implement label for dropdown
		//el.label = label;

		el['items'] = items;
		
		var labels:Array = [];
		for ( var i:Number = 0; i < items.length; i++ ) {
			labels.push( items[i].label );
		}
		
		el.dropdown = 'ScrollingListGray';
		el.itemRenderer = 'ListItemRendererGray';
		el.dataProvider = labels;
		
		el.selectedIndex = initial != undefined ? initial : -1;
		
		if ( onChange != undefined ) {
			el['changeHandler'] = onChange
			el.addEventListener( 'change', this, "dropdownChangeHandler" );
		}

		el.addEventListener("change", this, "removeFocus");
		el.addEventListener("stateChange", this, "dropdownStateChangeHandler");
		
		el.data = data;
		
		el._x = _currentColumn.cursor.x;
		el._y = _currentColumn.cursor.y;

		_currentColumn.cursor.y += el._height;
	}

	private function addSlider(id:String, label:String, data:Object, min:Number, max:Number, initial:Number, snap:Number, onChange:Object ):Void {
		UtilsBase.PrintChatText('addSlider');
		
		var el:Slider = _currentColumn.mc.attachMovie( 'Slider', id, _currentColumn.mc.getNextHighestDepth() );
		_currentColumn.elements.push( el );

		el['labelTextField'].text = label;
		el['labelTextField'].autoSize = 'left';

		el.liveDragging = true;
		
		el.minimum = min;
		el.maximum = max;
		if ( snap != undefined && snap != 0 ) {
			el.snapInterval = snap;
			el.snapping = true;
		}
		
		el.value = initial;
		el['valueTextField'].text = String(initial);
		el['valueTextField'].autoSize = 'right';
		
		el.addEventListener("focusIn", this, "removeFocus");		
		
		if ( onChange != undefined ) {
			el['changeHandler'] = onChange
			el.addEventListener( 'change', this, "sliderChangeHandler" );
		}
		
		el['data'] = data;

		el._x = _currentColumn.cursor.x;
		el._y = _currentColumn.cursor.y;

		_currentColumn.cursor.y += el._height;
	}
	
	private function checkboxChangeHandler(event:Object):Void {
		UtilsBase.PrintChatText('checkboxChangeHandler');
		Delegate.create( event.target.changeHandler.context, event.target.changeHandler.fn )( event.target.selected, event.target.data );
	}

	private function dropdownChangeHandler(event:Object):Void {
		UtilsBase.PrintChatText('dropdownChangeHandler');
		Delegate.create( event.target.changeHandler.context, event.target.changeHandler.fn )( event.target.selectedIndex, event.target.items[ event.target.selectedIndex ].data, event.target.data );
	}

	private function dropdownStateChangeHandler(event:Object):Void {
		UtilsBase.PrintChatText('dropdownStateChangeHandler');
		if ( event.state == 'up' ) removeFocus();
	}
	
	private function sliderChangeHandler(event:Object):Void {
		UtilsBase.PrintChatText('sliderChangeHandler');
		event.target.valueTextField.text = String( event.target.value );
		Delegate.create( event.target.changeHandler.context, event.target.changeHandler.fn )( event.target.value, event.target.data );
	}

    // universally remove focus
    private function removeFocus():Void {
        Selection.setFocus(null);
    }	
}