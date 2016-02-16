import com.Utils.Signal;
import flash.filters.DropShadowFilter;
import flash.geom.Point;

import com.GameInterface.Tooltip.TooltipData;
import com.GameInterface.Tooltip.TooltipManager;
import com.GameInterface.Tooltip.TooltipInterface;

import com.GameInterface.DistributedValue;

import com.Utils.GlobalSignal;

import com.ElTorqiro.UITweaks.Const;
import com.ElTorqiro.UITweaks.App;
import com.ElTorqiro.UITweaks.AddonUtils.GuiEditMode.GemController;

import com.GameInterface.UtilsBase;

/**
 * 
 * 
 */
class com.ElTorqiro.UITweaks.AppIcon extends MovieClip {
	
	public static var __className:String = "com.ElTorqiro.UITweaks.AppIcon";
	
	public function AppIcon() {
		
		App.debug( "AppIcon: " + _name + ": constructor" );

		isVtioIcon = _name == "Icon";
		
		attachMovie( "icon", "m_Icon", getNextHighestDepth() );
		
		// no point keeping the old icon around if vtio has created a fresh one
		if ( isVtioIcon ) {
			_parent.m_Icon.removeMovieClip();
		}
		
		// if this is not the duplicate created by VTIO, handle regular setup of icon
		if ( !isVtioIcon ) {
			
			SignalGeometryChanged = new Signal();
			
			this.filters = [ new DropShadowFilter( 50, 1, 0, 0.8, 8, 8, 1, 3, false, false, false ) ];
			
			loadScale();
			loadPosition();

			// listen for GUI Edit Mode signal
			GlobalSignal.SignalSetGUIEditMode.Connect( manageGuiEditMode, this );

			// listen for resolution changes
			guiResolutionScale = DistributedValue.Create("GUIResolutionScale");
			guiResolutionScale.SignalChanged.Connect( loadScale, this );
			
		}
		
		else {
			// vtio needs to be positioned at 0,0 which for some reason doesn't happen for some people only on the initial load, not after /reloadui
			_x = _y = 0;
			m_Icon._x = m_Icon._y = 0;
		}
		
		// listen for pref changes
		App.prefs.SignalValueChanged.Connect( prefChangeHandler, this );
		
		this.onReleaseOutside = this["onReleaseOutsideAux"] = this.onRollOut;
	}
	
	/**
	 * moves icon to loaded position
	 */
	private function loadPosition() : Void {
		
		var pos:Point = App.prefs.getVal( "icon.position" );
		if ( pos == undefined ) {
			pos = new Point( Math.floor((Stage.visibleRect.width - this._width) / 2), Math.floor((Stage.visibleRect.height + this._height) / 4) );
		}
		
		position = pos;
	}

	/**
	 * loads scale
	 */
	private function loadScale() : Void {
		scale = App.prefs.getVal( "icon.scale" );
	}
	
	public function onMousePress( button:Number ) : Void {
		
		// left button toggles config window
		if ( button == 1 ) {
			
			DistributedValue.SetDValue( Const.ShowConfigWindowDV, !DistributedValue.GetDValue( Const.ShowConfigWindowDV ) );
			closeTooltip();
		}
		
	}
	
	public function onRollOver() : Void {
		openTooltip();
	}
	
	public function onRollOut() : Void {
		closeTooltip();
	}
	
	private function closeTooltip() : Void {
		tooltip.Close();
		tooltip = null;
	}
	
	/**
	 * opens a tooltip on the icon, showing the current status of AegisHUD and some instructions
	 */
	private function openTooltip() : Void {
		
		closeTooltip();
		
		var td:TooltipData = new TooltipData();
		td.AddAttribute( "", "<font face=\'_StandardFont\' size=\'14\' color=\'#00ccff\'><b>" + Const.AppName + " v" + Const.AppVersion + "</b></font>" );
		td.AddAttributeSplitter();
		td.AddAttribute( "", "" );
		
		td.AddAttribute("", "<font face=\'_StandardFont\' size=\'11\' color=\'#BFBFBF\'><b>Left Click</b> Open/Close configuration window.</font>");
		
		td.m_Padding = 8;
		td.m_MaxWidth = 256;
		
		// create tooltip instance
		tooltip = TooltipManager.GetInstance().ShowTooltip( this, TooltipInterface.e_OrientationVertical, 0, td );
		
	}

	/**
	 * manages the GUI Edit Mode state
	 * 
	 * @param	edit
	 */
	public function manageGuiEditMode( edit:Boolean ) : Void {
	
		if ( edit && !gemController ) {
			gemController = GemController.create( "m_GuiEditModeController", _parent, _parent.getNextHighestDepth(), this );
			gemController.addEventListener( "scrollWheel", this, "gemScrollWheelHandler" );
			gemController.addEventListener( "endDrag", this, "gemEndDragHandler" );
		}
		
		else if ( !edit ) {
			gemController.removeMovieClip();
			gemController = null;
		}
		
	}

	private function gemScrollWheelHandler( event:Object ) : Void {
		
		App.prefs.setVal( "icon.scale", App.prefs.getVal( "icon.scale" ) + event.delta * 5 );
	}
	
	private function gemEndDragHandler( event:Object ) : Void {
		
		App.prefs.setVal( "icon.position", new Point( _x, _y ) );
	}
	
	/**
	 * handles updates based on pref changes
	 * 
	 * @param	pref
	 * @param	newValue
	 * @param	oldValue
	 */
	private function prefChangeHandler( pref:String, newValue, oldValue ) : Void {
		
		switch ( pref ) {
			
			case "icon.scale":
				loadScale();
			break;
			
			case "icon.position":
				loadPosition();
			break;
			
		}
		
	}
	
	/*
	 * internal variables
	 */

	public var m_Icon:MovieClip;
	 
	private var tooltip:TooltipInterface;

	private var isVtioIcon:Boolean;
	
	private var guiResolutionScale:DistributedValue;
	
	private var gemController:GemController;
	
	/*
	 * properties
	 */

	public var SignalGeometryChanged:Signal;
	 
	// the position of the hud
	public function get position() : Point { return new Point( this._x, this._y ); }
	public function set position( value:Point ) : Void {
		
		if ( isVtioIcon ) return;
		
		this._x = value.x;
		this._y = value.y;
		
		SignalGeometryChanged.Emit();
	}

	// the scale of the hud
	public function get scale() : Number { return App.prefs.getVal( "icon.scale" ); }
	public function set scale( value:Number ) : Void {

		if ( isVtioIcon ) return;
		
		// the default game GUI scale, based on screen resolution
		var resolutionScale:Number = guiResolutionScale.GetValue();
		if ( resolutionScale == undefined ) resolutionScale = 1;
		
		this._xscale = this._yscale = resolutionScale * value;

		SignalGeometryChanged.Emit();
	}
	
}