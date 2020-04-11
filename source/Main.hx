package;

import djFlixel.D;
import flixel.FlxGame;
import openfl.display.Sprite;

class Main extends Sprite
{
	var startState = StateTest;
	//var startState = StateAmstrad;
	//var startState = StateTitle;
	
	public function new() 
	{
		super();
		
		// :: First thing initialize djFlixel
		D.init({
			name:"Future Knight Remake v1.4",
			debug_keys:true	// Automatic asset reload on F12
		});
		
		// :: Do this before creating the game
		Reg.init();
		
		// :: Start the game after loading the dynamic assets (they were defined in Reg.init)
		D.assets.reload( ()->{	
			addChild(new FlxGame(320, 240, startState, 2, 40, 40, true));
		});
		
	}//---------------------------------------------------;
	
}//--end class--