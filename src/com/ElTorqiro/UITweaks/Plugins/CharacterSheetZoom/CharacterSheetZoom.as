import com.ElTorqiro.UITweaks.Plugins.Plugin;

import com.GameInterface.DistributedValue;
import gfx.utils.Delegate;
import flash.geom.Point;
import com.GameInterface.Game.Camera;

import com.ElTorqiro.UITweaks.AddonUtils.WaitFor;


/**
 * 
 * 
 */
class com.ElTorqiro.UITweaks.Plugins.CharacterSheetZoom.CharacterSheetZoom extends Plugin {

	// plugin properties
	public var id:String = "characterSheetZoom";
	public var name:String = "Character Sheet Zoom";
	public var description:String = "Locks the character sheet zoom at a selectable level.";
	public var author:String = "ElTorqiro";
	public var prefsVersion:Number = 1;

	public function CharacterSheetZoom() {
		
		prefs.add( "fadelines.hide", true );
		prefs.add( "zoom.level", 100 );
		
	}

	public function onLoad() : Void {
		super.onLoad();
		
		charSheetMonitor = DistributedValue.Create("character_sheet");
		charSheetMonitor.SignalChanged.Connect( apply, this );
	}
	
	public function apply() : Void {
		stopWaitFor();

		if ( enabled && charSheetMonitor.GetValue() ) {
			waitForId = WaitFor.start( waitForTest, 10, 2000, Delegate.create(this, hook) );
		}
		
		// set state if character sheet became closed
		else {
			hooked = false;
		}
	}

	private function waitForTest() : Boolean {
		return _root.charactersheet.UpdatePosition;
	}
	
	public function stopWaitFor() : Void {
		WaitFor.stop( waitForId );
		waitForId = undefined;
	}
	
	public function onModuleDeactivated() : Void {
		stopWaitFor();
		hooked = false;
	}
	
	public function hook() : Void {
		stopWaitFor();
		if ( hooked ) return;

		var charSheet = _root.charactersheet;

		// unlink onEnterFrame which does a heap of thrashing for nothing
		charSheet.UITweaks_CharacterSheetZoom_onEnterFrame_Original = charSheet.onEnterFrame;
		charSheet.onEnterFrame = undefined;
		
		// hook UpdatePosition function, which is responsible for zoom
		charSheet.UITweaks_CharacterSheetZoom_UpdatePosition_Original = charSheet.UpdatePosition;
		charSheet.UpdatePosition = Delegate.create( this, redraw );
		
		hooked = true;
		
		// redraw with hook in place
		redraw();
	}

	public function revert() : Void {
		stopWaitFor();
		if ( !hooked ) return;

		var charSheet = _root.charactersheet;
		if ( !charSheet ) return;
		
		// restore UpdatePosition
		if ( charSheet.UITweaks_CharacterSheetZoom_UpdatePosition_Original ) {
			charSheet.UpdatePosition = charSheet.UITweaks_CharacterSheetZoom_UpdatePosition_Original;
			delete charSheet.UITweaks_CharacterSheetZoom_UpdatePosition_Original;
		}
		
		// restore onEnterFrame thrash
		if ( charSheet.UITweaks_CharacterSheetZoom_onEnterFrame_Original ) {
			charSheet.onEnterFrame = charSheet.UITweaks_CharacterSheetZoom_onEnterFrame_Original;
			delete charSheet.UITweaks_CharacterSheetZoom_onEnterFrame_Original;
		}
		
		hooked = false;
		
		charSheet.UpdatePosition();
		
	}
	
	private function redraw() : Void {
		
		if ( !hooked ) return;
		
		var _sheet = _root.charactersheet;
		
		//    var camDist:Number = m_Character.GetCameraDistance();
		var camDist:Number =  Camera.GetZoom();
		var pos:Point = _sheet.m_Character.GetScreenPosition(128);


		var scaleAt1Meter = 3;

		var minScale = 0.7;
		var maxScale = Math.min( 1.7, 1.45 * Stage.width / 1024 );
		var scale:Number = (camDist > 0) ? Math.min( maxScale, scaleAt1Meter / camDist ) : maxScale;

		pos.y -= 15 + 45 * scale;

		//scale = Math.max( minScale, scale );
		//scale = maxScale;
		scale = prefs.getVal( "zoom.level" ) / 100;

		/*
		if ( pos.x < 0 ) // Camera to close to make a projection
		{
			pos.x = Stage.width * 0.5;
			pos.y = Stage.height * 0.5;
		}
		*/
		pos.x = Stage.width * 0.5;
		pos.y = Stage.height * 0.5;
		
		
		_sheet._xscale = scale * 100;
		_sheet._yscale = scale * 100;
			
		var newPosX:Number = pos.x - Stage.width * scale * 0.5;
		var newPosY:Number = pos.y - Stage.height * scale * 0.5;
		var wasCapped:Boolean = false;

		var viewportLeft = 20;
		var viewportRight = Stage.width - 20;
		var viewportBottom = Stage.height - 100 * _sheet.s_ResolutionScale.GetValue();

		if ( _sheet.m_ActivePanel && newPosX < viewportLeft - _sheet.m_ActivePanel._x * scale )
		{
			newPosX = viewportLeft - _sheet.m_ActivePanel._x * scale;
			wasCapped = true;
		}
		else if ( newPosX > viewportRight - (_sheet.m_EquipmentSlots._x + _sheet.m_EquipmentSlots._width) * scale )
		{
			newPosX = viewportRight - (_sheet.m_EquipmentSlots._x + _sheet.m_EquipmentSlots._width) * scale;
			wasCapped = true;
		}
			
		if ( newPosY > viewportBottom - (_sheet.m_EquipmentSlots._y + _sheet.m_EquipmentSlots._height) * scale )
		{
			newPosY = viewportBottom - (_sheet.m_EquipmentSlots._y + _sheet.m_EquipmentSlots._height) * scale;
			wasCapped = true;
		}
			
		_sheet._x = newPosX;
		_sheet._y = newPosY;
			
		_sheet.m_FadeLine._visible = !wasCapped && !prefs.getVal( "fadelines.hide" );
	}

	/**
	 * handle pref value changes for the plugin
	 * 
	 * @param	name
	 * @param	newValue
	 * @param	oldValue
	 */
	private function prefChangeHandler( name:String, newValue, oldValue ) : Void {
		
		switch ( name ) {
			
			case "fadelines.hide":
			case "zoom.level":
				redraw();
			break;
				
		}
		
	}

	public function getConfigPanelLayout() : Array {

		return [
		
			{	id: "zoom.level",
				type: "slider",
				min: 20,
				max: 200,
				step: 1,
				valueFormat: "%i%%",
				label: "Zoom Level",
				tooltip: "Zoom Level",
				data: { pref: "zoom.level" }
			},
			
			{	id: "fadelines.hide",
				type: "checkbox",
				label: "Hide faded lines",
				tooltip: "Hides the faded lines that are drawn between your character and the equipment slots.",
				data: { pref: "fadelines.hide" }
			}
				
		];
		
	}
	
	/**
	 * internal variables
	 */
	
	private var waitForId:Number;
	private var hooked:Boolean;
	private var charSheetMonitor:DistributedValue;

}