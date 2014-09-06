import com.GameInterface.DistributedValue;
import mx.utils.Delegate;
import com.GameInterface.UtilsBase;
import flash.geom.Point;
import com.ElTorqiro.UITweaks.Enums.States;
import com.GameInterface.Game.Shortcut;
import com.GameInterface.ProjectUtils;


class com.ElTorqiro.UITweaks.Plugins.AbilityBarDeFX.AbilityBarDeFX {

	// settings
	private var _hideReflections:Boolean = true;
	private var _hideGloss:Boolean = true;
	
	// utility objects
	private var _findMCThrashCount:Number = 0;
	private var _lastSlot:Number;

	// state
	private var _active = false;
	
	public function AbilityBarDeFX() {
		_lastSlot = ProjectUtils.GetUint32TweakValue('PlayerMaxActiveSpells') - 1;
	}
	
	public function Apply():Void {

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
		
		_active = true;
	}

	public function Restore():Void {
		
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

		// remove property on abilitybar to indicate the plugin has not applied
		delete _root.abilitybar.UITweaks_AbilityBarDeFX;
		
		// trigger refresh of the abilitybar slots
		_root.abilitybar.SlotShortcutsRefresh();
		
		_active = false;
	}
	

	public function get hideReflections():Boolean { return _hideReflections };
	public function set hideReflections(value:Boolean):Void {
		if ( _hideReflections == value || value == undefined ) return;

		_hideReflections = value;
		
		if ( _active ) {
			Restore();
			Apply();
		}
	}

	public function get hideGloss():Boolean { return _hideGloss };
	public function set hideGloss(value:Boolean):Void {
		if ( _hideGloss == value || value == undefined ) return;
		
		_hideGloss = value;

		if ( _active ) {
			Restore();
			Apply();
		}
	}
	
}