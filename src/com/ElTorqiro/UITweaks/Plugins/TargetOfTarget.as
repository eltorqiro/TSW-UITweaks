import com.GameInterface.UtilsBase;
import com.ElTorqiro.UITweaks.Plugins.PluginBase;
import com.ElTorqiro.UITweaks.AddonUtils.AddonUtils;
import com.GameInterface.Game.Character
import com.Utils.ID32;

class com.ElTorqiro.UITweaks.Plugins.TargetOfTarget extends com.ElTorqiro.UITweaks.Plugins.PluginBase {

	private var _character:Character;
	private var _target:ID32;
	private var _targetOfTarget:ID32;
	
	public function TargetOfTarget() {
		super();
	}

	private function Activate() {
		super.Activate();

		 _character = Character.GetClientCharacter();
		_character.SignalOffensiveTargetChanged.Connect(UserTargetChanged, this);
	}

	private function Deactivate() {
		super.Deactivate();
	
	}
	
	private function UserTargetChanged():Void {
		
		_target = _character.GetOffensiveTarget();
		
		_character.SignalOffensiveTargetChanged.Disconnect(UserTargetChanged, this);
		
		_target.SignalOffensiveTargetChanged.Connect(TargetOfTargetDisplay, this);
		
	}
	
	private function TargetOfTargetDisplay():Void 
	{
		_targetOfTarget = _target.GetOffensiveTarget();
		
		_target.SignalOffensiveTargetChanged.Disconnect(TargetOfTargetDisplay, this);
		
		UtilsBase.PrintChatText(_targetOfTarget);
	}
}