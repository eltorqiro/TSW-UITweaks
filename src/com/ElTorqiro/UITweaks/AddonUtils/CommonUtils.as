import flash.geom.ColorTransform;

import com.GameInterface.UtilsBase;


/**
 * 
 * 
 */
class com.ElTorqiro.UITweaks.AddonUtils.CommonUtils {
	
	private function CommonUtils() { }
	
	/**
	 * Colorize movieclip using color multiply method rather than flat color
	 * 
	 * Courtesy of user "bummzack" at http://gamedev.stackexchange.com/a/51087
	 * 
	 * @param	object The object to colorizee
	 * @param	color Color to apply
	 */	
	public static function colorize( object:MovieClip, color:Number ) : Void {
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
	 * @return	true if the number is a valid RGB, otherwise false
	 */
	public static function isRGB( value:Number ) : Boolean {
		return value >= 0 && value <= 0xffffff;
	}

	/**
	 * Converts a numeric color value into a HTML compatible hex string, excluding the leading #
	 * 
	 * @param	color	Numeric value representing an RGB color
	 * @return	color converted into a hex string, e.g. "FF88AA", or an empty string if a non-valid RGB value is passed
	 */
	public static function colorToHex( color:Number ) : String {
		if ( !isRGB(color) ) return '';
		
		var colArr:Array = color.toString(16).toUpperCase().split('');
		var numChars:Number = colArr.length;
		for ( var a:Number = 0; a < (6 - numChars); a++ ) {
			colArr.unshift("0");
		}
		return ( colArr.join('') );
	}

	/**
	 * Returns a copy of a string, with the first letter capitalised and the rest set to lowercase
	 * 
	 * @param	word	String to convert
	 * @return	The string with first letter capitalised
	 */
	public static function firstToUpper( word:String ) : String {
		var firstLetter = word.substring(1, 0);
		var restOfWord = word.substring(1);
		return ( firstLetter.toUpperCase() + restOfWord.toLowerCase() );
	}
	
	/**
	 * Returns a copy of a string, with all HTML removed from it
	 * 
	 * @param	string	String to remove HTML from
	 * @return	The string with HTML removed
	 */
	public static function stripHtml( htmlText:String ) : String {
		if ( !(htmlText.length > 0) ) return htmlText;
		
		var istart:Number;
		var plainText:String = htmlText;
		while ((istart = plainText.indexOf("<")) != -1) {
			plainText = plainText.split(plainText.substr(istart, plainText.indexOf(">") - istart + 1)).join("");
		}

		return plainText;
	}

	/**
	 * Returns a copy of a string, in reverse character order.
	 * 
	 * @param	string	String to reverse.
	 * @return	The string in reverse character order.
	 */
	public static function reverseString( original:String ):String {
		var charArray:Array = original.split();
		charArray.reverse();
		return charArray.join();
	}
	
	/**
	 * Extracts numeric sequences (including decimal point) from a string and returns them as an array of numbers
	 * 
	 * Only works with digits 0-9 and . so does not support hex or other base values
	 * 
	 * @param	string	The string to find numbers inside
	 * @return	The numeric values found, in an array, zero length if no numbers found
	 */
	public static function extractNumbers( string:String ) : Array {
		
		var capturing:Boolean = false;
		var numArray:Array = [];
		var numbers:Array = [];
		
		var length:Number = string.length;
		for ( var i:Number = 0; i < length; i++ ) {
			
			var charCode:Number = string.charCodeAt(i);
			if ( (charCode >= 48 && charCode <= 57) || ( capturing && charCode == 46 && i != length - 1)) {
				capturing = true;
				numArray.push( string.charAt(i) );
			}
			
			else if ( capturing ) {
				capturing = false;
				numbers.push( Number(numArray.join('')) );
				numArray = [];
			};
		}

		if( numArray.length > 0 ) { numbers.push( Number(numArray.join('')) ); }

		return numbers;
	}
	
	/**
	 * Scans the _global.Enums object for an Enum with the "path" containing the find string
	 * 
	 * @param	find	string to find in the entire Enum path, leave empty to print the entire nested list
	 */
	public static function findGlobalEnum( find:String ) : Void {
		
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
	 * Draws a rectangle on an existing movieclip, with options for rounded corners
	 * 
	 * Does not process any fill or line on the draw, begin those on the movieclip prior to calling this function
	 * 
	 * @param	mc					MovieClip to draw onto
	 * @param	x					x coordinate within the movieclip to start the rectangle
	 * @param	y					y coordinate within the movieclip to start the rectangle
	 * @param	w					width of the coordinate, which will be in movieclip-local scale, not pixel
	 * @param	h					height of the coordinate, which will be in movieclip-local scale, not pixel
	 * @param	topLeftCorner		radius of the top left corner, leave zero to not have a curved corner
	 * @param	topRightCorner		radius of the top right corner, leave zero to not have a curved corner
	 * @param	bottomRightCorner	radius of the bottom right corner, leave zero to not have a curved corner
	 * @param	bottomLeftCorner	radius of the bottom left corner, leave zero to not have a curved corner
	 */
	public static function drawRectangle(	mc:MovieClip, x:Number, y:Number, w:Number, h:Number, 
											topLeftCorner:Number, topRightCorner:Number, bottomRightCorner:Number, bottomLeftCorner:Number) : Void {

		if ( mc == undefined || !(mc instanceof MovieClip) ) return;
		
		if ( topLeftCorner == undefined ) topLeftCorner = 0;
		if ( topRightCorner == undefined ) topRightCorner = 0;
		if ( bottomRightCorner == undefined ) bottomRightCorner = 0;
		if ( bottomLeftCorner == undefined ) bottomLeftCorner = 0;
		
		mc.moveTo(topLeftCorner+x, y);
		mc.lineTo(w - topRightCorner, y);
		mc.curveTo(w, y, w, topRightCorner+y);
		mc.lineTo(w, topRightCorner+y);
		mc.lineTo(w, h - bottomRightCorner);
		mc.curveTo(w, h, w - bottomRightCorner, h);
		mc.lineTo(w - bottomRightCorner, h);
		mc.lineTo( bottomLeftCorner+x, h);
		mc.curveTo(x, h, x, h - bottomLeftCorner);
		mc.lineTo(x, h - bottomLeftCorner);
		mc.lineTo(x, topLeftCorner+y);
		mc.curveTo(x, y, topLeftCorner+x, y);
		mc.lineTo(topLeftCorner+x, y);
	}
	
	/*
	 * internal variables
	 */

	 
	/*
	 * properties
	 */
	
}