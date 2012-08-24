package {
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	public class Broker {

		public static var money:Number;
									
		public static var originalMoneyPerSecond:Number = 
									-500; 
									// -400; 
									// -300; 
									// -200; 
									// -100; // harsh! 
									// -75; // harsh! 
									// -50; // harsh! 
									// -20; // dull
									// -10; // dull?
									// -1; // slow
		public static var moneyPerSecond:Number = Broker.originalMoneyPerSecond;
		public static var tutorMoney:Number = 6000;
		public static var stock:int = 
									0;
									// 1000; // nothing to do?
		public static var unit:int = 
								// 1; // tedious
								// 10; // tedious?
								// 100; // depends on price of stock?  okay with dramatized MSFT prices [1..4]
								// 200; 
								500;
								
		public static var startMoney:int =
										// 100; // quick death
									// 200; // quick death
									// 400; // quick death
									// 800; // if buy, die quick.
									// 1000; // sell too early?
									// 3000; // die before buy and sell
									// 4000; // die before buy and sell
									// 6000; 
									// 8000; // hard at x2 time 
									16000; // okay at x2 MSFT
									// 100000; // GOOG buy 100
	
		// Strangely, array will not get arrays during static initialization.
		public static var array:Vector.<Number> = new Vector.<Number>();

		/*
		public static function get array():Vector.<Number> {
			return _array;
		}
		
		/* Change vector of numbers in place, so memory address is unaffected. * /
		public static function set array(setArray:Vector.<Number>):void {
			for (var i:int = _array.length - 1; 0 <= i; i-- ) {
				_array.pop();
			}
			for (i = 0; i < setArray.length; i++ ) {
				_array.push(setArray[i]);
			}
		}
		*/
		
		public static var arrays:Object = new Object();
		
		// Dramatized prices, copied from spreadsheet.

		// http://stackoverflow.com/questions/4173845/how-do-i-initialize-a-vector-with-an-array-of-values
 arrays["NEWB"] = new <Number>[ 
 400.00 
 ,320 
 ,240 
 ,160 
 ,1 
 ,1 
 ,1 
 ,1 
 ,1 
 ,160 
 ,240 
 ,320 
 ,480 
 ,480 
 ,480 
 ,320 
 ,160 
 ,1 
 ,160 
 ,320 
 ,480 
 ,640 
 ,800 
 ,480 
];


		
		arrays["MSFT"] = new <Number>[ 
 3.82 
 ,4.44749999999999 
 ,4.1175 
 ,4.7475 
 ,3.9075 
 ,2.2875 
 ,1.7475 
 ,2.7975 
 ,2.6475 
 ,2.4975 
 ,1.9575 
 ,1.92749999999999 
 ,1.5975 
 ,0.1875 
 ,1.5075 
 ,1.7475 
 ,2.0475 
 ,2.1675 
 ,2.2275 
 ,2.94749999999999 
 ,4.4775 
 ,4.1475 
 ,5.0775 
 ,5.9175 
 ,3.7575 
 ,4.3875 
 ,4.7175 
 ,4.5975 
 ,4.0275 
 ,6.1575 
 ,6.6075 
 ,7.2975 
 ,8.4675 
 ,9.3075 
 ,10.6275 
 ,9.5475 
 ,9.8775 
 ,9.0075 
 ,8.8875 
 ,9.3075 
 ,9.2775 
 ,8.4975 
 ,7.2675 
 ,7.0575 
 ,5.8875 
 ,5.1675 
 ,5.9775 
 ,5.5275 
 ,5.6475 
 ,3.8175 
 ,4.5675 
 ,4.2075 
 ,4.3875 
 ,4.2375 
 ,6.5775 
 ,9.1275 
 ,9.5175 
 ,8.9775 
 ,9.0675 
 ,10.1475 
 ,9.69749999999999 
 ,10.4775 
 ,10.2075 
];


		arrays["GOOG"] = new <Number>[ 
50.96 
 ,48.3 
 ,60.15 
 ,61.08 
 ,50.97 
 ,56.24 
 ,55.64 
 ,58.19 
 ,68.68 
 ,72.8 
 ,72.79 
 ,72.74 
 ,65.32 
 ,46.78 
 ,51.63 
 ,58.01 
 ,65.46 
 ,54.96 
 ,53.62 
 ,41.16 
 ,21.64 
 ,28.02 
 ,30.82 
 ,40.83 
 ,41.24 
 ,63.29 
 ,69.3 
 ,74.62 
 ,85.11 
 ,117.8 
 ,108.53 
 ,116.63 
 ,106.82 
 ,109.79 
 ,116.61 
 ,122.54 
 ,109.28 
 ,112.43 
 ,124.79 
 ,126.26 
 ,118.76 
 ,104.77 
 ,110.94 
 ,123.62 
 ,122.26 
 ,134.45 
 ,138.46 
 ,127.07 
 ,121.2 
 ,134.47 
 ,139.12 
 ,142.68 
 ,137.59 
 ,126.99 
 ,121 
 ,107.06 
 ,106.12 
 ,96.23 
 ,89.12 
 ,114.31 
 ,109.05 
 ,125.51 
 ,139.89 
 ,146.48 
 ,151.77 
 ,149.89 
 ,149.51 
 ,142.17 
 ,153.54 
 ,151.51 
 ,151.75 
 ,144.19 
 ,145.66 
 ,152.08 
 ,147.95 
 ,156.49 
 ,151.94 
 ,155.82 
 ,158 
 ,166.37 
 ,165.82 
 ,168.52 
 ,172.02 
 ,191.53 
 ,194.4 
 ,185.13 
 ,178.85 
 ,148.58 
 ,149.26 
 ,152.08 
 ,155.76 
 ,151.11 
 ,154.7 
 ,159.03 
 ,165.69 
 ,112.11 
 ,111.64 
 ,107.05 
 ,95.61 
 ,94.22 
];

		/* Maximum number in the populated vector.  If no vector, throw error. 
		 For example, see TestPlayState.as
		 
		 Math.max.apply(null, vec) complains vec is not an array.  
		 ActionScript 3 does not support compile-time generic type, so non-number vectors would need a separate function.
		 http://stackoverflow.com/questions/4071536/how-would-you-implement-generics-like-vector-t
		 */
		public static function max(vec:Vector.<Number>):Number {
			var length:int = vec.length;
			if (length <= 0) {
				throw new Error("max:  Vector has no elements " + vec.toString() );
			}
			var _max:Number = vec[0];
			for (var i:int = 1; i < length; i++ ) {
				if (_max < vec[i]) {
					_max = vec[i];
				}
			}
			return _max;
		}

		public static function min(vec:Vector.<Number>):Number {
			var length:int = vec.length;
			if (length <= 0) {
				throw new Error("max:  Vector has no elements " + vec.toString() );
			}
			var _min:Number = vec[0];
			for (var i:int = 1; i < length; i++ ) {
				if (vec[i] < _min) {
					_min = vec[i];
				}
			}
			return _min;
		}

		/* How many units a player buys with each click on this level.  For example, see TestPlayState.as */
		public static function unitBuy(seconds:Number, moneyPerSecond:Number, priceVector:Vector.<Number>, startMoney:Number):int {
			var maxPrice:Number = Broker.max(priceVector);
			var maxMoney:Number = 0.0 - (seconds * moneyPerSecond);
			var unit:int = int(maxMoney / maxPrice);
			var maxStartBuyCount:int = 5;
			var startBuyCount:int = int(startMoney / unit);
			if (maxStartBuyCount < startBuyCount) {
				unit = int(startMoney / maxPrice / maxStartBuyCount);
			}
			return unit;
		}
		
		/* Get absolute maximum slope from each rise per run. 
		Multiply each slope by this factor such that the absolute maximum slope in the vector equals the given maximum. 
		Example:  targetMaxSlope / absMaxSlope(priceVector);
		For example, see TestPlayState.as 
		
		Cast vector of int to Number.
		http://stackoverflow.com/questions/8155322/actionscript-3-vector-number-does-not-extend-vector
		*/
		public static function absMaxSlope(priceVector:Vector.<Number>, run:Number = 1.0):Number {
			var length:int = priceVector.length;
			if (! (2 <= length)) {
				throw new Error("absMaxSlope:  Expect price vector to have two or more numbers, got " + priceVector.toString() );
			}
			var maxSlope:Number = -1.0;
			var slope:Number;
			run *= 1.0; // guarantee float.
			for (var i:int = 1; i < length; i++ ) {
				slope = Math.abs(priceVector[i] - priceVector[i - 1]) / run;
				if (maxSlope < slope) {
					maxSlope = slope;
				}
			}
			return maxSlope; 
		}

		/* Earliest close prices from CSV.  For example, see test.as */
		public static function csvToPrices(reversedCsvString:String, priceCount:int=100):Vector.<Number> {
			var prices:Vector.<Number> = new Vector.<Number>();
			var lines:Array = reversedCsvString.split("\n");
			for (var l:int = 0; l < lines.length; l++ ) {
				if (0 == lines[l].length) {
					lines.splice(l, 1);
				}
			}
			var c:int = lines[0].split(",").indexOf("Close");
			for (l = Math.max(1, lines.length - priceCount); l < lines.length; l++ ) {
				var line:String = lines[l];
				var columns:Array = line.split(",");
				if (1 <= columns.length && c < columns.length) {
					var closePrice:Number = columns[c];
					prices.push(closePrice);
				}
			}
			return prices.reverse();
		}
		
		/* Lower minimum until ratio greater than or equal to maximum. 
		For examples, see test.as

		Instead of ZeroDivisionError, ActionScript return not a number, which will cause dramatize to do nothing.
		Vector map might not work in Flash Player 10.1
		http://stackoverflow.com/questions/4875830/how-does-vector-map-work-in-actionscript-3
		 */
		public static function dramatize(prices:Vector.<Number>, minRatio:Number = 50):Vector.<Number> {
			var oldMin:Number = Broker.min(prices);
			var oldMax:Number = Broker.max(prices);
			var addend:Number = 0;
			if (oldMax <= oldMin) {
				trace("dramatize: Expected min " + oldMin.toString() + " less than max " + oldMax.toString());
			}
			else {
				var oldRatio:Number = oldMax / oldMin;
				if (oldRatio < minRatio) {
					var range:Number = oldMax - oldMin;
					var newMin:Number = range / (minRatio - 1);
					addend = newMin - oldMin;
				}
			}
			var addedPrices:Vector.<Number> = new Vector.<Number>();
			for (var p:int = 0; p < prices.length; p++ ) {
				addedPrices.push(prices[p] + addend);
			}
			return addedPrices;
		}

		public static function loadStockError(e:Event): void {
				var message:String = "Could not load stock.  Wait 5 seconds and try again?\nEvent: " + e;
				trace(message);
				throw new URIError(message);
		}
		
		/* After load stock, Ethan expects level to be appended to end.
		Stock is fetched from Google NASDAQ and appended to arrays.  Set Broker array to the loaded stock.
		google.com root crossdomain.xml does not allow our site, so load from our crossdomain relay server.
		Unfortunately Broker array when placed as parameter and then assigned is not actually updated.
		For example, see test.as
		*/
		public static function loadStock(crossdomainUrl:String, tickerSymbol:String, arrays:Object, errorCallback:Function = null):URLLoader {
			if (null === errorCallback) {
				errorCallback = Broker.loadStockError;
			}
			var stockLoader:URLLoader = new URLLoader();
			function onLoaded(e:Event):void {
				stockLoader.removeEventListener(Event.COMPLETE, onLoaded);
				stockLoader.removeEventListener(IOErrorEvent.IO_ERROR, errorCallback);
				arrays[tickerSymbol] = Broker.csvToPrices(e.target.data);
				arrays[tickerSymbol] = Broker.dramatize(arrays[tickerSymbol], 50);
				Broker.array = arrays[tickerSymbol];
			}
			stockLoader.addEventListener(Event.COMPLETE, onLoaded);
			stockLoader.addEventListener(IOErrorEvent.IO_ERROR, errorCallback);
			stockLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorCallback);
			var tickerUrl:String = "http://www.google.com/finance/historical?q=NASDAQ:" + tickerSymbol + "&output=csv";
			var relayUrl:String = crossdomainUrl + "/relay?" + tickerUrl;
			stockLoader.load(new URLRequest(relayUrl));
			return stockLoader;
		}

		/* End of static variables and static functions */
		
		public var maxParticleCount:int = 
										16;
										// 64;   // lag
		public var maxPrice:Number;
		public var minPrice:Number;
		public var rangeSquare:Number;
			
		/* Precompute stable getParticleCount paramters. */
		public function Broker(priceVector:Vector.<Number>) {
			Broker.array = priceVector;
			this.maxPrice = Broker.max(priceVector);
			this.minPrice = Broker.min(priceVector);
			if (! (this.minPrice < this.maxPrice)) {
				throw new RangeError("Expected min price less than max price, got minPrice " + this.minPrice + ", maxPrice " + this.maxPrice);
			}
			this.rangeSquare = Math.pow(this.maxPrice - this.minPrice, 2);
		}
		
		/* Proportion of maximum and at least 1.  For examples, see test.as */
		public function getParticleCount(price:Number):int {
			return Math.max(1, 
				int(Math.ceil(
					this.maxParticleCount * Math.pow(price - this.minPrice, 2) / this.rangeSquare
				))
			);
		}
	}
}
