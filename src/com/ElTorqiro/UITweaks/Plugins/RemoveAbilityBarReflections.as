import com.ElTorqiro.UITweaks.Plugins.PluginBase;
import com.GameInterface.DistributedValue;
import mx.utils.Delegate;
import com.GameInterface.UtilsBase;
import flash.geom.Point;
import com.ElTorqiro.UITweaks.Enums.States;
import com.GameInterface.Game.Shortcut;
import com.GameInterface.ProjectUtils;

class com.ElTorqiro.UITweaks.Plugins.RemoveAbilityBarReflections extends com.ElTorqiro.UITweaks.Plugins.PluginBase {

	private var _findMCThrashCount:Number = 0;
	private var _lastSlot:Number;
	
	private var _sheet:MovieClip;
	
	// TODO: make these configurable
	private var _scale:Number = 100;
	private var _repositionBar:Boolean = false;

	public function RemoveAbilityBarReflections() {
		super();
		
		_lastSlot = ProjectUtils.GetUint32TweakValue("PlayerMaxActiveSpells") - 1;
	}
	
	private function Activate() {
		super.Activate();
		
		Remove();
	}
	
	private function Deactivate() {
		super.Deactivate();

		Restore();
	}
	
	private function Remove():Void {

		var lastSlot:Number = _lastSlot;
		if ( _root.abilitybar['slot_' + _lastSlot] == undefined ) {
			if (_findMCThrashCount++ == 20) _findMCThrashCount = 0;
			else _global.setTimeout( Delegate.create(this, Remove), 100);
			return;
		}
		_findMCThrashCount = 0;

		for ( var i:Number = 0; i <= _lastSlot; i++ ) {
			
			var slot = _root.abilitybar.m_AbilitySlots[i];
			
			if( slot.AddEffects_UITweaks_Saved == undefined ) {
				slot.AddEffects_UITweaks_Saved = slot.AddEffects;
				slot.AddEffects = undefined;
			}
			
			// remove the reflection movieclip
			slot.m_Reflection.removeMovieClip();
		}
	}

	private function Restore():Void {
		for ( var i:Number = 0; i <= _lastSlot; i++ ) {
			
			var slot = _root.abilitybar.m_AbilitySlots[i];
			
			if( slot.AddEffects_UITweaks_Saved != undefined ) {
				slot.AddEffects = slot.AddEffects_UITweaks_Saved;
				slot.AddEffects_UITweaks_Saved = undefined;
			}
		}
		
		// trigger refresh of the abilitybar slots
		_root.abilitybar.SlotShortcutsRefresh();
	}
	
}