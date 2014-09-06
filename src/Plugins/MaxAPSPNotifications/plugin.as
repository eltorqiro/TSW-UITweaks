import com.Utils.Archive;
import com.GameInterface.UtilsBase;
import com.ElTorqiro.UITweaks.Plugins.MaxAPSPNotifications.MaxAPSPNotifications;

var suppressMax:MaxAPSPNotifications;

function onLoad():Void {
	suppressMax = new MaxAPSPNotifications();
}

function onPluginActivated(settings:Archive):Void {
	suppressMax.suppressMaxAP = settings.FindEntry( 'suppressMaxAP' );
	suppressMax.suppressMaxSP = settings.FindEntry( 'suppressMaxSP' );
	
	suppressMax.Suppress();
}

function onPluginDeactivated():Archive {
	suppressMax.Restore();
	
	var settings:Archive = new Archive();
	settings.AddEntry( 'suppressMaxAP', suppressMax.suppressMaxAP );
	settings.AddEntry( 'suppressMaxSP', suppressMax.suppressMaxSP );

	return settings;
}

function getPluginConfiguration():Object {

	return {
		elements: [
			{ type: 'checkbox', label: 'Suppress max AP', data: { }, initial: suppressMax.suppressMaxAP,
				onChange: { context: this, fn: function(state:Boolean, data:Object) {
					suppressMax.suppressMaxAP = state;
				}}
			},
			{ type: 'checkbox', label: 'Suppress max SP', data: { }, initial: suppressMax.suppressMaxSP,
				onChange: { context: this, fn: function(state:Boolean, data:Object) {
					suppressMax.suppressMaxSP = state;
				}}
			}
		]
	};
}