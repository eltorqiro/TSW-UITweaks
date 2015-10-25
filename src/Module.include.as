import com.ElTorqiro.UITweaks.App;

/**
 * standard MovieClip onLoad event handler
 */
function onLoad() : Void {
	App.debug("Module: onLoad");

	// start app running
	App.start( this );
}

/**
 * TSW GUI event, called when the module is activated by the game
 */
function OnModuleActivated() : Void {
	App.debug("Module: OnModuleActivated");
	
	// activate app
	App.activate();
}

/**
 * TSW GUI event, called when the module is deactivated by the game
 */
function OnModuleDeactivated() : Void {
	App.debug("Module: OnModuleDeactivated");
	
	// deactivate app
	App.deactivate();
}

/**
 * TSW GUI event, called when the game unloads the clip (via SFClipLoader)
 * - this is not the same as the generic AS2 onUnload method
 */
function OnUnload() : Void {
	App.debug("Module: OnUnload");

	// stop app running
	App.stop();
}
