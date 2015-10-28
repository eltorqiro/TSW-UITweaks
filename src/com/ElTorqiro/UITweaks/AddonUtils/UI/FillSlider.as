import gfx.controls.Slider;
import gfx.utils.Constraints;

import com.Utils.Format;


/**
 * 
 * A Slider component that "fills up" the track bar from the left side up to the thumb position.
 * 
 * Useful for things like volume meters or the like.
 * 
 */
class com.ElTorqiro.UITweaks.AddonUtils.UI.FillSlider extends Slider {

	public function FillSlider() {

	}

	public function configUI() : Void {
		
		super.configUI();

		constraints.addElement( fill, Constraints.LEFT | Constraints.RIGHT );
		constraints.addElement( valueField, Constraints.LEFT | Constraints.RIGHT );
		
		track.addEventListener( "rollOver", this, "rollOver" );
		track.addEventListener( "rollOut", this, "rollOut" );
		
		thumb.addEventListener( "rollOver", this, "rollOver" );
		thumb.addEventListener( "rollOut", this, "rollOut" );
		
		addEventListener( "change", this, "updateValueField" );
	}

	private function draw() : Void {
		super.draw();
		
		updateValueField();
	}
	
	private function rollOver() : Void {
		fill.gotoAndPlay( "over" );
	}
	
	private function rollOut() : Void {
		fill.gotoAndPlay( "up" );
	}
	
	private function updateThumb() : Void {
		super.updateThumb();
		
		fillMask._width = thumb._x + (thumb._width / 2) + offsetLeft;
	}
	
	private function updateValueField() : Void {
		valueField.text = Format.Printf( _valueFormat, value );
	}
	
	private function trackPress( e:Object ) : Void {
		
		super.trackPress( e );
		
		// handles the case of clicking the track after release, without moving mouse first
		if ( trackDragMouseIndex == undefined ) {
			trackDragMouseIndex = e.controllerIdx;
			thumb.onPress(trackDragMouseIndex);
			dragOffset = {x:0};
		}
		
	}

	private function endDrag() : Void {
		super.endDrag();
		
		// handles the case of udpating visuals if releasing dragged mouse outside of track
		if ( !track.hitTest( _root._xmouse, _root._ymouse ) ) {
			rollOut();
		}
	}
	
	/*
	 * internal variables
	 */
	
	public var fillMask:MovieClip;
	public var fill:MovieClip;
	public var valueField:TextField;
	
	/*
	 * properties
	 */
	
	private var _valueFormat:String = "%i";
	public function get valueFormat() : String { return _valueFormat; }
	public function set valueFormat( value:String ) : Void {
		_valueFormat = value;
		if ( initialized ) {
			updateValueField();
		}
	}
}