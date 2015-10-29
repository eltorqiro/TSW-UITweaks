import com.Components.ItemSlot;
import com.ElTorqiro.UITweaks.Plugins.Plugin;
import GUI.Inventory.IconBox;
import GUI.Inventory.ItemIconBox;

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
		
		pressDelegate = function( buttonIdx:Number ) {
			
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
		
	}

	public function onLoad() : Void {
		super.onLoad();
		
		backpackMonitor = DistributedValue.Create("inventory_visible");
		backpackMonitor.SignalChanged.Connect( apply, this );
		
	}
	
	public function apply() : Void {
		stopWaitFor();
		
		// only apply if enabled
		if ( enabled ) {
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
		
		for ( var s:String in bags ) {
			
			var bag = bags[s];
			
			// apply or revert hook on window chrome only when inventory is open
			if ( backpackMonitor.GetValue() ) {
				hookWindowChrome( bag, enabled );
			}
					
			// apply or revert hook on item slots
			if ( bag["m_IsPinned"] ) {
				
				var hookSlots:Boolean = enabled && !backpackMonitor.GetValue();
				
				if ( (hookSlots && !bag.UITweaks_BagLock_SlotsHooked) || (!hookSlots && bag.UITweaks_BagLock_SlotsHooked) ) {

					// shortcutbar uses m_Slots and is a one dimensional array
					if ( s == "-1" ) {
						hookItemSlots( bag.m_Slots, hookSlots );
					}
					
					else {
						var columns:Array = bag.m_ItemSlots;
						for ( var x:String in columns ) {
							hookItemSlots( columns[x], hookSlots );
						}
					}
					
					hookSlots ? bag.UITweaks_BagLock_SlotsHooked = true : delete bag.UITweaks_BagLock_SlotsHooked;
				}
			}
		}
		
	}

	private function hookWindowChrome( bag, setHook:Boolean ) : Void {

		// only take action if it is needed
		if ( (setHook && window.UITweaks_BagLock_ChromeHooked) || (!setHook && !window.UITweaks_BagLock_ChromeHooked ) ) return;
		
		var window:MovieClip = bag["m_WindowMC"];
		
		var funcMap:Object = {
			i_Background: "onMousePress",
			i_FrameName: "onPress",
			i_TopBar: "onPress",
			i_ResizeButton: "onMousePress",
			i_TrashButton: "onPress",
			i_SortButton: "onPress"
		};

		for ( var elementName:String in funcMap ) {
			
			var element:MovieClip = window[ elementName ];
			var funcName:String = funcMap[ elementName ];
			
			if ( setHook ) {
				element.UITweaks_BagLock_Press_Original = element[ funcName ];
				element[ funcName ] = Delegate.create( element, pressDelegate );
				
				element.UITweaks_BagLock_Prefs = prefs;
			}
			
			else {
				element[ funcName ] = element.UITweaks_BagLock_Press_Original;
				delete element.UITweaks_BagLock_Press_Original;
				
				delete element.UITweaks_BagLock_Prefs;
			}
			
		}

		setHook ? window.UITweaks_BagLock_ChromeHooked = true : delete window.UITweaks_BagLock_ChromeHooked;
	}
	
	private function hookItemSlots( slots:Array, setHook:Boolean ) : Void {
		
		for ( var i:String in slots ) {
			
			var slot = slots[i];

			if ( setHook ) {
				slot.UITweaks_BagLock_StartDraggingItem_Original = slot["StartDraggingItem"];
				slot["StartDraggingItem"] = undefined;
			
				slot.UITweaks_BagLock_StartSplittingItem_Original = slot["StartSplittingItem"];
				slot["StartSplittingItem"] = undefined;
			}

			else {
				slot["StartDraggingItem"] = slot.UITweaks_BagLock_StartDraggingItem_Original;
				delete slot.UITweaks_BagLock_StartDraggingItem_Original;

				slot["StartSplittingItem"] = slot.UITweaks_BagLock_StartSplittingItem_Original;
				delete slot.UITweaks_BagLock_StartSplittingItem_Original;
			}
		}
		
	}
	
	private function pressDelegate( buttonIdx:Number ) : Void { }
	
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