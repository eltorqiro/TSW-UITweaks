
/**
 * 
 * 
 */
class com.ElTorqiro.UITweaks.AddonUtils.WaitFor {
	
	private function WaitFor() { }
	
	/**
	 * run a given test at specified intervals, with a maximum wait time for it to become true, and callback based on result
	 * 
	 * @param	test		function to run as a test - must return a boolean
	 * @param	interval	milliseconds between each test
	 * @param	timeout		maximum milliseconds to wait for test to pass
	 * @param	success		callback if test becomes true
	 * @param	failure		callback if test doesn't become true and timeout is exceeded
	 * 
	 * @return	
	 */
	public static function start( test:Function, interval:Number, timeout:Number, success:Function, failure:Function, data:Object ) : Number {
	
		var id:Number = ++increment;
		
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
	 * stop and clear a registered wait
	 * 
	 * @param	id
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