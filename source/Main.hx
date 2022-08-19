package;

import djFlixel.D;
import flixel.FlxGame;
import openfl.display.Sprite;

class Main extends Sprite
{
	inline static var FPS = 40;
	inline static var START_STATE = states.StateAmstrad;
	 
	// --
	public function new() 
	{
		super();
		
		// :: First thing initialize djFlixel
		D.init({
			name:"Future Knight DX " + Reg.VERSION,
			savename:"fkdx",
			smoothing:false,
			init:Reg.init
		});
		
		addChild(new FlxGame(320, 240, START_STATE, 2, FPS, FPS, true)); // true = SkipSplash
		
	}//---------------------------------------------------;
	
}//--end class--