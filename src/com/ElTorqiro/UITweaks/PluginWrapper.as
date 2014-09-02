import GUIFramework.ClipNode;
import com.ElTorqiro.UITweaks.Plugins.PluginBase;
import GUIFramework.SFClipLoader;
import mx.utils.Delegate;
import com.GameInterface.UtilsBase;

class com.ElTorqiro.UITweaks.PluginWrapper {

	// properties
	public var id:String;
	
	public var name:String;
	public var author:String;
	public var contactURL:String;
	
	public var path:String;
	
	public var clipNode:ClipNode;
	public var depth:Number;
	public var subDepth:Number;
	
	public var mc:MovieClip;
	
	public var plugin:PluginBase;

	public var enabled:Boolean;
	
	public var state:Number;
	
	
	public function PluginWrapper(id:String, name:String, path:String, depth:Number, subDepth:Number) {
		
		this.id = id;
		this.name = name;
		this.path = path;
		this.depth = depth;
		this.subDepth = subDepth;
	}

	public function Load():Void {
		
		clipNode = SFClipLoader.LoadClip( path + '/plugin.swf', id, false, depth, subDepth);
		clipNode.SignalLoaded.Connect( clipLoaded, this );
	}

	private function clipLoaded(clipNode:ClipNode, success:Boolean):Void {

		if ( success ) {
			mc = clipNode.m_Movie;
			plugin = new mc.plugin( this );
		}
		//Commented To Clean Up Chat Window For Other Dev Debug
		//UtilsBase.PrintChatText('s:' + mc);
		
		// fire callback
		onLoad( this, success );
		
		// TODO: implement failure to load message / handling
	}
	
	public function onLoad(pluginWrapper:PluginWrapper, success:Boolean):Void {}
	
	public function Unload():Void {
		
		plugin.Deactivate();
		mc.UnloadClip();
		
		onUnload( this );
	}
	
	public function onUnload(pluginWrapper:PluginWrapper):Void {}
}