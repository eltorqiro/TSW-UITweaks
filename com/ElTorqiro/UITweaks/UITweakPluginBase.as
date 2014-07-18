import com.ElTorqiro.UITweaks.Enums.States;

class com.ElTorqiro.UITweaks.UITweakPluginBase {
	
	private var _active:Boolean = false;
	private var _state:Number;

	public function UITweakPluginBase() {
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
	
}