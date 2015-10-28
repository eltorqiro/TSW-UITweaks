/**
 * 
 * Repeats a test function at defined intervals until it either becomes true or a timeout occurs.  In either case, a callback is called.
 * 
 * -- This is best used to "wait for" a thing to become available before manipulating it.
 * 
 */
class com.ElTorqiro.UITweaks.AddonUtils.WaitFor {
	
	/**
	 * static class only, cannot be instantiated
	 */
	private function WaitFor() { }
	
	/**
	 * run a given test at specified intervals, with a maximum wait time for it to become true, and callback based on result
	 * 
	 * @param	test		function to run as a test - must return a boolean
	 * @param	interval	milliseconds between each test
	 * @param	timeout		maximum milliseconds to wait for test to pass
	 * @param	success		callback if test becomes true; signature: success( id:Number, success:Boolean, data:object )
	 * @param	failure		callback if test doesn't become true by the time the timeout is exceeded; signature: failure( id:Number, success:Boolean, data:object )
	 * @param	data		user-defined object which will be passed as a parameter to the success or failure callbacks
	 * 
	 * @return	a unique id number for the created waitfor
	 */
	public static function start( test:Function, interval:Number, timeout:Number, success:Function, failure:Function, data:Object ) : Number {
	
		// use simple rotating "unique id" autoincrement, since no test should be so long running that we reach MAX_VALUE of waitfors before it ends
		if ( ++increment == Number.MAX_VALUE ) increment = 1;
		var id:Number = increment;
		
		// add test to registry
		registry[id] = {
			id: id,
			test: test,
			interval: interval,
			timeout: timeout,
			success: success,
			failure: failure,
			data: data,
			
			startedAt: new Date(),
			timerId: setTimeout( tick, 1, id )
		};
		
		return id;
	}
	
	/**
	 * Used internally to process the tick events for each waitfor.
	 * 
	 * Runs the waitfor's test, and either:
	 *		a) runs the success callback if the test returns true
	 * 		b) runs the failure callback if the test is false and the timeout has occurred
	 * 		c) sets up another wait period when the test will be run again
	 * 
	 * @param	id		the waitfor id to process a tick on
	 */
	private static function tick( id:Number ) : Void {

		var runner:Object = registry[id];
		
		// try to find element at path
		var success:Boolean = Boolean( runner.test() );
		
		// if test passed, trigger success callback
		if ( success ) {
			runner.success( runner.id, true, runner.data );
			delete registry[id];
		}

		// if test failed
		else {
			
			// if timer hasn't expired, try again
			if ( (new Date()) - runner.startedAt < runner.timeout ) {
				runner.timerId = setTimeout( tick, runner.interval, runner.id );
			}
			
			// otherwise trigger failure, test didn't pass in time
			else {
				runner.failure( runner.id, false, runner.data );
				delete registry[id];
			}
			
		}
		
	}
	
	/**
	 * stop and clear a registered waitfor
	 * 
	 * @param	id		the waitfor id to stop
	 */
	public static function stop( id:Number ) : Void {
		if ( id != undefined ) {
			clearTimeout( registry[id].timerId );
			delete registry[id];
		}
	}
	
	/*
	 * internal variables
	 */

	private static var registry:Object = { };
	private static var increment:Number = 0;
	
}