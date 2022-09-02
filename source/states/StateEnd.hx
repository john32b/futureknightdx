/**
	- When player completes the game
	- End sequence
	- Some data on map file "end.tmx"
	- DELETES THE SAVEGAME!!!!
===================================== **/


package states;

import djFlixel.D;
import djFlixel.gfx.FilterFader;
import djFlixel.gfx.pal.Pal_CPCBoy;
import djFlixel.other.DelayCall;
import djFlixel.ui.FlxAutoText;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.tweens.FlxTween;
import gamesprites.Player;
import djFlixel.gfx.StarfieldSimple;

class StateEnd extends FlxState
{
	var map:MapFK;
	var pl:Player;
	var fr:FlxSprite;
	
	override public function create():Void 
	{
		super.create();
		
		//>> MUSIC should carry over from the previous state
		
		// --
		pl = new Player();
		
		// -- A very map setup, just to load and display a level
		map = new MapFK(pl);
		FlxG.cameras.reset(map.camera);
		map.camera.y += 58;
		
		// -- stars
		var stars = new StarfieldSimple(map.ROOM_WIDTH, map.ROOM_HEIGHT);
		stars.WIDE_PIXEL = true;
		stars.STAR_SPEED = 0.2;
		stars.STAR_ANGLE = 40;
		stars.COLORS = [ Pal_CPCBoy.COL[0], 0xff3a4466, 0xff181425, 0xffb55088 ];
		add(stars);
		
		add(map);
		map.onEvent = (e)-> { if (e == loadMap) DO(); };
		map.loadMap('end');
		
		new FilterFader(false, {time:0.5});
		
		// --
		D.save.deleteSlot(1);
		trace("Save Slot (1) Deleted");
	}//---------------------------------------------------;
	
	// - Map loaded
	function DO()
	{
		// Position datas
		var obj = map.T.getObjMap('Entities');
		
		// -- Just like <StateIntro.hx> hack the player sprite
		pl.setPosition(obj['player'].x, obj['player'].y);
		pl.animation.play('walk');
		@:privateAccess pl.fsm.switchTo(null);	// force no state
		pl.alive = false;
		add(pl);
		
		// -- Friend Sprite
		fr = new FlxSprite(obj['friend'].x, obj['friend'].y);
		Reg.IM.loadGraphic(fr, 'friend', 'yellow');
		fr.animation.add('main', [3, 4, 3, 2], 10);
		fr.animation.play('main');
		add(fr);
		
		// --
		var mapEndX = map.ROOM_WIDTH * map.roomTotal.x;
		FlxTween.tween(map.camera.scroll, {x:mapEndX - map.ROOM_WIDTH}, cast(obj['camera'].prop.time, Float));
		FlxTween.tween(pl, {x:mapEndX}, cast(obj['player'].prop.time, Float));
		FlxTween.tween(fr, {x:mapEndX}, cast(obj['friend'].prop.time, Float));
		
		
		// -- Display Some Texts
		D.align.pInit(0, 40, map.ROOM_WIDTH, map.ROOM_HEIGHT);
		var st_p = {f:'fnt/text.ttf', s:16, c:Pal_CPCBoy.COL[26], bc:Pal_CPCBoy.COL[1], bt:2, bs:1};
		var st_p2 = {f:'fnt/text.ttf', s:16, c:Pal_CPCBoy.COL[15], bc:Pal_CPCBoy.COL[1], bt:2, bs:1};
		var t1 = D.align.pT('', {ta:"c"}, st_p);
		var t2 = D.align.pT('', {ta:"c"}, st_p2);
		
		
		// -- Credits on screen
		
		var T = new FlxAutoText(0, 0, map.ROOM_WIDTH, 2);
		T.style = {f:'fnt/arcade.ttf', s:10, c:Pal_CPCBoy.COL[26], bc:Pal_CPCBoy.COL[1], bt:2, bs:1, a:"center"};
		D.align.screen(T);
		T.y -= 8;
		T.scrollFactor.set(0.0);
		T.setText(Reg.INI.get('text', 'endtext'));
		add(T);
		
		// --
		new DelayCall(obj['camera'].prop.time - 3, ()->{
			new FilterFader( ()-> FlxG.switchState(new StateTitle()), {time:1.6});
		});
		
	}//---------------------------------------------------;
}// --