import com.GameInterface.UtilsBase;
import com.ElTorqiro.UITweaks.Plugins.PluginBase;
import flash.geom.Point;
import mx.utils.Delegate;
import com.Utils.HUDController;
import com.ElTorqiro.UITweaks.AddonUtils.AddonUtils;
import com.GameInterface.DistributedValue;
import flash.filters.GlowFilter;
import com.GameInterface.Tooltip.TooltipUtils;
import com.GameInterface.Tooltip.TooltipInterface;


class com.ElTorqiro.UITweaks.Plugins.MoveAnyHUD extends com.ElTorqiro.UITweaks.Plugins.PluginBase {

	private var _modules:Object = { };
	private var _configLayer:MovieClip;
	
	public function MoveAnyHUD() {
		super();
		
		_modules['HUDBackground'] = { };
		_modules['AbilityBar'] = { };
		_modules['AAPassivesBar'] = { };
		_modules['SprintBar'] = { };
		//_modules['AbilityList'] = { };
		//_modules['PassivesList'] = { };
		_modules['PlayerInfo'] = { };
		_modules['TargetInfo'] = { };
		_modules['PlayerCastBar'] = { };
		_modules['TargetCastBar'] = { };
		_modules['DodgeBar'] = { };
		_modules['FIFO'] = { };
		//_modules['DamageInfo'] = { };
		//_modules['FriendlyMenu'] = { };
		_modules['HUDXPBar'] = { };
		_modules['MissionTracker'] = { };
		_modules['Compass'] = { };
		_modules['PvPMiniScoreView'] = { };
		//_modules['LatencyWindow'] = { };
		_modules['AnimaWheelLink'] = { };
		_modules['SignUpNotifications'] = { };
		//_modules['AchievementLoreWindow'] = { };
		//_modules['WalletController'] = { };
		
	}

	private function Activate() {
		super.Activate();
		
		_global.setTimeout( Delegate.create(this, HookClips), 2000, true );
		
		//_root._alpha = 50;
	}

	private function Deactivate() {
		super.Deactivate();

		ConfigClips( false );
		
		for ( var s:String in _modules ) {
			if( _modules[s].hijacked ) {
				HUDController.RegisterModule( s, _modules[s].mc );
				
				_modules[s] = { };
			}
		}
	}

	private function LayoutClips():Void {
		//UtilsBase.PrintChatText( 'b:' + _dirty );
	}
	
	private function ConfigClips(show:Boolean):Void {
		
		if ( _configLayer ) _configLayer.removeMovieClip();
		if ( !show ) return;

		_configLayer = _root.createEmptyMovieClip( 'm_UITweaks_ConfigClipsProxy', _root.getNextHighestDepth() );
		
		for ( var s:String in _modules ) {
			
			var mc:MovieClip = _modules[s].mc;
			var box:MovieClip = _configLayer.createEmptyMovieClip( _modules[s].name, _configLayer.getNextHighestDepth() );

			var bounds:Object = mc.getBounds( box._parent );
			box._x = bounds.xMin;
			box._y = bounds.yMin;
			
			box.lineStyle( 2, 0x0099ff, 100 );
			box.beginFill( 0x0099ff, 20 );
			AddonUtils.DrawRectangle( box, 0, 0, mc._width, mc._height, 6, 6, 6, 6);
			box.endFill();
			
			box.mc = mc;
			
			TooltipUtils.AddTextTooltip(box, s, 200, TooltipInterface.e_OrientationHorizontal, true, false);
			
			box.onPress = function() {
				this.filters = [ new GlowFilter(0x0099ff, 0.8, 16, 16, 2, 3, false, false) ];
				this.prevX = this._x;
				this.prevY = this._y;

				this.onMouseMove = function() {
					this.mc._x += this._x - this.prevX;
					this.mc._y += this._y - this.prevY;
					
					this.prevX = this._x;
					this.prevY = this._y;
				};
				
				this.startDrag();
			};
			
			box.onRelease = box.onReleaseOutside = function() {
				this.stopDrag();
				this.onMouseMove = undefined;
				this.filters = [];
			};
			
			//box.onRollOver = function() {
				// TODO: tooltip the name of the module
				
			//};
		}
		
	}
	
	private function HookClips():Void {
		
		for ( var s:String in _modules ) {
			_modules[s] = {
				name: s,
				mc: HUDController.GetModule( s ),
				hijacked: true
			};

			HUDController.DeregisterModule( s );
		}
		
		ConfigClips( true );
	}
}