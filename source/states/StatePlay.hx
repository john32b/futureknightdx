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

========================================= **/


package states;

import djFlixel.D;
import djFlixel.gfx.BoxFader;
import djFlixel.other.DelayCall;
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

class StatePlay extends FlxState
{
	public var map:MapFK;				// MAP loading, drawing
	public var player:Player;
	public var ROOMSPR:RoomSprites;		// Enemies; Animated; Items
	public var PM:ParticleManager;
	public var BM:BulletManager;
	public var INV:Inventory;
	public var HUD:Hud;
	public var key_ind:KeyIndicator;	// A special sprite that goes on top of some sprites, when players sits on front of them
	
	//====================================================;
	
	/**
	   - Will always load a previously saved game
	   - For NEW GAME, delete the save beforehand
	**/
	override public function create():Void 
	{
		super.create();
		
		bgColor = Reg.BG_COLOR;
		Reg.st = this;
		Reg.add_border();
	
		player = new Player();
			player.pushEvent = on_player_events;
		map = new MapFK(player);	// << DEV WARNING : This creates a camera and makes it default. So mind the ordering.
			map.onEvent = on_map_event;
		ROOMSPR = new RoomSprites();
		key_ind = new KeyIndicator(); 
		PM = new ParticleManager();
		BM = new BulletManager();
		INV = new Inventory();
			INV.onClose = resume;
			INV.onOpen = pause;
			INV.onItemSelect = on_inventory_select;

		// :: Layer Ordering
		add(map);
		add(ROOMSPR);
		add(player);
		add(PM);
		add(BM);
		add(key_ind);
		add(INV);
		
		// :: Creating the Hud will automatically create a camera, so do this last
		HUD = new Hud();
		add(HUD);
		
		// --
		var MAP_TO_LOAD = "";
		var _isNew = false;	// Is it a new game
		
		// -- Load game or new game
		var S = Reg.LOAD_GAME();
		if (S != null) {
			trace("SAVE - Exists OK, loading..", S);
			player.SAVE(S.pl);
			INV.SAVE(S.inv);
			HUD.reset();
			HUD.SAVE(S.hud);
			MAP_TO_LOAD = S.map.levelid;
			map.SAVE(S.map);
			
		}else{
			trace("SAVE - Does not exist, starting new");
			MAP_TO_LOAD = Reg.START_MAP;
			HUD.reset();
			_isNew = true;
		}
		
		// : Override the starting map when debugging
		#if debug
			var L = Reg.INI.get('DEBUG', 'startLevel');
			if (L != null) MAP_TO_LOAD = L;
			// This is when pressing [f12] to reload the map, spawn to the current level again
			if (D.DEBUG_RELOADED) {
				if (MapFK.LAST_LOADED.substr(0, 5) == "level") { // I don't want to reload "intro,end"
					trace("Debug: [F12] Reload level", MapFK.LAST_LOADED);
					MAP_TO_LOAD = MapFK.LAST_LOADED;
				}
			}
		#end
		
		// : Last thing, load the level, this till trigger the on_map_event()
		map.loadMap(MAP_TO_LOAD);
		map.camera.flash(0xFF000000, 0.5);
		D.snd.play("teleport2", 0.5);
		
		// : This should appear at the first level, (when no save exists)
		if (_isNew)
		{
			HUD.set_text("Teleportation successful. Find Amelia.", true, 7);
			map.flash(3);
			FlxFlicker.flicker(player, 0.5, 0.04, true);
		}
		
		D.snd.stopMusic(); /// TODO < : MUSIC!
	}//---------------------------------------------------;
		
		
	/**
	   Usually called when the inventory opens
	   - Can by called on its own
	**/
	public function pause()
	{
		ROOMSPR.active = false;
		player.active = false;
		PM.active = false;
		BM.active = false;
	}//---------------------------------------------------;
	
	/**
	   Called when the inventory closes
	**/
	public function resume()
	{
		ROOMSPR.active = true;
		player.active = true;
		PM.active = true;
		BM.active = true;
	}//---------------------------------------------------;
	// --
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		
		// Notes:
		// ------
		// Player->Map collisions , in player.update()
		// Bullet->Map collisions , in BulletManager.update()
		
