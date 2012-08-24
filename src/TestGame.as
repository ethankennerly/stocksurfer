package
{
	import org.flixel.*;

	[SWF(width="550", height="400", backgroundColor="#000000")]
	[Frame(factoryClass="TestPreloader")]

	public class TestGame extends FlxGame
	{
		public function Test()
		{
			super(550,400,TestPlayState,1);
		}
	}
}

