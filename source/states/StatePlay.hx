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
import djFlixel.gfx.FilterFader;
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
	public var map:MapFK;				// MAP Sprite + Logic
	public var player:Player;
	public var ROOMSPR:RoomSprites;		// Enemies; Animated; Items
	public var PM:ParticleManager;
	public var BM:BulletManager;
	public var INV:Inventory;
	public var HUD:Hud;
	public var key_ind:KeyIndicator;	// A special sprite that goes on top of some sprites, when players sits on front of them
	public var minimap:MiniMap;
	
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
		Reg.sendGameEvent = on_game_event;
	
		player = new Player();
		
		map = new MapFK(player);
		map.onEvent = on_map_event;
		FlxG.cameras.reset(map.camera);	// << Make the map camera default for everything from now on
			
		ROOMSPR = new RoomSprites();
		key_ind = new KeyIndicator(); 
		PM = new ParticleManager();
		BM = new BulletManager();
		INV = new Inventory();
			INV.onClose = resume;
			INV.onOpen = pause;
			INV.onItemSelect = on_inventory_select;
			
		minimap = new MiniMap();

		// :: Layer Ordering
		add(map); 
		add(ROOMSPR);
		add(player);
		add(PM);
		add(BM);
		add(key_ind);
		add(INV);
		add(minimap);
		
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
		
		// : Override the starting map to whatever the INI file says
		#if debug
			var L = Reg.INI.get('DEBUG', 'startLevel');
			if (L != null) MAP_TO_LOAD = L;
		#end
		
		// : This will load the map and will trigger everything else 
		//   with events, check on_map_event()
		map.loadMap(MAP_TO_LOAD);
		
		// : This should appear at the first level, (when no save exists)
		if (_isNew)
		{
			HUD.set_text("Teleportation successful. Find Amelia.", true, 7);
			FlxFlicker.flicker(player, 0.5, 0.04, true);
			D.snd.play("teleport2", 0.5);
			map.flash(3);
		}else{
			
			new FilterFader(false, {time:0.5, delayPost:0});
		}
		
		D.snd.stopMusic(); /// TODO < : MUSIC!
		
		// I think it is a bit too fast, adjust it a bit
		// Restore it when exiting this state
		FlxG.timeScale = 0.9;
		FlxG.signals.preStateSwitch.addOnce(() -> {
			FlxG.timeScale = 1;
		});
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
		
		// DEV: Do not check when the game is paused
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
	
	
	// -- Activates current equipped item if any
	function use_current_item()
	{		
		var item:ITEM_TYPE = Reg.st.HUD.equipped_item;
		if (item == null) return;
		
		switch (item) {
			
		case MAP:
			if (!minimap.open())
			{
				// The minimap is not available for this region
				HUD.set_text2("No use, this map is for the spaceship.");
			}
			
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
			if (ROOMSPR.has_final_boss) {
				HUD.set_text2("It does not affect it.");
				return;
			}
			
			// DEV: For enemies that are softKilled, when they respawn, they will respect the freeze timer [OK]
			ROOMSPR.enemies_freeze(true);
			ROOMSPR.counter  = Reg.P.confuse_time;
			
			
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
			if (!ROOMSPR.has_final_boss) {
				HUD.set_text2("Can't use this here");
				return;
			}
			// Boss exists: I need the AI object
			var en = ROOMSPR.getFinalBoss();
			if (cast(en.ai, AI_Final_Boss).spell_used()) {
					INV.removeItemWithID(item);
					HUD.item_pickup();
					HUD.score_add(Reg.SCORE.item_destruct);	
					// Sound handled in the sprite
			}	
			
		case RELEASE_SPELL:
			HUD.set_text2("Can't use this here");
			
		case _:
			HUD.set_text2("Can`t use this here");
		}
		
	}//---------------------------------------------------;
	
	
	// -- Handles special events
	function on_game_event(name:String)
	{
		switch (name)
		{
			case "useitem":
				// called by player
				use_current_item();
					
			case "revive": // Called after reviving from dead
				Reg.st.ROOMSPR.enemies_freeze(false);
				
			case "die":	// Every time player dies
				Reg.st.ROOMSPR.counter = 0;
				Reg.st.ROOMSPR.enemies_freeze(true);
			
			case "die_final": // After being dead, this is sent when no more lives left
				new DelayCall(1.5, ()->{
					new FilterFader( ()->{
						FlxG.switchState(new StateGameover());
					});
				});
				
			// Final room, touched your friend
			case "friend":
				pause();
				D.snd.playV('title');
				new DelayCall(2, ()->{
					new FilterFader( ()->{
							FlxG.switchState(new StateEnd());
						}, 
						{ delayPost:2 }
					);
						
				});
				
			case "final_spawn":
				HUD.set_text2("It's the Henchodroid! You must defeat it.");
				map.appendMap(false);
				
			case "final_die":
				map.appendRemove();
				map.flash(3);
				HUD.score_add(Reg.SCORE.final_boss);
				
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
				
			// Called right after a `scrollStart` starts. Gives the entities that are to be created
			case roomEntities(b):
				
				for (en in b)  
				{
					ROOMSPR.spawn(en);
				}
				
			// Sent only when changing rooms by going at the edges
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
		if (HUD.equipped_item != id) {
			HUD.item_pickup(id);
		}
	}//---------------------------------------------------;
	
}// --