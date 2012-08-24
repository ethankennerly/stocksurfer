package
{
	import org.flixel.FlxButton;
	import org.flixel.FlxG;
	import org.flixel.FlxState;
	import org.flixel.FlxText;
	import org.flixel.plugin.photonstorm.FlxBar;

	public class LoseState extends FlxState
	{
		public static var progressPercent:int;
		public var progressBar:FlxBar;
		
		public var epilogueText:FlxText;
		public var tryAgainButton:FlxButton;
		
		override public function create():void {
			super.create();

			this.progressBar = PlayState.createProgressBar(LoseState.progressPercent);
			add(this.progressBar);
			
			FlxG.bgColor = 0xFF000000;
			epilogueText = new FlxText(FlxG.width * 0.5, FlxG.height * 0.2, 200, FlxG.saves["epilogue"]);
			epilogueText.scrollFactor.x = 0;
			epilogueText.scrollFactor.y = 0;
			epilogueText.size = 16;
			epilogueText.alignment = "center";
			epilogueText.color = 0xFFAAAAAA;
			add(epilogueText);
			FlxG.play(SoundRegistry.BubbleShootLowNoiseSoundClass);
			if (1 <= FlxG.level) {
				Broker.money = Broker.tutorMoney;
				FlxG.score = Broker.tutorMoney;
			}
			else {
				Broker.money = Broker.startMoney;
				FlxG.score = Broker.startMoney;
			}
			tryAgainButton = new FlxButton(FlxG.width * 0.125, FlxG.height * 0.75, "< TRY AGAIN");
			tryAgainButton.onDown = this.tryAgain;
			tryAgainButton.scrollFactor.x = 0;
			tryAgainButton.scrollFactor.y = 0;
			add(tryAgainButton);
		}
		
		override public function update():void {
			super.update();
			if (FlxG.keys.justPressed("LEFT")) {
				tryAgain();
			}
		}
		
		public function tryAgain():void {
			FlxG.switchState(new MenuState());			
		}
	}
}