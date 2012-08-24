package
{

	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.ui.Mouse;
	import flash.events.MouseEvent;
	import org.flixel.*;
	import org.flixel.plugin.photonstorm.API.FlxKongregate;
	import org.igorcosta.hacks.SWF;
	
	/*
	LoadStockMovieClip compiled from swc.
	http://blog.log2e.com/2008/05/07/creating-a-swc-component-in-flashdevelop/	
	*/
	public class MenuState extends FlxState
	{
		public static var repeat:Boolean = false;
		public static var startedMusic:Boolean = false;
		public static var prompted:Boolean;
		public static var start:Function;
		public static var logReplay:Function;
		public static var compilationDate:Date;
								
		public var titleText:FlxText;
		public var bodyText:FlxText;
		public var startButton:FlxButton;
		public var loadButton:FlxButton;
		
		/*
		Show a button to start.
		After completing a few levels, show a button to load.
		*/
		override public function create():void
		{
			super.create();
			Replay.replaying = false;
			MenuState.logReplay = Replay.decorate("logReplay", MenuState._logReplay);
			MenuState.start = Replay.decorate("start", MenuState._start);
			LoadState.loadStock = Replay.decorate("loadStock", LoadState._loadStock);
			var swf:SWF = new SWF(FlxG.stage.loaderInfo);
			MenuState.compilationDate = swf.readCompilationDate();
			
			if (Config.debug) {
				var debugStatus:String = "CONFIG::debug" 
										+ "\nonline: " + Config.online.toString()
										+ "\ncompiled: " + MenuState.compilationDate.toString();
				var debugText:FlxText = new FlxText(0, 0, 150, debugStatus);
				add(debugText);
			}
			
			if (! MenuState.startedMusic) {
				FlxG.playMusic(SoundRegistry.BackgroundMusicClass);
				MenuState.startedMusic = true;
			}
			FlxG.play(SoundRegistry.BubbleUpSoundClass);
			
			FlxG.bgColor = 0xFFAAAAFF;
		
			var scoreText:FlxText = new FlxText(FlxG.width - 100, 0, 100, "WORTH " + FlxG.score.toString());
			scoreText.scrollFactor.x = 0;
			scoreText.scrollFactor.y = 0;
			add(scoreText);
			
			titleText = new FlxText(0,FlxG.height * 0.25,FlxG.width,"STOCK SURFER\nBUY LOW, SELL HIGH, OR DIE!");
			titleText.size = 16;
			titleText.alignment = "center";
			add(titleText);

			bodyText = new FlxText(FlxG.width/2-75,FlxG.height * 0.6,150,"CLICK ANYWHERE");
			bodyText.size = 12;
			bodyText.alignment = "center";

			add(bodyText);
			
			startButton = new FlxButton(FlxG.width * 0.125, FlxG.height * 0.75, "< HELP");
			startButton.onDown = this.prompt;
			startButton.scrollFactor.x = 0;
			startButton.scrollFactor.y = 0;
			add(startButton);

			FlxG.mouse.show();
			
			if (! MenuState.prompted) {
				FlxG.levels = Config.levels;
			}
			else {
				this.prompt();
			}
			
			if (Config.online) {
				if (Config.tutorLevelsLength <= FlxG.level) {
					this.loadButton = new FlxButton(FlxG.width * 0.625, FlxG.height * 0.75, "LOAD >");
					this.loadButton.onDown = MenuState.showLoad;
					this.loadButton.scrollFactor.x = 0;
					this.loadButton.scrollFactor.y = 0;
					add(this.loadButton);
				}
			}
			
			// After stage is setup, connect to Kongregate.
			// http://flixel.org/forums/index.php?topic=293.0
			// http://www.photonstorm.com/tags/kongregate
			if (! FlxKongregate.hasLoaded) {
				FlxKongregate.init(apiHasLoaded);
			}
		}

		private function apiHasLoaded():void
		{
			FlxKongregate.connect();
		}

		override public function update():void
		{
			super.update();
			if (Config.debug) {
				if (FlxG.keys.justPressed("R")) {
					if (FlxG.keys.SHIFT) {
						Replay.parseDelaysMethods(TestReplay.inputCsv, Replay.delays, Replay.methods, Replay.args);
						Replay.replay();
						FlxG.log("replaying test: " + Replay.replaying);
					}
					else {
						function parseAndReplayImmediately(inputCsv:String):void { 
							var _watchReplay:Class = Replay;
							Replay.parse(inputCsv);
							Replay.replay(true);
							Replay.elapsedMilliseconds = Replay.delays[0];
							FlxG.log("replaying: " + Replay.replaying);
						}
						Csv.open(parseAndReplayImmediately);
					}
				}
				Replay.update();
			}
			
			if (! MenuState.prompted) {
				if (MenuState.repeat || FlxG.mouse.justPressed() ||　FlxG.keys.justPressed("LEFT")) {
					prompt();
				}
			}
			else {
				if (FlxG.keys.justPressed("LEFT")) {
					MenuState.startDefault();
				}
				if (null != this.loadButton) {
					if (FlxG.keys.justPressed("RIGHT")) {
						MenuState.showLoad();
					}
				}
			}
		}
		
		protected function prompt():void {
			this.titleText.text = "STOCK " + FlxG.levels[FlxG.level];
			FlxG.play(SoundRegistry.CoinLongSoundClass);
			this.bodyText.text = "BUY: PRESS LEFT\nSELL: PRESS RIGHT\n\n\n< BUY            SELL >\n\n\nTO START,\nPRESS LEFT";
			this.startButton.label.text = "< START";
			this.startButton.onDown = MenuState.startDefault;
			MenuState.prompted = true;
		}

		public static function initReplay():void {
			Replay.init();
			if ("" == Replay.user) {
				
				if (Config.debug) {
					Replay.user = "debug_"
				}
				
				Replay.user += FlxKongregate.getUserName + "_" + FlxKongregate.getUserId.toString();
			}
		}
		
		public static function startDefault():void {
			if (0 == Replay.methods.length || Replay.methods[0] != "loadStock") {
				MenuState.initReplay();
			}
			MenuState.start(FlxG.level, FlxG.levels[FlxG.level]);
			MenuState.logReplay("compiled: " + MenuState.compilationDate.toString());
		}
		
		public static function _start(level:int, ticker:String):void {
			FlxG.level = level;
			if (0 == level) {
				FlxG.score = Broker.tutorMoney;
			}
			else {
				FlxG.score = Broker.startMoney;
			}
			Broker.array = Broker.arrays[ticker];
			FlxG.switchState(new PlayState());			
		}
		
		public static function _logReplay(message:String):void {
			trace("logReplay: " + message);
			FlxG.log("logReplay: " + message);
		}
		
		public static function showLoad():void {
			FlxG.switchState(new LoadState());
		}
	}
}

