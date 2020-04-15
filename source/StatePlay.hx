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
	public var map:MapFK;
	
	public var ROOMSPR:RoomSprites;
	public var player:Player;
	public var PM:ParticleManager;
	public var BM:BulletManager;
	
	var menu:FlxMenu;
	
	
	override public function create():Void 
	{
		super.create();
		Reg.st = this;
		ROOMSPR = new RoomSprites();
		player = new Player();
		map = new MapFK();
		PM = new ParticleManager();
		BM = new BulletManager();
		
		map.onEvent = event_map_handler;
		
		// :: Ordering
		add(map);
		add(ROOMSPR);
		add(player);
		add(PM);
		add(BM);
		
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
			if (!b.alive) return;
			var en:Enemy = cast b;
			b.hurt(100);
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
			case loadMap: 
				// Map has just loaded. Tilemap Created, Entities and Tiles Processed
				ROOMSPR.reset();
				for (i in PM) i.kill();
				for (i in BM) i.kill();
				
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
				// DEV: I don't need to get player. ROOMSPR will ignore it
				for (en in b)  
				{
					ROOMSPR.spawn(en);
				}
				
				
			// This is called before the new room entities are pushed
			case scrollStart:
				for (i in BM) i.kill();
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