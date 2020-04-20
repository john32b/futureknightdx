package states;

import djFlixel.D;
import djFlixel.fx.StarfieldSimple;
import djFlixel.gfx.pal.Pal_CPCBoy;
import flixel.FlxSprite;
import flixel.FlxState;


class StateGameover extends FlxState
{
	override public function create():Void 
	{
		super.create();
		
		// -- Stars
		var stars = new StarfieldSimple(320, 240);	// Default colors, transparent BG
		stars.setBGCOLOR(Pal_CPCBoy.COL[1]);
		stars.WIDE_PIXEL = true;
		stars.STAR_SPEED = 1.9;
		add(stars);
		
		// --
		Reg.add_border();
		
		// --
		var pl = new FlxSprite();
		Reg.IM.loadGraphic(pl, "player");
		pl.animation.frameIndex = 17;
		D.align.screen(pl);
		pl.y -= 32;
		add(pl);
		
		// --
		var tx1 = D.text.get("GAME OVER", 0, 0, {s:16});
		D.align.downCenter(tx1, pl, 4);
		add(tx1);
		
		// --
		var tx2 = D.text.get("-try again-", 0, 0 );
		D.align.downCenter(tx2, tx1, 4);
		add(tx2);
	}//---------------------------------------------------;
	
}// --