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
import djFlixel.gfx.pal.Pal_CPCBoy;
import djFlixel.other.StepTimer;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.effects.FlxFlicker;
import gamesprites.*;
import flixel.util.FlxColor;
import gamesprites.Item.ITEM_TYPE;
import openfl.filters.ColorMatrixFilter;

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
	
	public var key_ind:KeyIndicator;
	
	var menu:FlxMenu;
	
	var _isflashing = false;
	
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
		key_ind = new KeyIndicator(); 
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
		add(key_ind);
		add(INV);
		
		// :: Hud on another camera view
		HUD = new Hud();
		add(HUD);
		HUD.reset();
		
		// --
		HUD.set_text("Welcome to Future Knight DX", 6);
		
		#if debug
			if (MapFK.LAST_LOADED != "") {
				map.loadMap(MapFK.LAST_LOADED);
				map.camera.flash(0xFF000000, 0.5);
				return;
			}
		#end
		
		// : Last thing, load the level, this till trigger the event_map_handler()
		map.loadMap(Reg.START_MAP);
		map.camera.flash(0xFF000000, 0.5);
		
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
		HUD.score_add(Reg.SCORE.enemy_hit);
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
					if (FlxFlicker.isFlickering(player)) return;
					var dam = Math.min(b.health, Reg.P_DAM.max_damage);
					// Note, if enemy/player is flickering, hurt() will deal with it
					b.hurt(dam);
					a.hurt(dam);
					
			case Item:
			
					var item:Item = cast b;
					if (FlxFlicker.isFlickering(item)) return;
					
					// Special Occasion :: 
					// (RELEASE SPELL) , you can only pick this up if a glove is equipped
					
					if (item.item_id == ITEM_TYPE.RELEASE_SPELL)
					{
						if (HUD.equipped_item != ITEM_TYPE.GLOVE)
						{
							item.cant_pick_up();
							HUD.set_text2("Too hot to pick up! Find a glove");
							return;
						}
					}
					
					
					if (INV.addItem(item.item_id))
					{
						// Pick up OK
						D.snd.play(Reg.SND.item_pickup);
						HUD.item_pickup(item.item_id);
						item.killExtra();
					}else{
						// No more space in inventory
						item.cant_pick_up();
						HUD.set_text2("No more space");
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
				key_ind.kill();
				
				if (map.PLAYER_SPAWN != null) 
				{
					var sp = map.PLAYER_SPAWN;
					player.spawn(sp.x, sp.y);	// Do this first thing, then the enemies, since some enemies rely on player pos
					map.camera_teleport_to_room_containing(sp.x, sp.y);	// This will trigger enemy creation
				}else{
					throw "No player spawn point";
				}
				
				INV.set_level_name(map.MAP_NAME);
				
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
				key_ind.kill();
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
	
	
	// -- Called from player
	public function on_player_no_lives()
	{
		FlxG.switchState(new StateGameover());
	}//---------------------------------------------------;
	
	
	
	
	/**
	   - Do a flash of the whole map/camera
	   @param	TICKS How many changes in color, 5 is a full cycle. You can do as much as you want
	   @param   callback Optional onComplete
	**/
	public function flash(TICKS:Int = 10, ?callback:Void->Void)
	{
		if (_isflashing) return; // should never happen in normal gameplay
	
		var MAT:Array<Array<Float>> = [
		
			[	// black and white
				1, 0, 0, 0, 0,
				1, 0, 0, 0, 0,
				1, 0, 0, 0, 0,
				0, 0, 0, 1, 0
			],	
			[
				1, 0, 0, 0, 128,
				0, 0, 0, 0, 0,
				0, 0, 1, 0, -128,
				0, 0, 0, 1, 0
			],		
			[
				0, 0, 0, 0, 0,
				0, 1, 0, 0, 128,
				0, 0, 1, 0, -128,
				0, 0, 0, 1, 0
			],
			[
				1, 1, 0, 0, 0,
				0, 1, 0, 0, -128,
				0, 0, 1, 0, 128,
				0, 0, 0, 1, 0
			],
			[
				1, 1, 0, 0, 128,
				0, 1, 1, 0, -20,
				1, 0, 1, 0, 20,
				0, 0, 0, 1, 0
			],			
		];
		
		// type 0, and type 1
		var s = new StepTimer((t, f)->{
			if (f){
				_isflashing = false;
				map.camera.setFilters([]);
				if (callback != null) callback();
				return;
			}
			var f = MAT[t % MAT.length];	
			map.camera.setFilters([new ColorMatrixFilter(f)]);
		});	
		
		s.start(0, TICKS, -0.1);
		_isflashing = true;
	}//---------------------------------------------------;
	
	
	// -- Called by player, activates current equipped item if any
	public function use_current_item()
	{		
		var item:ITEM_TYPE = Reg.st.HUD.equipped_item;
		if (item == null) return;
		
		trace("ITEM USE : ", item);
		
		switch (item) {
			
		case BOMB1, BOMB2, BOMB3:
			// :: Kill enemies forever and also enemies that are waiting to be spawned
			flash(10);
			HUD.item_pickup();
			ROOMSPR.enemies_killAll();
			D.snd.play(Reg.SND.item_bomb);
			INV.removeItemWithID(item);
			HUD.score_add(Reg.SCORE.item_bomb);
			
		case CONFUSER_UNIT:
			flash(4);
			HUD.item_pickup();
			ROOMSPR.enemies_freeze(true);	// Player has timer for restore
			D.snd.play(Reg.SND.item_confuser);
			player.confuserTimer = Reg.P.confuse_time;
			INV.removeItemWithID(item);
			HUD.score_add(Reg.SCORE.item_confuser);
			
			// Ok the above^ will freeeze ALIVE enemies,
			// I need to have a flag, so when an enemy is respawed, it will NOT move
			// respect the global freeze flag ok?
			
		case GLOVE:
			HUD.set_text2("With this you are able to pick up hot objects");
				
		case FLASH_BANG_SPELL:
			flash(5);
			HUD.item_pickup();
				
		case SCEPTER:
			HUD.set_text2("Does not do anything.");
			
			
		//case DESTRUCT_SPELL:
				
			
		//case RELEASE_SPELL:
			
		case _:
			HUD.set_text2("Can`t use this here");
		}
		
	}//---------------------------------------------------;
	
}// --