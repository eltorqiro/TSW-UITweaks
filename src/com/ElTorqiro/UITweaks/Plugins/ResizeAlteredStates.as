import com.GameInterface.UtilsBase;
import com.ElTorqiro.UITweaks.Plugins.PluginBase;
import flash.geom.Point;
import mx.utils.Delegate;


class com.ElTorqiro.UITweaks.Plugins.ResizeAlteredStates extends com.ElTorqiro.UITweaks.Plugins.PluginBase {

	private var _findTargetThrashCount:Number = 0;
	
	public function ResizeAlteredStates() {
		super();
	}

	private function Activate() {
		super.Activate();

		ResizeHook();
	}

	private function Deactivate() {
		super.Deactivate();
	}

	private function ResizeHook():Void {
		if ( _root.playerinfo.m_States == undefined ) {
			if (_findTargetThrashCount++ == 30) _findTargetThrashCount = 0;
			else _global.setTimeout( Delegate.create(this, ResizeHook), 10);
			return;
		}

		_findTargetThrashCount = 0;

		Resize( _root.playerinfo.m_States );
		Resize( _root.targetinfo.m_States );
	}

	private function Resize(states:MovieClip):Void {

		var icons:Array = [ states.m_Afflicted, states.m_Hindered, states.m_Impaired, states.m_Weakened ];

		for( var s:String in icons ) {
			var oldSize:Point = new flash.geom.Point( icons[s]._width, icons[s]._height );
			icons[s]._xscale = icons[s]._yscale = 80;
			icons[s]._x += (oldSize.x - icons[s]._width) / 2;
		}
	}
}