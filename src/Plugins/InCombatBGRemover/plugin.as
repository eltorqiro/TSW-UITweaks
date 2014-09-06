import com.Utils.Archive;
import com.GameInterface.UtilsBase;
import com.ElTorqiro.UITweaks.Plugins.InCombatBGRemover.InCombatBGRemover;

var remover:InCombatBGRemover;

function onLoad():Void {
	remover = new InCombatBGRemover();
}

function onPluginActivated(settings:Archive):Void {
	
	remover.Activate();
}

function onPluginDeactivated():Archive {
	remover.Deactivate();
	
	return undefined;
}

function getPluginConfiguration():Object {

	return undefined;
}