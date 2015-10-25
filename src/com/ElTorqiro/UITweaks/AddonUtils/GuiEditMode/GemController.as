import flash.geom.Point;
import gfx.core.UIComponent;

import com.ElTorqiro.UITweaks.AddonUtils.MovieClipHelper;
import com.ElTorqiro.UITweaks.AddonUtils.GuiEditMode.GemOverlay;


/**
 * 
 * 
 */
class com.ElTorqiro.UITweaks.AddonUtils.GuiEditMode.GemController extends UIComponent {
	
	public static var __className:String = "com.ElTorqiro.UITweaks.AddonUtils.GuiEditMode.GemController";

	public function GemController() {

		dragging = false;
		clickEvent = null;
		dragOverlay = null;
		
		prevMousePos = null;
		 
		if ( groupMoveModifiers == undefined ) {
		
			groupMoveModifiers = [
				{	button: 1,
					keys: [
						Key.SHIFT
					]
				}
			];
		}
		
		if ( overlayLinkage == undefined ) {
			overlayLinkage = "GemOverlay";
		}
		
		if ( overlayPadding == undefined ) {
			overlayPadding = 5;
		}
		
	}
	
	private function configUI() : Void {

		overlays = [ ];
		
		if ( targets instanceof MovieClip ) {
			targets = [ targets ];
		}
		
		for ( var i:Number = 0; i < targets.length; i++ ) {
			
			var overlay:GemOverlay = GemOverlay( MovieClipHelper.attachMovieWithClass( overlayLinkage, GemOverlay, "", this, getNextHighestDepth(), { target: targets[i], padding: overlayPadding } ) );
			
			overlay.addEventListener( "press", this, "pressHandler" );
			overlay.addEventListener( "release", this, "releaseHandler" );

			overlay.addEventListener( "scrollWheel", this, "scrollWheelHandler" );
			
			overlays.push( overlay );
			
		}
		
	}

	private function pressHandler( event:Object ) : Void {
		
		prevMousePos = new Point( _xmouse, _ymouse );
		
		dragOverlay = event.target;
		clickEvent = event;
		
		// right click moves all groups
		moveOverlays = event.button == 1 ? overlays : [ dragOverlay ];
		
		onMouseMove = function() {
			
			var diff:Point = new Point( _xmouse - prevMousePos.x, _ymouse - prevMousePos.y );
			
			if ( !dragging ) {
				dragging = true;
				dispatchEvent( { type: "startDrag", overlay: dragOverlay } );
				
				for ( var s:String in moveOverlays ) {
					dispatchEvent( { type: "targetStartDrag", overlay: moveOverlays[s] } );
				}
				
			}
			
			dispatchEvent( { type: "drag", overlay: dragOverlay, delta: diff } );
			
			for ( var s:String in moveOverlays ) {
				moveOverlays[s].moveBy( diff );
				dispatchEvent( { type: "targetDrag", overlay: moveOverlays[s], delta: diff } );
			}

			prevMousePos = new Point( _xmouse, _ymouse );
			
		}
		
	}
	
	private function releaseHandler( event:Object ) : Void {

		if ( dragging ) {
			dispatchEvent( { type: "endDrag", overlay: dragOverlay } );

			for ( var s:String in moveOverlays ) {
				dispatchEvent( { type: "targetEndDrag", overlay: moveOverlays[s] } );
			}
			
			moveOverlays = undefined;
			dragging = false;
		}
		
		else {
			dispatchEvent( { type: "click", overlay: clickEvent.target, button: clickEvent.button, shift: clickEvent.shift, ctrl: clickEvent.ctrl } );
		}
		
		clickEvent = null;
		dragOverlay = null;
		onMouseMove = undefined;
	}
	
	private function scrollWheelHandler( event:Object ) : Void {
		dispatchEvent( { type: "scrollWheel", overlay: event.target, delta: event.delta } );
	}
	
	/**
	 * factory method for creating a new instance of GemController
	 * 
	 * @param	name
	 * @param	parent
	 * @param	depth
	 * 
	 * @return
	 */
	public static function create( name:String, parent:MovieClip, depth:Number, targets ) : GemController {
		
		return GemController( MovieClipHelper.createMovieWithClass( GemController, name, parent, depth, { targets: targets } ) );
		
	}
	
	/**
	 * internal variables
	 */
	
	private var dragging:Boolean;
	private var clickEvent:Object;
	private var dragOverlay:GemOverlay;
	
	private var moveOverlays:Array;
	
	private var prevMousePos:Point;
	 
	private var targets;
	private var overlays:Array;
	
	private var groupMoveModifiers:Array;
	
	private var overlayLinkage:String;
	private var overlayPadding:Number;
	 
	/**
	 * properties
	 */
	 
}