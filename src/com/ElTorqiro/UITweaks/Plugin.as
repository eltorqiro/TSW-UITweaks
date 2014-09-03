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
	public var author:String;
	public var contactURL:String;
	
	public var path:String;
	
	public var clipNode:ClipNode;
	public var depth:Number;
	public var subDepth:Number;
	
	public var mc:MovieClip;
	
	private var _enabled:Boolean;
	private var _isLoaded:Boolean;
	public  var settings:Archive;
	
	public var state:String;
	
	public var SignalLoaded:Signal;
	
	public function Plugin(id:String, name:String, path:String, depth:Number, subDepth:Number) {
		
		this.id = id;
		this.name = name;
		this.path = path;
		this.depth = depth ? depth : 3;
		this.subDepth = subDepth ? subDepth : 0;
		
		SignalLoaded = new Signal();
	}

	public function Load():Void {
		
		if ( _isLoaded ) Unload();
		
		clipNode = SFClipLoader.LoadClip( path + '/plugin.swf', id, false, depth, subDepth);
		clipNode.SignalLoaded.Connect( clipLoaded, this );
	}

	private function clipLoaded(clipNode:ClipNode, success:Boolean):Void {

		if ( success ) {
			mc = clipNode.m_Movie;
			mc.Activate();
			
			_enabled = true;
			_isLoaded = true;
		}

		SignalLoaded.Emit( this, success );
		
		// TODO: implement failure to load message / handling
	}
	
	public function Unload():Void {
		
		mc.Deactivate();
		mc.UnloadClip();
		
		_enabled = false;
		_isLoaded = false;
	}

	public function get enabled():Boolean { return _enabled };
	public function get isLoaded():Boolean { return _isLoaded };
}