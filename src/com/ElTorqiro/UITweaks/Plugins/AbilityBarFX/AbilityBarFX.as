import com.ElTorqiro.UITweaks.Plugins.Plugin;
import flash.filters.DropShadowFilter;

import gfx.utils.Delegate;
import com.GameInterface.ProjectUtils;

import com.ElTorqiro.UITweaks.AddonUtils.WaitFor;


/**
 * 
 * 
 */
class com.ElTorqiro.UITweaks.Plugins.AbilityBarFX.AbilityBarFX extends Plugin {

	// plugin properties
	public var id:String = "abilityBarFx";
	public var name:String = "Ability Bar FX";
	public var description:String = "Customises the look of the buttons in the ability bar.";
	public var author:String = "ElTorqiro";
	public var prefsVersion:Number = 1;
	
	public function AbilityBarFX() {

		prefs.add( "reflections.hide", true );
		prefs.add( "gloss.hide", false );
		
		prefs.add( "borders.regular.hide", true );
		prefs.add( "borders.elite.hide", true );
		prefs.add( "borders.aux.hide", true );
		
		prefs.add( "icon.shadow.enable", true );
		prefs.add( "icon.shadow.alpha", 50 );
		prefs.add( "icon.shadow.distance", 4 );
		prefs.add( "icon.shadow.blur", 2 );
		prefs.add( "icon.shadow.angle", 90 );
		
		prefs.add( "button.shadow.enable", true );
		prefs.add( "button.shadow.alpha", 50 );
		prefs.add( "button.shadow.distance", 6 );
		prefs.add( "button.shadow.blur", 4 );
		prefs.add( "button.shadow.angle", 90 );
		
	}
	
	public function apply() : Void {
		stopWaitFor();

		waitForId = WaitFor.start( waitForTest, 100, 2000, Delegate.create(this, hook) );
	}

	private function waitForTest() : Boolean {
		return _root.abilitybar.m_AbilitySlots.length == ProjectUtils.GetUint32TweakValue('PlayerMaxActiveSpells');
	}
	
	public function stopWaitFor() : Void {
		WaitFor.stop( waitForId );
		waitForId = undefined;
	}
	
	public function onModuleDeactivated() : Void {
		stopWaitFor();
		hooked = false;
	}
	
	public function hook() : Void {
		stopWaitFor();
		if ( hooked ) return;
		
		var slots:Array = _root.abilitybar.m_AbilitySlots;
		
		var redrawSlotDelegate:Function = Delegate.create( this, redrawSlot );
		
		for ( var i:Number = 0; i < slots.length; i++ ) {
			
			var slot = slots[i];

			// only apply hook if it hasn't already been applied
			if ( slot.UITweaks_AbilityBarDeFX_RedrawSlotDelegate == undefined ) {
				
				slot.UITweaks_AbilityBarDeFX_RedrawSlotDelegate = redrawSlotDelegate;
				
				slot.UITweaks_AbilityBarDeFX_AddEffects_Original = slot.AddEffects;
				slot.AddEffects = function() {
					this.UITweaks_AbilityBarDeFX_RedrawSlotDelegate( this );
				}
			}
		}

		hooked = true;
		
		// redraw the slots with the hook in place
		redraw();

	}

	public function redraw() : Void {
		
		if ( !hooked ) return;
		
		var bar = _root.abilitybar;
		var slots:Array = bar.m_AbilitySlots;
		
		for ( var i:Number = 0; i < slots.length; i++ ) {
			slots[i].AddEffects();
		}
		
		// auxiliary slot border is controlled in the abilitybar itself
		bar.m_AuxilliaryFrame._alpha = prefs.getVal( "borders.aux.hide" ) ? 0 : 100;
		
	}
	
