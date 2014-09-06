import com.Utils.Archive;
import com.GameInterface.UtilsBase;
import com.ElTorqiro.UITweaks.Plugins.CharacterSheetZoom.CharacterSheetZoom;

var zoomControl:CharacterSheetZoom;

function onLoad():Void {
	zoomControl = new CharacterSheetZoom();
}

function onPluginActivated(settings:Archive):Void {
	if( settings != undefined ) {
		zoomControl.scale = settings.FindEntry( 'scale' );
		zoomControl.hideFadeLines = settings.FindEntry( 'hideFadeLines' );
	}
	
	zoomControl.Suppress();
}

function onPluginDeactivated():Archive {
	zoomControl.Restore();
	
	var settings:Archive = new Archive();
	settings.AddEntry( 'scale', zoomControl.scale );
	settings.AddEntry( 'hideFadeLines', zoomControl.hideFadeLines );

	return settings;
}

function getPluginConfiguration():Object {

	return {
		elements: [
			{ type: 'checkbox', label: 'Hide fade lines', data: { }, initial: zoomControl.hideFadeLines,
				onChange: { context: this, fn: function(state:Boolean, data:Object) {
					zoomControl.hideFadeLines = state;
				}}
			},
			{ type: 'slider', label: 'Sheet scale', min: 25, max: 150, initial: zoomControl.scale, snap: 1, data: { },
				onChange: { context: this, fn: function(value:Number, data:Object) {
					zoomControl.scale = value;
				}}
			}
		]
	};
}