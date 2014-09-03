import com.Utils.Archive;
import com.Utils.Signal;
import XML;
import com.ElTorqiro.UITweaks.Plugin;
import com.ElTorqiro.UITweaks.AddonInfo;
import com.GameInterface.UtilsBase;
import com.GameInterface.DistributedValueBase;

class com.ElTorqiro.UITweaks.PluginHost {
	
	public static var plugins:Array = [];
	public static var ready:Boolean = false;
	
	public static var SignalReady:Signal;
	
	private static var _initialised:Boolean = false;
	private static var _xml:XML;
	
	
	private function PluginHost() {}

	public static function init():Void {
		if ( _initialised ) return;
		
		SignalReady = new Signal();
		_initialised = true;
	}
	
	public static function Load(xmlFile:String):Void {
		// only allow loading once
		// TODO: if "reloading", unload all existing clips, and clear plugins array
		if ( ready ) return;
		
		if ( !_initialised ) init();
		
		_xml = new XML();

		_xml.onLoad = onXMLLoaded;
		_xml.ignoreWhite = true;
		_xml.load( xmlFile );
	}

	private static function onXMLLoaded(success:Boolean):Void {
		// TODO: if status is 0, xml could not be parsed successfully, some user friendly message needed
		//UtilsBase.PrintChatText('loaded:' + success + ', status:' + _xml.status);
		
		var pluginsNode = _xml.firstChild;
		// TODO: check if pluginsNode is actually the <plugins> node
		//UtilsBase.PrintChatText('pluginsNode:' + pluginsNode.nodeName );

		var accountSettings:Archive = DistributedValueBase.GetDValue(AddonInfo.Path + '_AccountPluginSettings');
		
		for (var aNode:XMLNode = pluginsNode.firstChild; aNode != null; aNode = aNode.nextSibling) {

			var plugin:Plugin = new Plugin( AddonInfo.Path.toLowerCase() + '_' + aNode.attributes.location, aNode.attributes.name, AddonInfo.Path + '/plugins/' + aNode.attributes.location, aNode.attributes.depth, aNode.attributes['sub-depth']);
			plugin.description = aNode.attributes.description;
			plugin.author = aNode.attributes.author;
			plugin.contactURL = aNode.attributes['contact-url'];
			
			var pluginSettings:Archive = accountSettings.FindEntry( aNode.attributes.location, new Archive() );
			plugin.settings = pluginSettings.FindEntry( 'settings', new Archive() );

			// load if saved enabled
			if ( pluginSettings.FindEntry('enabled', false) ) plugin.Load();
			
			plugins.push( plugin );
		}
		
		// sort the array alphabetically
		plugins.sortOn( 'name', Array.CASEINSENSITIVE );
		
		ready = true;
		SignalReady.Emit();
	}
	
	private static function onPluginLoaded( plugin:Plugin, success:Boolean ):Void {
		UtilsBase.PrintChatText( 'loaded plugin: ' + plugin.name );
	}
}