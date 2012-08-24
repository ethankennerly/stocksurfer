package  
{
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;
	import org.flixel.FlxG;
	import org.flixel.FlxSprite;

	/* Water levels image to draw on bitmap data.
	 * @author Ethan Kennerly
	 */
	public class Water extends Sprite {

		public static var lineWidth:int = 4;

		// var xPerPrice:int = 10; // too narrow
		// public static var xPerPrice:int = 30; // too narrow?
		// public static var xPerPrice:int = 60; // too narrow?
		public static var xPerPrice:int = 120; // too narrow?
		// var xPerPrice:int = 35; // Invalid BitmapData
		// var xPerPrice:int = 50; // Invalid BitmapData
		// var xPerPrice:int = 100; // Invalid BitmapData
		// public static var yPerPrice:int = 40; // too shallow?
		// public static var yPerPrice:int = 30; // why is water offset?
		// public static var yPerPrice:int = 60;  
		public static var yPerPrice:int = 
							// 12;  // MSFT do not see slope.
							120;   // price 100, do not see.
		// public static var yPerPrice:int = 80; // offset?
		// public static var yPerPrice:int = 50; // too high?
		// public static var yPerPrice:int = 100; // too high?
		// public static var priceBase:Number = -20;  // flat
		public static var priceBase:Number = 0;
		public static var xs:Vector.<int> = new Vector.<int>();
		public static var ys:Vector.<int> = new Vector.<int>();
		
		/* Construct vector image of line chart of stock prices and populate coordinates. */
		public function Water(prices:Vector.<Number> = null) {
			if (null === prices) {
				prices = Broker.array;
			}
			super();
			var targetMaxSlope:Number = 4.0;
			var slopeScale:Number = targetMaxSlope / Broker.absMaxSlope(prices);
			Water.yPerPrice = Water.xPerPrice * slopeScale;
			var maxPrice:Number = Broker.max(prices);
			Water.xs = new Vector.<int>();
			Water.ys = new Vector.<int>();
			this.graphics.clear();
			this.graphics.beginFill(0xffaaaacc);
			this.graphics.lineStyle(lineWidth, 0xffddddff);
			this.graphics.beginFill(0x33666699);
			for (var p:int = 0; p < prices.length; p ++) {
				var price:Number = prices[p];
				var px:int = p * Water.xPerPrice;
				var py:int = int((maxPrice - price) * Water.yPerPrice + lineWidth);
				Water.xs.push(px);
				Water.ys.push(py);
				if (0 == p) {
					this.graphics.moveTo(px, py);					
				}
				else {
					this.graphics.lineTo(px, py);
				}
			}
			var maxY:int = int(maxPrice * Water.yPerPrice + lineWidth + FlxG.height);
			this.graphics.lineTo(px, maxY);
			this.graphics.lineTo(0, maxY);
			this.graphics.endFill();
		}
		
		/* Interpolate integer of vertical position on screen */
		public function getY(sx:int):int {
			var px0:int = 0;
			var px1:int = 0;
			var py0:int = 0;
			var py1:int = 0;
			var sy:int = 0;
			for (var p:int = 0; p < xs.length; p ++) {
				px1 = xs[p];
				py1 = ys[p];
				if (px0 <= sx && sx <= px1) {
					var rate:Number = (py1 - py0) / (px1 - px0); 
					sy = py0 + int( (sx - px0) * rate);
					break;
				}
				px0 = px1;
				py0 = py1;
			}			
			return sy;
		}

		/* interpolate floating point value of each unit of stock */
		public function getPrice(price_array:Vector.<Number>, sx:int):Number {
			var px0:int = 0;
			var px1:int = 0;
			var price0:Number = 0;
			var price1:Number = 0;
			var price:Number = 0;
			for (var p:int = 0; p < xs.length; p ++) {
				px1 = xs[p];
				price1 = price_array[p];
				if (px0 <= sx && sx <= px1) {
					var rate:Number = (price1 - price0) / (px1 - px0); 
					price = price0 + (sx - px0) * rate;
					break;
				}
				px0 = px1;
				price0 = price1;
			}			
			return price;
		}
		
		public function buoy(sprite:FlxSprite, offsetY:int = 0):void {
			var sy:int = this.getY(sprite.x + sprite.offset.x); // why is higher than water line?
			var floatY:int = sprite.y
					+ 0.5 * 
					sprite.height + offsetY; // levitate
					// sprite.height; // levitate
			if (sy < floatY) {
				sprite.velocity.y = 
				// sprite.velocity.y = -400 * (sprite.y - sy); // too bouncy
				// sprite.velocity.y = -200 * (sprite.y - sy); // too bouncy
				// sprite.velocity.y = -100 * (floatY - sy); // too bouncy
				// sprite.velocity.y = -75 * (floatY - sy); // bouncy
										// -68 // bouncy
										// -57 // bouncy at x4
										-50 // strict
										* (floatY - sy); 
				// sprite.velocity.y = -50 * (sprite.y - sy); // strict
				sprite.acceleration.y *= 0.5; // follow strictly
				// sprite.acceleration.y = 0; // follow strictly
				// sprite.acceleration.y = -50; // too loose
				// sprite.acceleration.y = -400 * (sprite.y - sy); // too loose
				// sprite.acceleration.y *= 0.95; // follow strictly
				// sprite.acceleration.y *= 0.9999; // follow strictly
				//sprite.y = sy;
			}
			else {
				// sprite.acceleration.y = 100; // too wavy
				sprite.acceleration.y = 400; 
				//sprite.y = sy;
			}
		}
	}
}
