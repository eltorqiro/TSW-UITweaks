import com.ElTorqiro.UITweaks.Enums.States;
import GUIFramework.ClipNode;

class com.ElTorqiro.UITweaks.PluginBase {
	
	private var _active:Boolean = false;
	private var _state:Number;
	
	private var _data:Object;

	public function PluginBase(data:Object) {
		_data = data;
		
		state = States.PluginInactive;
	}
	
	private function Activate() {
		state = States.PluginActive;
	}
	
	private function Deactivate() {
		state = States.PluginInactive;
	}
	
	public function get active():Boolean { return _active };
	public function set active(value:Boolean):Void {
		_active = value;
		active ? Activate() : Deactivate();
	}
	
	public function get state():Number { return _state; };
	public function set state(value:Number):Void {
		_state = value;
	}
	
	// readonly
	public function get clipNode():ClipNode { return _data.clipNode; };
}