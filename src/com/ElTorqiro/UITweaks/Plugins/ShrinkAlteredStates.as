import com.GameInterface.UtilsBase;
import com.ElTorqiro.UITweaks.Plugins.PluginBase;
import mx.utils.Delegate;


class com.ElTorqiro.UITweaks.Plugins.ShrinkAlteredStates extends com.ElTorqiro.UITweaks.Plugins.PluginBase {

	public function ShrinkAlteredStates() {
		super();
		
	}
	
	private var _targetMC:MovieClip;
	private var _findTargetThrashCount:Number = 0;
	
	private function Activate() {
		super.Activate();

		Suppress();
	}
	
	private function Deactivate() {
		super.Deactivate();
	}
	
	private function Suppress():Void {
		if ( _root.playerinfo.m_States == undefined ) {
			if (_findTargetThrashCount++ == 30) _findTargetThrashCount = 0;
			else _global.setTimeout( Delegate.create(this, Suppress), 10);
			return;
		}
		_findTargetThrashCount = 0;
		_targetMC = _root.playerinfo.m_States;
		
		ShrinkIcons();
	}
	
	private function ShrinkIcons():Void {
		
		//_targetMC.m_Afflicted._xscale = _targetMC.m_Afflicted.mc._scale * 0.5;
		//Half Of THe Prevois Width  ((newWidth - Old With) / 2) + _x
		
		var icons:Array = [ _targetMC.m_Afflicted, _targetMC.m_Hindered, _targetMC.m_Impaired, _targetMC.m_Weakened ];

		for( var s:String in icons ) {
			var oldSize:flash.geom.Point = new flash.geom.Point( icons[s]._width, icons[s]._height );

			icons[s]._xscale = icons[s]._yscale = 80;

			icons[s]._x += (icons[s]._width - oldSize.x) / 2;
			
		}
	}
}