import com.ElTorqiro.UITweaks.Plugins.PluginBase;
import com.ElTorqiro.UITweaks.PluginWrapper;
import mx.utils.Delegate;
import com.GameInterface.UtilsBase;
import flash.geom.Point;
import com.GameInterface.Lore;
import gfx.motion.Tween;


class com.ElTorqiro.UITweaks.Plugins.InCombatBGRemover.InCombatBGRemover extends PluginBase {
	
	private var _hideCombatBackground:Boolean = true;
	private var _findTargetThrashCount:Number = 0;
	private var _combat:MovieClip;
	
	//Use In Other Function ( Declaired For Compile )
	public var isInCombat:Boolean;
	public var m_AuxilliarySlotAchievement:Number;
	public var Strong;
	
	public function TargetOfTarget(wrapper:PluginWrapper) {
		super(wrapper);
	}

	private function Activate() {
		super.Activate();
		
		FindInCombatIndicator();
	}

	private function Deactivate() {
		super.Deactivate();
	}
	
	private function FindInCombatIndicator():Void {
		
		if ( _hideCombatBackground) {
			
			if ( _root.combatbackground.i_CombatBackground == undefined ) {
			if (_findTargetThrashCount++ == 30) _findTargetThrashCount = 0;
			else _global.setTimeout( Delegate.create(this, FindInCombatIndicator), 10);
			return;
			}

		_findTargetThrashCount = 0;
		
		UtilsBase.PrintChatText("Found _root.combatbackground.i_CombatBackground");
		
		_combat = _root.combatbackground;
		_combat.InCombatCheck = Delegate.create(this, InCombatCheck);	
		_combat.SlotToggleCombat = _combat.InCombatCheck;
		
		//_combat.InCombat(isInCombat);
		}
	}
	
	public function InCombatCheck(isInCombat){ 
		
		UtilsBase.PrintChatText("Function Called");

		if (Lore.IsLocked(m_AuxilliarySlotAchievement)) {
			_combat.i_CombatBackground._x = 317; 
		} else { 
			_combat.i_CombatBackground._x = 345;
		}
	
		if (isInCombat) { 
			if ( _combat._visible == false) { _combat._visible = true; }
			
			UtilsBase.PrintChatText("in Combat");
		
			_combat.i_CombatBackground.tweenTo(1, { _alpha:75 }, Strong.easeIn); 
		
		} else { 
			_combat.i_CombatBackground.tweenTo(2, { _alpha:0 }, Strong.easeOut);
			_combat._visible = false;
			
			UtilsBase.PrintChatText("Not In Combat");
		}
	
	}
		
}