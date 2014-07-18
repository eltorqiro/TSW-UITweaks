import com.GameInterface.DistributedValue;
import mx.utils.Delegate;
import com.GameInterface.UtilsBase;
import flash.geom.Point;
import com.GameInterface.Game.Camera;


class com.ElTorqiro.UITweaks.SuppressCharacterSheetScaling extends com.ElTorqiro.UITweaks.UITweakPluginBase {

	private var _characterSheetActiveVar:DistributedValue;
	private var _findCharacterSheetThrashCount:Number = 0;

	// TODO: make these configurable
	private var _scale:Number = 150;
	private var _hideFadeLines:Boolean = false;

	
	public function SuppressCharacterSheetScaling() {
		super();
		
		_characterSheetActiveVar = DistributedValue.Create("character_sheet");
	}
	
	private function Activate() {
		_characterSheetActiveVar.SignalChanged.Connect(Suppress, this);
		Suppress();		
	}
	
	private function Deactivate() {
		_characterSheetActiveVar.SignalChanged.Disconnect(Suppress, this);
		
		if ( _root.charactersheet.UpdatePositionSaved != undefined ) {
			_root.charactersheet.UpdatePosition = _root.charactersheet.UpdatePositionSaved;
			_root.charactersheet.UpdatePositionSaved = undefined;
		}
	}
	
	private function Suppress():Void {
		if( !_characterSheetActiveVar.GetValue() ) {
			_findCharacterSheetThrashCount = 0;
			return;
		}

		if ( _root.charactersheet.UpdatePosition == undefined ) {
			if (_findCharacterSheetThrashCount++ == 30) _findCharacterSheetThrashCount = 0;
			else _global.setTimeout( Delegate.create(this, Suppress), 10);
			return;
		}
		_findCharacterSheetThrashCount = 0;

		_root.charactersheet.UpdatePositionSaved = _root.charactersheet.UpdatePosition;
		_root.charactersheet.UpdatePosition = Delegate.create(this, UpdatePosition);
	}

	
	private function UpdatePosition():Void {
		var sheet = _root.charactersheet;
		
		//    var camDist:Number = m_Character.GetCameraDistance();
		var camDist:Number =  Camera.GetZoom();
		var pos:Point = sheet.m_Character.GetScreenPosition(128);


		var scaleAt1Meter = 3;

		var minScale = 0.7;
		var maxScale = Math.min( 1.7, 1.45 * Stage.width / 1024 );
		var scale:Number = (camDist > 0) ? Math.min( maxScale, scaleAt1Meter / camDist ) : maxScale;

		pos.y -= 15 + 45 * scale;

		//scale = Math.max( minScale, scale );
		//scale = maxScale;
		scale = _scale / 100;

		if ( pos.x < 0 ) // Camera to close to make a projection
		{
			pos.x = Stage.width * 0.5;
			pos.y = Stage.height * 0.9;
		}
			
		sheet._xscale = scale * 100;
		sheet._yscale = scale * 100;
			
		var newPosX:Number = pos.x - Stage.width * scale * 0.5;
		var newPosY:Number = pos.y - Stage.height * scale * 0.5;
		var wasCapped:Boolean = false;

		var viewportLeft = 20;
		var viewportRight = Stage.width - 20;
		var viewportBottom = Stage.height - 100 * sheet.s_ResolutionScale.GetValue();

		if ( sheet.m_ActivePanel && newPosX < viewportLeft - sheet.m_ActivePanel._x * scale )
		{
			newPosX = viewportLeft - sheet.m_ActivePanel._x * scale;
			wasCapped = true;
		}
		else if ( newPosX > viewportRight - (sheet.m_EquipmentSlots._x + sheet.m_EquipmentSlots._width) * scale )
		{
			newPosX = viewportRight - (sheet.m_EquipmentSlots._x + sheet.m_EquipmentSlots._width) * scale;
			wasCapped = true;
		}
			
		if ( newPosY > viewportBottom - (sheet.m_EquipmentSlots._y + sheet.m_EquipmentSlots._height) * scale )
		{
			newPosY = viewportBottom - (sheet.m_EquipmentSlots._y + sheet.m_EquipmentSlots._height) * scale;
			wasCapped = true;
		}
			
		sheet._x = newPosX;
		sheet._y = newPosY;
			
		sheet.m_FadeLine._visible = !wasCapped && !_hideFadeLines;
	}
}