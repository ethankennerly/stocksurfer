package  
{
	import org.flixel.FlxParticle;
	
	/**Add particle, not sprite, to emitter.
	 * http://forums.flixel.org/index.php?topic=4883.0
	 * @author Ethan Kennerly
	 */
	public class BuyParticle extends FlxParticle
	{
		public function BuyParticle() 
		{
			super();
			var sheet:BuyParticleSpritesheet = new BuyParticleSpritesheet();
			this.loadGraphic(BuyParticleSpritesheet, true, false, sheet.frameWidth, sheet.frameHeight);
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
class BuyParticleSpritesheet extends FlxMovieClip
{
	// AS3 Embedded MovieClip Gotcha:  Need two frames to declare movieclip.
	// http://www.airtightinteractive.com/2008/05/as3-embedded-movieclip-gotcha/
	[Embed(source="../data/buy_particle.swf", symbol="buy_particle")] public static var MovieClipClass:Class;
	
	public function BuyParticleSpritesheet() 
	{
		super(MovieClipClass);
	}
}
