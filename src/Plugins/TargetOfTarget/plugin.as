import com.Utils.Archive;
import com.GameInterface.UtilsBase;
import flash.geom.Point;
import com.ElTorqiro.UITweaks.Plugins.TargetOfTarget.TargetOfTarget;

var targetOfTarget:TargetOfTarget;

function onLoad():Void {
	targetOfTarget = new TargetOfTarget( this );
}

function onPluginActivated(settings:Archive):Void {
	targetOfTarget.showDefTargetWindow = settings.FindEntry( 'showDefTarget' );
	targetOfTarget.showOffTargetWindow = settings.FindEntry( 'showOffTarget' );
	
	targetOfTarget.Activate( settings.FindEntry('offSaveLocation'), settings.FindEntry('defSaveLocation') );
}

function onPluginDeactivated():Archive {
	targetOfTarget.Deactivate();

	var settings:Archive = new Archive();
	
	settings.AddEntry( "offSaveLocation", new Point( targetOfTarget.m_Offensive._x, targetOfTarget.m_Offensive._y));
	settings.AddEntry( "defSaveLocation", new Point( targetOfTarget.m_Defensive._x, targetOfTarget.m_Defensive._y));
	settings.AddEntry( "showDefTarget", targetOfTarget.showDefTargetWindow);
	settings.AddEntry( "showOffTarget", targetOfTarget.showOffTargetWindow);
	
	return settings;
}

function getPluginConfiguration():Object {

	return {
		onOpen: { context: this, fn: function() {
			targetOfTarget.m_Offensive._visible = targetOfTarget.showOffTargetWindow;
			targetOfTarget.m_Defensive._visible = targetOfTarget.showDefTargetWindow;
		}},
		
		onClose: { context: this, fn: function() {
			targetOfTarget.TargetOfTargetDisplay();
		}},
		
		elements: [
			{ type: 'checkbox', label: 'Show Defensive Target of Target', data: { }, initial: targetOfTarget.showDefTargetWindow,
				onChange: { context: this, fn: function(state:Boolean, data:Object) {
					targetOfTarget.showDefTargetWindow = state;
					targetOfTarget.m_Defensive._visible = state;
				}}
			},
			{ type: 'checkbox', label: 'Show Offensive Target of Target', data: { }, initial: targetOfTarget.showOffTargetWindow,
				onChange: { context: this, fn: function(state:Boolean, data:Object) {
					targetOfTarget.showOffTargetWindow = state;
					targetOfTarget.m_Offensive._visible = state;
				}}
			}
		]
	};
}