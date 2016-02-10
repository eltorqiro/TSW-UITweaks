import com.Utils.Archive;
import com.Utils.GlobalSignal;

import com.Utils.Signal;
import GUIFramework.ClipNode;
import GUIFramework.SFClipLoader;
import com.GameInterface.LoreBase;
import com.GameInterface.Game.Character;
import com.GameInterface.DistributedValue;
import com.GameInterface.WaypointInterface;

import com.GameInterface.UtilsBase;
import com.GameInterface.LogBase;

import com.ElTorqiro.UITweaks.Const;
import com.ElTorqiro.UITweaks.AddonUtils.CommonUtils;
import com.ElTorqiro.UITweaks.AddonUtils.Preferences;
import com.ElTorqiro.UITweaks.AddonUtils.VTIOConnector;

import com.ElTorqiro.UITweaks.AddonUtils.MovieClipHelper;

import com.ElTorqiro.UITweaks.Plugins.Plugin;
import com.ElTorqiro.UITweaks.Plugins.AbilityBarFX.AbilityBarFX;
import com.ElTorqiro.UITweaks.Plugins.CharacterSheetZoom.CharacterSheetZoom;
import com.ElTorqiro.UITweaks.Plugins.HudBackgroundRemoval.HudBackgroundRemoval;
import com.ElTorqiro.UITweaks.Plugins.ResizeStates.ResizeStates;
import com.ElTorqiro.UITweaks.Plugins.Inspecto.Inspecto;
import com.ElTorqiro.UITweaks.Plugins.BagLock.BagLock;
import me.jupath.tsw.UITweaks.Fix4K.Fix4K;
import me.jupath.tsw.UITweaks.Resizer.Resizer;
import com.ElTorqiro.UITweaks.Plugins.BooDecksFocusFix.BooDecksFocusFix;
import com.ElTorqiro.UITweaks.Plugins.MembershipFilter.MembershipFilter;

/**
 * 
 * 
 */
class com.ElTorqiro.UITweaks.App {
	
	// static class only
	private function App() { }
	
	// starts the app running
	public static function start( host:MovieClip ) {

		if ( running ) return;
		_running = true;
		
		debug( "App: start" );
		
		hostMovie = host;
		hostMovie._visible = false;

		// create plugin instances
		plugins = [
			new AbilityBarFX(),
			new CharacterSheetZoom(),
			new HudBackgroundRemoval(),
			new ResizeStates(),
			new Inspecto(),
			new BagLock(),
			new Fix4K(),
			new Resizer(),
			new BooDecksFocusFix(),
			new MembershipFilter()
		];
		plugins.sortOn( 'name', Array.CASEINSENSITIVE );
		
		// load preferences
		prefs = new Preferences( Const.PrefsName );
		createPrefs();
		prefs.load();

		// perform initial installation tasks
		install();
		
		// attach app icon
		_isRegisteredWithVtio = false;
		iconClip = SFClipLoader.LoadClip( Const.IconClipPath, Const.AppID + "_Icon", false, Const.IconClipDepthLayer, Const.IconClipSubDepth, [] );
		iconClip.SignalLoaded.Connect( iconLoaded );
	
		// prepare for config window signal
		showConfigWindowMonitor = DistributedValue.Create( Const.ShowConfigWindowDV );
		
		// listen for pref changes and route to appropriate behaviour
		prefs.SignalValueChanged.Connect( prefChangeHandler );
		
		// load plugin prefs
		for ( var s:String in plugins ) {
			var plugin:Plugin = plugins[s];
			
			debug( "loading plugin: " + plugin.id);
			
			plugin.prefs.apply( prefs.getVal( "plugins." + plugin.id ) );
			plugin.onLoad();
		}

	}

	/**
	 * stop app running and clean up resources
	 */
	public static function stop() : Void {
		
		debug( "App: stop" );

		// stop listening for pref value changes
		prefs.SignalValueChanged.Disconnect( prefChangeHandler );
		
		// release resources for config window signal
		showConfigWindowMonitor = null;
		
		// unload icon
		SFClipLoader.UnloadClip( Const.AppID + "_Icon" );
		iconClip = null;
		
		// dispose plugins
		for ( var s:String in plugins ) {
			plugins[s].dispose();
		}
		plugins = null;
		
		// remove prefs
		prefs.dispose();
		prefs = null;
		
		_running = false;

	}
	
	/**
	 * make the app active
	 * - typically called by OnModuleActivated in the module
	 */
	public static function activate() : Void {
		
		debug( "App: activate" );
		
		_active = true;
		
		// component clip visibility
		iconClip.m_Movie._visible = true;

		// manage config window
		showConfigWindowMonitor.SignalChanged.Connect( manageConfigWindow );
		manageConfigWindow();
		
		// activate plugins
		for ( var s:String in plugins ) {
			var plugin:Plugin = plugins[s];
			
			if ( plugin.enabled ) {
				debug( "App: activate: " + plugin.id );
				plugin.onModuleActivated();
			}
		}
	}

