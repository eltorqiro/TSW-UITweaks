import com.GameInterface.DistributedValue;
import com.Utils.Archive;
import com.Utils.Signal;
import flash.geom.Point;
import gfx.events.EventDispatcher;
import mx.utils.Delegate;

import com.GameInterface.UtilsBase;
import com.GameInterface.LogBase;


/**
 * 
 * Preferences storage, usage and change event class for TSW
 * 
 * - use add() to create a preference entry with default & initial values
 * - use load() to populate all defined preferences from the assigned DistributedValue (and thus, by proxy, from disk)
 * - use getVal() to retrieve the value of a preference entry
 * - listen for changes to preferences with SignalValueChanged [ OnPrefChanged( name, newValue, oldValue ) ] or with addEventListener
 * - use setVal() to set the value of a preference entry
 * - use save() to serialise and save the preference entries to the assigned DistributedValue (which will push them to disk)
 * 
 * - serialise() will create an Archive object from the preference entries
 * - apply() will deserialise an Archive object and put its values into the matching preference entries
 * 
 */
class com.ElTorqiro.UITweaks.AddonUtils.Preferences {
	
	/**
	 * creates a new Preferences instance
	 * @param	storeName	optional; name of the DistributedValue to use for persistence interface
	 */
	public function Preferences( storeName:String ) {
		
		EventDispatcher.initialize( this );
		SignalValueChanged = new Signal();
		
		prefs = new Object();
		this.storeName = storeName;
	}
	
	// EventDispatcher mix-in
	/** Mixed in from {@link EventDispatcher#addEventListener EventDispatcher} */
	public var addEventListener:Function;	
	/** Mixed in from {@link EventDispatcher#removeEventListener EventDispatcher} */
	public var removeEventListener:Function;
	/** Mixed in from {@link EventDispatcher#hasEventListener EventDispatcher} */
	public var hasEventListener:Function;
	/** Mixed in from {@link EventDispatcher#removeAllEventListeners EventDispatcher} */
	public var removeAllEventListeners:Function;	
	/** Mixed in from {@link EventDispatcher#cleanUpEvents EventDispatcher} */
	private var cleanUpEvents:Function;
	/** Mixed in from {@link EventDispatcher#dispatchEvent EventDispatcher} */
	private var dispatchEvent:Function;

	/**
	 * adds a preference to the list
	 * 
	 * @param	name
	 * @param	defaultvalue
	 * @param	validator	either a function that is called on setVal [ validator(newValue, oldValue) must return the validated new value ] or an object containing min/max values
	 */
	public function add( name:String, defaultValue, validator ) : Void {
		
		prefs[ name ] = {
				value: defaultValue,
				defaultValue: defaultValue,
				validator: validator
		};
		
	}
	
	/**
	 * removes a preference from the list
	 * 
	 * @param	name
	 * @return	true if preference was removed, false if it did not exist
	 */
	public function remove( name:String ) : Boolean {

		if ( prefs[name] != undefined ) {
			delete prefs[name];
			removeAllEventListeners( name );
			
			return true;
		}
		
		return false;
	}
	
	/**
	 * removes all preferences, and also all event listeners
	 */
	public function removeAll() : Void {
		prefs = new Object();
		removeAllEventListeners();
	}
	
	/**
	 * sets a preference value
	 * - Object, Array and Archive types are set as references
	 * 
	 * @param	name
	 * @param	value
	 * @return	the new value of the preference
	 */
	public function setVal( name:String, value ) {

		var equivalentCheckTypes:Object = { string: true, number: true, boolean: true };
		
		// if pref has not been added, report an error
		if ( prefs[name] == undefined ) { 
			debug( "attempt to set value on nonexistent pref: " + name );
			return;
		}

		var oldValue = prefs[name].value;

		// only update if new value is different to old value
		if ( equivalentCheckTypes[ typeof(value) ] && oldValue == value ) return value;

		var newValue = value;
		
		var validator = prefs[name].validator;
		if ( validator ) {
			if ( typeof(validator) == "function" ) {
				newValue = validator( newValue, oldValue );
			}
			
			else {
				newValue = Preferences.validateMinMax( newValue, oldValue, validator );
			}
		}
		
		prefs[name].value = newValue;
		
		dispatchEvent( { type: name, value: newValue, oldValue: oldValue } );
		SignalValueChanged.Emit( name, newValue, oldValue );
		
		return value;
		
	}
	
	public static function validateMinMax( newValue, oldValue, limits ) {
		var value:Number = Math.min( newValue, limits.max );
		value = Math.max( value, limits.min );
				
		return value;
	}
	
	/**
	 * gets the value of a preference
	 * - Object, Array and Archive types are fetched as references
	 * 
	 * @param	name
	 * @return	the value of the preference
	 */
	public function getVal( name:String ) {

		if ( prefs[name] == undefined ) {
			return;
		}
		
		return prefs[name].value;
		
	}

	/**
	 * gets the value of a preference
	 * 
	 * @param	name
	 * @return	the default value of the preference
	 */
	public function getDefault( name:String ) {

		if ( prefs[name] == undefined ) {
			return;
		}
		
		return prefs[name].defaultValue;
	}
		
	/**
	 * resets a preference to its default value
	 * 
	 * @param	name
	 */
	public function reset( name:String ) : Void {
		setVal( name, prefs[name].defaultValue );
	}

