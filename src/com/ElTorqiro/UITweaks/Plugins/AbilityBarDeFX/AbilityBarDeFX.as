import com.ElTorqiro.UITweaks.Plugins.PluginBase;
import com.GameInterface.DistributedValue;
import mx.utils.Delegate;
import com.GameInterface.UtilsBase;
import flash.geom.Point;
import com.ElTorqiro.UITweaks.Enums.States;
import com.GameInterface.Game.Shortcut;
import com.GameInterface.ProjectUtils;

class com.ElTorqiro.UITweaks.Plugins.AbilityBarDeFX.AbilityBarDeFX extends com.ElTorqiro.UITweaks.PluginBase {

	// settings
	// TODO: make these configurable
	private var _hideReflections:Boolean = true;
	private var _hideGloss:Boolean = true;
	private var _repositionBar:Boolean = false;	// currently unused, TODO: position bar at bottom of screen
	
	// utility objects
	private var _findMCThrashCount:Number = 0;
	private var _lastSlot:Number;
	
	private var _sheet:MovieClip;
	
	public function AbilityBarDeFX(data:Object) {
		super(data);
		
		_lastSlot = ProjectUtils.GetUint32TweakValue("PlayerMaxActiveSpells") - 1;
	}
	
	private function Activate() {
		super.Activate();
		
		Apply();
	}
	
	private function Deactivate() {
		super.Deactivate();

		Restore();
	}
	
	private function Apply():Void {

		// find last slot in ability bar
		if ( _root.abilitybar['slot_' + _lastSlot] == undefined ) {
			if (_findMCThrashCount++ == 20) _findMCThrashCount = 0;
			else _global.setTimeout( Delegate.create(this, Apply), 100);
			return;
		}
		_findMCThrashCount = 0;

		for ( var i:Number = 0; i <= _lastSlot; i++ ) {
			
			var slot = _root.abilitybar.m_AbilitySlots[i];
			
			// override the slot AddEffects only if the plugin hasn't already applied the override
			if( !_root.abilitybar.UITweaks_AbilityBarDeFX ) {
				slot.UITweaks_AbilityBarDeFX_AddEffects_Original = slot.AddEffects;
				
				slot.AddEffects = function() {
					this.UITweaks_AbilityBarDeFX_HideReflection();
					this.UITweaks_AbilityBarDeFX_HideGloss();
				};
			}
			
			// hide reflection effect
			slot.UITweaks_AbilityBarDeFX_HideReflection = !_hideReflections ?
				slot.UITweaks_AbilityBarDeFX_AddEffects_Original :
				function() { this.m_Reflection.removeMovieClip(); };

			// hide gloss effect
			slot.UITweaks_AbilityBarDeFX_HideGloss = !_hideGloss ? undefined : function() { this.m_Ability.m_Gloss._alpha = 0; };
		}

		// set property on abilitybar to indicate it has been modified
		_root.abilitybar.UITweaks_AbilityBarDeFX = true;
		
		// trigger refresh of the abilitybar slots with the override in place
		_root.abilitybar.SlotShortcutsRefresh();		
	}

	private function Restore():Void {
		
		if( _root.abilitybar.UITweaks_AbilityBarDeFX ) {
		
			for ( var i:Number = 0; i <= _lastSlot; i++ ) {
				
				var slot = _root.abilitybar.m_AbilitySlots[i];
				
				// restore original AddEffects function
				if( slot.UITweaks_AbilityBarDeFX_AddEffects_Original != undefined ) {
					slot.AddEffects = slot.UITweaks_AbilityBarDeFX_AddEffects_Original;
					
					// zero footprint
					delete slot.UITweaks_AbilityBarDeFX_AddEffects_Original;
					delete slot.UITweaks_AbilityBarDeFX_HideReflection;
					delete slot.UITweaks_AbilityBarDeFX_HideGloss;
				}
			}
		}

		// remove property on abilitybar to indicate the plugin has not not applied
		delete _root.abilitybar.UITweaks_AbilityBarDeFX;
		
		// trigger refresh of the abilitybar slots
		_root.abilitybar.SlotShortcutsRefresh();
	}
}