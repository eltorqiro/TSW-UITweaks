import com.GameInterface.DistributedValue;
import com.GameInterface.Game.Character;
import mx.utils.Delegate;
import com.GameInterface.UtilsBase;
import com.GameInterface.Utils;

class com.ElTorqiro.UITweaks.Plugins.MaxAPSPNotifications.MaxAPSPNotifications {
	
	private var _targetMC:MovieClip;
	private var _findTargetThrashCount:Number = 0;
	
	private var _suppressMaxAP:Boolean;
	private var _suppressMaxSP:Boolean;

	
	public function MaxAPSPNotifications() {
		_suppressMaxAP = true;
		_suppressMaxSP = true;
	}
	
	public function Suppress():Void {
		if ( _root.animawheellink.SetVisible == undefined ) {
			if (_findTargetThrashCount++ == 30) _findTargetThrashCount = 0;
			else _global.setTimeout( Delegate.create(this, Suppress), 10);
			return;
		}
		_findTargetThrashCount = 0;
		_targetMC = _root.animawheellink;
		
		var character:Character = Character.GetClientCharacter();
		
		var maxAP:Number = Utils.GetGameTweak("LevelTokensCap") + character.GetStat(_global.Enums.Stat.e_PersonalAnimaTokenCap, 2);
		var maxSP:Number = Utils.GetGameTweak("SkillTokensCap") + character.GetStat(_global.Enums.Stat.e_PersonalSkillTokenCap, 2);		
		
		var currentAP:Number = character.GetTokens(_global.Enums.Token.e_Anima_Point);
		var currentSP:Number = character.GetTokens(_global.Enums.Token.e_Skill_Point);
		
		if ( currentAP >= maxAP ) {
			_targetMC.SetVisible(_targetMC.m_AnimaPointsIcon, !_suppressMaxAP);
		}
		
		if ( currentSP >= maxSP) {
			_targetMC.SetVisible(_targetMC.m_SkillPointsIcon, !_suppressMaxSP);
		}
	}
	
	
	public function Restore():Void {
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
	function SlotTokenAmountChanged(id, newValue, oldValue)	{
		if ( id == 1 || id == 2 ) Suppress();
	}
	
	public function get suppressMaxAP():Boolean { return _suppressMaxAP; }
	public function set suppressMaxAP(value:Boolean):Void {
		if ( value == undefined ) return;
		
		_suppressMaxAP = value;
		Suppress();
	}
	
	public function get suppressMaxSP():Boolean { return _suppressMaxSP; }
	public function set suppressMaxSP(value:Boolean):Void {
		if ( value == undefined ) return;
		
		_suppressMaxSP = value;
		Suppress();
	}
	
}