import com.ElTorqiro.UITweaks.App;
import com.ElTorqiro.UITweaks.AppIcon;

import com.ElTorqiro.UITweaks.AddonUtils.MovieClipHelper;


/**
 * standard MovieClip onLoad event handler
 */
function onLoad() : Void {
	App.debug("Icon: onLoad");
	
	var appIcon:AppIcon = AppIcon( MovieClipHelper.createMovieWithClass( AppIcon, "m_Icon", this, this.getNextHighestDepth() ) );
}

/**
 * TSW GUI event, called when the game unloads the clip (via SFClipLoader)
 * - this is not the same as the generic AS2 onUnload method
 */
function OnUnload() : Void {
	App.debug("Icon: OnUnload");
}

/**
 * TSW GUI event, called after the loading of the clip is complete (via SFClipLoader)
 */
function LoadArgumentsReceived( arguments:Array ) : Void {
	App.debug("Icon: LoadArgumentsReceived");
}
