import com.Utils.Archive;
import com.GameInterface.UtilsBase;
import com.ElTorqiro.UITweaks.Plugins.InspectoPetronum.InspectoPetronum;

var inspecto:InspectoPetronum;

function onLoad():Void {
	inspecto = new InspectoPetronum();
}

function onPluginActivated(settings:Archive):Void {
	inspecto.Activate();
}

function onPluginDeactivated():Archive {
	inspecto.Deactivate();
	
	return undefined;
}

function getPluginConfiguration():Object {

	return undefined;
}