	/**
	 * serialises the pref data into an Archive object, which can then be saved to a DistributedValue for persistence
	 */
	public function serialise() : Archive {

		var data:Archive = new Archive();
			
		for ( var s:String in prefs ) {
			
			var pref:Object = prefs[s];
			
			if ( pref.value instanceof Array ) {
				// place elements in an envelope to cater for single element arrays, which would otherwise be loaded back out as non-arrays
				var envelope:Archive = new Archive();
				envelope.AddEntry( "type", "array" );

				var values:Archive = new Archive();
				
				for ( var i in pref.value ) {
					envelope.AddEntry( "keys", i );
					values.AddEntry( i, pref.value[i] );
				}
				
				envelope.AddEntry( "values", values );
				
				data.AddEntry( s, envelope );
			}
			
			else if ( pref.value instanceof Archive ) {
				// place archive in an envelope to avoid confusion with archives that are used as envelopes for other data types
				var envelope:Archive = new Archive();
				envelope.AddEntry( "type", "archive" );
				envelope.AddEntry( "contents", pref.value );
				
				data.AddEntry( s, envelope );
			}
			
			else if ( pref.value instanceof Point ) {
				data.AddEntry( s, new Point( pref.value.x, pref.value.y ) );
			}
			
			else if ( pref.value instanceof Object ) {
				// place object properties in an envelope
				var envelope:Archive = new Archive();
				envelope.AddEntry( "type", "object" );

				var values:Archive = new Archive();
				
				for ( var i in pref.value ) {
					envelope.AddEntry( "keys", i );
					values.AddEntry( i, pref.value[i] );
				}
				
				envelope.AddEntry( "values", values );
				
				data.AddEntry( s, envelope );
			}
			
			else if ( typeof(pref.value) == "number" ) {
				data.AddEntry( s, pref.value );
			}
			
			else if ( typeof(pref.value) == "string" ) {
				data.AddEntry( s, pref.value );
			}
			
			else if ( typeof(pref.value) == "boolean" ) {
				data.AddEntry( s, pref.value );
			}
			
			// not one of the supported types, but try to save it anyway
			else {
				data.AddEntry( s, pref.value );
			}
			
		}

		return data;
	}
	
	/**
	 * saves the preferences to the store distributed value, ready for persistence by the game engine
	 * - this forces an actual commit to disk, which is handled by the game, because it puts a value into one of the DistributedValue defined in Modules.xml
	 */
	public function save() : Void {
		if ( storeName != undefined ) {
			DistributedValue.SetDValue( storeName, serialise() );
		}
	}
	
	/**
	 * loads the preferences from the persistence interface
	 * - cannot force the store dv to be populated from disk, that is handled by the game
	 */
	public function load() : Void {
		if ( storeName != undefined ) {
			apply( DistributedValue.GetDValue( storeName ) );
		}
	}
	
	/**
	 * applies the contents of a serialised Archive to the current values of the prefs
	 */
	public function apply( store:Archive ) : Void {

		if ( store == undefined || !(store instanceof Archive) ) return;
		
		for ( var s:String in prefs ) {
			
			var el = store.FindEntry( s, null );
			
			// avoid making the value empty if there is simply nothing to load, this will leave it at the default value
			if ( el == null ) continue;
			
			var value;
			
			// if an archive, it is an envelope for another data type
			if ( el instanceof Archive ) {
				
				var type:String = el.FindEntry( "type" );
				
				switch ( type ) {

					case "array":
						
						value = new Array();
						
						var keys:Array = el.FindEntryArray( "keys" );
						var values:Archive = el.FindEntry( "values" );
						for ( var i in keys ) {
							value[ keys[i] ] = values.FindEntry( keys[i] );
						}
						
					break;
					
					case "archive":
						value = el.FindEntry( "contents" );
					break;
					
					case "object":
					
						value = new Object();
						
						var keys:Array = el.FindEntryArray( "keys" );
						var values:Archive = el.FindEntry( "values" );
						for ( var i in keys ) {
							value[ keys[i] ] = values.FindEntry( keys[i] );
						}
						
					break;
				}
				
			}
			
			// otherwise a regular data type, load it directly
			else {
				value = el;
			}

			// apply value to preference
			prefs[s].value = value;
		}
		
	}

	/**
	 * return the private contents object (m_Dictionary) from inside an Archive
	 * - note this is a reference, so be careful you don't change its contents to something out-of-format
	 * - be careful that an Archive that has been "deconstructed" like this never gets saved, it will crash the game
	 * 
	 * @param	archive
	 * @return
	 */
	private static function getArchiveDictionary( archive:Archive ) : Object {
		
		archive["fn"] = Delegate.create( archive, function() {
			return this["m_Dictionary"];
		});
		
		var dict:Object = archive["fn"]();
		
		delete archive["fn"];
		
		return dict;
	}
	
	/**
	 * clears up as much of the state of the object as possible
	 */
	public function dispose() : Void {
		prefs = null;
		removeAllEventListeners();
		
		SignalValueChanged = null;
	}
	
	/**
	 * prints a message to the chat window and the ClientLog.txt file if debug is enabled
	 * 
	 * @param	msg
	 */
	public static function debug( msg:String ) : Void {
		
		var message:String = msg;
		
		UtilsBase.PrintChatText( "Preferences: " + message );
		LogBase.Print( 3, "Preferences", message );
	}

	/*
	 * internal variables
	 */
	 
	private var prefs:Object;
	private var storeName:String;

	
	/*
	 * properties
	 */
	
	public function get list() : Object {
		return prefs;
	}
	 
	public var SignalValueChanged:Signal;
}