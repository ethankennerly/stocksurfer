package  
{
	import org.flixel.*;
	/**
	 * @author Ethan Kennerly
	 */
	public class Shark extends FlxSprite
	{
		public var xPerMoney:Number = 	
										// 0.01; // instant death
										0.03125; 
										// 0.0625; // where is shark?
										// 0.125; // do not see shark  
										// 0.25;  // why never catches?
										// 0.5; // where is shark?
										// 1; // where is shark?
										// 50; // where is shark?
		
		public function Shark(X:int = 0, Y:int = 0, SimpleGraphic:Class = null) 
		{
			super(X, Y, SimpleGraphic);
			var sheet:SharkSpritesheet = new SharkSpritesheet();
			FlxG.log("Shark:  width = " + sheet.frameWidth.toString() + " height = " + sheet.frameHeight.toString());
			this.loadGraphic(SharkSpritesheet, true, false, sheet.frameWidth, sheet.frameHeight);
			
			this.addAnimation("idle", [0], 12);
			
			//basic shark physics
			// why does shark disappear? // maximum velocity less than player
			this.maxVelocity.x = FlxG.width *
										// 0.25; // too slow
										// 0.5;  // too slow?
										0.5;  // too fast?
										// 1.0;  // springy?
			this.maxVelocity.y = FlxG.height * 
										0.625; // about 3 tiles high
										// 0.75; // too high?
										// 1.0; // jump too high!
			this.drag.x = this.maxVelocity.x * 8;

			// hit box
			this.width = this.frameWidth *
										0.5;  // narrow
										// 0.625;  // instant death
			this.offset.x = this.frameWidth *
										0.25;
			this.height = this.frameHeight *
										0.5;  // too tall 
										// 0.625;  // too tall 
			this.offset.y = this.frameHeight *
										// 0.125; // too high
										0.25;
										// 0.3125; // too low 
			this.centerOffsets(true);
		}

		/* Do not overshoot */
		public function chase(money:Number, preyX:int):void {
			var targetX:int = preyX - int(money * this.xPerMoney) - (this.frameWidth * 0.5);
			if (preyX < targetX) {
				targetX = preyX;
			}
			this.acceleration.x = (targetX - this.x) * 
											// 0.125; // vicious // swingy?
											// 1; // vicious // swingy?
											// 2; // bouncy
											// 10; // springy
											20; // bouncy
											// 100; // snappy
		}
		
	}		
}


/**
 * Hold the pixels of a sprite sheet in this.bitmapData.
 */
class SharkSpritesheet extends FlxMovieClip
{
	// AS3 Embedded MovieClip Gotcha:  Need two frames to declare movieclip.
	// http://www.airtightinteractive.com/2008/05/as3-embedded-movieclip-gotcha/
	[Embed(source="../data/shark.swf", symbol="shark")] public static var MovieClipClass:Class;
	
	public function SharkSpritesheet() 
	{
		super(MovieClipClass);
	}
}
