import com.ElTorqiro.UITweaks.Plugins.PluginBase;
import com.GameInterface.DistributedValue;
import com.GameInterface.Game.Character;
import mx.utils.Delegate;
import com.GameInterface.UtilsBase;
import flash.geom.Point;
import com.GameInterface.Game.Camera;
import com.ElTorqiro.UITweaks.Enums.States;
import com.GameInterface.Utils;

class com.ElTorqiro.UITweaks.Plugins.SuppressMaxAPSPNotifications extends com.ElTorqiro.UITweaks.Plugins.PluginBase {
	
	private var _targetMC:MovieClip;
	private var _findTargetThrashCount:Number = 0;
	
	// TODO: make these configurable
	private var _suppressMaxAP:Boolean = true;
	private var _suppressMaxSP:Boolean = true;

	
	public function SuppressMaxAPSPNotifications() {
		super();
	}
	
	private function Activate() {
		super.Activate();
		
		Suppress();
	}
	
	private function Deactivate() {
		super.Deactivate();
		
		Restore();
	}
	
	private function Suppress():Void {
		if ( _root.animawheellink.SetVisible == undefined ) {
			if (_findTargetThrashCount++ == 30) _findTargetThrashCount = 0;
			else _global.setTimeout( Delegate.create(this, Suppress), 10);
			return;
		}
		_findTargetThrashCount = 0;
		_targetMC = _root.animawheellink;
		
		var character:Character = Character.GetClientCharacter();
		
		var maxAP:Number = Utils.GetGameTweak("LevelTokensCap") + character.GetStat(_global.Enums.Stat.e_PersonalAnimaTokenCap, 2);
		var maxSP:Number = Utils.GetGameTweak("SkillTokensCap");
		
		var currentAP:Number = character.GetTokens(_global.Enums.Token.e_Anima_Point);
		var currentSP:Number = character.GetTokens(_global.Enums.Token.e_Skill_Point);
		
		if ( currentAP >= maxAP ) {
			_targetMC.SetVisible(_targetMC.m_AnimaPointsIcon,false);
		}
		
		if ( currentSP >= maxSP) {
			_targetMC.SetVisible(_targetMC.m_SkillPointsIcon,false);
		}
	}
	
	
	private function Restore():Void {
		if ( _targetMC == undefined ) return;
		
		_targetMC.SlotCharacterAlive();
		_targetMC = undefined;
	}
	
	/**
	 * If this is wired up, it'll suppress even the initial icon you get when you reach max, which seems undesirable.
	 * 
	 * @param	id
	 * @param	newValue
	 * @param	oldValue
	 */
	function SlotTokenAmountChanged(id, newValue, oldValue)
	{
		if ( id == 1 || id == 2 ) Suppress();
	}
}