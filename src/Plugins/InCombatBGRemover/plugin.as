import com.Utils.Archive;
import com.GameInterface.UtilsBase;
import com.ElTorqiro.UITweaks.Plugins.InCombatBGRemover.InCombatBGRemover;

var remover:InCombatBGRemover;

function onLoad():Void {
	remover = new InCombatBGRemover();
}

function onPluginActivated(settings:Archive):Void {
	
	remover.Activate();
	
	if( settings != undefined ) {
		remover.waitTime = settings.FindEntry('WaitTime');
	}
}

function onPluginDeactivated():Archive {
	remover.Deactivate();
	
	var settings:Archive = new Archive();
	settings.AddEntry( 'WaitTime', remover.removerReDraw );
	return settings;
}

function getPluginConfiguration():Object {

	return {
	  elements: [
		{ type: 'slider', label: 'Redraw Wait Time ( MS )', min: 100, max: 1000, initial: remover.waitTime, snap: 1, data: { },
		onChange: { context: this, fn: function(value:Number, data:Object) {
		remover.waitTime = value;
		}}
		}
	  ]
	};
}