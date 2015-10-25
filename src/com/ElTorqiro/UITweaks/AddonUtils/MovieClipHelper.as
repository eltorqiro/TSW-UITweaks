

/**
 * 
 * 
 */
class com.ElTorqiro.UITweaks.AddonUtils.MovieClipHelper {
	
	private function MovieClipHelper() { }
	
	/**
	 * creates an empty movieclip from a class, without needing it to be linked to a symbol in the library
	 * - class definitions used by this method must contain a public static string __className which uniquely identifies the class, minus the "__Packages." prefix
	 * - instances created this way fully support duplicateMovieClip and are in all other ways treated the same as a regular attachMovie() would be
	 * - the class can attach its own internal movieclips to display visual elements
	 * 
	 * @param	classRef	must contain a static var __className containing the fully qualified path of the class
	 * @param	name
	 * @param	parent
	 * @param	depth
	 * @param	initObj
	 * 
	 * @return
	 */
	public static function createMovieWithClass( classRef:Function, name:String, parent:MovieClip, depth:Number, initObj:Object ) : Object {
		
		if ( parent == undefined || classRef.__className == undefined ) return;
		if ( depth == undefined ) depth = parent.getNextHighestDepth();
		if ( name == undefined || name == "" ) name = classRef.__className.split(".").join("_") + "_" + parent.getNextHighestDepth();
		
		Object.registerClass( "__Packages." + classRef.__className, classRef );
		return parent.attachMovie( "__Packages." + classRef.__className, name, depth, initObj );
		
	}

	/**
	 * attaches a symbol from the library, and links it to a class
	 * - instances created this way do not support duplicateMovieClip, which will instead duplicate a raw movieclip (or whatever class the symbol was originally linked to in the library)
	 * 
	 * @param	id
	 * @param	classRef
	 * @param	name
	 * @param	parent
	 * @param	depth
	 * @param	initObj
	 * 
	 * @return
	 */
	public static function attachMovieWithClass( id:String, classRef:Function, name:String, parent:MovieClip, depth:Number, initObj:Object ) : Object {

		var mc:MovieClip = parent.attachMovie( id, name, depth, initObj );

		mc.__proto__ = classRef.prototype;
		
		for ( var s:String in initObj ) {
			mc[s] = initObj[s];
		}
		
		// trigger constructor
		classRef.apply(mc);
		
		// trigger onLoad, since the timeline has already called onLoad on the originally attached movieclip and won't do so again
		mc.onLoad();

		return mc;
	}

	/**
	 * attaches a symbol from the library, first registering it with a class, then clearing the registration
	 * - instances created this way *may* not support duplicateMovieClip
	 * - instances use the full Flash flow for movieclip creation, the same as regular attachMovie()
	 * - this is a good alternative for keeping symbol+className linkages unique per project
	 * 
	 * @param	id
	 * @param	classRef
	 * @param	name
	 * @param	parent
	 * @param	depth
	 * @param	initObj
	 * 
	 * @return
	 */
	public static function attachMovieWithRegister( id:String, classRef:Function, name:String, parent:MovieClip, depth:Number, initObj:Object ) : MovieClip {
		
		Object.registerClass( id, classRef );
		var mc:MovieClip = parent.attachMovie( id, name, depth, initObj );
		Object.registerClass( id, null );
		
		return mc;
	}
	
	/**
	 * changes the class of an existing movieclip
	 * - instances modified this way do not support duplicateMovieClip
	 * - it is best to only ever do this on clips that start off as raw MovieClip objects, as extended classes *may* have listeners or other behaviour which doesn't necessarily go out of scope
	 * 
	 * @param	id
	 * @param	classRef
	 * @param	name
	 * @param	parent
	 * @param	depth
	 * @param	initObj
	 * 
	 * @return
	 */
	public static function changeMovieClass( clip:MovieClip, classRef:Function ) : MovieClip {
		
		clip.__proto__ = classRef.prototype;
		
		// trigger constructor
		classRef.apply( clip );
		
		// trigger onLoad, since the timeline won't call it again
		clip.onLoad();
		
		return clip;
	}
	
}