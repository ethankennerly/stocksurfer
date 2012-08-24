package
{
	import org.flixel.FlxGame;
	
	[SWF(width="550", height="400", backgroundColor="#AAAAFF")]
	[Frame(factoryClass="Preloader")]

	public class stocksurfer extends FlxGame
	{
		public function stocksurfer()
		{
			super(550,400,MenuState,1);
		}
	}
}

