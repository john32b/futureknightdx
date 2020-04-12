/**
	FUTURE KNIGHT - MAIN PLAY STATE
	===============================

**/


package;

import flixel.FlxG;
import flixel.FlxState;
import gamesprites.*;

import djFlixel.ui.FlxMenu;


class StatePlay extends FlxState
{
	
	var menu:FlxMenu;
	
	var map:MapFK;
	
	var ROOMSPR:RoomSprites;
	
	var player:Player;
	
	override public function create():Void 
	{
		super.create();
		
		ROOMSPR = new RoomSprites();
		player = new Player();
		map = new MapFK();
		map.onEvent = event_map_handler;
		
		Game.map = map;
		Game.player = player;
		Game.roomspr = ROOMSPR;

		// :: Ordering
		add(map);
		add(ROOMSPR);
		add(player);
		
		// : load the level, logic will be auto-triggered 
		map.load(Reg.LEVELS[0]);
	}//---------------------------------------------------;
	
	// --
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		
		// --
		FlxG.overlap(player, ROOMSPR, _overlap_player_roomgroup);
	}//---------------------------------------------------;
	
	
	function _overlap_player_roomgroup(a:Player, b:MapSprite)
	{
		if (Std.is(b, Enemy)){

		}
		else if (Std.is(b, Item)){
			
		}
		else if (Std.is(b, AnimatedTile))
		{
			player.event_anim_tile(player, cast b);
		}
	}//---------------------------------------------------;
	
	
	function event_map_handler(ev:MapFK.MapEvent)
	{
		switch(ev) 
		{
			case loadMap: // Map has just loaded. Tilemap Created, Entities and Tiles Processed
				
				ROOMSPR.reset();
				
				if (map.PLAYER_SPAWN != null) 
				{
					var sp = map.PLAYER_SPAWN;
					trace("Player Spawn Point FOUND",sp);
					map.camera_teleport_to_room_containing(sp.x, sp.y);
					player.spawn(sp.x, sp.y);
				}else{
					// Scan for ENTRY points and teleport to the correct one
					trace("NO PLAYER SPAWN POINT");
				}
				
				
			case roomEntities(b): 
				// These entities are to be set in the current room
				for (en in b) 
				{
					// DEV: I don't need to get player
					ROOMSPR.spawn(en);
				}
				
			case scrollStart:
				for (e in ROOMSPR) e.active = false;
				player.active = false;
				ROOMSPR.stashSave();
				
			case scrollEnd:
				ROOMSPR.stashKill();
				for (e in ROOMSPR) e.active = true;
				player.active = true;
		}
	}//---------------------------------------------------;
	
	
}// --