/**
	Gameover screen
	-------

   - A quick GameOver screen, then it goes to StateTitle
   - It WILL delete the savegame.

 **/

package states;

import djFlixel.D;
import djFlixel.core.Dcontrols;
import djFlixel.gfx.TextBouncer;
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
		
		D.snd.stopMusic();
		D.snd.playV('gameover');
		
		// Static fx
		var fx = new djFlixel.gfx.StaticNoise(0, 0, cast FlxG.width / 2, FlxG.height );
		fx.color_custom([0xff000000, 0xff101010]);
		fx.centerOrigin();
		fx.scale.x = 2;
		fx.x = 80;
		add(fx);
		
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
		
		// --
		D.save.deleteSlot(1);
		trace("Save Slot (1) Deleted");
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
