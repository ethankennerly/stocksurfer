package 
{
	import flash.events.Event;
	import flash.events.ErrorEvent;
	import flash.errors.IOError;
	import flash.events.IOErrorEvent;
	import flash.net.FileFilter;
	import flash.text.TextField;
	import flash.utils.getTimer;
	
	public class TestReplay {
		
		static public var testSlow:Boolean = false;
		static public var inputCsv:String = "delay,method,args"
									+ "\n2000,start,0;NEWB"
									+ "\n500,buy,"
									+ "\n500,buy,"
									+ "\n1500,sell,\n";
		static public var escapedCsv:String = "delay%2Cmethod%2Cargs" 
									+ "%0A2000%2Cstart%2C0%3BNEWB" 
									+ "%0A500%2Cbuy%2C" 
									+ "%0A500%2Cbuy%2C" 
									+ "%0A1500%2Csell%2C%0A";
		static public var parsedDelays:Vector.<uint> = new <uint>[2000, 500, 500, 1500];
		static public var parsedMethods:Vector.<String> = new <String>["start", "buy", "buy", "sell"];
		static public var parsedArgs:Array = [[0, "NEWB"], [], [], []];
		
		static public function testAll(result_txt:TextField):void
		{
			TestReplay.testReplayInput(TestReplay.inputCsv);
			TestReplay.testReplayImmediately();
			TestReplay.testReplayUnknownMethod();
			TestReplay.testReplayDecorate();
			TestReplay.testReplayDecorateArgs();
			TestReplay.testFormatCsvText();
			TestReplay.testFormatSaveUrl(TestReplay.escapedCsv, TestReplay.inputCsv);
			if (TestReplay.testSlow) {
				TestReplay.testInteractiveBrowseCsv(TestReplay.inputCsv, result_txt);
			}
		}
		
		/*
		Ethan expects to replay essential inputs from a CSV that contains delay milliseconds, method.
		For example:  start, buy, buy, sell.
		Each update that exceeds delay, Ethan expects to consume first delay and method.
		Ethan expects to add each function to method dictionary.
		During parsing, if method not found in methods, because decoration may not be available, Ethan expects no error.
		During update, if method not found in methods, Ethan expects reference error.
		If decorated repetitively, Ethan expects cache of first function, for example decorate sell three times it is only decorated once.
		*/
		public static function testReplayInput(inputCsv:String):void {
			Replay.init();
			var startCount:uint = 0;
			function start():void {
				startCount ++;
			}
			start = Replay.decorate("start", start);
			var buyCount:uint = 0;
			function buy():void {
				buyCount ++;
			}
			buy = Replay.decorate("buy", buy);
			var sellCount:uint = 0;
			function sell():void {
				sellCount ++;
			}
			sell = Replay.decorate("sell", sell);
			var delays:Vector.<uint> = new <uint>[];
			var methods:Vector.<String> = new <String>[];
			var args:Array = [];
			Replay.parseDelaysMethods(inputCsv, delays, methods, args);
			test.assertEqualSequences(parsedDelays, delays);
			test.assertEqualSequences(parsedMethods, methods);
			test.assertEqualSequences(parsedArgs, args);
			var remainingMilliseconds:uint = 0;
			remainingMilliseconds = Replay._update(250 + remainingMilliseconds, new <uint>[], new <String>[], []);
			if (! (250 == remainingMilliseconds)) {
				throw new Error("Expected 250 remainingMilliseconds, got " + remainingMilliseconds.toString());
			}
			remainingMilliseconds = Replay._update(125 + remainingMilliseconds, delays, methods, args);
			if (! (375 == remainingMilliseconds)) {
				throw new Error("Expected 375 remainingMilliseconds, got " + remainingMilliseconds.toString());
			}
			test.assertEqualSequences(parsedDelays, delays);
			test.assertEqualSequences(parsedMethods, methods);
			test.assertEqualSequences(parsedArgs, args);
			remainingMilliseconds = Replay._update(1650 + remainingMilliseconds, delays, methods, args);
			if (! (25 == remainingMilliseconds)) {
				throw new Error("Expected 25 remainingMilliseconds, got " + remainingMilliseconds.toString());
			}
			test.assertEqualSequences(new <uint>[500, 500, 1500], delays);
			test.assertEqualSequences(new <String>["buy", "buy", "sell"], methods);
			if (! (1 == startCount)) {
				throw new Error("Expected startCount 1, got " + startCount.toString());
			}
		}

		/*
		Ethan expects to replay with minimal delay for first entry.
		*/
		public static function testReplayImmediately():void {
			Replay.init();
			Replay.parseDelaysMethods(TestReplay.inputCsv, Replay.delays, Replay.methods, Replay.args);
			var expectedLength:int = Replay.delays.length - 1;
			Replay.replay(true);
			Replay.update();
			if (! (expectedLength == Replay.delays.length)) {
				throw new Error("After replay immediately, expected count of replays to be " + expectedLength.toString() + ", got " + Replay.delays.length.toString() + ".");
			}
		}

		/*
		During parsing, if method not found in methods, because decoration may not be available, Ethan expects no error.
		During update, if method not found in methods, Ethan expects reference error.
		*/
		public static function testReplayUnknownMethod():void {
			var _watchReplay:Class = Replay;
			var noMethodCsv:String = "delay,method,args"
									+ "\n0,_NONE_,"; 
			Replay.parse(noMethodCsv);
			test.assertEqualSequences(new <uint>[0], Replay.delays);
			test.assertEqualSequences(new <String>["_NONE_"], Replay.methods);
			test.assertEqualSequences([[]], Replay.args);
			try {
				Replay._update(Replay.elapsedMilliseconds, Replay.delays, Replay.methods, Replay.args);
				throw new Error("During update, if method not in dictionary, expected reference error.");
			}
			catch (err:ReferenceError) {
			}
		}
		
		/*
		If decorated repetitively, Ethan expects decoration occurs repetively.
		If function is called, then append delay and method.  For example, sell once.
		When not replaying, expect only to record.  
		At start of replay, Ethan expects delays to occur relative to current time.
		When replaying sell, expect not to append delay and method.
		*/
		public static function testReplayDecorate():void {
			var _watchReplay:Class = Replay;
			Replay.init();
			var sellCount:uint = 0;
			function sell():void {
				sellCount ++;
			}
			
			sell = Replay.decorate("sell", sell);
			sell();
			sell();
			if (! (Replay.delays[0] == Replay.previousMilliseconds)) {
				throw new Error("Expected previous milliseconds, got " + Replay.previousMilliseconds 
								+ " delay " + Replay.delays[0]);
			}
			if (! (2 == sellCount)) {
				throw new Error("Expected sellCount 2, got " + sellCount.toString());
			}
			if (! (2 == Replay.delays.length)) {
				throw new Error("Expected one delay, got " + Replay.delays);
			}
			if (! (2 == Replay.methods.length)) {
				throw new Error("Expected one method, got " + Replay.methods);
			}
			if (! ("sell" == Replay.methods[0])) {
				throw new Error("Expected method \"sell\", got " + Replay.methods[0]);
			}
			
			Replay.update(7777);
			if (! (2 == sellCount)) {
				throw new Error("Expected sellCount 2, got " + sellCount.toString());
			}
			if (! (Replay.delays[0] == Replay.previousMilliseconds)) {
				throw new Error("Expected previous milliseconds, got " + Replay.previousMilliseconds 
								+ " delay " + Replay.delays[0]);
			}
			
			var now:uint = getTimer();
			var margin:uint = 4;
			Replay.replay();
			if (! (0 == Replay.elapsedMilliseconds)) {
				throw new Error("At start of replay, expected elapsed 0, got " + Replay.elapsedMilliseconds.toString());
			}
			test.assertUIntIsClose(now, margin, Replay.previousMilliseconds, "At start of replay, previousMilliseconds ");
			
			var recent:uint = Replay.delays[0];
			Replay.update(8888);
			if (! (3 == sellCount)) {
				throw new Error("Expected sellCount 3, got " + sellCount.toString());
			}
			if (! (1 == Replay.delays.length)) {
				throw new Error("Expected 1 delay, got " + Replay.delays);
			}
			if (! (1 == Replay.methods.length)) {
				throw new Error("Expected 1 method, got " + Replay.methods);
			}
			test.assertUIntIsClose(now + recent, margin, Replay.previousMilliseconds, "After recent, previousMilliseconds ");
			test.assertUIntIsClose(8888 - now - recent, margin, Replay.elapsedMilliseconds, "After recent, elapsedMilliseconds ");
			
			var recent2:uint = Replay.delays[0];
			Replay.update(9999);
			var expectedElapsed:uint = 9999 - now - recent - recent2;
			test.assertUIntIsClose(expectedElapsed, margin, Replay.elapsedMilliseconds, "After recent, elapsedMilliseconds ");
			if (! (0 == Replay.delays.length)) {
				throw new Error("Expected 0 delays, got " + Replay.delays);
			}
			if (! (0 == Replay.methods.length)) {
				throw new Error("Expected 0 methods, got " + Replay.methods);
			}
			
			sell = Replay.decorate("sell", sell);
			sell();
			if (! (2 == Replay.delays.length)) {
				throw new Error("Expected 2 delays, got " + Replay.delays);
			}
		}
		
		/*
		After decorating functions with arguments, Ethan expects function to be called with arguments.
		When replaying, Ethan expects arguments to passed as strings.
		*/
		public static function testReplayDecorateArgs():void {
			Replay.init();
			var _watchReplay:Class = Replay;
			var aCount:uint = 0;
			var bCount:uint = 0;
			var a:*;
			var b:*;
			function hasArgs0():void { 
			}
			function hasArgs1(first:*):void { 
				aCount++;
				a = first;
			}
			function hasArgs2(first:*, second:*):void { 
				aCount++; 
				bCount++; 
				a = first;
				b = second;
			}
			hasArgs0 = Replay.decorate("hasArgs0", hasArgs0);
			hasArgs1 = Replay.decorate("hasArgs1", hasArgs1);
			hasArgs2 = Replay.decorate("hasArgs2", hasArgs2);
			hasArgs0();
			hasArgs1(3);
			if (! (1 == aCount)) {
				throw new Error("Expected a count 1, got " + aCount.toString());
			}
			if (! (3 == a)) {
				throw new Error("Expected a 3, got " + a.toString());
			}
			hasArgs2(4, 5);
			if (! (2 == aCount)) {
				throw new Error("Expected a count 2, got " + aCount.toString());
			}
			if (! (1 == bCount)) {
				throw new Error("Expected b count 1, got " + bCount.toString());
			}
			if (! (4 == a)) {
				throw new Error("Expected a 4, got " + a.toString());
			}
			if (! (5 == b)) {
				throw new Error("Expected b 5, got " + b.toString());
			}
			
			var testArray:Array = new Array();
			var instanceHasArgs1:Function = Replay.decorate("instanceHasArgs1", testArray.join, testArray);
			testArray.push(1, 2);
			if (! ("1;2" == instanceHasArgs1(";"))) {
				throw new Error("Expected 1;2, got " + instanceHasArgs1(";").toString());
			}
			
			a = 0;
			b = 1;
			Replay.replay();
			Replay.update(9999);
			Replay.update(99999);
			Replay.update(999999);
			if (! (4 == aCount)) {
				throw new Error("Expected a count 4, got " + aCount.toString());
			}
			if (! (2 == bCount)) {
				throw new Error("Expected b count 2, got " + bCount.toString());
			}
			if (! (4 == a)) {
				throw new Error("Expected a 4, got " + a.toString());
			}
			if (! (5 == b)) {
				throw new Error("Expected b 5, got " + b.toString());
			}
			
		}
		
		public static function testFormatCsvText():void {
			Replay.parse(inputCsv);
			var csvText:String = Replay.formatCsvText();
			TestReplay.testReplayInput(csvText);
		}
		
		/**
		 * Ethan expects to manually open file dialog, select file, and text is equal to inputCsv text. 
		 * This is manual, because Flash security prohibits automatically saving or opening a local file.
		 * @param	inputCsv	Text to save and compare.
		 * @param	result_txt	Text field to append status.
		 */
		public static function testInteractiveBrowseCsv(inputCsv:String, result_txt:TextField): void {
			function assertEqualToInputCsv(csvContents:String):void {
				if (! (csvContents == inputCsv)) {
					throw new Error("Expected: " + inputCsv + "\n[" + inputCsv.length + " characters]" 
								+ "\nGot:      " + csvContents + "\n[" + csvContents.length + " characters]" );
				}
				TestReplay.testReplayInput(csvContents);
				result_txt.appendText("\ntestBrowseCsv: OK");
			}
			
			function pleaseOpenSameCsv():void {
				var fileTypes:Array = [new FileFilter("Open same file you saved", "test_browse.csv")];
				Csv.open(assertEqualToInputCsv, fileTypes);
			}
			
			result_txt.appendText("\ntestBrowseCsv: Please save test_browse.csv then open test_browse.csv");
			Csv.save(inputCsv, pleaseOpenSameCsv, "test_browse.csv");
		}
		
		public static function testFormatSaveUrl(escapedCsv:String, inputCsv:String):void {
			Replay.init();
			var expectedUrl:String = "http://localhost:8080/save?2012-05-11_1423_23_ethan.csv=" + escapedCsv;
			var url:String = Replay.formatSaveUrl("http://localhost:8080", inputCsv, "2012-05-11_1423_23", "ethan");
			if (! (expectedUrl == url)) {
				throw new Error("Expected: " + expectedUrl
							  + "\nGot:    " + url);
			}
		}
	}
}

