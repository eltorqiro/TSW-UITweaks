import com.Utils.Archive;
import com.GameInterface.UtilsBase;
import com.ElTorqiro.UITweaks.Plugins.MobileHUD.MobileHUD;

var mobileHUD:MobileHUD;

function onLoad():Void {
	mobileHUD = new MobileHUD();
}

function onPluginActivated(settings:Archive):Void {
	//deFX.hideReflections = settings.FindEntry( 'hideReflections' );
	//deFX.hideGloss = settings.FindEntry( 'hideGloss' );
	
	mobileHUD.Activate();
}

function onPluginDeactivated():Archive {
	mobileHUD.Deactivate();
	
	var settings:Archive = new Archive();
	//settings.AddEntry( 'hideReflections', deFX.hideReflections );
	//settings.AddEntry( 'hideGloss', deFX.hideGloss );

	return settings;
}

function getPluginConfiguration():Object {

	return {
		onOpen: { context: this, fn: function() {
			mobileHUD.ConfigOverlay( true );
		}},
		
		onClose: { context: this, fn: function() {
			mobileHUD.ConfigOverlay( false );
		}},
		
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