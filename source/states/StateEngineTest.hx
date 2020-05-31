/**
   
	= Test load-reload map + colors
	= Test load-reload sprites + colors

**/


package states;

import djFlixel.D;
import djFlixel.fx.BoxFader;
import djFlixel.tool.DelayCall;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.effects.FlxFlicker;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import gamesprites.*;
import gamesprites.Enemy_AI.AI_Final_Boss;
import gamesprites.Item.ITEM_TYPE;

import djFlixel.ui.FlxMenu;

class StateEngineTest extends FlxState
{
	var map:MapFK;
	var pl:Player;
	var spr:FlxSprite;
	
	var MAPS = ['level_01', 'level_02:A'];
	var COLS = ['red', 'green'];
	var c = 0;
	
	//====================================================;
	
	override public function create():Void 
	{
		trace(" >>> ENGINE TEST STATE >>>");
		super.create();
		
		bgColor = Reg.BG_COLOR;
		
		// -- Dummy player, need this to work for map to work
		pl = new Player();
		pl.active = pl.alive = false;
		
		// --
		map = new MapFK(pl);
		map.onEvent = on_map_event;
		add(map);
		
		spr = new FlxSprite();
		spr.setPosition(64, 64);
		add(spr);
		
		loadNextMap();
	}//---------------------------------------------------;
	
	function loadNextMap()
	{
		c++;
		if (c >= 2) c = 0;
		map.loadMap(MAPS[c]);
		Reg.IM.loadGraphic(spr, 'enemy_sm', COLS[c]);
	}//---------------------------------------------------;
	
	function on_map_event(e:MapFK.MapEvent)
	{
		trace("MAP EVENT", e);
	}//---------------------------------------------------;
	
	
	// --
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		if (FlxG.keys.justPressed.SPACE)
		{
			loadNextMap();
		}
	}//---------------------------------------------------;
		
}// --