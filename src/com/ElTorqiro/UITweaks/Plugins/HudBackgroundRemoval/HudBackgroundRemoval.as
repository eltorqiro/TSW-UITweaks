import com.ElTorqiro.UITweaks.Plugins.Plugin;

import com.Utils.HUDController;
import flash.geom.Point;
import gfx.utils.Delegate;

import com.ElTorqiro.UITweaks.AddonUtils.WaitFor;


/**
 * 
 * 
 */
class com.ElTorqiro.UITweaks.Plugins.HudBackgroundRemoval.HudBackgroundRemoval extends Plugin {

	// plugin properties
	public var id:String = "hudBackgroundRemoval";
	public var name:String = "Black Background Removal";
	public var description:String = "Removes the blurry black background from the bottom of the screen, while still allowing the default \"in combat\" indicator to be used.";
	public var author:String = "ElTorqiro";
	public var prefsVersion:Number = 1;

	public function HudBackgroundRemoval() {

	}

	public function apply() : Void {
		stopWaitFor();
		waitForId = WaitFor.start( Delegate.create( this, waitForTest ), 10, 3000, Delegate.create( this, hook ) );
	}
	
	private function waitForTest() : Boolean {
		return _root.combatbackground.i_CombatBackground != undefined && HUDController.GetModule( "HUDBackground" ) != null;
	}

	public function revert() : Void {
		stopWaitFor();
		if ( !hooked ) return;
		
		hudBackground.i_CombatBackground._y = originalInCombatPosition.y;
		HUDController.RegisterModule( 'HUDBackground', hudBackground );
		
		hudBackground = undefined;
		hooked = false;
	}

	public function onModuleDeactivated() : Void {
		revert();
	}
	
	private function hook() : Void {
		stopWaitFor();
		if ( hooked ) return;
		
		/*
		 * unregister module from the HUDController
		 * this prevents HUDController.Layout() from routinely updating the size and position of the clip
		 */
		hudBackground = HUDController.GetModule( "HUDBackground" );
		HUDController.DeregisterModule( "HUDBackground" );

		// remember existing incombat clip position
		var inCombat:MovieClip = hudBackground.i_CombatBackground;
		originalInCombatPosition = new Point( inCombat._x, inCombat._y );
		
		// shift entire hudBackground clip off the screen, but put its incombat sub-clip back where it was originally
		var newPosition = new Point( originalInCombatPosition.x, originalInCombatPosition.y );
		hudBackground.localToGlobal( newPosition );
		//hudBackground._y += 500;
		hudBackground._y = Stage.visibleRect.height;
		hudBackground.globalToLocal( newPosition );
		
		inCombat._y = newPosition.y;
		
		hooked = true;
	}

	public function stopWaitFor() : Void {
		WaitFor.stop( waitForId );
		waitForId = undefined;
	}
	
	/**
	 * internal variables
	 */
	
	private var waitForId:Number;
	private var hudBackground:MovieClip;
	private var originalInCombatPosition:Point;
	private var hooked:Boolean;

}
