import gfx.controls.TextInput;

import com.ElTorqiro.UITweaks.AddonUtils.CommonUtils;
import com.Utils.Format;


/**
 *
 * An input field component that only allows hex-based colour values to be entered.
 * 
 * Will colorize the sub-clip named "preview" when the value changes
 * 
 */
class com.ElTorqiro.UITweaks.AddonUtils.UI.ColorInput extends TextInput {

	public function ColorInput() {

	}

	public function configUI() : Void {
		
		super.configUI();

		textField.restrict = "#0123456789ABCDEFabcdef";	// allow hex characters only, and an optional #
		maxChars = 7;	// allow 6 digits and an optional leading #
		
		textField.onKillFocus = function( newFocus:Object ) {
			if ( newFocus != this && newFocus != this._parent ) {
				this._parent.focused = false;
			}
		};
		
		textField.onSetFocus = function( oldFocus:Object ) {
			if ( oldFocus != this && oldFocus != this._parent ) {
				this._parent.focused = true;
			}
		};
		
		addEventListener( "textChange", this, "updateValue" );
		addEventListener( "focusIn", this, "selectAll" );
		addEventListener( "focusOut", this, "formatText" );

	}

	private function draw() : Void {
		super.draw();
		
		applyColor();
		
		if ( !focused ) {
			formatText();
		}
	}
	
	private function updateValue() : Void {
		
		// update the numeric value of the field
		var newText:String = text.split( "#" ).join( "" );
		var offset:Number = newText.length > 6 ? newText.length - 6 : 0;
		var newText:String = newText.substr( offset, 6 );
		
		value = parseInt( "0x" + newText );
	}
	
	private function selectAll( event:Object ) : Void {
		Selection.setSelection( 0, event.target.text.length );
	}
	
	private function formatText() : Void {
		
		// format the field
		var newText:String = Format.Printf( "%06X", value.toString(16) ).toUpperCase();
		newText = "#" + newText.substr( newText.length - 6, 6 );
		
		text = newText;
	}
	
	private function applyColor() : Void {
		CommonUtils.colorize( preview, value );
	}
	
	/*
	 * internal variables
	 */
	
	public var preview:MovieClip;
	 
	/*
	 * properties
	 */
	
	private var _value:Number = 0;
	public function get value() : Number { return _value; }
	public function set value( value:Number ) : Void {
		if ( _value != value && Number( value ) != Number.NaN ) {
			_value = value;
			
			if ( initialized ) {
				dispatchEvent( { type: "change" } );
				invalidate();
			}
		}
	}
	
}