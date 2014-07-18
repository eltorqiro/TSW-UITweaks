import com.GameInterface.DistributedValue;
import mx.utils.Delegate;

class com.ElTorqiro.UITweaks.SuppressCharacterSheetScaling extends com.ElTorqiro.UITweaks.UITweakPluginBase {

	private var _characterSheetActiveVar:DistributedValue;
	private var _findCharacterSheetThrashCount:Number = 0;

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
	
	function Suppress():Void {
		if( !_characterSheetActiveVar.GetValue() ) {
			_findCharacterSheetThrashCount = 0;
			return;
		}

		if ( _root.charactersheet.UpdatePosition == undefined ) {
			if (_findCharacterSheetThrashCount++ == 10) _findCharacterSheetThrashCount = 0;
			else _global.setTimeout( Delegate.create(this, Suppress), 50);
			return;
		}
		_findCharacterSheetThrashCount = 0;

		_root.charactersheet.UpdatePositionSaved = _root.charactersheet.UpdatePosition;
		_root.charactersheet.UpdatePosition = function() { };
	}
	
}