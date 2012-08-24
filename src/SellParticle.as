package  
{
	import org.flixel.FlxParticle;
	
	/**Add particle, not sprite, to emitter.
	 * http://forums.flixel.org/index.php?topic=4883.0
	 * @author Ethan Kennerly
	 */
	public class SellParticle extends FlxParticle
	{
		public function SellParticle() 
		{
			super();
			var sheet:SellParticleSpritesheet = new SellParticleSpritesheet();
			this.loadGraphic(SellParticleSpritesheet, true, false, sheet.frameWidth, sheet.frameHeight);
			this.addAnimation("idle", [0, 1], 2, true);
			exists = false;
			this.centerOffsets(true);
        }
       
        override public function onEmit():void
        {
			this.play("idle");
		}
	}
}


/**
 * Hold the pixels of a sprite sheet in this.bitmapData.
 */
class SellParticleSpritesheet extends FlxMovieClip
{
	// AS3 Embedded MovieClip Gotcha:  Need two frames to declare movieclip.
	// http://www.airtightinteractive.com/2008/05/as3-embedded-movieclip-gotcha/
	[Embed(source="../data/sell_particle.swf", symbol="sell_particle")] public static var MovieClipClass:Class;
	
	public function SellParticleSpritesheet() 
	{
		super(MovieClipClass);
	}
}
