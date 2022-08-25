/**
	- When player completes the game
	- End sequence
	- Some data on map file "end.tmx"
	- DELETES THE SAVEGAME!!!!
===================================== **/


package states;

import djFlixel.D;
import djFlixel.core.Dcontrols;
import djFlixel.gfx.FilterFader;
import djFlixel.gfx.pal.Pal_CPCBoy;
import djFlixel.other.FlxSequencer;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.effects.FlxFlicker;
import flixel.tweens.FlxTween;
import gamesprites.Player;


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
		map = new MapFK(pl);
		FlxG.cameras.reset(map.camera);
		add(map);
		map.onEvent = (e)-> { if (e == loadMap) P01(); };
		map.loadMap('end');
		
		new FilterFader(false, {time:0.5});
		
		// --
		D.save.deleteSlot(1);
		trace("Save Slot (1) Deleted");
	}//---------------------------------------------------;
	
	function P01()
	{
		// Position datas
		var obj = map.T.getObjMap('Entities');
		
		// -- Just like <introstate> hack the player sprite
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
		
		var mapEndX = map.ROOM_WIDTH * map.roomTotal.x;
		FlxTween.tween(map.camera.scroll, {x:mapEndX - map.ROOM_WIDTH}, obj['player'].prop.time2);
		FlxTween.tween(pl, {x:mapEndX}, obj['player'].prop.time);
		FlxTween.tween(fr, {x:mapEndX}, obj['friend'].prop.time);
		
		
		// -- Display Some Texts
		D.align.pInit(0, 40, map.ROOM_WIDTH, map.ROOM_HEIGHT);
		var st_p = {f:'fnt/text.ttf', s:16, c:Pal_CPCBoy.COL[26], bc:Pal_CPCBoy.COL[1], bt:2, bs:1};
		var st_p2 = {f:'fnt/text.ttf', s:16, c:Pal_CPCBoy.COL[15], bc:Pal_CPCBoy.COL[1], bt:2, bs:1};
		var t1 = D.align.pT('', {ta:"c"}, st_p);
		var t2 = D.align.pT('', {ta:"c"}, st_p2);
		
		add(new FlxSequencer((seq)->{
			switch(seq.step){
				case 1:
					add(t1); add(t2);
					t1.text = "original game";
					t2.text = "Gremlin Graphics, 1986";
					seq.next(5);
				case 2:
					FlxFlicker.flicker(t1, 1);
					FlxFlicker.flicker(t2, 1);
					seq.next(1);
				case 3:
					t1.text = "DX Version";
					t2.text = "John32B 2021";
					seq.next(5);
				case 4:
					FlxFlicker.flicker(t1, 1);
					FlxFlicker.flicker(t2, 1);
					seq.next(1);	
				case 5:
					t1.text = "-- THE END --";
					t2.text = "";
					seq.next(8);
				case 6:
					t1.text = "";
					new FilterFader( ()->{
						FlxG.switchState(new StateTitle());
					}, {time:2});
				case _:
			}
		}, 2)); // start after 2 seconds
		
	}//---------------------------------------------------;
}// --