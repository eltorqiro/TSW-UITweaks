import com.Utils.Archive;
import com.GameInterface.UtilsBase;
import com.ElTorqiro.UITweaks.Plugins.Resizer.Resizer;

var resizerControl:Resizer;

function onLoad():Void {
	resizerControl = new Resizer();
}

function onPluginActivated(settings:Archive):Void {
	if( settings != undefined ) {
		resizerControl.missionReward = settings.FindEntry( 'missionReward' );
		resizerControl.missionJournal = settings.FindEntry( 'missionJournal' );
		resizerControl.friends = settings.FindEntry( 'friends' );
		resizerControl.pets = settings.FindEntry( 'pets' );
		resizerControl.social = settings.FindEntry( 'social' );
		resizerControl.deliveredItems = settings.FindEntry( 'deliveredItems' );
		resizerControl.lockoutTimers = settings.FindEntry( 'lockoutTimers' );
		resizerControl.challengeJournal = settings.FindEntry( 'challengeJournal' );
		resizerControl.shop = settings.FindEntry( 'shop' );
	}
	
	resizerControl.Activate();
}

function onPluginDeactivated():Archive {
	resizerControl.Deactivate();
	
	var settings:Archive = new Archive();
	settings.AddEntry( 'missionReward', resizerControl.missionReward );
	settings.AddEntry( 'missionJournal', resizerControl.missionJournal );
	settings.AddEntry( 'friends', resizerControl.friends );
	settings.AddEntry( 'pets', resizerControl.pets );
	settings.AddEntry( 'social', resizerControl.social );
	settings.AddEntry( 'deliveredItems', resizerControl.deliveredItems );
	settings.AddEntry( 'lockoutTimers', resizerControl.lockoutTimers );
	settings.AddEntry( 'challengeJournal', resizerControl.challengeJournal );
	settings.AddEntry( 'shop', resizerControl.shop );

	return settings;
}

function getPluginConfiguration():Object {

	return {
		elements: [
			{ type: 'slider', label: 'Challenge Journal Scale', min: 50, max: 200, initial: resizerControl.challengeJournal, snap: 1, data: { },
				onChange: { context: this, fn: function(value:Number, data:Object) {
					resizerControl.challengeJournal = value;
				}}
			},
			{ type: 'slider', label: 'Delivered Items Scale', min: 50, max: 200, initial: resizerControl.deliveredItems, snap: 1, data: { },
				onChange: { context: this, fn: function(value:Number, data:Object) {
					resizerControl.deliveredItems = value;
				}}
			},
			{ type: 'slider', label: 'Friends/Cabal Window Scale', min: 50, max: 200, initial: resizerControl.friends, snap: 1, data: { },
				onChange: { context: this, fn: function(value:Number, data:Object) {
					resizerControl.friends = value;
				}}
			},
			{ type: 'slider', label: 'Lockout Timers Scale', min: 50, max: 200, initial: resizerControl.lockoutTimers, snap: 1, data: { },
				onChange: { context: this, fn: function(value:Number, data:Object) {
					resizerControl.lockoutTimers = value;
				}}
			},
			{ type: 'slider', label: 'Mission Journal Scale', min: 50, max: 200, initial: resizerControl.missionJournal, snap: 1, data: { },
				onChange: { context: this, fn: function(value:Number, data:Object) {
					resizerControl.missionJournal = value;
				}}
			},
			{ type: 'slider', label: 'Mission Reward Scale', min: 50, max: 200, initial: resizerControl.missionReward, snap: 1, data: { },
				onChange: { context: this, fn: function(value:Number, data:Object) {
					resizerControl.missionReward = value;
				}}
			},
			{ type: 'slider', label: 'Pets/Sprints Scale', min: 50, max: 200, initial: resizerControl.pets, snap: 1, data: { },
				onChange: { context: this, fn: function(value:Number, data:Object) {
					resizerControl.pets = value;
				}}
			},
			{ type: 'slider', label: 'Social Window Scale', min: 50, max: 200, initial: resizerControl.social, snap: 1, data: { },
				onChange: { context: this, fn: function(value:Number, data:Object) {
					resizerControl.social = value;
				}}
			},
			{ type: 'slider', label: 'Vendor Scale', min: 50, max: 200, initial: resizerControl.shop, snap: 1, data: { },
				onChange: { context: this, fn: function(value:Number, data:Object) {
					resizerControl.shop = value;
				}}
			}
		]
	};
}

