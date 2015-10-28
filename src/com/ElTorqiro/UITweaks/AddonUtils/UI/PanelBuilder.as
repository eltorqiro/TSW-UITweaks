import gfx.core.UIComponent;

import flash.geom.Point;

import gfx.controls.CheckBox;
import gfx.controls.DropdownMenu;
import gfx.controls.TextInput;
import gfx.controls.Button;
import com.ElTorqiro.UITweaks.AddonUtils.UI.FillSlider;
import com.ElTorqiro.UITweaks.AddonUtils.UI.ColorInput;

import com.ElTorqiro.UITweaks.AddonUtils.MovieClipHelper;


/**
 * 
 * Builds a panel full of configuration related widgets, based on a supplied definition
 * 
 */
class com.ElTorqiro.UITweaks.AddonUtils.UI.PanelBuilder extends UIComponent {

	public static var __className:String = "com.ElTorqiro.UITweaks.AddonUtils.UI.PanelBuilder";
	
	public function PanelBuilder() {
		
	}
	
	/**
	 * build a configuration panel as defined in a definition object, built within a container movieclip
	 * 
	 * @param	def		definition of components and layout to build
	 */
	public function build( def:Object ) : Void {

		components = { };
		
		var columnWidth:Number = def.columnWidth != undefined ? def.columnWidth : 280;
		var columnSpacing:Number = def.columnSpacing != undefined ? def.columnSpacing : 60;
		var indentSpacing:Number = def.indentSpacing != undefined ? def.indentSpacing : 10;
		var groupSpacing:Number = def.groupSpacing != undefined ? def.groupSpacing : 7;
		var sectionSpacing:Number = def.sectionSpacing != undefined ? def.sectionSpacing : 30;
		var componentSpacing:Number = def.componentSpacing != undefined ? def.componentSpacing : 0;

		sliderSymbol = def.sliderSymbol != undefined ? def.sliderSymbol : "eltorqiro.ui.widgets.slider";
		checkBoxSymbol = def.checkBoxSymbol != undefined ? def.checkBoxSymbol : "eltorqiro.ui.widgets.checkbox";
		dropdownSymbol = def.dropdownSymbol != undefined ? def.dropdownSymbol : "eltorqiro.ui.widgets.dropdown";
		dropdownListSymbol = def.dropdownListSymbol != undefined ? def.dropdownListSymbol : "eltorqiro.ui.widgets.dropdown.list";
		dropdownItemSymbol = def.dropdownItemSymbol != undefined ? def.dropdownItemSymbol : "eltorqiro.ui.widgets.dropdown.item";
		buttonSymbol = def.buttonSymbol != undefined ? def.buttonSymbol : "eltorqiro.ui.widgets.button";
		h1Symbol = def.h1Symbol != undefined ? def.h1Symbol : "eltorqiro.ui.widgets.label.h1";
		h2Symbol = def.h2Symbol != undefined ? def.h2Symbol : "eltorqiro.ui.widgets.label.h2";
		labelSymbol = def.labelSymbol != undefined ? def.labelSymbol : "eltorqiro.ui.widgets.label.label";
		textSymbol = def.textSymbol != undefined ? def.textSymbol : "eltorqiro.ui.widgets.label.multiline";
		colorInputSymbol = def.colorInputSymbol != undefined ? def.colorInputSymbol : "eltorqiro.ui.widgets.textinput.color";
		
		data = def.data;
		
		var defaultLoad:Function = def.load;
		var defaultSave:Function = def.save;
		
		var labelOffset:Number = 2;
		
		var defaultButtonWidth = def.buttonWidth != undefined ? def.buttonWidth : "40%";

		columnCount = 1;
		__width = columnWidth;
		var cursor:Point = new Point( 0, 0 );
		var indentLevel:Number = 0;
		var preSpacing:Number = 0;
		var useableWidth:Number = 0;
		var name:String;
		var id:String;
		
		var layout:Array = def.layout;
		
		for ( var i:Number = 0; i < layout.length; i++ ) {
			
			var element:Object = layout[ i ];
			
			name = "__$_" + i;
			id = element.id ? element.id : i;
		
			var component:MovieClip;
			
			cursor.x = __width - columnWidth + indentLevel * indentSpacing;
			cursor.y = Math.round ( cursor.y );
			useableWidth = __width - cursor.x;
			
			switch ( element.type ) {
				
				case "section":
					var heading:MovieClip = attachH1( name, { text: element.label } );
					
					cursor.y += cursor.y != 0 ? sectionSpacing : 0;
					
					if ( heading ) {
						heading._x = cursor.x;
						heading._y = cursor.y;
						
						cursor.y += heading._height;
					}
					
					preSpacing = 0;
					
				break;
				
				case "h2":
					var heading:MovieClip = attachH2( name, element );
					
					cursor.y += cursor.y != 0 ? 4 : 0;
					
					if ( heading ) {
						heading._x = cursor.x;
						heading._y = cursor.y;
						
						cursor.y += heading._height;
					}
				
					preSpacing = 0;
					
				break;
				
				case "button":
					component = attachButton( name, element );
					
					cursor.y += preSpacing;
					
					var offset:Number = useableWidth == columnWidth ? labelOffset : 0;
					component._x = cursor.x + offset;
					component._y = cursor.y;
					
					var width = element.width != undefined ? element.width : defaultButtonWidth;
					
					if ( width == "auto" ) {
						component.autoSize = "left";
					}
					
					else {
						component.width = Math.round( (columnWidth - offset) * getPercentage( width ) );
					}
					
					cursor.y += component.height;
					
					preSpacing = componentSpacing + 2;
					
				break;
				
				case "checkbox":
					component = attachCheckBox( name, element );
					
					cursor.y += preSpacing;
					
					component._x = cursor.x + labelOffset;
					component._y = cursor.y;
					
					cursor.y += component._height;
					
					preSpacing = componentSpacing;
					
				break;
				
				case "dropdown":
					component = attachDropdown( name, element );

					cursor.y += preSpacing;
					
					// if there is no label, offset for alignment
					var offset:Number = component.api.label ? 0 : labelOffset;
					var width:Number = component.api.label ? 145 : useableWidth - offset;
					
					component._x = cursor.x + useableWidth - width;
					component._y = cursor.y;
					component.width = width;
					
					component.api.label._x = cursor.x;
					component.api.label._y = cursor.y + 2;
					
					cursor.y += component._height;
					
					preSpacing = componentSpacing + 2;
					
				break;
				
				case "slider":
					component = attachSlider( name, element );
					
					cursor.y += preSpacing;

					component.api.label._x = cursor.x;
					component.api.label._y = cursor.y + 1;
					
					cursor.y += Math.floor( component.api.label._height );
					
					component._x = cursor.x + labelOffset;
					component._y = cursor.y;
					component.width = useableWidth - labelOffset;

					cursor.y += 12;// component._height;
					
					preSpacing = componentSpacing + 2;
					
				break;
				
				case "colorInput":
					component = attachColorInput( name, element );

					cursor.y += preSpacing;

					// if there is a label, right align, otherwise left align
					var offset:Number = Math.round( component.api.label ? useableWidth - component._width : labelOffset );
					
					component._x = cursor.x + offset;
					component._y = cursor.y;
					
					component.api.label._x = cursor.x;
					component.api.label._y = cursor.y + 1;
					
					cursor.y += component._height;
					
					preSpacing = componentSpacing + 2;

				break;
				
				case "text":
					var text:MovieClip = attachText( name, element );
					
					cursor.y += preSpacing;
					
					if ( text ) {
						text._x = cursor.x;
						text._y = cursor.y;
						text.textField._width = useableWidth;
						
						preSpacing = componentSpacing + 2;
						cursor.y += text._height;
					}
					
					else {
						preSpacing = 0;
					}

				break;
				
				case "indent-in":
					indentLevel++;
				break;
				
				case "indent-out":
					indentLevel--;
				break;
				
				case "indent-reset":
					indentLevel = 0;
				break;
				
				case "group":
					cursor.y += groupSpacing;
					
				break;
				
			case "column":
				
					columnCount++;
					cursor.y = 0;
					__width = columnCount * columnWidth + ((columnCount - 1) * columnSpacing);
					indentLevel = 0;
					preSpacing = 0;
					
				break;
				
			}
			
			// set common properties of component
			if ( component ) {

				components[id] = component;
				
				component.api.panel = this;
				component.api.data = element.data;
				component.api.load = element.load != undefined ? element.load : defaultLoad;
				component.api.save = element.save != undefined ? element.save : defaultSave;
				component.api.onChange = element.onChange;
				component.api.onClick = element.onClick;
				
				// initial load of value
				component.api.load();

			}
			
		}
		
		__height = Math.round( _height );
	}
	
	
	/**
	 * component creators
	 */
	
