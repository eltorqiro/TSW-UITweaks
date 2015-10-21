import com.GameInterface.DistributedValue;
import mx.utils.Delegate;

class com.ElTorqiro.UITweaks.Plugins.Fix4K.Fix4K {

	private var _skillHiveActiveVar:DistributedValue;
	private var _maxSkillHiveDelay:Number;
	private var _delayInterval:Number = 50; //ms

	public function Fix4K() {
		_skillHiveActiveVar = DistributedValue.Create("skillhive_window");
	}
	
	public function Activate():Void {
		//Disable the message box that fails at 4K resolution, preventing the allocation of skill points.
		DistributedValue.SetDValue("ShowSkillWarning", false);
		
		_skillHiveActiveVar.SignalChanged.Connect(DoFixSkillHiveBackground, this);
		DoFixSkillHiveBackground();
	}

	public function Deactivate():Void {
		_skillHiveActiveVar.SignalChanged.Disconnect(DoFixSkillHiveBackground, this);
	}
	
	private function DoFixSkillHiveBackground():Void {
		if (_skillHiveActiveVar.GetValue() == true) {
			_maxSkillHiveDelay = 2000;
			FixSkillHiveBackground();
		}
	}
	private function FixSkillHiveBackground():Void {
		var window = _root.skillhive;
		if (window != undefined && window.i_SkillhiveBackground != undefined && window.i_SkillhiveBackground.i_Background != undefined) {
			var screenWidth:Number = Stage["visibleRect"].width;
			var backgroundWidth:Number = window.i_SkillhiveBackground.i_Background._width;
			window.i_SkillhiveBackground.i_Background._width = screenWidth;
			window.i_SkillhiveBackground.i_Background._x -= (screenWidth - backgroundWidth) / 2;
		} else {
			_maxSkillHiveDelay -= _delayInterval;
			if (_maxSkillHiveDelay > 0) _global.setTimeout( Delegate.create(this, FixSkillHiveBackground), _delayInterval);
		}
	}
}
