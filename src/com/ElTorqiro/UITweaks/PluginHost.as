import com.Utils.Signal;
import XML;
import com.ElTorqiro.UITweaks.PluginWrapper;
import com.ElTorqiro.UITweaks.AddonInfo;
import com.GameInterface.UtilsBase;


class com.ElTorqiro.UITweaks.PluginHost {
	
	public static var plugins:Array = [];
	public static var ready:Boolean = false;
	
	public static var SignalReady:Signal;
	
	private static var _initialised:Boolean = false;
	private static var _xml:XML;
	
	
	private function PluginHost() {}

	public static function init():Void {
		SignalReady = new Signal();
		_initialised = true;
	}
	
	public static function Load(xmlFile:String):Void {
		// only allow loading once
		if ( ready ) return;
		
		if ( !_initialised ) init();
		
		_xml = new XML();

		_xml.onLoad = onLoad;
		_xml.ignoreWhite = true;
		_xml.load( xmlFile );
	}

	private static function onLoad(success:Boolean):Void {
		// TODO: if status is 0, xml could not be parsed successfully, some user friendly message needed
		UtilsBase.PrintChatText('loaded:' + success + ', status:' + _xml.status);
		
		var pluginsNode = _xml.firstChild;
		// TODO: check if pluginsNode is actually the <plugins> node
		
		//Commented To Clean Up Chat Window For Other Dev Debug
		//UtilsBase.PrintChatText('pluginsNode:' + pluginsNode.nodeName );
		
		for (var aNode:XMLNode = pluginsNode.firstChild; aNode != null; aNode = aNode.nextSibling) {

			var plugin:PluginWrapper = new PluginWrapper( AddonInfo.Path.toLowerCase() + '_' + aNode.attributes.location, aNode.attributes.name, AddonInfo.Path + '/plugins/' + aNode.attributes.location, aNode.attributes.depth, aNode.attributes['sub-depth'] );
			plugin.author = aNode.attributes.author;
			plugin.contactURL = aNode.attributes['contact-url'];
			
			/* settings: TODO: fetch settings from archive */
			//plugin.onLoad = function() { this.plugin.Activate(); UtilsBase.PrintChatText('m:' + this.mc ); }
			plugin.onLoad = function() { this.plugin.Activate(); }
			
			plugins.push( plugin );
		}
		
		// sort the array alphabetically
		plugins.sortOn( 'name', Array.CASEINSENSITIVE );
		
		ready = true;
		SignalReady.Emit();
	}
	
}