	private function attachH1( name:String, element:Object ) : MovieClip {

		// attach heading clip
		var heading:MovieClip;
		if ( element.text != undefined ) {
			heading = attachMovie( h1Symbol, name, getNextHighestDepth() );
			heading.textField.text = element.text.toUpperCase();
			heading.textField.autoSize = "left";
			
			heading.hitTestDisable = true;
		}
		
		return heading;
	}

	private function attachH2( name:String, element:Object ) : MovieClip {

		// attach heading clip
		var heading:MovieClip;
		if ( element.text != undefined ) {
			heading = attachMovie( h2Symbol, name, getNextHighestDepth() );
			heading.textField.text = element.text.toUpperCase();
			heading.textField.autoSize = "left";
			
			heading.hitTestDisable = true;
		}
		
		return heading;
	}
	
	private function attachLabel( name:String, element:Object ) : MovieClip {

		// attach label clip
		var label:MovieClip;
		if ( element.label != undefined ) {
			label = attachMovie( labelSymbol, name, getNextHighestDepth() );
			label.textField.autoSize = "left";
			label.textField.text = element.label;
			
			label.hitTestDisable = true;
		}

		return label;
	}

	private function attachText( name:String, element:Object ) : MovieClip {
		
		// attach text block clip
		var text:MovieClip;
		if ( element.text != undefined ) {
			
			text = attachMovie( textSymbol, name, getNextHighestDepth() );
			text.textField.text = element.text;
			text.textField.verticalAutoSize = "top";
			
			text.hitTestDisable = true;
			
		}
		
		return text;
	}
	
