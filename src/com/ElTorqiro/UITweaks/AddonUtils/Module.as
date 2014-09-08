import com.GameInterface.DistributedValue;
import com.GameInterface.Tooltip.TooltipData;
import com.GameInterface.Tooltip.TooltipInterface;
import com.GameInterface.Tooltip.TooltipManager;
import com.Utils.Signal;
import flash.geom.Point;
import GUIFramework.ClipNode;
import GUIFramework.SFClipLoader;
import mx.utils.Delegate;

class com.ElTorqiro.UITweaks.AddonUtils.Module {

	private var _moduleMC:MovieClip;

	private var _name:String;
	private var _author:String;
	private var _version:String;
	private var _dvName:String;
	private var _toggleDV:DistributedValue;
	
	private var _modulePath:String;
	private var _moduleFile:String;

	private var _iconClip:ClipNode;
	private var _iconMC:MovieClip;
	public  var centreScaleIcon:Boolean;
	
	public  var autoRegisterWithVTIO:Boolean;
	private var _isRegisteredWithVTIO:Boolean;
	private var _VTIOLoaded:DistributedValue;
	
	private var _state:String;
	
	private var _tooltip:TooltipInterface;
	
	public var SignalIconAttached:Signal;
	public var SignalRegisteredWithVTIO:Signal;

	
	public function Module( moduleClip:MovieClip, name:String, author:String, version:String, dvName:String ) {

		SignalIconAttached = new Signal();
		SignalRegisteredWithVTIO = new Signal();
		
		_moduleMC = moduleClip;
		_name = name;
		_author = author;
		_version = version;
		_dvName = dvName;
		
		var nodes:Array = unescape(moduleClip._url).split('Data/GUI/Customized/Flash/').join('').split('/');
		_moduleFile = String(nodes.pop());
		_modulePath = nodes.join('/');
		
		_state = 'default';
		centreScaleIcon = true;
		
		autoRegisterWithVTIO = true;
		_VTIOLoaded = DistributedValue.Create( 'VTIO_IsLoaded' );
		
		_toggleDV = DistributedValue.Create( dvName );
	}
	
	public function attachIcon( file:String, position:Point, scale:Number ):Void {
		var iconFile:String = _modulePath + '/' + ( file == undefined ? 'Icon.swf' : file );
		
		_iconClip = SFClipLoader.LoadClip( iconFile, _moduleMC._name + '_icon', false, 3, 2, [{position:position, scale:scale}] );
		_iconClip.SignalLoaded.Connect( iconClipLoaded, this );
	}
	
	public function detachIcon():Void {
		_iconClip.m_Movie.UnloadClip();
	}
	
	private function iconClipLoaded(clipNode, loaded):Void {
		
		_iconMC = _iconClip.m_Movie.m_Icon;
		
		var loadArgumentsObject:Object = _iconClip.m_LoadArguments[0];
		
		iconScale = loadArgumentsObject.scale;
		iconPosition = loadArgumentsObject.position;
		
		_iconMC._x = iconPosition.x;
		_iconMC._y = iconPosition.y;
		
		attachDefaultIconBehaviours();
		
		SignalIconAttached.Emit( this );
		
		if ( autoRegisterWithVTIO ) {
			registerWithVTIO();
		}
	}

	public function attachDefaultIconBehaviours():Void {
		
		_iconMC.onMousePress = Delegate.create( this, function(buttonID) {
			closeTooltip();
			
			// dragging icon with CTRL held down, only if VTIO not present
			if ( !isRegisteredWithVTIO && buttonID == 1 && Key.isDown(Key.CONTROL) ) {
				_iconMC.startDrag(
					false,
					0,
					0,
					Stage.visibleRect.right,
					Stage.visibleRect.bottom
				);
			}
			
			// left mouse click, toggle config window
			else if ( buttonID == 1 ) {
				_toggleDV.SetValue( !_toggleDV.GetValue() );
			}
			
			// reset icon scale, only if VTIO not present
			else if (!isRegisteredWithVTIO && buttonID == 2 && Key.isDown(Key.CONTROL)) {
				iconScale = 100;
			}
		});
		
		// stop dragging icon
		_iconMC.onRelease = _iconMC.onReleaseOutside = Delegate.create( this, function() {
			if ( !isRegisteredWithVTIO )  _iconMC.stopDrag();
		});
		
		// resize icon with CTRL mousewheel
		_iconMC.onMouseWheel = Delegate.create( this, function(delta) {
			closeTooltip();
			
			if ( !isRegisteredWithVTIO && Key.isDown(Key.CONTROL)) {
				// determine scale
				var scaleTo:Number = iconScale + (delta * 5);
				scaleTo = Math.max(scaleTo, 35);
				scaleTo = Math.min(scaleTo, 100);
				iconScale = scaleTo;
			}
		});
		
		// mouse hover, show tooltip
		_iconMC.onRollOver = Delegate.create( this, function() {
			showTooltip();
		});

		// mouse out, hide tooltip
		_iconMC.onRollOut = Delegate.create( this, function() {
			closeTooltip();
		});
	}
	
