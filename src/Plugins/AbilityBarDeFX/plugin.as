import com.Utils.Archive;
import com.GameInterface.UtilsBase;
import com.ElTorqiro.UITweaks.Plugins.AbilityBarDeFX.AbilityBarDeFX;

var deFX:AbilityBarDeFX;

function onLoad():Void {
	deFX = new AbilityBarDeFX();
}

function onPluginActivated(settings:Archive):Void {
	deFX.hideReflections = settings.FindEntry( 'hideReflections' );
	deFX.hideGloss = settings.FindEntry( 'hideGloss' );
	
	deFX.Apply();
}

function onPluginDeactivated():Archive {
	deFX.Restore();
	
	var settings:Archive = new Archive();
	settings.AddEntry( 'hideReflections', deFX.hideReflections );
	settings.AddEntry( 'hideGloss', deFX.hideGloss );

	return settings;
}

function getPluginConfiguration():Object {

	return {
		elements: [
			{ type: 'checkbox', label: 'Remove button reflections', data: { }, initial: deFX.hideReflections,
				onChange: { context: this, fn: function(state:Boolean, data:Object) {
					deFX.hideReflections = state;
				}}
			},
			{ type: 'checkbox', label: 'Hide button gloss effect', data: { }, initial: deFX.hideGloss,
				onChange: { context: this, fn: function(state:Boolean, data:Object) {
					deFX.hideGloss = state;
				}}
			}
		]
	};
}