	private function attachButton( name:String, element:Object ) : Button {
		
		// attach button control
		var button:Button = Button(
			MovieClipHelper.attachMovieWithRegister( buttonSymbol, Button, name, this, this.getNextHighestDepth() )
		);
		
		button.label = element.text;
		button.disableFocus = true;

		// create common interface for component
		var api:Object = { };
		api.component = button;
		
		api.clickHandler = function( event:Object ) {
			this.onClick( this.component );
		}

		button.addEventListener( "click", api, "clickHandler" );
		
		button["api"] = api;
		
		return button;
	}
	
	private function attachCheckBox( name:String, element:Object ) : CheckBox {

		// attach checkbox control
		var checkbox:CheckBox = CheckBox(
			MovieClipHelper.attachMovieWithRegister( checkBoxSymbol, CheckBox, name, this, this.getNextHighestDepth() )
		);

		checkbox.label = element.label == undefined ? "" : element.label;
		checkbox.disableFocus = true;
		checkbox.textField.autoSize = "left";

		// create common interface for component
		var api:Object = { };
		api.component = checkbox;
		
		api.getValue = function() {
			return this.component.selected;
		}
		
		api.setValue = function( value ) {
			if ( Boolean( value ) != this.component.selected ) {
				this.component.selected = Boolean( value );
			}
		}
		
		api.changeHandler = function( event:Object ) {
			this.onChange( this.component );
			
			this.save();
		}
		
		api.clickHandler = function( event:Object ) {
			this.onClick( this.component );
			
			this.save();
		}

		//checkbox.addEventListener( "select", api, "changeHandler" );
		checkbox.addEventListener( "click", api, "clickHandler" );
		
		checkbox["api"] = api;
		
		return checkbox;
	}
	
