import com.GameInterface.UtilsBase;
import com.ElTorqiro.UITweaks.Plugins.PluginBase;
import com.ElTorqiro.UITweaks.AddonUtils.AddonUtils;
import com.GameInterface.Game.Character
import com.Utils.ID32;

class com.ElTorqiro.UITweaks.Plugins.TargetOfTarget extends com.ElTorqiro.UITweaks.Plugins.PluginBase {

	private var _character:Character;
	private var _target:Character;
	private var _offensiveTargetOfTarget:Character;
	private var _defensiveTargetOfTarget:Character;
	
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
		if( _target != undefined ) _target.SignalDefensiveTargetChanged.Disconnect( TargetOfTargetDisplay, this );
	}
	
	private function UserTargetChanged():Void {
		
		if ( _target != undefined ) _target.SignalOffensiveTargetChanged.Disconnect( TargetOfTargetDisplay, this );
		if ( _target != undefined ) _target.SignalDefensiveTargetChanged.Disconnect( TargetOfTargetDisplay, this );
				
		_target = Character.GetCharacter( _character.GetOffensiveTarget() );
		
		_target.SignalOffensiveTargetChanged.Connect(TargetOfTargetDisplay, this);
		_target.SignalDefensiveTargetChanged.Connect(TargetOfTargetDisplay, this);
		
		/**
		 * Debug:
		 *UtilsBase.PrintChatText("My Target: " + _target.GetName());
		 **/
		
		 TargetOfTargetDisplay();
	}
	
	private function TargetOfTargetDisplay():Void 
	{
		_offensiveTargetOfTarget = Character.GetCharacter( _target.GetOffensiveTarget() );
		_defensiveTargetOfTarget = Character.GetCharacter( _target.GetDefensiveTarget() );
		
				
		UtilsBase.PrintChatText("OFFTOT: " + _offensiveTargetOfTarget.GetName());
		UtilsBase.PrintChatText("DEFFTOT: " + _defensiveTargetOfTarget.GetName());
	}
}