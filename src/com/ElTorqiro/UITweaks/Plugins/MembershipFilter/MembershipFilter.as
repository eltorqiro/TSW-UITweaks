import com.ElTorqiro.UITweaks.Plugins.Plugin;
import com.Utils.ID32;

import gfx.utils.Delegate;
import com.GameInterface.Nametags;
import com.Components.Nametag;

import com.GameInterface.UtilsBase;

import com.ElTorqiro.UITweaks.AddonUtils.WaitFor;
import com.ElTorqiro.UITweaks.AddonUtils.CommonUtils;


/**
 * 
 * 
 */
class com.ElTorqiro.UITweaks.Plugins.MembershipFilter.MembershipFilter extends Plugin {

	// plugin properties
	public var id:String = "membershipFilter";
	public var name:String = "Membership Filter";
	public var description:String = "Filters out unnecessary membership indicators.";
	public var author:String = "ElTorqiro";
	public var prefsVersion:Number = 1;

	public function MembershipFilter() {
		
		prefs.add( "nametag.icon.hide", true );
		
		initialisedTime = new Date();
		
	}

	public function apply() : Void {
		stopWaitFor();
		waitForId = WaitFor.start( Delegate.create( this, waitForTest ), 10, 3000, Delegate.create( this, hook ) );
	}
	
	public function waitForTest() : Boolean {
		return _root.nametagcontroller.SetTarget != undefined;
	}
	
	private function hook() : Void {
		stopWaitFor();
		if ( hooked ) return;
		
		controller = _root.nametagcontroller;

		// hook original function
		controller.UITweaks_SetTarget = controller.SetTarget;
		controller.UITweaks_MembershipFilterPlugin = this;
		controller.SetTarget = Delegate.create( controller, function( newTarget:ID32, oldTarget:ID32 ) {
			
			this.UITweaks_SetTarget( newTarget, oldTarget );
			
			var nametag:Nametag = this.m_NametagArray[ this.GetNametagIndex( newTarget ) ];

			if ( nametag ) {
				nametag["m_MemberIcon"]._visible = !this.UITweaks_MembershipFilterPlugin.prefs.getVal( "nametag.icon.hide" );
			}

		});
		
		controller.UITweaks_RefreshTargets = Delegate.create( controller, function() {
			
			this.SlotDefensiveTargetChanged( undefined );
			this.SlotDefensiveTargetChanged( this.m_ClientCharacter.GetDefensiveTarget() );
			
			this.SlotOffensiveTargetChanged( undefined );
			this.SlotOffensiveTargetChanged( this.m_ClientCharacter.GetOffensiveTarget() );
			
			
		});
		
		hooked = true;

		prefs.SignalValueChanged.Connect( refreshTargetTags, this );

		// trigger a refresh of nametags, but delay a short period only on the initial launch after a /reloadui, to avoid the "3 nametags are created on the target" issue
		if ( (new Date()) - initialisedTime > 3000 ) {
			refreshTargetTags();
		}
		
	}
	
	private function setTargetHandler( newTarget:ID32, oldTarget:ID32 ) : Void {
		
		this["UITweaks_SetTarget"]( newTarget, oldTarget );
		
	}
	
	private function refreshTargetTags( name:String ) : Void {

		if ( name != "plugin.enabled" ) {
			controller.UITweaks_RefreshTargets();
		}
		
	}
	
	public function revert() : Void {
		stopWaitFor();
		if ( !hooked ) return;
		
		// restore original create nametag function
		controller.SetTarget = controller.UITweaks_SetTarget;
		delete controller.UITweaks_SetTarget;
		delete controller.UITweaks_MembershipFilterPlugin;

		hooked = false;
		
		// trigger a refresh of nametags
		prefs.SignalValueChanged.Disconnect( refreshTargetTags, this );
		refreshTargetTags();
		
		controller = null;

	}

	public function onModuleDeactivated() : Void {
		revert();
	}

	public function stopWaitFor() : Void {
		WaitFor.stop( waitForId );
		waitForId = undefined;
	}
	
	public function getConfigPanelLayout() : Array {

		return [
		
			{	id: "nametag.icon.hide",
				type: "checkbox",
				label: "Hide nametag membership icon",
				tooltip: "Hides the membership icon from player nametags.",
				data: { pref: "nametag.icon.hide" }
			}
			
		];
		
	}
	
	/**
	 * internal variables
	 */
	
	private var waitForId:Number;
	private var hooked:Boolean;
	private var controller;
	
	private var initialisedTime:Date;

	/**
	 * properties
	 */
	
}