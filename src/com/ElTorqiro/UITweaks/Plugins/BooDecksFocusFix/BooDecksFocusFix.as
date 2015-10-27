import com.ElTorqiro.UITweaks.Plugins.Plugin;

import com.Utils.HUDController;
import flash.geom.Point;
import gfx.utils.Delegate;

import com.ElTorqiro.UITweaks.AddonUtils.WaitFor;

import com.GameInterface.UtilsBase;

/**
 * 
 * 
 */
class com.ElTorqiro.UITweaks.Plugins.BooDecksFocusFix.BooDecksFocusFix extends Plugin {

	// plugin properties
	public var id:String = "booDecksFocusFix";
	public var name:String = "BooDecks Focus Fix";
	public var description:String = "Prevents BooDecks from hijacking all textfields in the game with broken tab handling.";
	public var author:String = "ElTorqiro";
	public var prefsVersion:Number = 1;

	public function BooDecksFocusFix() {

	}

	public function onLoad() : Void {
		super.onLoad();
		
		// only needs to be applied once at startup as ASwing.FocusManger is a static class
		if ( enabled ) apply();
	}
	
	// prevent hook running every time the ui is activated
	public function onModuleActivated() : Void {}
	
	public function apply() : Void {
		stopWaitFor();
		waitForId = WaitFor.start( Delegate.create( this, waitForTest ), 100, 3000, Delegate.create( this, hook ) );
	}
	
	private function waitForTest() : Boolean {
		return _global.org.aswing.FocusManager.disableTraversal;
	}

	public function revert() : Void {
		stopWaitFor();
		_global.org.aswing.FocusManager.enableTraversal();
	}

	private function hook() : Void {
		stopWaitFor();
		_global.org.aswing.FocusManager.disableTraversal();
	}

	public function stopWaitFor() : Void {
		WaitFor.stop( waitForId );
		waitForId = undefined;
	}
	
	/**
	 * internal variables
	 */
	
	private var waitForId:Number;

}
