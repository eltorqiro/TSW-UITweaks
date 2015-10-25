
import com.ElTorqiro.UITweaks.AddonUtils.Preferences;


/**
 * 
 * 
 */
class com.ElTorqiro.UITweaks.Plugins.Plugin {

	/**
	 * these properties must be set in the plugin or the constructor
	 * -----------------------
	 */
	public var id:String;
	public var name:String;
	public var description:String;
	public var author:String;
	public var prefsVersion:Number;
	/**
	 * -----------------------
	 */
	
	public function Plugin() {
		
		prefs = new Preferences();
		
		prefs.add( "plugin.installed", false );
		prefs.add( "prefs.version", prefsVersion );
		prefs.add( "plugin.enabled", false );
		
	}

	/**
	 * called in onLoad to perform initial install tasks, only run when plugin is first installed
	 */
	private function install() : Void {	}

	/**
	 * called in onLoad to perform upgrade tasks from one version to the next
	 */
	private function upgrade() : Void {	}
	
	/**
	 * called after the preference values have been loaded in by the module
	 */
	public function onLoad() : Void {
		
		// only "install" once ever
		if ( !prefs.getVal( "plugin.installed" ) ) {;
			prefs.setVal( "plugin.installed", true );
			install();
		}

		// perform upgrade tasks
		upgrade();
		prefs.reset( "prefs.version" );
		
		// listen for plugin enabled toggle
		prefs.SignalValueChanged.Connect( pluginEnabledHandler, this );
		
		// general listener for other plugins, should be overridden by plugin implementation
		prefs.SignalValueChanged.Connect( prefChangeHandler, this );
	}
	
	/**
	 * handle pref value change for the plugin.enabled meta-pref
	 * 
	 * @param	name
	 * @param	newValue
	 * @param	oldValue
	 */
	private function pluginEnabledHandler( name:String, newValue, oldValue ) : Void {
		if ( name == "plugin.enabled" ) {
			newValue ? apply() : revert();
		}
	}

	/**
	 * handle pref value changes for the plugin
	 * 
	 * @param	name
	 * @param	newValue
	 * @param	oldValue
	 */
	private function prefChangeHandler( name:String, newValue, oldValue ) : Void { }
	
	/**
	 * called immediately prior to the module saving the pref values for the plugin to disk
	 * can be used to update any values that need last minute updates
	 */
	public function onSave() : Void { }
	
	/**
	 * called when the host module is activated via OnModuleActivated, such as after a teleport etc
	 * - only called if the plugin is enabled
	 * - by default, will call apply() if the plugin is enabled; override if this behaviour is not wanted
	 */
	public function onModuleActivated() : Void {
		apply();
	}
	
	/**
	 * called when the host module is deactivated via OnModuleDeactivated, such as before a teleport etc
	 * - only called if the plugin is enabled
	 * - should not call revert() unless specifically necessary for the plugin to clean up resources, as most tweaked clips will be destroyed by the UI at this point
	 */
	public function onModuleDeactivated() : Void { }

	/**
	 * called when the plugin needs to trigger its effects, such as when being enabled or when the game UI activates after zoning
	 */
	public function apply() : Void { }
	
	/**
	 * called to stop the plugin applying its effects, typically when a user sets the plugin disabled
	 */
	public function revert() : Void { }
	
	/**
	 * implement if the plugin provides a configuration panel interface for users
	 * - returns an array of elements, as used by a PanelBuilder object
	 * 
	 * @return the layout portion of a config panel builder definition
	 */
	public function getConfigPanelLayout() : Array { return undefined; }
	
	/**
	 * called when the plugin is being destroyed, to free up resources cleanly
	 */
	public function dispose():Void {
		prefs.dispose();
		prefs = null;
	}

	
	/**
	 * properties
	 */

	public var prefs:Preferences;
	 
	public function get enabled() : Boolean { return prefs.getVal( "plugin.enabled" ); }
	public function set enabled( value:Boolean ) : Void {
		if ( prefs.getVal( "plugin.enabled" ) != value ) {
			prefs.setVal( "plugin.enabled", Boolean(value) );
		}
	}
}