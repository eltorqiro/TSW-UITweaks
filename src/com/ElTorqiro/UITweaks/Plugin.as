import com.Utils.Archive;
import com.Utils.Signal;
import GUIFramework.ClipNode;
import com.ElTorqiro.UITweaks.Plugins.PluginBase;
import GUIFramework.SFClipLoader;
import mx.utils.Delegate;
import com.GameInterface.UtilsBase;

class com.ElTorqiro.UITweaks.Plugin {

	// properties
	public var id:String;
	
	public var name:String;
	public var description:String;
	public var _author:String;
	public var contactURL:String;
	
	public var path:String;
	
	public var clipNode:ClipNode;
	public var depth:Number;
	public var subDepth:Number;
	
	public var mc:MovieClip;
	
	private var _enabled:Boolean;
	private var _isLoaded:Boolean;
	public  var settings:Archive;
	
	private var _state:String;
	
	public var SignalLoaded:Signal;
	public var SignalUnloaded:Signal;
	
	private var SignalStateChange:Signal;
	
	public function Plugin(id:String, name:String, path:String, depth:Number, subDepth:Number) {
		
		this.id = id;
		this.name = name;
		this.path = path;
		this.depth = depth ? depth : 3;
		this.subDepth = subDepth ? subDepth : 0;
		
		this.author = 'Unknown';
		
		SignalLoaded = new Signal();
		SignalUnloaded = new Signal();
		SignalStateChange = new Signal();
		
		state = 'unloaded';
	}

	public function Load():Void {
		
		if ( _isLoaded ) Unload();
		
		state = 'loading';
		
		clipNode = SFClipLoader.LoadClip( path + '/plugin.swf', id, false, depth, subDepth);
		clipNode.SignalLoaded.Connect( clipLoaded, this );
	}

	private function clipLoaded(clipNode:ClipNode, success:Boolean):Void {

		state = 'loaded';
		
		if ( success ) {
			
			mc = clipNode.m_Movie;
			
			state = 'activating';
			mc.SignalPluginReady.Connect( pluginReady, this );
			
			mc.onPluginActivated(settings);
			
			_enabled = true;
			_isLoaded = true;
		}

		SignalLoaded.Emit( this, success );
		
		// TODO: implement failure to load message / handling
	}
	
	public function Unload():Void {
		
		if ( !isLoaded ) return;
		
		state = 'deactivating';
		
		if ( mc.onPluginDeactivated != undefined ) {
			settings = mc.onPluginDeactivated();
		}
		
		mc.SignalPluginReady.Disconnect( pluginReady, this );
		
		state = 'unloading';
		
		mc.UnloadClip();
		
		_enabled = false;
		_isLoaded = false;
		
		state = 'unloaded';
		
		SignalUnloaded.Emit( this );
	}

	private function pluginReady():Void {
		state = 'active';
	}
	
	public function get enabled():Boolean { return _enabled }
	public function get isLoaded():Boolean { return _isLoaded }
	
	public function get author():String { return _author; }
	public function set author(value:String):Void {
		if ( value != undefined ) _author = value;
	}
	
	public function get state():String { return _state; }
	public function set state(value:String):Void {
		_state = value;
		SignalStateChange.Emit( this, value );
	}
}