

class com.ElTorqiro.UITweaks.UITweakPluginBase {
	
	private var _active:Boolean = false;

	public function UITweakPluginBase() {

	}
	
	private function Activate() {
		
	}
	
	private function Deactivate() {
		
	}
	
	
	public function get active():Boolean { return _active };
	public function set active(value:Boolean):Void {
		_active = value;
		active ? Activate() : Deactivate();
	}
}