	public function registerWithVTIO():Boolean {
		// don't re-register
		if ( isRegisteredWithVTIO ) return false;
		
		if ( !isVTIOLOaded ) {
			_VTIOLoaded.SignalChanged.Connect( registerWithVTIO, this );
		}

		// register with VTIO
		DistributedValue.SetDValue( 'VTIO_RegisterAddon', 
			_name + '|' + _author + '|' + _version + '|' + _dvName + '|' + _iconMC
		);
		
		_VTIOLoaded.SignalChanged.Disconnect( registerWithVTIO, this );
		_isRegisteredWithVTIO = true;
		SignalRegisteredWithVTIO.Emit( this );
		
		return true;
	}

	public function showTooltip(tooltipData:TooltipData):Void {

		var data:TooltipData = tooltipData;
		
		if( data == undefined ) {
			data = new com.GameInterface.Tooltip.TooltipData();
			data.AddAttribute("", "<font face=\'_StandardFont\' size=\'14\' color=\'#00ccff\'><b>" + _name + " v" + _version + "</b></font>");
			data.AddAttributeSplitter();
			data.AddAttribute("","");
			data.AddAttribute("", "<font face=\'_StandardFont\' size=\'11\' color=\'#BFBFBF\'><b>Left Click</b> Open/Close configuration window.</font>");
			
			// show icon handling control instructions if not registered with VTIO
			if ( !isRegisteredWithVTIO ) {
				data.AddAttributeSplitter();
				data.AddAttribute("","");		
				data.AddAttribute("", "<font face=\'_StandardFont\' size=\'12\' color=\'#FFFFFF\'><b>Icon</b>\n</font><font face=\'_StandardFont\' size=\'11\' color=\'#BFBFBF\'><b>CTRL + Left Drag</b> Move icon.\n<b>CTRL + Roll Mousewheel</b> Resize icon.\n<b>CTRL + Right Click</b> Reset icon size to 100%.</font>");
			}
		}
		
		closeTooltip();
		_tooltip = TooltipManager.GetInstance().ShowTooltip( undefined, TooltipInterface.e_OrientationVertical, 0, data );
	}
	
	public function closeTooltip():Void {
		_tooltip.Close();
	}
	
	public function get state():String { return _state }
	public function set state(value:String):Void {
		_state = value;
		_iconClip.m_Movie.gotoAndStop( value );
	}
	
	public function get iconPosition():Point { return new Point( _iconMC._x, _iconMC._y ) }
	public function set iconPosition(value:Point):Void {
		// TODO: ensure icon is on screen, there is an AddonUtils.OnScreen method for this
		
		_iconMC._x = value.x;
		_iconMC._y = value.y;
	}
	
	public function get iconScale():Number { return _iconMC._xscale; }
	public function set iconScale(value:Number):Void {
		var oldWidth:Number = _iconMC._width;
		var oldHeight:Number = _iconMC._height;

		_iconMC._xscale = _iconMC._yscale = value;
		
		// scale around centre of icon
		if( centreScaleIcon ) {
			iconPosition = new Point( _iconMC._x - (_iconMC._width - oldWidth) / 2, _iconMC._y - (_iconMC._height - oldHeight) / 2 );
		}
	}
	
	public function get icon():MovieClip { return _iconMC; }
	public function set icon(value:MovieClip):Void {
		_iconMC = value;
	}
	
	public function get iconClip():ClipNode { return _iconClip; }
	
	public function get isVTIOLOaded():Boolean { return Boolean(_VTIOLoaded.GetValue()); }
	public function get isRegisteredWithVTIO():Boolean { return _isRegisteredWithVTIO; }
	
	public function get modulePath():String { return _modulePath; };
}