/**
	FUTURE KNIGHT - MAIN PLAY STATE
	===============================

**/


package;

import djFlixel.D;
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
	public var INV:Inventory;
	
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
		INV = new Inventory();
		INV.onClose = resume;
		INV.onOpen = pause;
		
		map.onEvent = event_map_handler;
		
		// :: Ordering
		add(map);
		add(ROOMSPR);
		add(player);
		add(PM);
		add(BM);
		add(INV);
		
		// : load the level, logic will be auto-triggered 
		//map.load(Reg.LEVELS[0]);
		map.load(D.assets.files.get(Reg.LEVELS[0]), true);
		
	}//---------------------------------------------------;
	
	// --
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		
		// Notes:
		// ------
		// Player->Map collisions , in player.update()
		// Bullet->Map collisions , in BulletManager.update()
		
		// Player->(Enemies,Items,AnimTiles)
		FlxG.overlap(player, ROOMSPR, _overlap_player_roomgroup);
		
		// Bullets->Player
		FlxG.overlap(player, BM, _overlap_player_bullet);
		
		// Bullets->Enemies
		FlxG.overlap(ROOMSPR.gr_enemy, BM, _overlap_enemy_bullet);
		
	}//---------------------------------------------------;
	
	
	// <COLLISION> Bullet to Enemy
	function _overlap_enemy_bullet(e:Enemy, b:BulletManager.Bullet)
	{
		if (b.owner != BulletManager.OWNER_PLAYER) return;
		BM.killBullet(b, true);
		e.hurt(Reg.P_DAM.player_bullet);	/// Do bullets have different power?
	}//---------------------------------------------------;
	// <COLLISION>, Bullet to Player
	function _overlap_player_bullet(a:Player, b:BulletManager.Bullet)
	{
		if (b.owner != BulletManager.OWNER_ENEMY) return;
		BM.killBullet(b);
		a.hurt(Reg.P_DAM.enemy_bullet);
	}//---------------------------------------------------;
	// <COLLISION> Player to (ENEMY,ITEM,ANIM)
	function _overlap_player_roomgroup(a:Player, b:MapSprite)
	{
		if (Std.is(b, Enemy)){
			if (!b.alive) return;
			var en:Enemy = cast b;
			b.hurt(Reg.P_DAM.player_to_enemy);
			a.hurt(Reg.P_DAM.enemy_to_player);
			
			// from old code:
			//if (enemy.isBig) 
			//{
				//if(enemy.health>100)
					//pl.hurt(100);
				//else
					//pl.hurt(enemy.health);
					//
				//enemy.hurt(100);
			//}else
			//{
				//pl.hurt(enemy.health);
				//enemy.softKill();				
			//}
		}
		else if (Std.is(b, Item)){
			var item:Item = cast b;
			item.killExtra();
			INV.addItem(item.item_id);
		}
		else if (Std.is(b, AnimatedTile))
		{
			player.event_anim_tile(player, cast b);
		}
	}//---------------------------------------------------;
	
	
	// --
	function event_map_handler(ev:MapFK.MapEvent)
	{
		switch(ev) 
		{
			case loadMap: 
				// Map has just loaded. Tilemap Created, Entities and Tiles Processed
				ROOMSPR.reset();
				BM.reset();
				PM.reset();
				
				if (map.PLAYER_SPAWN != null) 
				{
					var sp = map.PLAYER_SPAWN;
					player.spawn(sp.x, sp.y);	// Do this first thing, then the enemies, since some enemies rely on player pos
					map.camera_teleport_to_room_containing(sp.x, sp.y);	// This will trigger enemy creation
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
				PM.kill();
				BM.kill();
				for (e in ROOMSPR) e.active = false;
				player.active = false;
				ROOMSPR.stashSave();
				
			case scrollEnd:
				ROOMSPR.stashKill();
				for (e in ROOMSPR) e.active = true;
				player.active = true;
		}
	}//---------------------------------------------------;
	
	// --
	public function pause()
	{
		ROOMSPR.active = false;
		player.active = false;
		PM.active = false;
		BM.active = false;
		trace("game pause()");
	}//---------------------------------------------------;
	
	// --
	public function resume()
	{
		ROOMSPR.active = true;
		player.active = true;
		PM.active = true;
		BM.active = true;
		trace("game resume()");
	}//---------------------------------------------------;
		
}// --