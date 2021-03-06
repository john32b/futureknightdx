package;

import djFlixel.D;
import flixel.FlxGame;
import openfl.display.Sprite;

class Main extends Sprite
{
	inline static var FPS = 40;
	//inline static var START_STATE = states.StateAmstrad;
	//inline static var START_STATE = states.StateTitle;
	//inline static var START_STATE = states.StateGameover;
	//inline static var START_STATE = states.StateEnd;
	//inline static var START_STATE = states.StatePlay;
	//inline static var START_STATE = states.StateIntro;
	//inline static var START_STATE = states.StateEngineTest;
	inline static var START_STATE = states.StateAmstrad;
	
	//
	public function new() 
	{
		super();
		
		// :: First thing initialize djFlixel
		D.init({
			name:"Future Knight Remake " + Reg.VERSION,
			savename:"fkdx",
			debug_keys:true		// Automatic asset reload on F12
		});
		
		// :: Do this before creating the game
		Reg.init_pre();
		
		// :: Start the game after loading the dynamic assets (they were defined in Reg.init_pre)
		D.assets.reload( ()->{
			trace("Assets Loaded, Staring game ..");
			addChild(new FlxGame(320, 240, START_STATE, 2, FPS, FPS, true));
			Reg.init_post();
		});
		
	}//---------------------------------------------------;
	
}//--end class--