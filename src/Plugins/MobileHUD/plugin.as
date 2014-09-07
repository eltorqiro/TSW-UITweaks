import com.Utils.Archive;
import com.GameInterface.UtilsBase;
import com.ElTorqiro.UITweaks.Plugins.MobileHUD.MobileHUD;
import com.Utils.Signal;
import flash.geom.Point;

var mobileHUD:MobileHUD;

var SignalPluginReady:Signal = new Signal();

function onLoad():Void {
	mobileHUD = new MobileHUD();
}

function onPluginActivated(settings:Archive):Void {

	for ( var s:String in mobileHUD.modules ) {
		mobileHUD.modules[s].position = settings.FindEntry( s + '_position', undefined );
	}
	
	mobileHUD.Activate();

	SignalPluginReady.Emit( this );
}

function onPluginDeactivated():Archive {

	var settings:Archive = new Archive();
	for ( var s:String in mobileHUD.modules ) {
		var module:Object = mobileHUD.modules[s];
		
		if ( module.hijacked ) {
			settings.AddEntry( s + '_position', new Point(module.mc._x, module.mc._y) );
		}
	}
	
	mobileHUD.Deactivate();
	
	return settings;
}

function getPluginConfiguration():Object {

	return {
		onOpen: { context: this, fn: function() {
			mobileHUD.ConfigOverlay( true );
		}},
		
		onClose: { context: this, fn: function() {
			mobileHUD.ConfigOverlay( false );
		}}
		
	};
}
