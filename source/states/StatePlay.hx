/**
	FUTURE KNIGHT - MAIN PLAY STATE
	===============================

	
	
	NOTES ON CAMERAS::
	--------------------
	
	- First create the background and put the border, at THE BOTTOM
	- Then the MAP gets created and it will create its own camera
	- I am making the MAP camera as the default camera for all sprites to be drawn on (flxcamera.defaultcameras)
	- Then the HUD uses its own camera, and all of the HUD objects are specified to use the HUD camera
	- The inventory and pause menu open inside the map camera
	- That's it, it works. The flixel camera system is just annoying, Why can't I just have layers?

========================================= **/


package states;

import djFlixel.D;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import gamesprites.*;
import gamesprites.Item.ITEM_TYPE;

import djFlixel.ui.FlxMenu;

class StatePlay extends FlxState
{
	public var map:MapFK;
	
	public var player:Player;
	
	public var ROOMSPR:RoomSprites;
	public var PM:ParticleManager;
	public var BM:BulletManager;
	public var INV:Inventory;
	public var HUD:Hud;
	
	var menu:FlxMenu;
	
	override public function create():Void 
	{
		super.create();
		
		Reg.st = this;
		bgColor = Reg.BG_COLOR;
		Reg.add_border();
	
		map = new MapFK();	// < WARNING : This creates a camera and makes it default
		ROOMSPR = new RoomSprites();
		player = new Player();
		PM = new ParticleManager();
		BM = new BulletManager();
		INV = new Inventory();
			INV.onClose = resume;
			INV.onOpen = pause;
			INV.onItemSelect = on_inventory_select;

		map.onEvent = event_map_handler;
		
		// :: Ordering
		add(map);
		add(ROOMSPR);
		add(player);
		add(PM);
		add(BM);
		add(INV);
		
		// :: Hud on another camera view
		HUD = new Hud();
		add(HUD);
		HUD.reset();
		
		// --
		HUD.set_text("Welcome to Future Knight DX", 5);
		
		#if debug
			if (MapFK.LAST_LOADED != "") {
				map.loadMap(MapFK.LAST_LOADED);
				return;
			}
		#end
		
		// : Last thing, load the level, this till trigger the event_map_handler()
		map.loadMap(Game.START_MAP);
		
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
	function _overlap_enemy_bullet(e:Enemy, b:Bullet)
	{
		if (b.owner != Bullet.OWNER_PLAYER) return;
		BM.killBullet(b, true);
		e.hurt(b.T.damage);
	}//---------------------------------------------------;
	
	// <COLLISION>, Bullet to Player
	function _overlap_player_bullet(a:Player, b:Bullet)
	{
		if (b.owner != Bullet.OWNER_ENEMY) return;
		BM.killBullet(b);
		a.hurt(b.T.damage);
	}//---------------------------------------------------;
	// <COLLISION> Player to (ENEMY, ITEM, ANIM)
	function _overlap_player_roomgroup(a:Player, b:MapSprite)
	{
		switch(Type.getClass(b))
		{
			case Enemy:
					if (!b.alive) return;
					var en:Enemy = cast b;
					b.hurt(Reg.P_DAM.enemy_from_player);
					a.hurt(Reg.P_DAM.player_from_enemy);
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
					
			case Item:
					var item:Item = cast b;
					if (INV.addItem(item.item_id))
					{
						// Pick up OK
						HUD.item_pickup(item.item_id);
						item.killExtra();
					}else{
						// No more space in inventory
						// >> sound error?
					}
					
					
			case AnimatedTile:
				// Animated Tiles: Weapon
				player.event_anim_tile(player, cast b);
				
			case _:
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
					
					// Search for an exit point?
					// But which one?
					
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
	}//---------------------------------------------------;
	
	// --
	public function resume()
	{
		ROOMSPR.active = true;
		player.active = true;
		PM.active = true;
		BM.active = true;
	}//---------------------------------------------------;
	
	
	function on_inventory_select(id:ITEM_TYPE)
	{
		INV.close();
		HUD.item_pickup(id);
	}//---------------------------------------------------;
	
	
	public function on_player_no_lives()
	{
		FlxG.switchState(new StateGameover());
	}//---------------------------------------------------;
}// --