package 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.ErrorEvent;
	import flash.errors.IOError;
	import flash.events.IOErrorEvent;
	import flash.net.FileFilter;
	import flash.net.URLLoader;
	import flash.text.TextField;
	import flash.utils.getTimer;
	import fl.controls.ComboBox;
	import org.flixel.system.FlxAnim;
	
	/*
	All lower case class "test" so that URL will be all lower case.
	*/
	public class test extends Sprite {
		
		static public var testSlow:Boolean = false;
		static public var result_txt:TextField;
		
		public function test()
		{
			result_txt = new TextField();
			result_txt.width = 800;
			result_txt.height = 600;
			addChild(result_txt);
			result_txt.text = "testing some stocksurfer functions ...";
			trace("testing some stocksurfer functions ...");
			
			var _watchArray:Vector.<Number> = Broker.array;
			var _watchArrayMsft:Vector.<Number> = Broker.arrays["MSFT"];
			var _watchArrayGoog:Vector.<Number> = Broker.arrays["GOOG"];
		
			test.testUnitBuy();
			test.testBuyMaxMoneySeconds();
			test.testMaxSlope();
			test.testSellParticleCount();
			test.testCsvToPrices();
			test.testDramatize();
			test.testComboBox();
			test.testReplaceAnimationFrames();
			test.testSlopeFrames();

			var status:String = "tests finished";
			if (Config.online && test.testSlow) {
				status = "online tests started";
				test.testLoadStock(result_txt);
				test.testPushStock([], "FLWS", result_txt);
			}
			
			TestReplay.testSlow = test.testSlow;
			TestReplay.testAll(result_txt);
			
			trace(status);
			result_txt.appendText("\n" + status);
			
		}
		
		/* Although equal, array or vector equal only if each refers to same object.
		Explores nested arrays, but because of no generics, equal nested vectors are always reported as different.
		http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/operators.html
		*/
		public static function assertEqualSequences(expecteds:*, gots:*):void {
			var equalSequences:Boolean = true;
			if (! (expecteds.length == gots.length)) {
				equalSequences = false;
			}
			else {
				for (var e:int = 0; e < expecteds.length; e++ ) {
					if (expecteds[e] is Array && gots[e] is Array) {
						assertEqualSequences(expecteds[e], gots[e]);
					}
					else if (! (expecteds[e] == gots[e])) {
						equalSequences = false;
					}
				}
			}
			if (! equalSequences) {
				throw new Error("\nExpected: " + expecteds.toString()
							  + "\nGot:      " + gots.toString() );
			}
		}
		
		/* Approximately equal +/- margin */
		public static function assertUIntIsClose(expected:uint, margin:uint, got:uint, prefix:String = ""):void {
			if (! (expected - margin  <= got 
										&& got <= expected + margin )) {
				throw new Error(prefix + "with margin " + margin.toString() + ", expected close to " + expected.toString() + ", got " + got.toString());
			}
		}

		/*
		Ethan expects to have shark following closely when buy as much as possible.
		With starting money, Ethan expects to buy no more than 5 times.
		So with 60000 starting money, Ethan expects to buy 6000 each.
		*/
		public static function testUnitBuy():void {
			var unit:int;
			unit = Broker.unitBuy(2.0, -500.0, new <Number>[100.0], 50);
			if (! (10 == unit)) {
				throw new Error("Expect to buy 10 units with rent -500 and price 100; got " + unit.toString());
			}
			unit = Broker.unitBuy(8.0, -500.0, new <Number>[100.0], 60000);
			if (! (120 == unit)) {
				throw new Error("Expect to buy 120 units with rent -500 and price 100 and start money 60000; got " + unit.toString());
			}
		}

		/*
		For MSFT or GOOG array of stock Broker and buying units, 
		after buying with maximum remainder,
		Ethan expects seconds to pay rent between 0.01 and 5.
		Ethan expects to start with enough money to buy 3 to 20 times at maximum price.
		
		Play state expects broker array to contain each step's price.
		Setting state notifies Flixel global helper to initialize bitmap cache.
		*/
		public static function testBuyMaxMoneySeconds():void {
			for (var s:String in Broker.arrays) {
				Broker.array = Broker.arrays[s];
				var maxPrice:Number = Broker.max(Broker.array);
				Broker.money = Broker.startMoney;
				var unitSeconds:Number =
											// 2.0;   // have to click too fast.
											// 4.0;   // make more money on MSFT
											8.0;
				Broker.unit = Broker.unitBuy(unitSeconds, Broker.moneyPerSecond, Broker.array, Broker.money);
				var maxRemainder:Number = Broker.unit * maxPrice * 0.999;
				var seconds:Number = 0.0 - (maxRemainder / Broker.moneyPerSecond);
				
				var message:String = "";
				if (! (0.01 <= seconds && seconds <= 10)) {
					message += "\nExpected seconds 0.01 <= " + seconds.toPrecision(5).toString() + " <= 10";
				}
				var minPurchaseCount:int = int(Broker.money / (maxPrice * Broker.unit));
				if (! (3 <= minPurchaseCount && minPurchaseCount <= 20)) {
					message += "\nExpected to purchase at least 3 <= " + minPurchaseCount.toString() + " <= 20";
				}
				if (! ("" == message)) {
					throw new Error(message 
						+ "\n    arrays[" + s + "] maxPrice " + maxPrice.toPrecision(5).toString() 
						+ " maxRemainder " + maxRemainder.toPrecision(5).toString() 
						+ "\nBroker.money " + Broker.money.toString() 
						+ " Broker.unit " + Broker.unit.toString() 
						+ " Broker.moneyPerSecond " + Broker.moneyPerSecond.toPrecision(5).toString() 
						+ "\nminPurchaseCount " + minPurchaseCount.toString() 
					);
				}
			}
		}
		
		/*
		On MSFT or GOOG, Ethan expects absolute (rise or fall) maximum slope between 2 and 6.
		*/
		public static function testMaxSlope():void {
			for (var s:String in Broker.arrays) {
				Broker.array = Broker.arrays[s];
				var water:Water = new Water(); 
				if (! (2 <= Water.ys.length) ) {
					throw new Error("Expected water y ordinates longer than " + Water.ys.length.toString());
				}
				var message:String = "";
				var ys:Vector.<Number> = new Vector.<Number>();
				for (var i:int = 0; i < Water.ys.length; i++ ) {
					ys.push(new Number(Water.ys[i]));
				}
				var maxSlope:Number = Broker.absMaxSlope(ys, new Number(Water.xPerPrice));
				if (! (2 <= maxSlope && maxSlope <= 6)) {
					message += "\nIn " + s + ", expected absolute max slope between 2 <= " + maxSlope.toString() + " <= 6";
				}
				if (! ("" == message)) {
					throw new Error(message);
				}
			}
		}
		
		/*
		To perform quickly, Ethan expects to precompute minimum and maximum Broker and their range.
		Ethan does not notice the marginal addition, he expects to interpolate by square.  For examples:
		With price range [0.125, 100.125], selling at price 100, Ethan expects 16 particles.
		Selling at price 1, Ethan expects 1 particle.
		Selling at price 50, Ethan expects 4 particle.		
		With price range [0.125, 10.125], selling at price 10.1, Ethan expects 16 particles.
		Selling at price 0.125, Ethan expects 1 particle.
		Selling at price 5.125, Ethan expects 4 particle.		
		With price range [1, 1], Ethan expects range error.
		*/
		public static function testSellParticleCount():void {
			var broker:Broker = new Broker(new <Number>[0.125, 100.125]);
			if (! (16 == broker.getParticleCount(100.0))) {
				throw new Error("Expected 16 particles, got " + broker.getParticleCount(100.0));
			}
			if (! (1 == broker.getParticleCount(1.0))) {
				throw new Error("Expected 1 particles, got " + broker.getParticleCount(1.0));
			}
			if (! (4 == broker.getParticleCount(50.0))) {
				throw new Error("Expected 4 particles, got " + broker.getParticleCount(50.0));
			}
			
			broker = new Broker(new <Number>[0.125, 10.125]);
			if (! (16 == broker.getParticleCount(10.1))) {
				throw new Error("Expected 16 particles, got " + broker.getParticleCount(10.1));
			}
			if (! (1 == broker.getParticleCount(0.125))) {
				throw new Error("Expected 1 particles, got " + broker.getParticleCount(0.125));
			}
			if (! (4 == broker.getParticleCount(5.125))) {
				throw new Error("Expected 4 particles, got " + broker.getParticleCount(5.125));
			}
			try {
				broker = new Broker(new <Number>[1, 1]);
				throw new Error("Expected RangeError");
			}
			catch (err:RangeError) {
			}
		}
		
		/*URL request to Google.
		For example, CSV of 3 days of NASDAQ starting March 19, in reverse order.
		http://www.google.com/finance/historical?q=NASDAQ:GOOG&startdate=Mar+19%2C+2012&num=3&output=csv
		Ethan expects vector of prices, in order.
		*/
		public static function testCsvToPrices():void {
			var nasdaqMar19CsvString:String = "Date,Open,High,Low,Close,Volume\n\
21-Mar-12,634.61,647.39,632.51,639.98,2469637\n\
20-Mar-12,630.92,636.06,627.27,633.49,1540778\n\
19-Mar-12,623.12,637.27,621.24,633.98,2172971\n\
"
			var expectedPrices:Vector.<Number> = new <Number>[633.98, 633.49, 639.98];
			var gotPrices:Vector.<Number> = Broker.csvToPrices(nasdaqMar19CsvString);
			test.assertEqualSequences(expectedPrices, gotPrices);
			var expectedTwoPrices:Vector.<Number> = new <Number>[633.98, 633.49];
			var gotTwoPrices:Vector.<Number> = Broker.csvToPrices(nasdaqMar19CsvString, 2);
			test.assertEqualSequences(expectedTwoPrices, gotTwoPrices);
		}
		
		/*
		If under minimum ratio, Ethan expects subtracted from lowest price until minimum ratio. 
		Ethan expects nothing will change if minimum price is 0 or if range is 0.
		*/
		public static function testDramatize():void {
			var prices:Vector.<Number> = new <Number>[1, 1.25, 2];
			var expectedPrices:Vector.<Number> = new <Number>[0.5, 0.75, 1.5];
			var gotPrices:Vector.<Number> = Broker.dramatize(prices, 3);
			test.assertEqualSequences(expectedPrices, gotPrices);
			prices = new <Number>[0.5, 10, 5];
			expectedPrices = new <Number>[0.19, 9.69, 4.69];
			gotPrices = Broker.dramatize(prices, 51);
			test.assertEqualSequences(expectedPrices, gotPrices);
			prices = new <Number>[1, 15, 100];
			expectedPrices = new <Number>[1, 15, 100];
			gotPrices = Broker.dramatize(prices, 50);
			test.assertEqualSequences(expectedPrices, gotPrices);
			test.assertEqualSequences(new <Number>[0],        Broker.dramatize(new <Number>[0],        50));
			test.assertEqualSequences(new <Number>[2.0, 2.0], Broker.dramatize(new <Number>[2.0, 2.0], 50));
		}

		/* Ethan expects combo box to sorted ticker symbol names. 
		*/
		public static function testComboBox():void {
			var tickerCbx:ComboBox = Market.populateTickerComboBox(new ComboBox());
			var item:* = tickerCbx.getItemAt(0);
			if (! ("AAC" == item.label)) {
				throw new Error("Expected first label of combo box to be A, got " + item.toString());
			}
			if (! ("AAC" == item.data)) {
				throw new Error("Expected first data of combo box to be A, got " + item.toString());
			}
		}
		
		/* After load stock, Ethan expects level to be appended to end.
		Stock is fetched from Google and appended to arrays and assigned to Broker array.
		If no stock found, Ethan expects an error and Broker array not changed.
		*/
		public static function testLoadStock(result:TextField):void {
			result.appendText("\ntestLoadStock:starting...");
			if (! (undefined === Broker.arrays["FLWS"])) {
				var message:String = "Expected no FLWS in Broker.arrays, got " + Broker.arrays["FLWS"].toString();
				result.appendText(message);
				throw new Error(message);
			}
			var watchBroker_array_before:Vector.<Number> = Broker.array;
			function assertLoaded(e:Event):void {
				stockLoader.removeEventListener(Event.COMPLETE, assertLoaded);
				if (! (50 <= Broker.arrays["FLWS"].length)) {
					var message:String = "Expected FLWS with length 50 or more in Broker.arrays, got " + Broker.arrays["FLWS"].toString();
					result.appendText(message);
					throw new Error(message);
				}
				var watchBroker_array:Vector.<Number> = Broker.array;
				var watchBroker_arrays_FLWS:Vector.<Number> = Broker.arrays["FLWS"];
				test.assertEqualSequences(Broker.array, Broker.arrays["FLWS"]);
				result.appendText("\ntestLoadStock:assertLoaded:OK");
			}
			function appendError(e:ErrorEvent):void {
				var message:String = "\ntestLoadStock: " + e.toString()
								   + "\nTarget data: " + e.target.data;
				result.appendText(message);
				throw new Error(message);
			}
			var stockLoader:URLLoader = Broker.loadStock(Config.crossdomainUrl, "FLWS", Broker.arrays, appendError);
			stockLoader.addEventListener(Event.COMPLETE, assertLoaded);
			function assertError(e:Event):void {
				stockLoader.removeEventListener(Event.COMPLETE, assertError);
				if (! (undefined === Broker.arrays["ZNONEZ"])) {
					var message:String = "Expected no ZNONEZ in Broker.arrays, got " + Broker.arrays["ZNONEZ"].toString();
					result.appendText(message);
					throw new Error(message);
				}
				test.assertEqualSequences(Broker.array, Broker.arrays["FLWS"]);
				result.appendText("\ntestLoadStock:assertErrorComplete:OK");
			}
			function expectStreamError(e:ErrorEvent):void {
				try {
					Broker.loadStockError(e);
				}
				catch (err:URIError) {
					var _pass:Boolean = true;
				}
				var errorBody:String = e.toString() 
									+ "\nTarget data: " + e.target.data;
				if (! (0 <= errorBody.indexOf("Error #2032"))) {
					var wrongErrorMessage:String = "\ntestLoadStock: " 
													+ "    \nExpected: Error #2032: Stream Error" 
													+ "    \nGot:      " + errorBody;
					result.appendText(wrongErrorMessage);
					throw new Error(wrongErrorMessage);
				}
			}
			stockLoader.addEventListener(Event.COMPLETE, assertError);
			stockLoader = Broker.loadStock(Config.crossdomainUrl, "ZNONEZ", Broker.arrays, expectStreamError);
		}
		
		/*
		Ethan expects replaced frames in the animation in the array to be equal.
		If no animation by this name, Ethan expects a reference error and animations are unaltered.
		*/
		public static function testReplaceAnimationFrames():void {
			var animations:Array = [];
			animations.push(new FlxAnim("idle", [0], 4, false));
			animations.push(new FlxAnim("tilt", [3, 4, 5, 6, 7, 8, 9, 10, 11, 12], 4, false));
			animations.push(new FlxAnim("buy", [1, 0], 4, false));
			animations.push(new FlxAnim("sell", [2, 0], 4, false));
			if (! (4 == animations.length)) {
				throw new Error("Expected 4 animations, got " + animations.length);
			}
			test.assertEqualSequences([3, 4, 5, 6, 7, 8, 9, 10, 11, 12], animations[1].frames);
			Player.replaceAnimationFrames(animations, "tilt", [4, 5, 6]);
			test.assertEqualSequences([4, 5, 6], animations[1].frames);
			Player.replaceAnimationFrames(animations, "tilt", [6, 5, 4]);
			test.assertEqualSequences([6, 5, 4], animations[1].frames);
			try {
				Player.replaceAnimationFrames(animations, "_NONE_", [7, 5, 4]);
			}
			catch (err:ReferenceError) {
			}
			test.assertEqualSequences([6, 5, 4], animations[1].frames);
			if (! (4 == animations.length)) {
				throw new Error("Expected 4 animations, got " + animations.length);
			}
		}
		
		/*
		Ethan expects animation frames from descending to ascending slope, with neutral in center frame.
		Ethan expects vertical ordinate at horizontal pixel of player and next 16 horizontal pixels, to derive a smooth slope,
		and the minimum and maximum frame of the animation, and the current frame index.
		Replace animation frames expects array of frames interpolated from current frame to target angle.
		Vertical depth is inverse of height.
		If currently below target, Ethan expects each frame to step up after current frame.
		If currently above target, Ethan expects each frame to step down after current frame.
		If absolute slope is greater than 1, replace anaimation frames expects to clamp frames between minimum and maximum.
		If current frame is out of range, then Ethan expects it is clamped to minimum or maximum.
		*/
		public static function testSlopeFrames():void {
			var frames:Array = Player.tiltFrames(16, 0, 3, 11, 8);
			test.assertEqualSequences([9, 10, 11], frames);
			frames = Player.tiltFrames(2, 18, 4, 13, 9);
			test.assertEqualSequences([8, 7, 6, 5, 4], frames);
			frames = Player.tiltFrames(2, 10, 4, 8, 7);
			test.assertEqualSequences([6, 5], frames);
			var stepUpFrames:Array = Player.tiltFrames(2, 10, 4, 8, 4);
			test.assertEqualSequences([5], stepUpFrames);
			var stepDownFrames:Array = Player.tiltFrames(10, 2, 4, 8, 8);
			test.assertEqualSequences([7], stepDownFrames);
			
			var clampedFrames:Array = Player.tiltFrames(48, 0, 3, 11, 8);
			test.assertEqualSequences([9, 10, 11], clampedFrames);
			clampedFrames = Player.tiltFrames(2, 66, 4, 13, 9);
			test.assertEqualSequences([8, 7, 6, 5, 4], clampedFrames);

			var aboveRangeFrames:Array = Player.tiltFrames(48, 0, 3, 11, 12);
			test.assertEqualSequences([11], aboveRangeFrames);
			var belowRangeFrames:Array = Player.tiltFrames(2, 66, 4, 13, 3);
			test.assertEqualSequences([4], belowRangeFrames);
		}
		
		public static function testPushStock(levels:Array, tickerSymbol:String = "FLWS", result:TextField = null):void {
			var stockLoader:URLLoader = Broker.loadStock(Config.crossdomainUrl, tickerSymbol, Broker.arrays);
			function pushLevels(e:Event):void {
				stockLoader.removeEventListener(Event.COMPLETE, pushLevels);
				levels.push(tickerSymbol);
				if (null != result) {
					result.appendText("testPushStock: OK: " + tickerSymbol);
				}
			}
			stockLoader.addEventListener(Event.COMPLETE, pushLevels);
		}
	}
}

