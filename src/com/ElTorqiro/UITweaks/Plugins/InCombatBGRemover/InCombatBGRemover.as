import com.ElTorqiro.UITweaks.Plugins.PluginBase;
import com.ElTorqiro.UITweaks.PluginWrapper;
import com.Utils.HUDController;
import flash.geom.Point;
import mx.utils.Delegate;


class com.ElTorqiro.UITweaks.Plugins.InCombatBGRemover.InCombatBGRemover extends PluginBase {
	
	private var _findTargetThrashCount:Number = 0;
	
	private var _originalPosition:Point;
	private var _hudBackgroundRegistered:MovieClip;
	
	public function TargetOfTarget(wrapper:PluginWrapper) {
		super(wrapper);
	}

	private function Activate() {
		super.Activate();
		_global.setTimeout( Delegate.create(this, FindInCombatIndicator), 1000 );
	}

	private function Deactivate() {
		super.Deactivate();
		
		_root.combatbackground.i_CombatBackground._y = _originalPosition.y;
		
		if( _hudBackgroundRegistered ) HUDController.RegisterModule( 'HUDBackground', _hudBackgroundRegistered );
	}
	
	private function FindInCombatIndicator():Void {

		if ( _root.combatbackground == undefined ) {
			if (_findTargetThrashCount++ == 30) _findTargetThrashCount = 0;
			else _global.setTimeout( Delegate.create(this, FindInCombatIndicator), 10);
			return;
		}
		_findTargetThrashCount = 0;

		var hudBackground:MovieClip = _root.combatbackground;
		
		/*
		 * unregister module from Funcom's HUDController
		 * no more Layout() will occur on the HUDBackground, such as when resolution or scale changes
		 * or when the user changes the HUD scale slider in the options
		 */
		
		_hudBackgroundRegistered = HUDController.GetModule( 'HUDBackground' );
    
		if ( _hudBackgroundRegistered != hudBackground ) return;
		HUDController.DeregisterModule( 'HUDBackground' );

		var position:Point = new Point( hudBackground.i_CombatBackground._x, hudBackground.i_CombatBackground._y );
		_originalPosition = new Point( hudBackground.i_CombatBackground._x, hudBackground.i_CombatBackground._y );
		
		hudBackground.localToGlobal( position );
		hudBackground._y += 500;
		hudBackground.globalToLocal( position );
		hudBackground.i_CombatBackground._y = position.y;
	}

}