	private function redrawSlot( slot:MovieClip ) {
		
		// reflections
		if ( prefs.getVal( "reflections.hide" ) ) {
			slot.m_Reflection.removeMovieClip();
		}
		
		else if ( !slot.m_Reflection ) {
			slot.UITweaks_AbilityBarDeFX_AddEffects_Original( slot.m_IconPath );
		}
		
		// gloss
		slot.m_Ability.m_Gloss._alpha = prefs.getVal( "gloss.hide" ) ? 0 : 100;

		// borders
		var outerLine:MovieClip = slot.m_Ability.m_OuterLine;
		var innerLine:MovieClip = slot.m_Ability.m_InnerLine;
		outerLine._xscale = outerLine._yscale = innerLine._xscale = innerLine._yscale = prefs.getVal( "borders.regular.hide" ) ? 0 : 100;

		var eliteFrame:MovieClip = slot.m_Ability.m_EliteFrame;
		eliteFrame._xscale = eliteFrame._yscale = prefs.getVal( "borders.elite.hide" ) ? 0 : 100;
		

		// 45' = 0.785398 rads
		// 90' = 1.5708 rads
		
		// icon shadow
		slot.m_Ability.m_Content.filters = !prefs.getVal( "icon.shadow.enable" ) ? [] : [ new DropShadowFilter(
			prefs.getVal( "icon.shadow.distance" ) * 10,
			degreesToRadians( prefs.getVal( "icon.shadow.angle" ) ),
			0,
			prefs.getVal( "icon.shadow.alpha" ) / 100,
			prefs.getVal( "icon.shadow.blur" ),
			prefs.getVal( "icon.shadow.blur" ),
			1, 3, false, false, false )
		];
					
		// button shadow
		slot.m_Ability.filters = !prefs.getVal( "button.shadow.enable" ) ? [] : [ new DropShadowFilter(
			prefs.getVal( "button.shadow.distance" ) * 10,
			degreesToRadians(prefs.getVal( "button.shadow.angle" )),
			0,
			prefs.getVal( "button.shadow.alpha" ) / 100,
			prefs.getVal( "button.shadow.blur" ),
			prefs.getVal( "button.shadow.blur" ),
			1, 3, false, false, false )
		];

	}

	private function degreesToRadians ( degrees:Number ) : Number {
		return degrees * Math.PI / 180;
	}
	
	public function revert() : Void {
		stopWaitFor();
		if ( !hooked ) return;
		
		var bar = _root.abilitybar;
		var slots:Array = bar.m_AbilitySlots;
		
		for ( var i:Number = 0; i < slots.length; i++ ) {
			
			var slot = slots[i];

			// only undo if it has been applied
			if ( slot.UITweaks_AbilityBarDeFX_RedrawSlotDelegate != undefined ) {
				slot.AddEffects = slot.UITweaks_AbilityBarDeFX_AddEffects_Original;
				delete slot.UITweaks_AbilityBarDeFX_AddEffects_Original;
				delete slot.UITweaks_AbilityBarDeFX_RedrawSlotDelegate;
			}
			
			slot.m_Ability.m_Gloss._alpha = 100;
		}
		
		hooked = false;
		
		// trigger refresh of the abilitybar slots without the override in place
		bar.SlotShortcutsRefresh();
	}

	/**
	 * handle pref value changes for the plugin
	 * 
	 * @param	name
	 * @param	newValue
	 * @param	oldValue
	 */
	private function prefChangeHandler( name:String, newValue, oldValue ) : Void {
		
		switch ( name ) {
			
			case "reflections.hide":
			case "gloss.hide":
			
			case "borders.regular.hide":
			case "borders.elite.hide":
			case "borders.aux.hide":
				
			case "icon.shadow.enable":
			case "icon.shadow.distance":
			case "icon.shadow.angle":
			case "icon.shadow.blur":
			case "icon.shadow.alpha":
				
			case "button.shadow.enable":
			case "button.shadow.distance":
			case "button.shadow.angle":
			case "button.shadow.blur":
			case "button.shadow.alpha":
				redraw();
			break;
				
		}
		
	}
	
