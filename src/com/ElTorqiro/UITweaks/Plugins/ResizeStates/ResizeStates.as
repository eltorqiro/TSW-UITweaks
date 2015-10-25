import com.ElTorqiro.UITweaks.Plugins.Plugin;

import flash.geom.Point;
import gfx.utils.Delegate;

import com.ElTorqiro.UITweaks.AddonUtils.WaitFor;


/**
 * 
 * 
 */
class com.ElTorqiro.UITweaks.Plugins.ResizeStates.ResizeStates extends Plugin {

	// plugin properties
	public var id:String = "resizeStates";
	public var name:String = "State Icons Size";
	public var description:String = "Allows the \"altered states\" icons in player and target info panels to be resized or hidden.";
	public var author:String = "ElTorqiro";
	public var prefsVersion:Number = 1;

	public function ResizeStates() {
		
		prefs.add( "states.scale", 100 );
		prefs.add( "states.hide", false );
		
	}

	public function apply() : Void {
		stopWaitFor();
		waitForId = WaitFor.start( Delegate.create( this, waitForTest ), 10, 3000, Delegate.create( this, clipsAvailable ) );
	}
	
	public function waitForTest() : Boolean {
		return _root.playerinfo.m_States != undefined && _root.targetinfo.m_States != undefined;
	}
	
	public function revert() : Void {
		stopWaitFor();
		redraw( true );
	}

	public function onModuleDeactivated() : Void {
		stopWaitFor();
	}

	public function stopWaitFor() : Void {
		WaitFor.stop( waitForId );
		waitForId = undefined;
	}
	
	private function clipsAvailable() : Void {
		stopWaitFor();
		redraw();
	}
	
	private function redraw( reset:Boolean ) : Void {
		
		if ( !enabled && !reset ) return;
		
		var scale:Number;
		var hide:Boolean;
		
		if ( !reset ) {
			scale = prefs.getVal( "states.scale" );
			hide = prefs.getVal( "states.hide" );
		}
		
		else {
			scale = 100;
			hide = false;
		}
		
		var panels:Array = [ _root.playerinfo.m_States, _root.targetinfo.m_States ];
		var stateIconNames:Array = [ "m_Afflicted", "m_Hindered", "m_Impaired", "m_Weakened" ];
		
		for ( var s:String in panels ) {
			
			var panel:MovieClip = panels[s];
			
			if ( hide ) {
				panel._visible = false;
			}
			
			else {
				for ( var i:String in stateIconNames ) {
					var icon:MovieClip = panel[ stateIconNames[i] ];
					
					// size around centre of clip
					var oldSize:Point = new Point( icon._width, icon._height );
					icon._xscale = icon._yscale = scale;
					icon._x += ( oldSize.x - icon._width ) / 2;
				}
				
				panel._visible = true;
			}
		}
		
	}

	/**
	 * handle pref value changes for the plugin
	 * 
	 * @param	name
	 * @param	newValue
	 * @param	oldValue
	 */
	private function prefChangeHandler( name:String, newValue, oldValue ) : Void {
		
		switch ( name ) {
			
			case "states.scale":
			case "states.hide":
				redraw();
			break;
				
		}
		
	}

	public function getConfigPanelLayout() : Array {

		return [
		
			{	id: "states.scale",
				type: "slider",
				min: 20,
				max: 200,
				step: 1,
				valueFormat: "%i%%",
				label: "State Icon Scale",
				tooltip: "Size of the state icons.",
				data: { pref: "states.scale" }
			},
			
			{	id: "states.hide",
				type: "checkbox",
				label: "Hide state icons",
				tooltip: "Hides the state icons completely.",
				data: { pref: "states.hide" }
			}
				
		];
		
	}

	/**
	 * internal variables
	 */
	
	private var waitForId:Number;

}