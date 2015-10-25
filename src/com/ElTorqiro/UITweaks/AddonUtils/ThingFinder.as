
/**
 * 
 * 
 */
class com.ElTorqiro.UITweaks.AddonUtils.ThingFinder {
	
	private function ThingFinder() { }
	
	/**
	 * find an element
	 * 
	 * @param	path		path to the "thing" - will be eval'd to discover if it exists
	 * @param	interval	milliseconds between each test for existence of thing
	 * @param	timeout		maximum milliseconds to wait for thing to exist
	 * @param	success		callback if thing is found
	 * @param	failure		callback if thing isn't found after timeout has passed
	 * 
	 * @return	
	 */
	public static function find( path:String, interval:Number, timeout:Number, success:Function, failure:Function ) : Number {
	
		var id:Number = ++increment;
		
		// setup search memory if it doesn't exist or an external source is asking it to be restarted
		finders[id] = {
			id: id,
			path: path,
			interval: interval,
			timeout: timeout,
			success: success,
			failure: failure,
			
			start: new Date(),
			timerId: setTimeout( test, 1, id )
		};
		
		return id;
	}
	
	private static function test( id:Number ) : Void {

		var finder:Object = finders[id];
		
		// try to find element at path
		var thing = eval( finder.path );

		// if thing is found, trigger success callback
		if ( thing != undefined ) {
			finder.success( finder.id, thing );
			delete finders[id];
		}

		// if it isn't found
		else {
			
			// if timer hasn't expired, look again
			if ( (new Date()) - finder.start < finder.timeout ) {
				finder.timerId = setTimeout( test, finder.interval, finder.id );
			}
			
			// otherwise trigger failure, thing wasn't found in time
			else {
				finder.failure( finder.id, finder.path );
				delete finders[id];
			}
			
		}
		
	}
	
	/**
	 * cancel an in-progress find
	 * 
	 * @param	id
	 */
	public static function cancel( id:Number ) : Void {
		if ( id != undefined ) {
			clearTimeout( finders[id].timerId );
			delete finders[id];
		}
	}
	
	/*
	 * internal variables
	 */

	private static var finders:Object = { };
	private static var increment:Number = 0;
	
	/*
	 * properties
	 */
	
}