	private function attachDropdown( name:String, element:Object ) : DropdownMenu {

		// attach label
		var label:MovieClip = attachLabel( name + "_label", element );
		
		// attach dropdown control
		var dropdown:DropdownMenu = DropdownMenu(
			MovieClipHelper.attachMovieWithRegister( dropdownSymbol, DropdownMenu, name, this, this.getNextHighestDepth(), { margin: 0, paddingBottom: 2 } )
		);

		// it is essential that disableFocus is set prior to the dropdown linkage being set below, else there is no way to have a "focus-less" dropdown working
		dropdown.disableFocus = true;
		
		dropdown.dropdown = dropdownListSymbol;
		dropdown.itemRenderer = dropdownItemSymbol;
		dropdown.dataProvider = element.list;
		
		// this has to be set after the list symbol has been set to complete the "focus-less" behaviour
		dropdown.dropdown.addEventListener( "focusIn", clearFocus );

		// create common interface for component
		var api:Object = { };
		api.component = dropdown;
		api.label = label;
		
		api.list = element.list;
		
		api.getValue = function() {
			return this.component.selectedItem.value;
		}
		
		api.setValue = function( value ) {
			if ( this.component.selectedItem.value == value ) return;
			
			for ( var s:String in this.list ) {
				if ( this.list[s].value == value ) {
					this.component.selectedIndex = s;
				}
			}
		}
		
		api.changeHandler = function( event:Object ) {
			this.onChange( this.component );
			
			this.save();
		}

		dropdown.dropdown.addEventListener( "itemClick", api, "changeHandler" );
		
		dropdown["api"] = api;
		
		return dropdown;
	}

	private function attachSlider( name:String, element:Object ) : FillSlider {

		// attach label
		var label:MovieClip = attachLabel( name + "_label", element );
		
		// attach slider control
		var slider:FillSlider = FillSlider(
			MovieClipHelper.attachMovieWithRegister( sliderSymbol, FillSlider, name, this, this.getNextHighestDepth(), { offsetLeft: 4, offsetRight: 4 } )
		);
		
		// prevent keyboard focus
		slider.addEventListener( "focusIn", clearFocus );

		slider.minimum = element.min;
		slider.maximum = element.max;
		slider.snapInterval = element.step != undefined ? element.step : 1;
		slider.snapping = true;
		slider.liveDragging = true;
		if ( element.valueFormat != undefined ) slider.valueFormat = element.valueFormat;
		
		// create common interface for component
		var api:Object = { };
		api.component = slider;
		api.label = label;
		
		api.getValue = function() {
			return this.component.value;
		}
		
		api.setValue = function( value ) {
			if ( this.component.value == value || Number(value) == Number.NaN ) return;
			this.component.value = Number ( value );
		}
		
		api.changeHandler = function( event:Object ) {
			this.onChange( this.component );
			
			this.save();
		}

		slider.addEventListener( "change", api, "changeHandler" );
		
		slider["api"] = api;
		
		return slider;
	}
	
	private function attachColorInput( name:String, element:Object ) : ColorInput {

		// attach label
		var label:MovieClip = attachLabel( name + "_label", element );
		
		// attach dropdown control
		var colorInput:ColorInput = ColorInput(
			MovieClipHelper.attachMovieWithRegister( colorInputSymbol, ColorInput, name, this, this.getNextHighestDepth(), { margin: 0, paddingBottom: 2 } )
		);

		// create common interface for component
		var api:Object = { };
		api.component = colorInput;
		api.label = label;
		
		api.getValue = function() {
			return this.component.value;
		}
		
		api.setValue = function( value ) {
			if ( this.component.value == value || Number(value) == Number.NaN ) return;
			this.component.value = Number ( value );
		}
		
		api.changeHandler = function( event:Object ) {
			this.onChange( this.component );
			
			this.save();
		}

		colorInput.addEventListener( "change", api, "changeHandler" );
		
		colorInput["api"] = api;

		return colorInput;
	}

	private static function clearFocus( event:Object ) : Void {
		
		event.target.focused = false;
		//Selection.setFocus( null );
	}
	
	private function getPercentage( value ) : Number {
		
		var percentage:Number = parseFloat( value );
		
		if ( percentage == Number.NaN ) return undefined;
		
		if ( value.indexOf( "%" ) >= 0 ) {
			percentage /= 100;
		}
		
		return percentage;
	}
	
	/*
	 * internal variables
	 */
	
	/*
	 * properties
	 */
	private var sliderSymbol:String;
	private var checkBoxSymbol:String;
	private var dropdownSymbol:String;
	private var dropdownListSymbol:String;
	private var dropdownItemSymbol:String;
	private var buttonSymbol:String;
	private var h1Symbol:String;
	private var h2Symbol:String;
	private var labelSymbol:String;
	private var textSymbol:String;
	private var colorInputSymbol:String;
	
	private var columnCount:Number;

	public var components:Object;
	public var data:Object;
	
}