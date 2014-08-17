import com.ElTorqiro.UITweaks.Plugins.PluginBase;
import com.ElTorqiro.UITweaks.PluginWrapper;
import mx.utils.Delegate;
import com.GameInterface.UtilsBase;
import flash.geom.Point;
import com.GameInterface.Lore;


class com.ElTorqiro.UITweaks.Plugins.InCombatBGRemover.InCombatBGRemover extends PluginBase {
	
	private var _hideCombatBackground:Boolean = true;
	private var _findTargetThrashCount:Number = 0;
	private var _combat:MovieClip;
	
	public var isInCombat:Boolean;
	public var m_AuxilliarySlotAchievement:Number;
	
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
			
			if ( _root.combatbackground == undefined ) {
			if (_findTargetThrashCount++ == 30) _findTargetThrashCount = 0;
			else _global.setTimeout( Delegate.create(this, FindInCombatIndicator), 10);
			return;
		}

		_findTargetThrashCount = 0;
		
		UtilsBase.PrintChatText("Found Background Removing 1");
		
		_combat = _root.combatbackground;
		
		_combat.SlotToggleCombat = _combat.InCombat;
		_combat.InCombat = Delegate.create(this, InCombat);
		_combat.InCombat(isInCombat);
		}
	}
	
	private function InCombat(isInCombat){ 

		

		if (Lore.IsLocked(m_AuxilliarySlotAchievement)) {
			_combat.i_CombatBackground._x = 317; 
		} else { 
			_combat.i_CombatBackground._x = 345;
		}
	
		if (isInCombat) { 
			if ( _combat._visible == false) { _combat._visible = true; }
			UtilsBase.PrintChatText("in Combat");
			//_combat.i_CombatBackground.tweenTo(1, { _alpha:75 }, Strong.easeIn); 
		}else { 
			_combat._visible = false;
			//_combat.i_CombatBackground.tweenTo(2, { _alpha:0 }, Strong.easeOut);
		}
	
	}
		
}