		// DEV: If this was not, collisions would happen even when paused
		//		e.g. player getting hurt over and over by an enemy, if they overlap and paused.
		if (!ROOMSPR.active) return;
		
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
					if (!a.alive || !b.alive) return;
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
						D.snd.playV(Reg.SND.item_pickup);
						HUD.item_pickup(item.item_id);
						item.killExtra();
					}else{
						// No more space in inventory
						item.cant_pick_up();
						HUD.set_text2("No more space");
					}
					
					
			case AnimatedTile:
				// Let the player sprite handle this
				player.event_anim_tile(player, cast b);
				
			case _:
		}
	}//---------------------------------------------------;
	
	
	
	// -- @called by player, activates current equipped item if any
	public function use_current_item()
	{		
		var item:ITEM_TYPE = Reg.st.HUD.equipped_item;
		if (item == null) return;
		
		switch (item) {
			
		case BOMB1, BOMB2, BOMB3:
			// :: Kill enemies forever and also enemies that are waiting to be spawned
			// :: Give health
			map.flash(10);
			player.fullHealth();
			
			for (i in ROOMSPR.gr_enemy) {
				if (i.exists) {
					cast(i, Enemy).kill_bomb();
				}
			}
			
			// Enemy hit sound + bomb off
			D.snd.play("en_hit_3", 0.7); 
			D.snd.playV(Reg.SND.item_bomb);
			INV.removeItemWithID(item);
			HUD.item_pickup();
			HUD.score_add(Reg.SCORE.item_bomb);
			
		case CONFUSER_UNIT:
			map.flash(4);
			D.snd.playV(Reg.SND.item_confuser);
			INV.removeItemWithID(item);
			HUD.item_pickup();
			HUD.score_add(Reg.SCORE.item_confuser);
			
			// NEW: if it is the boss, do nothing but also tell
			if (ROOMSPR.getFinalBoss() != null) {
				HUD.set_text2("It does not affect it.");
				return;
			}
			
			ROOMSPR.enemies_freeze(true);
			ROOMSPR.counter  = Reg.P.confuse_time;
			
			// DEV: For enemies that are softKilled, when they respawn, they will respect the freeze timer
			
		case GLOVE:
			HUD.set_text2("With this you are able to pick up hot objects");
				
		case FLASH_BANG_SPELL:
			map.flash(4);
			INV.removeItemWithID(item);
			HUD.item_pickup();
			HUD.score_add(Reg.SCORE.item_flashbang);
			D.snd.playV(Reg.SND.item_flash);
			HUD.set_text2("It doesn't affect the aliens.");
			
		case SCEPTER:
			HUD.set_text2("Does not do anything.");
			
		case DESTRUCT_SPELL:
			var en = ROOMSPR.getFinalBoss();
			if (en == null) {
				HUD.set_text2("Can't use this here");
				return;
			}
			// Boss exists: I need its AI object
			// Sound handled in there
			if (cast(en.ai, AI_Final_Boss).spell_used()) {
					INV.removeItemWithID(item);
					HUD.item_pickup();
					HUD.score_add(Reg.SCORE.item_destruct);	
			}	
			
		case RELEASE_SPELL:
			HUD.set_text2("Can't use this here");
			
		case _:
			HUD.set_text2("Can`t use this here");
		}
		
	}//---------------------------------------------------;
	
	/**
	   AutoCalled whenever a room changes
	   - Special checks, like is this the final boss room? etc
	   @param	R Room Coordinates, 'x,y'
	**/
	function handle_room(R:String)
	{
		if (map.MAP_NAME == "Henchodroids lair")
		{
			if (R == "4,1") {
				// Only add walls, if there is a boss there
				if (ROOMSPR.getFinalBoss() != null) {
					HUD.set_text2("It's the Henchodroid! You must defeat it.");
					map.appendMap(false);
				}
			}
		}
	}//---------------------------------------------------;
	
	// -- @called from player, handles special events
	function on_player_events(name:String)
	{
		switch (name)
		{
			case "revive": // Called after reviving from dead
				Reg.st.ROOMSPR.enemies_freeze(false);
				
			case "die":	// Every time player dies
				Reg.st.ROOMSPR.counter = 0;
				Reg.st.ROOMSPR.enemies_freeze(true);
			
			case "die_final": // After being dead, this is sent when no more lives left
				var bf = new BoxFader();
				add(bf);
				new DelayCall(()->{
					bf.fadeColor(()->{FlxG.switchState(new StateGameover()); });
				}, 1.5);
			
			case "friend":
				pause();
				D.snd.playV('title');
				var bf = new BoxFader();
				add(bf);
				new DelayCall(()->{
					bf.fadeColor(()->{FlxG.switchState(new StateEnd()); } , {delayPost:2});
				}, 2);
				
			default:
		}
		
	}//---------------------------------------------------;
	
	
	/**
	   Handles MAP EVENTS as they occur
	   - loadMap : Map has just loaded. Tilemap Created, Entities and Tiles Processed
	   - roomEntities(EntityDataArray) : These entities exist in the current room. I need to create sprites based off this data
	   - scrollStart : This is called before the new room entities are pushed
	   - scrollEnd : New room has scrolled into the view
	**/
	function on_map_event(ev:MapFK.MapEvent)
	{
		switch(ev) 
		{
			case loadMap: 
				ROOMSPR.reset();	// Will clear all sprites and reset any timers
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
				
				for (en in b)  
				{
					ROOMSPR.spawn(en);
					// DEV: When the new sprites spawn, they are inactive, (ROOMSPR is inactive)
				}
				
				// Extra, handle special rooms:
				handle_room(map.roomCurrent.toCSV());
				
			case scrollStart:
				PM.kill();
				BM.kill();
				ROOMSPR.active = player.active = false;
				ROOMSPR.stashSave(); // < All sprites put to a stash, they are to be removed when the room stops scrolling later
				
			case scrollEnd:
				key_ind.kill();
				ROOMSPR.stashKill(); // < Kill all the sprites that were stashed earlier
				ROOMSPR.active = player.active = true;
		}
	}//---------------------------------------------------;
	
	/** Inventory , an item was selected */
	function on_inventory_select(id:ITEM_TYPE)
	{
		INV.close();
		if (HUD.equipped_item != id) {
			HUD.item_pickup(id);
		}
	}//---------------------------------------------------;
	
}// --