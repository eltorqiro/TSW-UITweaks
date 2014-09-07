import com.GameInterface.UtilsBase;
import flash.geom.Point;
import mx.utils.Delegate;
import com.Utils.HUDController;
import com.ElTorqiro.UITweaks.AddonUtils.AddonUtils;
import com.GameInterface.DistributedValue;
import flash.filters.GlowFilter;
import com.GameInterface.Tooltip.TooltipUtils;
import com.GameInterface.Tooltip.TooltipInterface;


class com.ElTorqiro.UITweaks.Plugins.MobileHUD.MobileHUD {

	private var _modules:Object = { };
	private var _overlayLayer:MovieClip;
	
	private var _hooked:Boolean;
	
	private var _overlayColour:Number = 0x0099ff;
	private var _overlayBoxMinSize:Number = 12;
	

	public function MobileHUD() {
		
		//_modules['HUDBackground'] = { };
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

	public function Activate() {
		//_global.setTimeout( Delegate.create(this, HookClips), 2000, true );
		HookClips();
	}

	public function Deactivate() {

		ConfigOverlay( false );
		
		for ( var s:String in _modules ) {
			if( _modules[s].hijacked ) {
				HUDController.RegisterModule( s, _modules[s].mc );
				
				_modules[s] = { };
			}
		}
		
		_hooked = false;
	}

	private function LayoutClips():Void {
		//UtilsBase.PrintChatText( 'b:' + _dirty );
	}
	
	public function ConfigOverlay(show:Boolean):Void {
		
		if ( _overlayLayer ) _overlayLayer.removeMovieClip();
		if ( !show ) return;

		_overlayLayer = _root.createEmptyMovieClip( 'm_UITweaks_ConfigOverlay', _root.getNextHighestDepth() );

		// show info panel briefly if clips aren't hooked
		if ( !_hooked ) {
			
			
			_global.setTimeout( Delegate.create(this, ConfigOverlay), 2000, show );
			return;
		}
		
		for ( var s:String in _modules ) {
			
			var mc:MovieClip = _modules[s].mc;
			var box:MovieClip = _overlayLayer.createEmptyMovieClip( _modules[s].name, _overlayLayer.getNextHighestDepth() );

			var bounds:Object = mc.getBounds( box._parent );
			box._x = bounds.xMin;
			box._y = bounds.yMin;
			
			var width:Number = Math.max( bounds.xMax - bounds.xMin, _overlayBoxMinSize );
			var height:Number = Math.max( bounds.yMax - bounds.yMin, _overlayBoxMinSize );
			
			box.lineStyle( 2, _overlayColour, 100 );
			box.beginFill( _overlayColour, 20 );
			AddonUtils.DrawRectangle( box, 0, 0, width, height, 6, 6, 6, 6);
			box.endFill();

			box.filters = [ new GlowFilter(_overlayColour, 0.8, 8, 8, 2, 3, false, false) ];
			box._alpha = 60;
			
			box.mc = mc;
			
			TooltipUtils.AddTextTooltip(box, s, 200, TooltipInterface.e_OrientationVertical, true, false);

			box.onPress = function() {
				this.originalAlpha = this._alpha;
				this._alpha = 30;
				this.prevX = this._x;
				this.prevY = this._y;

				this.onMouseMove = function() {
					this.mc._x += this._x - this.prevX;
					this.mc._y += this._y - this.prevY;
					
					this.prevX = this._x;
					this.prevY = this._y;
				};
				
				this.startDrag(false, Stage.visibleRect.left - this._width + 10, Stage.visibleRect.top - this._height + 10, Stage.visibleRect.right - 10, Stage.visibleRect.bottom - 10);
			};
			
			box.onRelease = box.onReleaseOutside = function() {
				this.stopDrag();
				this.onMouseMove = undefined;
				this._alpha = this.originalAlpha;
			};
			
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
		
		_hooked = true;
	}
	
}