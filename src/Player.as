package  
{
	import org.flixel.*;
	/**
	 * @author Ethan Kennerly
	 */
	public class Player extends FlxSprite
	{
		public static const TILT_FIRST_FRAME:uint = 3;
		public static const TILT_LAST_FRAME:uint = 11;
		public static var originalVelocityX:Number = 
												// 20; // shakey slow
												// 40; // shakey slow
												// 80; // slow.  bored.
												160; // interested.  aware. // why does shark disappear?
		
		public function Player(X:int = 0, Y:int = 0, SimpleGraphic:Class = null) 
		{
			super(X, Y);
			var sheet:PlayerSpritesheet = new PlayerSpritesheet();
			FlxG.log("Player:  width = " + sheet.frameWidth.toString() + " height = " + sheet.frameHeight.toString());
			this.loadGraphic(PlayerSpritesheet, true, true, sheet.frameWidth, sheet.frameHeight);
			
			this.addAnimation("idle", [0], 12);
			this.addAnimation("buy", [1, 0], 8, false);
			this.addAnimation("sell", [2, 0], 8, false);
			this.addAnimation("tilt", [Player.TILT_FIRST_FRAME, Player.TILT_LAST_FRAME], 
					2, 
					// 4,  // too fast? 
					false);
			
			// Stream forward, jump and fall.
			this.maxVelocity.y = FlxG.height * 
											// 0.25; // too slow
											// 0.5;  // too slow?
											0.625; // about 3 tiles high
											// 0.75; // too high?
											// 1.0; // jump too high!
			this.velocity.x = Player.originalVelocityX;

			// hit box is smaller than buy and sell animations.
			this.width = this.frameWidth * 0.5;
			this.height = this.frameHeight * 0.5;
			this.offset.x = this.frameWidth * 0.5;
			this.offset.y = this.frameHeight * 0.5;
			this.centerOffsets();
		}

		/*
		Replace only the frame indexes of the animation that has this name.
		For example, see test.as
		*/
		public static function replaceAnimationFrames(animations:Array, Name:String, Frames:Array):void {
			var length:uint = animations.length;
			var i:uint = 0;
			while (i < length && animations[i].name != Name)
			{
				i++;
			}
			if (length <= i) {
				throw new ReferenceError("No animation called \"" + Name + "\"");
			}
			else {
				animations[i].frames = Frames;
			}
		}
		
		/*
		Array from current frame to smoothed target slope interpolated between first and last frame.
		For example, see test.as
		*/
		public static function tiltFrames(yAtX:Number, yAtXPlus16:Number, firstFrame:uint, lastFrame:uint, currentFrame:uint):Array {
			const MIN_SLOPE:Number = -1.0;
			const MAX_SLOPE:Number = 1.0;
			const MAX_FRAME_LENGTH:uint = 32;
			const X_DISTANCE:Number = 16.0;
			var frames:Array = new Array();
			var negativeSlope:Number = (yAtX - yAtXPlus16) / X_DISTANCE;
			negativeSlope = Math.max(MIN_SLOPE, Math.min(MAX_SLOPE, negativeSlope));
			var progress:Number = (negativeSlope - MIN_SLOPE) / (MAX_SLOPE - MIN_SLOPE);
			var targetFrame:uint = int(Math.round(progress * (lastFrame - firstFrame) + firstFrame));
			if (currentFrame < firstFrame) {
				frames.push(firstFrame);
			}
			else if (lastFrame < currentFrame) {
				frames.push(lastFrame);
			}
			var frame:uint = Math.max(firstFrame, Math.min(lastFrame, currentFrame));
			if (targetFrame != frame) {
				var step:int = 1;
				if (targetFrame < frame) {
					step = -1;
				}
				if (Config.debug) {
					var stepCount:uint = 0;
				}
				while (targetFrame != frame) {
					frame += step;
					frames.push(frame);
					if (Config.debug) {
						stepCount++;
						if (MAX_FRAME_LENGTH <= stepCount) {
							throw RangeError("tiltFrames: frames longer than expected: " + frames);
						}
					}
				}
			}
			return frames;
		}
		
		/*
		Replace tilt frames in this sprite's animations and plays.
		*/
		public function playTilt(yAtX:Number, yAtXPlus1:Number):void {
			var tiltFrames:Array = Player.tiltFrames(yAtX, yAtXPlus1, Player.TILT_FIRST_FRAME, Player.TILT_LAST_FRAME, this.frame);
			if (1 <= tiltFrames.length) {
				Player.replaceAnimationFrames(this._animations, "tilt", tiltFrames);
				this.play("tilt", true);
			}
		}
	}		
}


/**
 * Hold the pixels of a sprite sheet in this.bitmapData.
 */
class PlayerSpritesheet extends FlxMovieClip
{
	// AS3 Embedded MovieClip Gotcha:  Need two frames to declare movieclip.
	// http://www.airtightinteractive.com/2008/05/as3-embedded-movieclip-gotcha/
	[Embed(source="../data/player.swf", symbol="player")] public static var MovieClipClass:Class;
	
	public function PlayerSpritesheet() 
	{
		super(MovieClipClass);
	}
	
}
