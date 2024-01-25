package;

import flixel.FlxGame;
import openfl.display.Sprite;

class Main extends Sprite
{
	static var START_STATE = states.StateAmstrad;

	// --
	public function new() 
	{
		super();
		
		// :: First thing initialize djFlixel
		djFlixel.D.init({
			name: "Future Knight DX",
			version: Reg.VERSION,
			savename:"fkdx",
			init:Reg.init
		});
		
		var FPS:Int = Std.parseInt(djA.Macros.getDefine('FPS'));
		addChild(new FlxGame(320, 240, START_STATE, FPS, FPS, true));
	}//---------------------------------------------------;
	
}//--end class--