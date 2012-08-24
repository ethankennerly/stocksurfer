package  
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.getTimer;
	import mx.formatters.DateFormatter;
	
	/**
	 For example, see test.as
	 @author Ethan Kennerly
	 */
	public class Replay 
	{
		/* Conveniently record user at start and then retrieve to save. */
		public static var user:String = "";
		/* Conveniently record timestamp at start and then retrieve to save. */
		public static var timestamp:String = "";
		internal static var replaying:Boolean = false;
		internal static var elapsedMilliseconds:uint = 0;
		internal static var delays:Vector.<uint> = new <uint>[];
		internal static var methods:Vector.<String> = new <String>[];
		internal static var args:Array = [];
		internal static var nameMethods:Object = { };
		internal static var nameScopes:Object = { };
		internal static var previousMilliseconds:uint = 0;
		
		/* Erase recording and reset timers.  Listen for new recording.  Keep method names.
		For example, see test.as */
		public static function init():void {
			Replay.replaying = false;
			Replay.elapsedMilliseconds = 0;
			Replay.delays = new <uint>[];
			Replay.methods = new <String>[];
			Replay.args = [];
			Replay.previousMilliseconds = 0;
			var formatter:DateFormatter = new DateFormatter();
			var date:Date = new Date();
			formatter.formatString = "YYYY-MM-DD_HHNN_SS";
			Replay.timestamp = formatter.format(date);
		}
		
		/** 
		 * For example, 
		 * @see	test.as 
		 */
		public static function decorate(name:String, func:Function, scope:* = null):Function
		{
			Replay.nameMethods[name] = func;
			Replay.nameScopes[name] = scope;
			var recordFunc:Function = function(... args:*):* {
				var now:uint = getTimer();
				Replay.previousMilliseconds = 0;
				for (var i:uint = 0; i < Replay.delays.length; i ++) {
					Replay.previousMilliseconds += Replay.delays[i];
				}
				var elapsed:uint = now - Replay.previousMilliseconds;
				Replay.delays.push(elapsed);
				Replay.methods.push(name);
				Replay.args.push(args);
				return func.apply(scope, args);
			}
			return recordFunc;	
		}
		
		/**
		 * Load CSV into replay.  For example, see test.as
		 * @param	inputCsv	Text from CSV file
		 * @param	delays	Milliseconds
		 * @param	methods	Names
		 * @param	args	Separated by semicolons.  Convert each fully numeric character arg convert to a number.
		 */
		public static function parseDelaysMethods(inputCsv:String, delays:Vector.<uint>, methods:Vector.<String>, args:Array):void 
		{
			var lines:Array = inputCsv.split("\n");
			var line:String;
			var maybeFloat:*;
			var maybeInt:*;
			for (var i:uint = 1; i < lines.length; i++) {
				line = lines[i];
				if (1 <= line.length) {
					var delaysMethods:Array = line.split(",");
					var delay:uint = int(delaysMethods[0]);
					var method:String = delaysMethods[1];
					var arg:Array = [];
					if (1 <= delaysMethods[2].length) {
						arg = delaysMethods[2].split(";");
						if (1 <= arg.length) {
							for (var a:uint = 0; a < arg.length; a++ ) {
								maybeInt = parseInt(arg[a]);
								if (! isNaN(maybeInt)) {
									arg[a] = maybeInt;
								}
								else {
									maybeFloat = parseFloat(arg[a]);
									if (! isNaN(maybeFloat)) {
										arg[a] = maybeFloat;
									}
								}
							}
						}
					}
					delays.push(delay);
					methods.push(method);
					args.push(arg);
				}
			}
		}
		
		public static function formatCsvText():String 
		{
			var csvText:String = "delay,method,args";
			for (var i:uint = 0; i < Replay.delays.length; i ++ ) {
				var arg_i:String = Replay.args[i].join(";");
				var elements:Array = [Replay.delays[i], Replay.methods[i], arg_i];
				var line:String = elements.join(",");
				csvText += "\n" + line;
			}
			return csvText;
		}
		
		public static function formatSaveUrl(url:String, csvText:String, timestamp:String, user:String):String {
			var saveUrl:String = url + "/save?" + timestamp + "_" + user + ".csv=" + escape(csvText);
			return saveUrl;
		}
		
		public static function loadUrl(url:String, errorPrefix:String):URLLoader {
			var loader:URLLoader = new URLLoader();
			function logError(e:Event):void {
				loader.removeEventListener(IOErrorEvent.IO_ERROR, logError);
				loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, logError);
				var message:String = errorPrefix + ": " + e;
				trace(message);
			}
			loader.addEventListener(IOErrorEvent.IO_ERROR, logError);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, logError);
			loader.load(new URLRequest(url));
			return loader;
		}
		
		public static function parse(inputCsv:String):void 
		{
			Replay.init();
			Replay.parseDelaysMethods(inputCsv, Replay.delays, Replay.methods, Replay.args); 
		}
		
		/* For example, see test.as */
		public static function replay(immediately:Boolean = false):void {
			Replay.previousMilliseconds = getTimer();
			if (immediately) {
				Replay.previousMilliseconds -= Replay.delays[0];
			}
			Replay.elapsedMilliseconds = 0;
			Replay.replaying = true;
		}
		
		/* Convenient API.  now -1: get live time
		For example, see test.as */
		public static function update(now:int = -1):void {
			if (-1 == now) {
				now = getTimer();
			}
			Replay.elapsedMilliseconds = now - Replay.previousMilliseconds;
			if (Replay.replaying) {
				Replay.elapsedMilliseconds = Replay._update(Replay.elapsedMilliseconds, Replay.delays, Replay.methods, Replay.args);			
			}
		}
		
		/* For example, see test.as */
		internal static function _update(elapsed:uint, delays:Vector.<uint>, methods:Vector.<String>, args:Array):uint
		{
			if (1 <= delays.length) {
				var delay:uint = delays[0];
				if (delay <= elapsed) {
					delays.shift();
					var method:String = methods.shift();
					if (undefined == Replay.nameMethods[method]) {
						throw new ReferenceError("Expected method " + method + " in dictionary " + Replay.nameMethods.toString());
					}
					var arg:Array = args.shift();
					var scope:* = Replay.nameScopes[method];
					trace("Replay._update: delay " + delay.toString() + " method " + method);
					if (0 == arg.length) {
						Replay.nameMethods[method]();
					}
					else {
						Replay.nameMethods[method].apply(scope, arg);
					}
					elapsed -= delay;
					Replay.previousMilliseconds += delay;
				}
			}
			return elapsed;
		}
	}
}