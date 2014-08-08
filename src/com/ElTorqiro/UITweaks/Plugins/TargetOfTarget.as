import com.GameInterface.UtilsBase;
import com.ElTorqiro.UITweaks.Plugins.PluginBase;
import com.ElTorqiro.UITweaks.AddonUtils.AddonUtils;
import com.GameInterface.Game.Character
import com.Utils.ID32;

class com.ElTorqiro.UITweaks.Plugins.TargetOfTarget extends com.ElTorqiro.UITweaks.Plugins.PluginBase {

	private var _character:Character;
	private var _target:Character;
	private var _targetOfTarget:Character;
	
	public function TargetOfTarget() {
		super();
	}

	private function Activate() {
		super.Activate();
		
		_character = Character.GetClientCharacter();
		_character.SignalOffensiveTargetChanged.Connect(UserTargetChanged, this);
		
		UserTargetChanged();
		
	}

	private function Deactivate() {
		super.Deactivate();
		
		_character.SignalOffensiveTargetChanged.Disconnect(UserTargetChanged, this);
	    
		if( _target != undefined ) _target.SignalOffensiveTargetChanged.Disconnect( TargetOfTargetDisplay, this );
	}
	
	private function UserTargetChanged():Void {
		
		if( _target != undefined ) _target.SignalOffensiveTargetChanged.Disconnect( TargetOfTargetDisplay, this );
		
		_target = Character.GetCharacter( _character.GetOffensiveTarget() );
		_target.SignalOffensiveTargetChanged.Connect(TargetOfTargetDisplay, this);
		
		/**
		 * Debug:
		 *UtilsBase.PrintChatText("My Target: " + _target.GetName());
		 **/
	}
	
	private function TargetOfTargetDisplay():Void 
	{
		_targetOfTarget = Character.GetCharacter( _target.GetOffensiveTarget() );
				
		UtilsBase.PrintChatText("TOT: " + _targetOfTarget.GetName());
	}
}