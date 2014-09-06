import com.Utils.Archive;
import com.GameInterface.UtilsBase;
import com.ElTorqiro.UITweaks.Plugins.ResizeAlteredStates.ResizeAlteredStates;

var resizer:ResizeAlteredStates;

function onLoad():Void {
	resizer = new ResizeAlteredStates();
}

function onPluginActivated(settings:Archive):Void {
	if( settings != undefined ) {
		resizer.scale = settings.FindEntry( 'scale' );
		resizer.hide = settings.FindEntry( 'hide' );
	}
	
	resizer.ResizeHook();
}

function onPluginDeactivated():Archive {
	resizer.Restore();
	
	var settings:Archive = new Archive();
	settings.AddEntry( 'scale', resizer.scale );
	settings.AddEntry( 'hide', resizer.hide );

	return settings;
}

function getPluginConfiguration():Object {

	return {
		elements: [
			{ type: 'checkbox', label: 'Hide states', data: { }, initial: resizer.hide,
				onChange: { context: this, fn: function(state:Boolean, data:Object) {
					resizer.hide = state;
				}}
			},
			{ type: 'slider', label: 'State icon scale', min: 25, max: 150, initial: resizer.scale, snap: 1, data: { },
				onChange: { context: this, fn: function(value:Number, data:Object) {
					resizer.scale = value;
				}}
			}
		]
	};
}