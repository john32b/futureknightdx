package;

import djFlixel.D;
import flixel.FlxG;
import openfl.display.Bitmap;
import openfl.display.Sprite;

class Main extends Sprite
{
	inline static var FPS = 40;
	//inline static var START_STATE = states.StateAmstrad;
	//inline static var START_STATE = states.StateTitle;
	//inline static var START_STATE = states.StateGameover;
	//inline static var START_STATE = states.StateEnd;
	//inline static var START_STATE = states.StateIntro;
	//inline static var START_STATE = states.StateEngineTest;
	//inline static var START_STATE = states.StateAmstrad;
	inline static var START_STATE = states.StatePlay;
	 
	// --
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
			addChild(new flixel.FlxGame(320, 240, START_STATE, 2, FPS, FPS, false));
			Reg.init_post();
			
			// -- Add a border/overlay
			// TODO::
			border = new Bitmap(flixel.system.FlxAssets.getBitmapData(Reg.IM.STATIC.overlay_scr));
			border.smoothing = true;
			border.pixelSnapping = "never";
			addChild(border);
			FlxG.signals.gameResized.add(onResize);
			onResize(0, 0);	// Force a border size fix
		});
		
	}//---------------------------------------------------;
	
	var border:Bitmap;
	function onResize(w:Int,h:Int)
	{
		border.x = FlxG.scaleMode.offset.x;
		border.y = FlxG.scaleMode.offset.y;
		border.width = FlxG.scaleMode.gameSize.x;
		border.height = FlxG.scaleMode.gameSize.y;
	}
	
}//--end class--