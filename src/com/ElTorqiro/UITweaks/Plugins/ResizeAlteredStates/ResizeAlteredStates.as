import com.GameInterface.UtilsBase;
import flash.geom.Point;
import mx.utils.Delegate;


class com.ElTorqiro.UITweaks.Plugins.ResizeAlteredStates.ResizeAlteredStates {

	private var _findTargetThrashCount:Number = 0;

	private var _scale:Number;
	private var _hide:Boolean;
	
	public function ResizeAlteredStates() {
		_scale = 80;
		_hide = false;
	}

	public function Restore() {
		Resize( _root.playerinfo.m_States, 100, false );
		Resize( _root.targetinfo.m_States, 100, false );
	}

	public function ResizeHook():Void {
		if ( _root.playerinfo.m_States == undefined ) {
			if (_findTargetThrashCount++ == 30) _findTargetThrashCount = 0;
			else _global.setTimeout( Delegate.create(this, ResizeHook), 10);
			return;
		}
		_findTargetThrashCount = 0;

		Resize( _root.playerinfo.m_States, _scale, _hide );
		Resize( _root.targetinfo.m_States, _scale, _hide );
	}

	private function Resize(states:MovieClip, scale:Number, hide:Boolean):Void {

		var icons:Array = [ states.m_Afflicted, states.m_Hindered, states.m_Impaired, states.m_Weakened ];

		states._visible = hide == undefined ? true : !hide;
			
		for ( var s:String in icons ) {
			var oldSize:Point = new Point( icons[s]._width, icons[s]._height );
			icons[s]._xscale = icons[s]._yscale = scale;
			icons[s]._x += (oldSize.x - icons[s]._width) / 2;
		}
	}
	
	public function get scale():Number { return _scale; }
	public function set scale(value:Number):Void {
		if ( value == undefined ) return;
		
		_scale = value;
		ResizeHook();
	}
	
	public function get hide():Boolean { return _hide; }
	public function set hide(value:Boolean):Void {
		if ( value == undefined ) return;
		
		_hide = value;
		ResizeHook();
	}
}