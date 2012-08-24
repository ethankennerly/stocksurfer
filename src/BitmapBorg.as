package
{
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;

	/* FlxG.addBitmap expects Class and reads its bitmapData.
	@author Ethan Kennerly
	Based on:
	Loading external images for use with Flixel Sprites
	Sun 24 Oct 2010 · 09:51 AM by Jarod
	http://www.iokat.com/posts/3/loading-external-images-for-use-with-flixel-sprites
	 */
	public class BitmapBorg {

		public static var _bitmapData:BitmapData;
		public static var _string:String = "[class BitmapBorg]";

		public function get bitmapData():BitmapData {
			return _bitmapData;
		}

		public function toString():String {
			return _string;
		}

		public static function setBitmapData(bitmapData:BitmapData, string:String):void {
			BitmapBorg._bitmapData = bitmapData;
			BitmapBorg._string = string;
		}

		public static function drawBitmapData(drawable:DisplayObject):void {
			BitmapBorg._bitmapData = new BitmapData(drawable.width, drawable.height, true, 0x00000000);
			BitmapBorg._bitmapData.draw(drawable);
			BitmapBorg._string = drawable.toString() + "[class BitmapBorg]";
		}
		
		/* Render a small rectangle bitmap from the vector image that may be too large. */
		public static function drawRectangle(drawable:DisplayObject, x:int, y:int, width:int, height:int, scaleX:Number=1, scaleY:Number=1):BitmapData {
			var pixels:BitmapData = new BitmapData(width, height, true, 0x00000000);
			var clipRect:Rectangle = new Rectangle(0, 0, width, height);
			var trans:Matrix = new Matrix(
										scaleX, 0, 
										0,      scaleY, 
										-x,     -y);
			pixels.draw(drawable, trans, null, null, clipRect, true);
			//? pixels.noise(getTimer(), 63, 127, 1, true);  // diagnostic
			return pixels;
		}
	}
}
