import com.ElTorqiro.UITweaks.Plugins.Plugin;

import com.GameInterface.DistributedValue;
import gfx.utils.Delegate;

import com.ElTorqiro.UITweaks.AddonUtils.WaitFor;


class me.jupath.tsw.UITweaks.Fix4K.Fix4K extends Plugin {

	// plugin properties
	public var id:String = "fix4K";
	public var name:String = "Fix 4K";
	public var description:String = "Fixes inherent problems with the game at 4K resolution. Disables the warning popup that should appear (but fails to) when allocating skills that do not increase your gear level. Fixes the background of the ability wheel so that abilities may be dragged into place again.";
	public var author:String = "Julian Paolo Thiry (Aedani)";
	public var prefsVersion:Number = 1;

	public function Fix4K() {
	}

	public function onLoad() : Void {
		super.onLoad();
		
		skillHiveMonitor = DistributedValue.Create("skillhive_window");
		skillHiveMonitor.SignalChanged.Connect(apply, this);
	}
	
	public function apply() : Void {
		stopWaitFor();

		if ( enabled && skillHiveMonitor.GetValue() ) {
			waitForId = WaitFor.start( waitForSkillHive, 10, 2000, Delegate.create(this, fixSkillHive) );
		}
	}

	private function waitForSkillHive() : Boolean {
		return _root.skillhive.i_SkillhiveBackground.i_Background;
	}
	
	public function stopWaitFor() : Void {
		WaitFor.stop( waitForId );
		waitForId = undefined;
	}
	
	public function onModuleDeactivated() : Void {
		stopWaitFor();
	}
	
	private function fixSkillHive() : Void {
		stopWaitFor();

		var window = _root.skillhive.i_SkillhiveBackground.i_Background;
		var screenWidth:Number = Stage["visibleRect"].width;
		var backgroundWidth:Number = window._width;
		window._width = screenWidth;
		window._x -= (screenWidth - backgroundWidth) / 2;
	}

	public function revert() : Void {
		stopWaitFor();
		
		var window = _root.skillhive.i_SkillhiveBackground.i_Background;
		if (window != undefined) {
			window._width = 2500;
			window._x = 0;
		}
	}
	
	private function prefChangeHandler( name:String, newValue, oldValue ) : Void {
		switch ( name ) {
			case "plugin.enabled":
				//Disable the message box that fails at 4K resolution, preventing the allocation of skill points.
				if (newValue) DistributedValue.SetDValue("ShowSkillWarning", false);
			break;
		}
	}

	/**
	 * internal variables
	 */
	
	private var waitForId:Number;
	private var skillHiveMonitor:DistributedValue;

}