	/**
	 * make the app inactive
	 * - typically called by OnModuleDeactivated in the module
	 */
	public static function deactivate() : Void {
		
		debug( "App: deactivate" );
		
		_active = false;

		// deactivate plugins
		for ( var s:String in plugins ) {
			var plugin:Plugin = plugins[s];
			
			if ( plugin.enabled ) {
				debug( "App: deactivate: " + plugin.id );
				plugin.onModuleDeactivated();
			}

			// save plugin prefs
			plugin.onSave();
			prefs.setVal( "plugins." + plugins[s].id, plugin.prefs.serialise() );
		}

		// destroy config window
		showConfigWindowMonitor.SetValue ( false );
		showConfigWindowMonitor.SignalChanged.Disconnect( manageConfigWindow );

		// component clip visibility
		iconClip.m_Movie._visible = false;
		
		// save settings
		prefs.save();
	}

	/**
	 * populate pref object with app entries
	 */
	private static function createPrefs() : Void  {
		
		prefs.add( "prefs.version", Const.PrefsVersion );
		
		prefs.add( "app.installed", false );
		
		prefs.add( "configWindow.position", undefined );
		
		prefs.add( "configWindow.lastSelectedPluginIndex", undefined );
		
		prefs.add( "icon.position", undefined );
		prefs.add( "icon.scale", 100,
			function( newValue, oldValue ) {
				var value:Number = Math.min( newValue, Const.MaxIconScale );
				value = Math.max( value, Const.MinIconScale );
				
				return value;
			}
		);
		
		prefs.add( "app.enabled", true );

		// plugin preference blobs
		for ( var s:String in plugins ) {
			prefs.add( "plugins." + plugins[s].id, new Archive() );
		}

	}

	/**
	 * handle pref value changes and route to appropriate behaviour
	 * 
	 * @param	name
	 * @param	newValue
	 * @param	oldValue
	 */
	private static function prefChangeHandler( name:String, newValue, oldValue ) : Void {
		
		switch ( name ) {
			
			case "app.enabled":
				
			break;
				
		}
		
	}
	
	/**
	 * triggers updates that need to occur after the icon clip has been loaded
	 * 
	 * @param	clipNode
	 * @param	success
	 */
	private static function iconLoaded( clipNode:ClipNode, success:Boolean ) : Void {
		debug("App: icon loaded: " + success);
		
		vtio = new VTIOConnector( Const.AppID, Const.AppAuthor, Const.AppVersion, Const.ShowConfigWindowDV, iconClip.m_Movie.m_Icon, registeredWithVTIO );
	}

	/**
	 * triggers updates that need to occur after the app has been registered with VTIO
	 * e.g. updating the state of the icon copy that VTIO creates
	 */
	private static function registeredWithVTIO() : Void {

		debug( "App: registered with VTIO" );
		
		// move clip to the depth required by VTIO icons
		SFClipLoader.SetClipLayer( SFClipLoader.GetClipIndex( iconClip.m_Movie ), VTIOConnector.e_VtioDepthLayer, VTIOConnector.e_VtioSubDepth );
		
		_isRegisteredWithVtio = true;
		vtio = null;
	}
	
	/**
	 * shows or hides the config window
	 * 
	 * @param	show
	 */
	public static function manageConfigWindow() : Void {
		debug( "App: manageConfigWindow" );
		
		if ( active && showConfigWindowMonitor.GetValue() ) {
			
			if ( !configWindowClip ) {
				debug("App: loading config window");
				configWindowClip = SFClipLoader.LoadClip( Const.ConfigWindowClipPath, Const.AppID + "_ConfigWindow", false, _global.Enums.ViewLayer.e_ViewLayerTop, 0, [] );
			}
		}
		
		else if ( configWindowClip ) {
			SFClipLoader.UnloadClip( Const.AppID + "_ConfigWindow" );
			configWindowClip = null;
			
			debug("App: config window clip unloaded");

		}
	}

	/**
	 * performs initial installation tasks
	 */
	private static function install() : Void {
		
		// only "install" once ever
		if ( !prefs.getVal( "app.installed" ) ) {;
			prefs.setVal( "app.installed", true );
		}
		
		
		// handle upgrades from one version to the next
		var prefsVersion:Number = prefs.getVal( "prefs.version" );
		
		// set prefs version to current version
		prefs.reset( "prefs.version" );
	}

	/**
	 * prints a message to the chat window if debug is enabled
	 * 
	 * @param	msg
	 */
	public static function debug( msg:String ) : Void {
		if ( !debugEnabled ) return;
		
		var message:String = Const.AppID + ": " + msg;
		
		UtilsBase.PrintChatText( message );
		LogBase.Print( 3, Const.AppID, message );
	}
	
	/*
	 * internal variables
	 */
	 
	private static var hostMovie:MovieClip;
	private static var iconClip:ClipNode;
	private static var configWindowClip:ClipNode;
	
	private static var showConfigWindowMonitor:DistributedValue;
	
	private static var vtio:VTIOConnector;
	
	/*
	 * properties
	 */

	public static var plugins:Array;
	 
	public static function get debugEnabled() : Boolean {
		return Boolean(DistributedValue.GetDValue( Const.DebugModeDV ));
	};
	
	public static var prefs:Preferences;

	private static var _active:Boolean;
	public static function get active() : Boolean { return _active; }

	private static var _running:Boolean;
	public static function get running() : Boolean { return Boolean(_running); }
	
	private static var _guiEditMode:Boolean;
	public static function get guiEditMode() : Boolean { return _guiEditMode; }
	
	private static var _isRegisteredWithVtio:Boolean;
	public static function get isRegisteredWithVtio() : Boolean { return _isRegisteredWithVtio; }
	
}