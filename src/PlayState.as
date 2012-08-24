package
{
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import org.flixel.*;
	import org.flixel.plugin.photonstorm.FlxBar;
	import org.flixel.plugin.photonstorm.API.FlxKongregate;


	public class PlayState extends FlxState
	{
		public var buy:Function;
		public var sell:Function;
		public var win:Function;
		public var lose:Function;
		
		public var progressBar:FlxBar;
		
		public var broker:Broker;
		public var player:Player;
		public var buyEmitter:FlxEmitter;
		public var sellEmitter:FlxEmitter;
		public var shark:Shark;
		public var water:Water;
		public var waterFlxSprite:FlxSprite;
		public var pay:Boolean;
		public var price:Number;
		public var stack:FlxGroup;
		public var moneyIcon:BuyParticle;
		public var moneyBar:FlxBar;
		
		public var buyButton:FlxButton;
		public var buyIcon:SellParticle;
		public var sellButton:FlxButton;
		public var sellIcon:BuyParticle;
		
		public var buyHelpText:FlxText;
		public var sellHelpText:FlxText;

		private var scoreText:FlxText;		
		private var moneyText:FlxText;		
		private var priceText:FlxText;		
		private var stockText:FlxText;		
		private var tickerText:FlxText;		
		private var distanceText:FlxText;		
		
		if (Config.debug) {
			private var map:FlxSprite;
			private var scrollText:FlxText;		
		}
		
		public static function createEmitterAndAddParticles(ParticleClass:Class, maxParticleCount:int):FlxEmitter {
			var emitter:FlxEmitter = new FlxEmitter(0, 0, maxParticleCount);
			emitter.setXSpeed( 
								-80, 80);  
								// -20, 20);  // bunched together
			emitter.setYSpeed( 
								-80, 0);  
								// -20, 20);  // low
			emitter.minRotation = 0;
			emitter.maxRotation = 0;
			emitter.gravity = 
										// 16;  // float
										// 64;  // slow
										128;
			for (var p:int = 0; p < maxParticleCount; p++ ) {
				emitter.add(new ParticleClass());
			}
			return emitter;
		}
		
		/* draw prices to movieclip.  movieclip to flxmovieclip to flxsprite.  */
		override public function create():void {
			super.create();
			this.buy = Replay.decorate("buy", this._buy);
			this.sell = Replay.decorate("sell", this._sell);
			this.win = Replay.decorate("win", this._win);
			this.lose = Replay.decorate("lose", this._lose);
			
			MenuState.repeat = true;
			FlxG.play(SoundRegistry.BubbleUpSoundClass);
			FlxG.saves = new Array();
			FlxG.saves["epilogue"] = "";
			waterFlxSprite = loadLevel();
			add(waterFlxSprite);
			player = new Player(
				// FlxG.width / 3, // too close to shark
				FlxG.width * 0.5, 
				// FlxG.height / 2);
				water.getY(FlxG.width * 0.5));
			pay = true;  
			Broker.money = FlxG.score;
			Broker.stock = 0;
			var unitSeconds:Number =
										// 2.0;   // have to click too fast.
										// 4.0;   // make more money on MSFT
										8.0;
			Broker.unit = Broker.unitBuy(unitSeconds, Broker.moneyPerSecond, Broker.array, Broker.money);
			this.broker = new Broker(Broker.array);
			add(player);
			this.stack = new FlxGroup();
			add(this.stack);
			this.buyEmitter = PlayState.createEmitterAndAddParticles(BuyParticle, 4 * this.broker.maxParticleCount);
			add(this.buyEmitter);
			this.sellEmitter = PlayState.createEmitterAndAddParticles(SellParticle, 4 * this.broker.maxParticleCount);
			add(this.sellEmitter);
			shark = new Shark(
					-FlxG.width, 
					// 0, // too close
					// FlxG.width / 12, // too close 
					FlxG.height / 2);
			add(shark);
			loadInput();
			loadHUD();
			if (0 == FlxG.level) {
				loadHelp();
			}
			var bound_x:int = Broker.array.length * Water.xPerPrice;
			var bound_y:int = Broker.max(Broker.array) * Water.yPerPrice + FlxG.height;
			FlxG.camera.setBounds(-bound_x, -bound_y, 2 * bound_x, 2 * bound_y, true);
			FlxG.camera.follow(player, FlxCamera.STYLE_PLATFORMER);
		}

		public static function createProgressBar(percent:int):FlxBar {
			var progressBar:FlxBar = new FlxBar(8, FlxG.height - 16, FlxBar.FILL_LEFT_TO_RIGHT, FlxG.width - 16, 8);
			progressBar.createFilledBar(0xFF7777AA, 0xFF9999FF);
			progressBar.scrollFactor.x = 0;
			progressBar.scrollFactor.y = 0;
			progressBar.percent = percent;
			return progressBar;
		}
		
		protected function loadLevel():FlxSprite {
			water = new Water(Broker.array);
			waterFlxSprite = new FlxSprite();
			waterFlxSprite.scrollFactor.x = 0;
			waterFlxSprite.scrollFactor.y = 0;
			waterFlxSprite.pixels = BitmapBorg.drawRectangle(water, FlxG.camera.scroll.x, FlxG.camera.scroll.y, FlxG.width, FlxG.height);
			return waterFlxSprite;
		}
		
		protected function updateLevel():void {
			waterFlxSprite.pixels = BitmapBorg.drawRectangle(water, FlxG.camera.scroll.x, FlxG.camera.scroll.y, FlxG.width, FlxG.height);
			
			if ((Broker.array.length - 2) * Water.xPerPrice <= player.x) {
				if (pay) {
					FlxG.play(SoundRegistry.BubbleShootLowSoundClass);
					FlxG.fade(0xFFFFFFFF, 4, win);
					pay = false;
				}
			}
		}
		
		protected function loadHUD():void {
			// tickerText = new FlxText(FlxG.width * 0.5 - 48, FlxG.height - 32, 100, FlxG.levels[FlxG.level]);
			tickerText = new FlxText(FlxG.width * 0.125, FlxG.height * 0.8, 100, FlxG.levels[FlxG.level]);
			tickerText.scrollFactor.x = 0;
			tickerText.scrollFactor.y = 0;
			tickerText.color = 0xFFEEEEFF;
			tickerText.size = 10;
			add(tickerText);
			priceText = new FlxText(
					tickerText.x + 60, 
					tickerText.y, 
					100, "9999");
			priceText.scrollFactor.x = 0;
			priceText.scrollFactor.y = 0;
			priceText.color = 0xFFFFAAAA;
			add(priceText);
			this.progressBar = createProgressBar(0);
			add(this.progressBar);
			this.moneyIcon = new BuyParticle();
			this.moneyIcon.exists = true;
			add(this.moneyIcon);
			this.moneyBar = new FlxBar(16, 16, FlxBar.FILL_LEFT_TO_RIGHT, 64, 8, this.player, "health");
			this.moneyBar.trackParent(0, 
										// -100);  // too high
										// -64);  // overlap stock stack
										// 16);  // overlap stock stack
										32);
			add(this.moneyBar);
			if (Config.debug) {
				map = new FlxSprite(FlxG.width * 0.125, FlxG.height * 0.875);
				map.scrollFactor.x = 0;
				map.scrollFactor.y = 0;
				map.pixels = BitmapBorg.drawRectangle(water, 
					FlxG.camera.scroll.x, FlxG.camera.scroll.y, FlxG.width, FlxG.height, 
					1.0 / 64, 1.0 / 64 );
				add(map);
				scrollText = new FlxText(FlxG.width - 100, 120, 100, "X,Y -1,-1");
				scrollText.scrollFactor.x = 0;
				scrollText.scrollFactor.y = 0;
				scrollText.color = 0xFFFFFF77;
				add(scrollText);
				stockText = new FlxText(tickerText.x, 
						priceText.y + 16,
						100, "9999");
				stockText.scrollFactor.x = 0;
				stockText.scrollFactor.y = 0;
				stockText.color = 0xFFEEEEFF;
				stockText.size = 10;
				add(stockText);
				distanceText = new FlxText(FlxG.width 
													- 150, 
													// - 125, 
													// - 100, 
													40, 200, "9999");
				distanceText.scrollFactor.x = 0;
				distanceText.scrollFactor.y = 0;
				distanceText.color = 
										// 0xFFFFFF77; // distracts
										// 0xFFccccff; // invisible on light blue
										0xFFeeeeff; // invisible on light blue
				distanceText.size = 16;
				add(distanceText);
				scoreText = new FlxText(FlxG.width - 100, 0, 100, "WORTH " + FlxG.score.toString());
				scoreText.scrollFactor.x = 0;
				scoreText.scrollFactor.y = 0;
				add(scoreText);
				moneyText = new FlxText(FlxG.width - 100, 10, 100, "MONEY " + Broker.money.toString());
				moneyText.scrollFactor.x = 0;
				moneyText.scrollFactor.y = 0;
				moneyText.color = 0xFF77FF77;
				add(moneyText);
			}
		}
		
		protected function updateHUD():void {
			Broker.money += FlxG.elapsed * Broker.moneyPerSecond;
			// update moneyBar.  For design, see bar.xls
			this.player.health = Math.pow(Math.max(Broker.money, 1), 0.5) * 0.325;  
			this.moneyIcon.x = this.moneyBar.x -
												16;
												// 64;
			this.moneyIcon.y = this.moneyBar.y - 8;
			
			var newPrice:Number = water.getPrice(Broker.array, player.x);
			if (newPrice < price) {
				priceText.color = 0xFFFFAAAA;
			} 
			else {
				priceText.color = 0xFFAAFFAA;
			}
			price = newPrice;
			FlxG.score = Broker.money + Broker.stock * price;
			priceText.text = price.toFixed(0).toString();
			this.progressBar.percent = this.progressPercent(player.x);
			if (Config.debug) {
				moneyText.text = "MONEY " + int(Broker.money).toString();
				moneyText.visible = FlxG.visualDebug;
				map.visible = FlxG.visualDebug;
				scrollText.text = "X " + FlxG.camera.scroll.x.toPrecision(5).toString() 
						+ "\nY " + FlxG.camera.scroll.y.toPrecision(5).toString();
				scrollText.visible = FlxG.visualDebug;
				stockText.text = int(Broker.stock).toString();
				stockText.visible = FlxG.visualDebug;
				scoreText.text = "WORTH " + int(FlxG.score).toString();
				scoreText.visible = FlxG.visualDebug;
				distanceText.text = "COMPLETE " + this.progressPercent(player.x).toString() + "%";
				distanceText.visible = FlxG.visualDebug;
			}
		}
		
		public function progressPercent(x:Number):int {
			return int(Math.round(100 * x / ((Broker.array.length - 2) * Water.xPerPrice)));			
		}
		
		protected function loadHelp():void {
			buyHelpText = new FlxText(FlxG.width, FlxG.height * 0.85, 1000, "BUY LOW: PRESS LEFT");
			buyHelpText.scrollFactor.x = 
										// 0;
										// 0.25; // crawl
										// 0.5;  // need time for next
										0.625;
										// 1.0;  // faster than stock
			buyHelpText.scrollFactor.y = 0;
			buyHelpText.color = 0xFFFFFFFF;
			buyHelpText.size = 16;
			add(buyHelpText);
			sellHelpText = new FlxText(FlxG.width * 2, FlxG.height * 0.85, 1000, "SELL HIGH: PRESS RIGHT");
			sellHelpText.scrollFactor.x = 
										// 0;
										// 0.25; // crawl
										// 0.5;  // need time for next
										0.625;
										// 1.0;  // faster than stock
			sellHelpText.scrollFactor.y = 0;
			sellHelpText.color = 0xFFFFFFFF;
			sellHelpText.size = 16;
			add(sellHelpText);
		}

		private function _buy():void {
			if (0 <= Broker.money) {
				var price:Number = water.getPrice(Broker.array, player.x);
				Broker.money -= Broker.unit * price;
				Broker.stock += Broker.unit;
				FlxG.play(SoundRegistry.BubbleUpSoundClass);
				this.player.play("buy");
				this.buyEmitter.start(true, 4.0, 0, broker.getParticleCount(price));
				var sellItem:SellParticle = new SellParticle();
				sellItem.exists = true;
				this.stack.add(sellItem);
				FlxG.log("buy:  price " + price.toString());
			}
			else {
				FlxG.play(SoundRegistry.CannotSoundClass);
			}
		}

		private function _sell():void {
			if (Broker.unit <= Broker.stock) {
				Broker.stock -= Broker.unit;
				var price:Number = water.getPrice(Broker.array, player.x);
				Broker.money += Broker.unit * price;
				FlxG.play(SoundRegistry.CoinLongSoundClass);
				this.player.play("sell");
				this.sellEmitter.start(true, 4.0, 0, broker.getParticleCount(price));
				this.stack.members.shift();
				this.stack.length--;
				FlxG.log("sell:  price " + price.toString());
			}
			else {
				FlxG.play(SoundRegistry.CannotSoundClass);
			}
		}
		
		protected function loadInput():void {
			FlxG.mouse.show();
			var buyRatioX:Number = 
							0.125;  // left
							// 0.25;  // left
							// 0.75; //right 
			var buyRatioY:Number = 
							0.75; // bottom
			buyButton = new FlxButton(FlxG.width * buyRatioX, FlxG.height * buyRatioY, "< BUY");
			buyButton.onDown = this.buy;
			buyButton.scrollFactor.x = 0;
			buyButton.scrollFactor.y = 0;
			add(buyButton);
			
			var sellRatioX:Number = 
							// 0.25;  // left
							// 0.6; //right 
							0.75; // bleed right 
			var sellRatioY:Number = 
							0.75; // bottom
			sellButton = new FlxButton(FlxG.width * sellRatioX, FlxG.height * sellRatioY, "SELL >");
			sellButton.onDown = this.sell;
			sellButton.scrollFactor.x = 0;
			sellButton.scrollFactor.y = 0;
			add(sellButton);
			this.buyIcon = new SellParticle();
			this.buyIcon.x = this.buyButton.x - 48;
			this.buyIcon.y = this.buyButton.y;
			this.buyIcon.scrollFactor.x = 0;
			this.buyIcon.scrollFactor.y = 0;
			this.buyIcon.exists = true;
			add(this.buyIcon);
			this.sellIcon = new BuyParticle();
			this.sellIcon.x = this.sellButton.x + 96;
			this.sellIcon.y = this.sellButton.y;
			this.sellIcon.scrollFactor.x = 0;
			this.sellIcon.scrollFactor.y = 0;
			this.sellIcon.exists = true;
			add(this.sellIcon);
		}

		public function updateInput():void {
			buyButton.visible = 0 <= Broker.money;
			buyIcon.visible = 0 <= Broker.money;
			sellButton.visible = 1 <= Broker.stock;
			sellIcon.visible = 1 <= Broker.stock;
			if (this.player.alive) {
				if (FlxG.keys.justPressed("LEFT")) {
					buy();
				}
				if (FlxG.keys.justPressed("RIGHT")) {
					sell();
				}
			}
			if (FlxG.keys.SHIFT) {
				if (FlxG.keys.justPressed("ONE")) {
					FlxG.timeScale = 1;
					FlxG.log("time scale 1");
				}
				else if (FlxG.keys.justPressed("TWO")) {
					FlxG.timeScale = 2;
					FlxG.log("time scale 2");
				}
				else if (FlxG.keys.justPressed("THREE")) {
					FlxG.timeScale = 4;
					FlxG.log("time scale 4");
				}
				else if (FlxG.keys.justPressed("FOUR")) {
					FlxG.timeScale = 8;
					FlxG.log("time scale 8");
				}
			}
			if (FlxG.keys.justPressed("W")) {
				if (FlxG.level < Config.tutorLevelsLength) {
					FlxG.switchState(new WinState());
				}
			}
			if (Config.debug) {
				if (FlxG.keys.justPressed("B")) {
					FlxG.visualDebug = !FlxG.visualDebug;				
				}
				if (FlxG.keys.justPressed("W")) {
					win();
				}
			}
		}

		override public function update():void {
			updateLevel();
			if (Config.debug) {
				Replay.update();
			}
			updateInput();
			shark.chase(Broker.money, this.player.x); 
			var yAtX:int = water.getY(this.player.x);
			var yAtXPlus16:int = water.getY(this.player.x + 16);
			this.player.playTilt(yAtX, yAtXPlus16);
			// After May 11, 2012, TiaSkyFire at Kongregate expects player to vary speed.
			var speedPercent:Number = 
										0.015625;  // slow with low health and 0.5 minSpeedFactor
										// 0.03125;  // slow
										// 0.0625;  // fast
										// 0.25;  // very fast
			var minSpeedFactor:Number = 
										// 0.25;   // stall with no health
										0.5;
			var speedFactor:Number = minSpeedFactor + this.player.health * speedPercent;
			this.player.velocity.x = Player.originalVelocityX * speedFactor;
			Broker.moneyPerSecond = Broker.originalMoneyPerSecond * speedFactor;
			water.buoy(player);
			water.buoy(shark);
			this.buyEmitter.x = this.player.x;
			this.buyEmitter.y = this.player.y + this.player.offset.y;
			for (var m:int = 0; m < this.buyEmitter.length; m++ ) {
				water.buoy(this.buyEmitter.members[m]);
			}
			this.sellEmitter.x = this.player.x;
			this.sellEmitter.y = this.player.y + this.player.offset.y;
			for (m = 0; m < this.sellEmitter.length; m++ ) {
				water.buoy(this.sellEmitter.members[m]);
			}
			for (m = 0; m < this.stack.length; m++ ) {
				if (undefined != this.stack.members[m]) {
					this.stack.members[m].x = this.player.x;
					this.stack.members[m].y = this.player.y + this.player.offset.y - 10 * m;
				}
			}
			
			if (pay) {
				FlxG.overlap(this.shark, this.player, overlapEnemy);			
			}
			updateHUD();
			super.update();
		}

		internal static function saveReplay():void {
			var csvText:String = Replay.formatCsvText();
			if (Config.online) {
				var saveUrl:String = Replay.formatSaveUrl(Config.crossdomainUrl, csvText, Replay.timestamp, Replay.user);
				Replay.loadUrl(saveUrl, "saveReplay");
			}
			else {
				Csv.save(csvText);
			}
			MenuState.initReplay();
		}
		
		internal function _lose():void {
			var days:int = int(player.x / Water.xPerPrice);
			var totalDays:int = Water.xs.length;
			FlxG.saves["epilogue"] = "YOU RAN OUT OF MONEY." 
				+ "\n\nYOU SURFED " + days.toString() 
				+ " DAYS\nON STOCK " + FlxG.levels[FlxG.level] 
				+ "\n\nTRY AGAIN TO FINISH ALL " + totalDays.toString() + " DAYS" 
				+ "\n\nPRESS LEFT";
			LoseState.progressPercent = this.progressBar.percent;
			if (! Replay.replaying) {
				PlayState.saveReplay();
			}
			FlxG.switchState(new LoseState());
		}
		
		internal function _win():void {
			var totalDays:int = Water.xs.length;
			FlxG.saves["epilogue"] = "YOU FINISHED!\n\n" + totalDays.toString() + " DAYS" 
				+ "\nON STOCK " + FlxG.levels[FlxG.level] 
				+ "\n\nYOU ARE WORTH $" + FlxG.score + "!" 
			if (FlxG.level < FlxG.levels.length - 1) {
				FlxG.saves["epilogue"] += "\n\nPLAY NEXT STOCK\n\nPRESS LEFT";
			}
			else {
				FlxG.saves["epilogue"] += "\n\nSTOCK SURFER\nBY ETHAN KENNERY\n\nSONG 'DUANE STOMP' BY THE VIVISECTORS\n\nSTART OVER\n\nPRESS LEFT";
			}
			if (! Replay.replaying) {
				FlxKongregate.api.stats.submit("Worth", FlxG.score );
				PlayState.saveReplay();
			}
			FlxG.switchState(new WinState());
		}

		protected function overlapEnemy(EnemyObject:FlxObject, PlayerObject:FlxObject):void {
			if (!(PlayerObject is Player))
			{
				FlxG.log("overlapEnemy:  expect Enemy, player.  got " + EnemyObject + " " + PlayerObject);
			}
			if (pay) {
				FlxG.log("overlapEnemy");
				FlxG.play(SoundRegistry.ExplodeSoundClass);
				EnemyObject.flicker(1);
				PlayerObject.kill();
				FlxG.fade(0xFF000000, 4, lose);
				pay = false;
			}
		}
	}

}






