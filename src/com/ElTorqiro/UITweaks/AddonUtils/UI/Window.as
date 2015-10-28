import com.Components.WinComp;

import flash.filters.DropShadowFilter;
import flash.filters.GlowFilter;
import flash.geom.Point;
import mx.transitions.easing.Strong;


/**
 * 
 * Window class used for, among other things, config windows.
 * 
 * Must be linked to a symbol for instantiation, e.g. using attachMovie()
 * 
 */
class com.ElTorqiro.UITweaks.AddonUtils.UI.Window extends WinComp {

	public function Window() {
	
		_alpha = 0;
		
		ShowStroke(false);
		ShowFooter(false);
		ShowResizeButton(false);
		
	}

	public function configUI() : Void {
		super.configUI();
		
		m_Shadow.hitTestDisable = true;
		
		SignalContentLoaded.Connect( contentLoadedHandler, this );
	}
	
	/**
	 * show the window only after content is loaded
	 */
	private function contentLoadedHandler() : Void {
		
		var position:Point = openingPosition ? openingPosition : new Point( _x, _y );
		
		_x = position.x;
		_y = position.y + 10;
		
		this["tweenTo"]( 0.3, { _y: position.y, _alpha: 100 }, Strong.easeInOut );
	}
	
	public function Layout() : Void {
		super.Layout();
		
		m_Shadow._width = m_Background._width + 86 + 6;
		m_Shadow._height = m_Background._height + 86 + 6;

		m_Title._y -= 3;
	}
	
	/*
	 * internal variables
	 */
	
	public var m_Shadow:MovieClip;
	
	private var openingPosition:Point;
	 
	/*
	 * properties
	 */
	
}