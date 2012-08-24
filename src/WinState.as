package
{
	import org.flixel.FlxButton;
	import org.flixel.FlxG;
	import org.flixel.FlxSprite;
	import org.flixel.FlxState;
	import org.flixel.FlxText;

	public class WinState extends FlxState
	{
		/*
		If last level, duplicate last level, which load may replace, or player may repeat.
		*/
		override public function create():void {
			super.create();
			FlxG.play(SoundRegistry.CoinLongSoundClass);
			var map:FlxSprite = new FlxSprite(0, 8);
			map.scrollFactor.x = 0;
			map.scrollFactor.y = 0;
			var water:Water = new Water(Broker.array);
			map.pixels = BitmapBorg.drawRectangle(water, 
				FlxG.camera.scroll.x, FlxG.camera.scroll.y, 
				FlxG.width, FlxG.height, 
				LoadState.mapScale, LoadState.mapScale );
			var centeredLeft:int = int(0.5 * (FlxG.width - (Water.xPerPrice * Water.xs.length) * LoadState.mapScale)); 
			map.x = centeredLeft;
			add(map);
			var epilogueText:FlxText = new FlxText(FlxG.width * 0.25, FlxG.height * 0.2, FlxG.width * 0.5, FlxG.saves["epilogue"]);
			epilogueText.scrollFactor.x = 0;
			epilogueText.scrollFactor.y = 0;
			epilogueText.size = 16;
			epilogueText.alignment = "center";
			epilogueText.color = 0xFFFFFFFF;
			add(epilogueText);
			var nextButton:FlxButton = new FlxButton(FlxG.width * 0.125, FlxG.height * 0.75, "< NEXT");
			nextButton.onDown = this.next;
			nextButton.scrollFactor.x = 0;
			nextButton.scrollFactor.y = 0;
			add(nextButton);
			FlxG.level ++;
			if (FlxG.levels.length <= FlxG.level) {
				FlxG.levels.push(FlxG.levels[FlxG.levels.length - 1]);
			}
		}
		
		override public function update():void {
			super.update();
			if (FlxG.keys.justPressed("LEFT")) {
				next();
			}
		}
		
		public function next():void {
			FlxG.switchState(new MenuState());	
		}
	}
}






