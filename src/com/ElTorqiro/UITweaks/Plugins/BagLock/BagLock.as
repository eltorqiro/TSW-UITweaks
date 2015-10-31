import com.Components.ItemSlot;
import com.ElTorqiro.UITweaks.Plugins.Plugin;
import GUI.Inventory.IconBox;
import GUI.Inventory.ItemIconBox;

import gfx.utils.Delegate;
import com.GameInterface.DistributedValue;

import com.ElTorqiro.UITweaks.AddonUtils.WaitFor;


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
		
		prefs.add( "bags.lock.enabled", true );
		prefs.add( "override.shift", true );
		prefs.add( "override.control", true );
		prefs.add( "override.alt", false );
		
		prefs.add( "items.lock.whenPinned", true );
		
		pressDelegate = function( buttonIdx:Number ) {
			
			var prefs = this._parent.UITweaks_BagLock_Prefs;
			
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

		var backpack = _root.backpack2;
		var bags:Array = backpack.m_IconBoxes;
		
		for ( var s:String in bags ) {
			
			var bag = bags[s];
			
			// apply or revert hook on window chrome only when inventory is open
			if ( backpackMonitor.GetValue() ) {
				hookWindowChrome( bag, enabled && prefs.getVal( "bags.lock.enabled" ) );
			}
					
			// apply or revert hook on item slots
			if ( bag["m_IsPinned"] ) {
				
				var lockSlots:Boolean = enabled && !backpackMonitor.GetValue() && prefs.getVal("items.lock.whenPinned");
				
				if ( (lockSlots && !bag.UITweaks_BagLock_SlotsLocked) || (!lockSlots && bag.UITweaks_BagLock_SlotsLocked) ) {

					var funcName:String = lockSlots ? "Disconnect" : "Connect";
					
					bag.SignalMouseDownItem[funcName]( backpack.SlotMouseDownItem, backpack );
					bag.SignalStartDragItem[funcName]( backpack.SlotStartDragItem, backpack );
					
					lockSlots ? bag.UITweaks_BagLock_SlotsLocked = true : delete bag.UITweaks_BagLock_SlotsLocked;
				}
			}
		}
		
	}

	private function hookWindowChrome( bag, setHook:Boolean ) : Void {

		var window:MovieClip = bag.m_WindowMC;

		// only take action if it is needed
		if ( (setHook && window.UITweaks_BagLock_Prefs) || (!setHook && !window.UITweaks_BagLock_Prefs ) ) return;
		
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
			}
			
			else {
				element[ funcName ] = element.UITweaks_BagLock_Press_Original;
				delete element.UITweaks_BagLock_Press_Original;
			}
			
		}

		setHook ? window.UITweaks_BagLock_Prefs = prefs : delete window.UITweaks_BagLock_Prefs;
	}
	
	private function pressDelegate( buttonIdx:Number ) : Void { }
	
	public function revert() : Void {
		hook();
	}

	private function prefChangeHandler( name:String, newValue, oldValue ) : Void {
	
		switch ( name ) {
			
			case "items.lock.whenPinned":
			case "bags.lock.enabled":
				hook();
			break;
			
		}
		
	}
	
	public function getConfigPanelLayout() : Array {

		return [

			{	id: "items.lock.whenPinned",
				type: "checkbox",
				label: "Lock items in pinned bags when inventory is closed",
				tooltip: "Prevents items from being moved in pinned bags when the inventory is closed.  Items can still be right-clicked to use them.",
				data: { pref: "items.lock.whenPinned" }
			},

			{	type: "group"
			},
					
			{	id: "bags.lock.enabled",
				type: "checkbox",
				label: "Lock bags",
				tooltip: "Prevents bags from being moved, resized, sorted or trashed accidentally.",
				data: { pref: "bags.lock.enabled" }
			},
			
			{	type: "h2",
				text: "BAG LOCK OVERRIDE COMBO"
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