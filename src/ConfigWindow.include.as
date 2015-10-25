import flash.geom.Point;
import com.GameInterface.DistributedValue;

import com.ElTorqiro.UITweaks.Const;
import com.ElTorqiro.UITweaks.App;
import com.ElTorqiro.UITweaks.AddonUtils.UI.Window;

import com.ElTorqiro.UITweaks.AddonUtils.MovieClipHelper;

  
/**
 * standard MovieClip onLoad event handler
 */
function onLoad() : Void {
	App.debug("Config Window: onLoad");
	
	// opening window position
	var position:Point = App.prefs.getVal( "configWindow.position" );
	if ( position == undefined ) {
		position = new Point( 300, 150 );
	}

	var window:Window = Window( MovieClipHelper.attachMovieWithRegister( "eltorqiro.ui.window", Window, "m_Window", this, getNextHighestDepth(), { openingPosition: position } ) );

	// set window properties
	window.SetTitle(Const.AppName + " v" + Const.AppVersion);
	
	window.SignalClose.Connect( this, function() {
		DistributedValue.SetDValue( Const.ShowConfigWindowDV, false );
	});
	
	window.SetContent("com.ElTorqiro.UITweaks.ConfigWindow.WindowContent");
	window.SetSize( 520, 400 );
	
}

/**
 * TSW GUI event, called when the game unloads the clip (via SFClipLoader)
 * - this is not the same as the generic AS2 onUnload method
 */
function OnUnload() : Void {
	App.debug("Config Window: OnUnload");
	
	// save position of config window
	App.prefs.setVal( "configWindow.position", new Point( m_Window._x, m_Window._y ) );
}

/**
 * TSW GUI event, called after the loading of the clip is complete (via SFClipLoader)
 */
function LoadArgumentsReceived( args:Array ) : Void {
	App.debug("Config Window: LoadArgumentsReceived");
}
