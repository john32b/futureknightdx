package states;

import djFlixel.D;
import djFlixel.core.Dcontrols;
import djFlixel.gfx.BoxFader;
import djFlixel.gfx.StarfieldSimple;
import djFlixel.gfx.TextBouncer;
import djFlixel.gfx.pal.Pal_CPCBoy;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;


class StateGameover extends FlxState
{
	static inline var FREEZE_TIME = 4;
	static inline var EXIT_TIME = 10;
	var _timer:Float = 0;
	
	override public function create():Void 
	{
		super.create();
		
		trace(":: Gameover State");
		
		D.snd.stopMusic();
		D.snd.playV('gameover');
		
		// -- Stars
		var stars = new StarfieldSimple(FlxG.width, FlxG.height, [	
			Pal_CPCBoy.COL[0],
			Pal_CPCBoy.COL[3],
			Pal_CPCBoy.COL[7],
			Pal_CPCBoy.COL[6]
		]);
		stars.WIDE_PIXEL = true;
		stars.STAR_SPEED = 1.9;
		add(stars);
		
		
		// --
		var pl = new FlxSprite();
		Reg.IM.loadGraphic(pl, "player", "blue");
		pl.animation.frameIndex = 17;
		D.align.screen(pl);
		pl.y -= 32;
		add(pl);
		
		// --
		var tb = new TextBouncer("GAME OVER", 78, 108, 
			{s:12, f:"fnt/score.ttf", bc:Pal_CPCBoy.COL[2], c:Pal_CPCBoy.COL[26], bs:2, bt:2});
		add(tb);
		tb.start();
		
	}//---------------------------------------------------;
	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		_timer += elapsed;
		if (_timer > FREEZE_TIME)
		{
			if (D.ctrl.justPressed(_ANY) || FlxG.mouse.justPressed)
			{
				exit();
				return;
			}
			
			if (_timer > EXIT_TIME) exit();
		}
	}//---------------------------------------------------;
	
	
	function exit()
	{
		FlxG.switchState(new StateTitle());
	}//---------------------------------------------------;
}// --