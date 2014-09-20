import com.Utils.Archive;
import com.GameInterface.UtilsBase;
import com.ElTorqiro.UITweaks.Plugins.InspectoPetronum.InspectoPetronum;

var inspecto:InspectoPetronum;

function onLoad():Void {
	inspecto = new InspectoPetronum();
}

function onPluginActivated(settings:Archive):Void {
	inspecto.Activate();

	if( settings != undefined ) {
		inspecto.waitTime = settings.FindEntry('WaitTime');
	}

}

function onPluginDeactivated():Archive {
	inspecto.Deactivate();
	
	var settings:Archive = new Archive();
	settings.AddEntry( 'WaitTime', inspecto.inspectReDraw );
	return settings;
}

function getPluginConfiguration():Object {

	return {
	elements: [
		{ type: 'slider', label: 'Redraw Wait Time ( MS )', min: 1, max: 1000, initial: inspecto.waitTime, snap: 1, data: { },
			onChange: { context: this, fn: function(value:Number, data:Object) {
				inspecto.waitTime = value;
			}}
		}
	]
};
}