	public function getConfigPanelLayout() : Array {

		return [
			{	id: "reflections.hide",
				type: "checkbox",
				label: "Hide reflections",
				tooltip: "Hides the reflection effect underneath the ability buttons.",
				data: { pref: "reflections.hide" }
			},
			
			{	id: "gloss.hide",
				type: "checkbox",
				label: "Hide glass-effect overlay",
				tooltip: "Hides the glass-like effect overlay at the top of the button.",
				data: { pref: "gloss.hide" }
			},
			
			{	type: "group"
			},
			
			{	id: "borders.regular.hide",
				type: "checkbox",
				label: "Hide regular ability borders",
				tooltip: "Hides the black borders around regular abilities.",
				data: { pref: "borders.regular.hide" }
			},
			
			{	id: "borders.elite.hide",
				type: "checkbox",
				label: "Hide elite ability borders",
				tooltip: "Hides the black borders around elite abilities.",
				data: { pref: "borders.elite.hide" }
			},
			
			{	id: "borders.aux.hide",
				type: "checkbox",
				label: "Hide auxiliary ability borders",
				tooltip: "Hides the black borders around auxiliary abilities.",
				data: { pref: "borders.aux.hide" }
			},
			
			{	type: "group"
			},
			
			{	id: "icon.shadow.enable",
				type: "checkbox",
				label: "Add shadow to ability icon",
				tooltip: "Adds a dropshadow effect to the ability icon inside the button.",
				data: { pref: "icon.shadow.enable" }
			},
			
			{	type: "indent-in"
			},
			
				{	id: "icon.shadow.angle",
					type: "slider",
					min: 0,
					max: 360,
					step: 1,
					valueFormat: "%i'",
					label: "Angle",
					tooltip: "The angle the shadow casts away from the icon.",
					data: { pref: "icon.shadow.angle" }
				},
				
				{	id: "icon.shadow.distance",
					type: "slider",
					min: 0,
					max: 10,
					step: 1,
					valueFormat: "%i",
					label: "Distance",
					tooltip: "The distance of the shadow from the icon.",
					data: { pref: "icon.shadow.distance" }
				},
				
				{	id: "icon.shadow.blur",
					type: "slider",
					min: 0,
					max: 16,
					step: 1,
					valueFormat: "%i",
					label: "Blur",
					tooltip: "The amount of blur applied to the shadow.",
					data: { pref: "icon.shadow.blur" }
				},
				
				{	id: "icon.shadow.alpha",
					type: "slider",
					min: 0,
					max: 100,
					step: 1,
					valueFormat: "%i%%",
					label: "Transparency",
					tooltip: "The transparency of the shadow.",
					data: { pref: "icon.shadow.alpha" }
				},
				
				{	type: "indent-reset"
				},
				
			{	type: "group"
			},
			
			{	id: "button.shadow.enable",
				type: "checkbox",
				label: "Add shadow to ability button",
				tooltip: "Adds a dropshadow effect to the ability button inside the button.",
				data: { pref: "button.shadow.enable" }
			},
			
			{	type: "indent-in"
			},
			
				{	id: "button.shadow.angle",
					type: "slider",
					min: 0,
					max: 360,
					step: 1,
					valueFormat: "%i'",
					label: "Angle",
					tooltip: "The angle the shadow casts away from the button.",
					data: { pref: "button.shadow.angle" }
				},
				
				{	id: "button.shadow.distance",
					type: "slider",
					min: 0,
					max: 10,
					step: 1,
					valueFormat: "%i",
					label: "Distance",
					tooltip: "The distance of the shadow from the button.",
					data: { pref: "button.shadow.distance" }
				},
				
				{	id: "button.shadow.blur",
					type: "slider",
					min: 0,
					max: 16,
					step: 1,
					valueFormat: "%i",
					label: "Blur",
					tooltip: "The amount of blur applied to the shadow.",
					data: { pref: "button.shadow.blur" }
				},
				
				{	id: "button.shadow.alpha",
					type: "slider",
					min: 0,
					max: 100,
					step: 1,
					valueFormat: "%i%%",
					label: "Transparency",
					tooltip: "The transparency of the shadow.",
					data: { pref: "button.shadow.alpha" }
				}
			
			
		];
		
	}
	
	
	/**
	 * internal variables
	 */
	
	
	private var waitForId:Number;
	private var hooked:Boolean;
	
	/**
	 * properties
	 */
	
}