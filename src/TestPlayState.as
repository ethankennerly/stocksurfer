package
{
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import org.flixel.FlxG;
	import org.flixel.FlxRect;
	import org.flixel.FlxSprite;

	public class TestPlayState extends MenuState
	{
		
		/*
		Play state create initializes follow min and max.
		If all tests pass, Ethan expects menu to appear.
		To avoid incompatible override, expect exactly same signature as play state.
		http://www.as3errors.com/1023-incompatible-override
		*/
		override public function create():void
		{
			var _watchArray:Vector.<Number> = prices.array;
			var _watchArrayMsft:Vector.<Number> = prices.arrays["MSFT"];
			var _watchArrayGoog:Vector.<Number> = prices.arrays["GOOG"];
			prices.array = prices.arrays["GOOG"];
		
			super.create();
			TestPlayState.testUnitBuy();
			TestPlayState.testBuyMaxMoneySeconds();
			TestPlayState.testMaxSlope();
			// TestPlayState.testSharkOverlapPlayer();
			// TODO:  TestPlayState.testScrollWater();
			// FlxG.switchState(new MenuState());
			// onEnterFrame calls FlxGame.switchState 
			// var eventDispatcher:EventDispatcher = new EventDispatcher();
			// eventDispatcher.dispatchEvent(new Event(Event.ENTER_FRAME, true));
		}

		/* Ethan expects to see a white circle with a section chopped on left edge of bitmap. */
		public static function drawClippedWhiteCircle():BitmapData {
			var sprite:Sprite = new Sprite();
			sprite.graphics.beginFill(0xFFFFFF);
			sprite.graphics.drawCircle(1<<8, 1<<8, 1<<8);
			sprite.graphics.endFill();
			return BitmapBorg.drawRectangle(sprite, 1<<6, 0, FlxG.width, FlxG.height);
		}

		/* Ethan expects to see water in upper left corner. */
		public static function addSmall(image:DisplayObject, stage:Stage):void {
			image.scaleX = 0.01;
			image.scaleY = 0.01;
			stage.addChild(image);
		}
		/*
		Ethan expects water Flixel sprite size of window.
		Ethan expects different height water to have different pixels.
		After update scrolls camera to where player is at and draws to bitmap data,
		Ethan expects pixels in rectangle before scroll and after scroll to match.
		*/
		/*
		public static function testScrollWater():void {
			if (! (FlxG.width / 16 <= Water.xPerPrice)) {
				throw new Error("Expected water x per price wider than " + Water.xPerPrice.toString());
			}
			prices.array = new Vector.<Number>();
			for (var n:Number = 1.0; n <= 32.0; n += 1.0) {
				prices.array.push(n);
			}
			FlxG.switchState( new PlayState() ); // TODO:  DOES NOT SWITCH STATE YET
			var state:PlayState = FlxG.state as PlayState;
			var waterFlxSprite:FlxSprite = state.waterFlxSprite;
			if (! (FlxG.width == waterFlxSprite.width)) {
				throw new Error("Expected width equal to window, got " + waterFlxSprite.width.toString());
			}
			if (! (FlxG.height == waterFlxSprite.height)) {
				throw new Error("Expected height equal to window, got " + waterFlxSprite.height.toString());
			}
			prices.x = Water.xs[2];
			prices.y = Water.ys[2];
			state.update();
			var x:int = FlxG.width - 1;
			var y:int = FlxG.height - 1;
			var rect:Rectangle = new Rectangle(x - Water.xPerPrice, 0, Water.xPerPrice, y);
			var pixels:ByteArray = waterFlxSprite.pixels.getPixels(rect);
			var scrolledRect:Rectangle = new Rectangle(x - 2 * Water.xPerPrice, 0, Water.xPerPrice, y);
			var scrolledPixels:ByteArray = waterFlxSprite.pixels.getPixels(scrolledRect);
			if (! (pixels != scrolledPixels)) {
				throw new Error("Expected pixels not to match before scrolled.");
			}
			state.prices.x = Water.xs[3];
			state.prices.y = Water.ys[3];
			state.update();
			scrolledPixels = waterFlxSprite.pixels.getPixels(scrolledRect);
			if (! (pixels == scrolledPixels)) {
				throw new Error("Expected pixels to match after scrolled.");
			}
		}
		*/
		
		/* 
		TODO:  Setting state notifies Flixel globals to initialize bitmap cache.
		Each point of the water is OUTSIDE the Flixel world follow boundaries.
		Because to align to camera, scroll shifts water in the opposite direction.
		*/
		public static function testWaterInFollowBounds():void {
			for (var s:String in prices.arrays) {
				prices.array = prices.arrays[s];
				FlxG.switchState( new PlayState() );
				if (! (2 <= Water.xs.length) ) {
					throw new Error("Expected water x ordinates longer than " + Water.xs.length.toString());
				}
				for (var i:int = 0; i < Water.xs.length; i ++) {
					var x:Number = Water.xs[i];
					var y:Number = Water.ys[i];
					var bounds:FlxRect = FlxG.camera.bounds as FlxRect;
					var min_x:Number = bounds.left;
					var message:String = "";
					if (! (x <= min_x) ) {
						message += "\nExpected water x below follow min x:";
					}
					var min_y:Number = bounds.top;
					if (! (y <= min_y) ) {
						message += "\nExpected water y below follow min y:"
					}
					var max_x:Number = bounds.right;
					if (! (max_x <= x) ) {
						message += "\nExpected follow max x below water y:"
					}
					var max_y:Number = bounds.bottom;
					if (! (max_y <= y) ) {
						message += "\nExpected follow max y below water y:"
					}
					if ("" != message) {
						message += "\n    water[" + i.toString() + "] x " + x.toString() + " y " + y.toString();
						message += "\n    followMin x " + min_x.toString() + " y " + min_y.toString();
						message += "\n    followMax x " + max_x.toString() + " y " + max_y.toString();
						throw new Error(message);
					}
				}
			}
		}

		/* If shark overlap player at beginning through end, Ethan expects player to die. */
		/*
		public static function testSharkOverlapPlayer():void {
			for (var s:String in prices.arrays) {
				prices.array = prices.arrays[s];
				FlxG.switchState( new PlayState() );
				var state:PlayState = FlxG.state as PlayState;
				state.update();
				if (! (state.prices.alive)) {
					throw new Error("Expect player alive.");
				}
				state.prices.x = Water.xs[Water.xs.length - 1];
				state.prices.y = Water.ys[Water.ys.length - 1];
				state.shark.x = state.prices.x;
				state.shark.y = state.prices.y;
				state.update();
				if (! (!state.prices.alive)) {
					throw new Error("In " + s + ", after overlap at end with shark, expect player dead.");
				}
			}
		}
		*/
		
		/*
		Ethan expects to have shark following closely when buy as much as possible.
		With starting money, Ethan expects to buy no more than 10 times.
		So with 60000 starting money, Ethan expects to buy 6000 each.
		*/
		public static function testUnitBuy():void {
			var unit:int;
			unit = prices.unitBuy(2.0, -500.0, new <Number>[100.0], 50);
			if (! (10 == unit)) {
				throw new Error("Expect to buy 10 units with rent -500 and price 100; got " + unit.toString());
			}
			unit = prices.unitBuy(2.0, -500.0, new <Number>[100.0], 60000);
			if (! (60 == unit)) {
				throw new Error("Expect to buy 60 units with rent -500 and price 100 and start money 60000; got " + unit.toString());
			}
		}

		/*
		For MSFT or GOOG array of stock prices and buying units, 
		after buying with maximum remainder,
		Ethan expects seconds to pay rent between 0.01 and 5.
		Ethan expects to start with enough money to buy 3 to 20 times at maximum price.
		
		Play state expects prices array to contain each step's price.
		Setting state notifies Flixel global helper to initialize bitmap cache.
		*/
		public static function testBuyMaxMoneySeconds():void {
			for (var s:String in prices.arrays) {
				FlxG.score = prices.startMoney;
				prices.array = prices.arrays[s];
				var maxPrice:Number = prices.max(prices.array);
				var player:Player = new Player();
				prices.money = prices.startMoney;
				var unitSeconds:Number =
											// 2.0;   // have to click too fast.
											// 4.0;   // make more money on MSFT
											8.0;
				prices.unit = prices.unitBuy(unitSeconds, prices.moneyPerSecond, prices.array, prices.money);
				var maxRemainder:Number = prices.unit * maxPrice * 0.999;
				var seconds:Number = 0.0 - (maxRemainder / prices.moneyPerSecond);
				
				var message:String = "";
				if (! (0.01 <= seconds && seconds <= 10)) {
					message += "\nExpected seconds 0.01 <= " + seconds.toPrecision(5).toString() + " <= 10";
				}
				var minPurchaseCount:int = int(prices.money / (maxPrice * prices.unit));
				if (! (3 <= minPurchaseCount && minPurchaseCount <= 20)) {
					message += "\nExpected to purchase at least 3 <= " + minPurchaseCount.toString() + " <= 20";
				}
				if (! ("" == message)) {
					throw new Error(message 
						+ "\n    arrays[" + s + "] maxPrice " + maxPrice.toPrecision(5).toString() 
						+ " maxRemainder " + maxRemainder.toPrecision(5).toString() 
						+ "\nplayer.money " + prices.money.toString() 
						+ " prices.unit " + prices.unit.toString() 
						+ " prices.moneyPerSecond " + prices.moneyPerSecond.toPrecision(5).toString() 
						+ "\nminPurchaseCount " + minPurchaseCount.toString() 
					);
				}
			}
		}
		
		/*
		On MSFT or GOOG, Ethan expects absolute (rise or fall) maximum slope between 2 and 6.
		*/
		public static function testMaxSlope():void {
			for (var s:String in prices.arrays) {
				prices.array = prices.arrays[s];
				var water:Water = new Water(); 
				if (! (2 <= Water.ys.length) ) {
					throw new Error("Expected water y ordinates longer than " + Water.ys.length.toString());
				}
				var message:String = "";
				var ys:Vector.<Number> = new Vector.<Number>();
				for (var i:int = 0; i < Water.ys.length; i++ ) {
					ys.push(new Number(Water.ys[i]));
				}
				var maxSlope:Number = prices.absMaxSlope(ys, new Number(Water.xPerPrice));
				if (! (2 <= maxSlope && maxSlope <= 6)) {
					message += "\nIn " + s + ", expected absolute max slope between 2 <= " + maxSlope.toString() + " <= 6";
				}
				if (! ("" == message)) {
					throw new Error(message);
				}
			}
		}
	}
}

