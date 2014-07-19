import com.ElTorqiro.UITweaks.Plugins.PluginBase;
import com.GameInterface.DistributedValue;
import mx.utils.Delegate;
import com.GameInterface.UtilsBase;
import flash.geom.Point;
import com.GameInterface.Game.Camera;
import com.ElTorqiro.UITweaks.Enums.States;

class com.ElTorqiro.UITweaks.Plugins.SuppressCharacterSheetScaling extends com.ElTorqiro.UITweaks.Plugins.PluginBase {

	private var _characterSheetActiveVar:DistributedValue;
	private var _findCharacterSheetThrashCount:Number = 0;

	private var _sheet:MovieClip;
	
	// TODO: make these configurable
	private var _scale:Number = 100;
	private var _hideFadeLines:Boolean = true;
	private var _suppressOnEnterFrameThrashing:Boolean = true;


	public function SuppressCharacterSheetScaling() {
		super();
		
		_characterSheetActiveVar = DistributedValue.Create("character_sheet");
	}
	
	private function Activate() {
		super.Activate();
		
		_characterSheetActiveVar.SignalChanged.Connect(Suppress, this);
		Suppress();
	}
	
	private function Deactivate() {
		super.Deactivate();

		_characterSheetActiveVar.SignalChanged.Disconnect(Suppress, this);
		Restore();
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
		_sheet = _root.charactersheet;
		
		_sheet.UpdatePositionSaved = _sheet.UpdatePosition;
		_sheet.UpdatePosition = Delegate.create(this, UpdatePosition);
		_sheet.UpdatePosition();
		
		if ( _suppressOnEnterFrameThrashing ) {
			_sheet.onEnterFrameSaved = _sheet.onEnterFrame;
			_sheet.onEnterFrame = function() { };
		}
	}

	private function Restore():Void {
		if ( _sheet == undefined ) return;
		
		_sheet.UpdatePosition = _sheet.UpdatePositionSaved;
		_sheet.UpdatePositionSaved = undefined;
		
		if ( _suppressOnEnterFrameThrashing ) {
			_sheet.onEnterFrame = _sheet.onEnterFrameSaved;
			_sheet.onEnterFrameSaved = undefined;
		}
		
		_sheet = undefined;			
	}
	
	private function UpdatePosition():Void {
		
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
		scale = _scale / 100;

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
			
		_sheet.m_FadeLine._visible = !wasCapped && !_hideFadeLines;
	}
}