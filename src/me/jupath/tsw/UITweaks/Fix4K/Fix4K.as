import com.ElTorqiro.UITweaks.Plugins.Plugin;

import com.GameInterface.DistributedValue;
import gfx.utils.Delegate;

import com.ElTorqiro.UITweaks.AddonUtils.WaitFor;


class me.jupath.tsw.UITweaks.Fix4K.Fix4K extends Plugin {

	// plugin properties
	public var id:String = "fix4K";
	public var name:String = "Fix 4K";
	public var description:String = "Fixes inherent problems with the game at 4K resolution.";
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

		var window = _root.skillhive;
		window.m_DefaultSkillhiveBackgroundWidth = window.i_SkillhiveBackground.i_Background._width = Stage["visibleRect"].width;
		//Would love to know why calling these methods directly does not work, but adding a timeout does....
		setTimeout(Delegate.create(window, window.Layout), 10);
		setTimeout(Delegate.create(window, window.UpdateBackgroundAndBarPositions, true), 10);
	}
	
	private function prefChangeHandler( name:String, newValue, oldValue ) : Void {
		switch ( name ) {
			case "plugin.enabled":
				//Disable the message box that fails at 4K resolution, preventing the allocation of skill points.
				if (newValue) DistributedValue.SetDValue("ShowSkillWarning", false);
			break;
		}
	}

	public function getConfigPanelLayout() : Array {
		return [
			{	type: "text",
				text: "Disables the warning popup that should appear (but fails to) when allocating skills that do not increase your gear level.\n\nFixes the background of the ability wheel so that abilities may be dragged into place again."
			}
		];
	};
	
	/**
	 * internal variables
	 */
	
	private var waitForId:Number;
	private var skillHiveMonitor:DistributedValue;

}