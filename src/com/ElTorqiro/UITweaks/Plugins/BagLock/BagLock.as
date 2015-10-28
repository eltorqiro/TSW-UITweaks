import com.ElTorqiro.UITweaks.Plugins.Plugin;

import gfx.utils.Delegate;
import com.GameInterface.DistributedValue;

import com.ElTorqiro.UITweaks.AddonUtils.WaitFor;

import com.GameInterface.UtilsBase;

/**
 * 
 * 
 */
class com.ElTorqiro.UITweaks.Plugins.BagLock.BagLock extends Plugin {

	// plugin properties
	public var id:String = "bagLock";
	public var name:String = "Bag Lock";
	public var description:String = "Prevents inventory windows being accidentally moved.";
	public var author:String = "ElTorqiro";
	public var prefsVersion:Number = 1;

	public function BagLock() {
		
		prefs.add( "override.shift", true );
		prefs.add( "override.control", true );
		prefs.add( "override.alt", false );
		
	}

	public function onLoad() : Void {
		super.onLoad();
		
		backpackMonitor = DistributedValue.Create("inventory_visible");
		backpackMonitor.SignalChanged.Connect( apply, this );
		
	}
	
	public function apply() : Void {
		stopWaitFor();
		
		// only apply if the backpack is open
		if ( enabled && backpackMonitor.GetValue() ) {
			waitForId = WaitFor.start( Delegate.create( this, waitForTest ), 100, 3000, Delegate.create( this, hook ) );
		}
	}
	
	public function waitForTest() : Boolean {
		return _root.backpack2.m_ModuleActivated;
	}
	
	public function onModuleDeactivated() : Void {
		stopWaitFor();
	}

	public function stopWaitFor() : Void {
		WaitFor.stop( waitForId );
		waitForId = undefined;
	}
	
	public function hook() : Void {
		stopWaitFor();

		var bags:Array = _root.backpack2.m_IconBoxes;
		
		var pressDelegate:Function = function( buttonIdx:Number ) {
			
			var prefs = this.UITweaks_BagLock_Prefs;
			
			var map:Object = {
				shift: Key.SHIFT,
				control: Key.CONTROL,
				alt: Key.ALT
			};
			
			var override:Boolean;
			for ( var s:String in map ) {
				var pref:Boolean = prefs.getVal( "override." + s );
				
				if ( pref ) {
					override = Key.isDown( map[s] );
					if ( !override ) break;
				}
			}
			
			if ( override ) {
				this.UITweaks_BagLock_Press_Original( buttonIdx );
			}
		}
		
		var funcMap:Object = {
			i_Background: "onMousePress",
			i_FrameName: "onPress",
			i_TopBar: "onPress",
			i_ResizeButton: "onMousePress",
			i_TrashButton: "onPress",
			i_SortButton: "onPress"
		};
		
		for ( var s:String in bags ) {
			
			var bagMC = bags[s].m_WindowMC;
			
			for ( var elementName:String in funcMap ) {
				
				var element:MovieClip = bagMC[ elementName ];
				var funcName:String = funcMap[ elementName ];
				
				// if not hooked and it should be, set hook
				if ( enabled && !element.UITweaks_BagLock_Press_Original ) {
					element.UITweaks_BagLock_Press_Original = element[ funcName ];
					element[ funcName ] = Delegate.create( element, pressDelegate );
					
					element.UITweaks_BagLock_Prefs = prefs;
				}
				
				// else if is hooked and should not be, remove hook
				else if ( !enabled && element.UITweaks_BagLock_Press_Original ) {
					element[ funcName ] = element.UITweaks_BagLock_Press_Original;
					delete element.UITweaks_BagLock_Press_Original;
					delete element.UITweaks_BagLock_Prefs;
				}
				
			}
			
		}
		
	}

	public function revert() : Void {
		hook();
	}
	
	public function getConfigPanelLayout() : Array {

		return [
			
			{	type: "h2",
				text: "OVERRIDE KEY COMBINATION"
			},
			
			{	id: "override.shift",
				type: "checkbox",
				label: "SHIFT",
				tooltip: "Adds Shift to the key modifiers needed to be held down to click locked bags.",
				data: { pref: "override.shift" }
			},

			{	id: "override.control",
				type: "checkbox",
				label: "CTRL",
				tooltip: "Adds Control to the key modifiers needed to be held down to click locked bags.",
				data: { pref: "override.control" }
			},
			
			{	id: "override.alt",
				type: "checkbox",
				label: "ALT",
				tooltip: "Adds Alt to the key modifiers needed to be held down to click locked bags.",
				data: { pref: "override.alt" }
			},
			
			{	type: "group"
			},

			{	type: "text",
				text: "Inventory bags can only be moved, resized, auto-sorted, or deleted by holding down the override key combination.\n\nAll other features, such as pinning, searching, and renaming, retain their default behaviour, and newly added bags can be manipulated normally until the inventory is re-opened.\n\nNote that the game leaves the Alt key in a \"stuck down\" state when you hit Alt-Tab.  Therefore, if you use it as part of your override combo, you will need to tap Alt once when you come back into the game to \"unstick\" it."
			}
		];
		
	}

	/**
	 * internal variables
	 */
	
	private var waitForId:Number;
	private var backpackMonitor:DistributedValue;

}