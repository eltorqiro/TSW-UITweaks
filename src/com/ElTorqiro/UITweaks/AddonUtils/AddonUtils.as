import com.GameInterface.UtilsBase;
import flash.geom.ColorTransform;
import flash.geom.Point;

/**
 * Utility class for TSW addons
 */
class com.ElTorqiro.UITweaks.AddonUtils.AddonUtils
{
	// cannot be instantiated, static class only
	private function Utils() {}
	
	/**
	 * Checks if a movieclip is fully within the visible area of the Stage, and returns the closest coordinates that would make it so
	 * 
	 * @param	mc MovieClip to check for
	 * @return	Point which would bring the movieclip fully into Stage.visibleRect (in mc-local coordinates)
	 */
	public static function OnScreen(mc:MovieClip):Point
	{
		// TODO: adjust for global / visible coordinates and back to local
		// Not sure how to do this successfully, as localToGlobal seems to give a result that is 2x bigger than (e.g. a real 500 becomes a "global" 1000)
		//    var s_ResolutionScaleMonitor = DistributedValueBase.GetDValue("GUIResolutionScale");
		//    var s_HUDScaleMonitor = DistributedValueBase.GetDValue("GUIScaleHUD");
		
		var onScreenPosition:Point = new Point(mc._x, mc._y);
		
		// check if bounds are outside visible area
		if ( mc._x < 0 ) onScreenPosition.x = 0;
		else if ( mc._x + mc._width > Stage.visibleRect.width ) onScreenPosition.x = Stage.visibleRect.width - mc._x - mc._width;

		if ( mc._y < 0 ) onScreenPosition.y = 0;
		else if ( mc._y + mc._height > Stage.visibleRect.height ) onScreenPosition.y = Stage.visibleRect.height - mc._y - mc._y;

		return onScreenPosition;
	}

	
	/**
	 * Prints the content of an object in the chat window in game
	 * 
	 * @param	o The object to dump
	 */
	public static function VarDump(o:Object):Void
	{
		for ( var s:String in o )
		{
			UtilsBase.PrintChatText( s + ": " + o[s] );
		}
	}
	
	
	/**
	 * Colorize movieclip using color multiply method rather than flat color
	 * 
	 * Courtesy of user "bummzack" at http://gamedev.stackexchange.com/a/51087
	 * 
	 * @param	object The object to colorizee
	 * @param	color Color to apply
	 */	
	public static function Colorize(object:MovieClip, color:Number):Void {
		// get individual color components 0-1 range
		var r:Number = ((color >> 16) & 0xff) / 255;
		var g:Number = ((color >> 8) & 0xff) / 255;
		var b:Number = ((color) & 0xff) / 255;

		// get the color transform and update its color multipliers
		var ct:ColorTransform = object.transform.colorTransform;
		ct.redMultiplier = r;
		ct.greenMultiplier = g;
		ct.blueMultiplier = b;

		// assign transform back to sprite/movieclip
		object.transform.colorTransform = ct;
	}	
	
	
	/**
	 * Test if a number is within the valid RGB colour range
	 * 
	 * @param	value Number to test for RGB validity
	 */
	public static function isRGB(value:Number):Boolean {
		return value >= 0 && value <= 0xffffff;
	}
	
	
	/**
	 * Test is an object has no properties
	 * 
	 * @param	object
	 * @return	true if there is at least one property in object
	 */
	public static function isObjectEmpty(object:Object):Boolean {
		var isEmpty:Boolean = true;
		for (var n in object) { isEmpty = false; break; }
		
		return isEmpty;
	}
	

	/**
	 * Scans the _global.Enums object for an Enum with the "path" containing the find string
	 * 
	 * @param	find	string to find in the entire Enum path, leave empty to print the entire nested list
	 */
	public static function FindGlobalEnum(find:String) {
		
		if ( find == "" ) find = undefined;
		
		var enumPaths:Array = [ "" ];
		var enums:Array = [ _global.Enums ];
		
		var theEnum = _global.Enums;
		var enumPath = "";
		
		var foundCount:Number = 0;
		
		var findText:String = find != undefined ? find : "[all names]";
		UtilsBase.PrintChatText('<br />');
		UtilsBase.PrintChatText('In _global.Enums, matching <font color="#00ccff">' + findText + "</font><br /><br />");
		
		while ( enums.length ) {
		
			for ( var s:String in theEnum ) {
				
				// push onto stack if it is another Enum blob node
				if ( theEnum[s] instanceof Object ) {
					enums.push( theEnum[s] );
					enumPaths.push( enumPath + "." + s );
				}
				
				// handle value node
				else {
					var varName = enumPath + "." + s;
					// case-insensitive find
					if ( find == undefined || varName.toLowerCase().indexOf( find.toLowerCase() ) > -1 ) {
						foundCount++;
						UtilsBase.PrintChatText( varName + ": " + theEnum[s] );
					}
					
				}
			}
			
			theEnum = enums.pop();
			enumPath = enumPaths.pop();
		}

		UtilsBase.PrintChatText("<br />");		
		UtilsBase.PrintChatText('Found <font color="#00ff00">' + foundCount + '</font> matching <font color="#00ccff">' + findText + '</font>');
	}

	/**
	 * Provides a copy of a string, in reverse character order.
	 * 
	 * @param	string	String to reverse.
	 * @return	The string in reverse character order.
	 */
	public static function ReverseString(string:String):String {
		var charArray:Array = string.split();
		charArray.reverse();
		return charArray.join();
	}
	
	
	/**
	 * Provides a copy of a string, with all HTML removed from it
	 * 
	 * @param	string	String to remove HTML from
	 * @return	The string with HTML removed
	 */
	public static function StripHTML(htmlText:String):String {
		if ( !(htmlText.length > 0) ) return htmlText;
		
		var istart:Number;
		var plainText:String = htmlText;
		while ((istart = plainText.indexOf("<")) != -1) {
			plainText = plainText.split(plainText.substr(istart, plainText.indexOf(">") - istart + 1)).join("");
		}

		return plainText;
	}
	
	
	/**
	 * Provides a copy of a string, with the first letter capitalised and the rest set to lowercase
	 * 
	 * @param	word	String to convert
	 * @return	The string with first letter capitalised
	 */
	public static function firstToUpper(word:String):String {
		var firstLetter = word.substring(1, 0);
		var restOfWord = word.substring(1);
		return ( firstLetter.toUpperCase() + restOfWord.toLowerCase() );
	}
	

	/**
	 * Converts a numeric color value into a HTML compatible hex string, excluding the leading #
	 * 
	 * @param	color	Numeric value representing an RGB color
	 * @return	color converted into a hex string, e.g. "FF88AA", or an empty string if a non-valid RGB value is passed
	 */
	public static function colorToHex(color:Number):String {
		if ( !isRGB(color) ) return '';
		
		var colArr:Array = color.toString(16).toUpperCase().split('');
		var numChars:Number = colArr.length;
		for ( var a:Number = 0; a < (6 - numChars); a++ ) {
			colArr.unshift("0");
		}
		return ( colArr.join('') );
	}
	
}