import com.Utils.Archive;
import com.GameInterface.UtilsBase;
import com.ElTorqiro.UITweaks.Plugins.Fix4K.Fix4K;

var fixerControl:Fix4K;

function onLoad():Void {
	fixerControl = new Fix4K();
}

function onPluginActivated(settings:Archive):Void {
	fixerControl.Activate();
}

function onPluginDeactivated():Archive {
	fixerControl.Deactivate();
	return new Archive();
}

function getPluginConfiguration():Object {
	return {
		elements: [
		]
	};
}

