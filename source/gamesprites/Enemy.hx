/*
Future Knight Enemy
======================================
- Assets loaded from `AssetColorizer.hx`
- Movement handles by an AI system check <Enemy_AI.hx>
 
== Enemy graphics ID
	1-8: Normal unique enemies
	9  : Ghost Explosion
	10 : Player Clone

	13-15 : Bigs
	16: Big Bounce
	17-18: Long Legs
	19-20: Worms

	
== SOUND_FILES
	en_die
	en_spawn	// rewrk this
	en_start	// when boss start moving? I don't need it?
 
**/
 
 
package gamesprites;

import djFlixel.D;
import djfl.util.TiledMap.TiledObject;
import flixel.FlxSprite;
import gamesprites.Enemy_AI;


class Enemy extends MapSprite
{
	
	// :: Some hard coded
	static inline var ANIM_FPS = 8;
	static inline var ANIM_FRAMES = 2; 		// Every enemy has 2 frames. In the future I could change it to 3 or 4
	static inline var HURT_I_TIME = 0.1;	// Invinvibility time after being hurt
	
	static public var PAR = {
		health 		 : 20,	// (2 bullets, 4 bullets, 2 bullets)
		health_chase : 30,	// (3 bullets, 5 bullets, 2 bullets)
		health_big  : 200,
		health_long : 120,
		health_tall	: 240,
		health_worm : 180,
		health_turret : 600,
		
		health_phase1 : 600,	// Final Boss 
		health_phase2 : 800,	// Final Boss
		
		spawntime: 		3.5,
		spawntime_big:  6,
		
		speed : 50,
		speed_big : 30,
		speed_long : 35,
		speed_turret  : 2.3,	// seconds between shots
		speed_bigtall : 1.5,	// seconds between shots
	};
	
	static public var SND = {
		hit:["en_hit_1", "en_hit_2", "en_hit_3"],
		die:["en_die_1", "en_die_2"],
		big_die:["big_die_1", "big_die_2"]
	};
	
	// Precalculated to avoid width/2 all the time.
	public var halfWidth:Int = 0;
	public var halfHeight:Int = 0;
	
	// Every enemy has an AI driver
	public var ai(default, null):Enemy_AI;
	
	var _spawnTimer:Float;	// SpawnTime counter. 
	var spawnTime:Float;	// Time to wait for regenerating. If <0 will never respawn
	var speed:Float;		// The actual speed of the enemy
	var startHealth:Float;
	
	// GFXType, used for creating appropriate explosions
	// 0:Normal, 1:Big, 2:Long, 3:Worm
	var _gfxtype:Int = 0;
	
	// Time since last hurt. This is so an enemy can't get hurt at each frame. Counts down to 0
	var _hurtTimer:Float = 0;
	
	// This is the palette coloring of the enemy. e.g. "red", "yellow"
	// Colors are defined in <ImageAssets.hx>
	// This is also passed to the explosion particle
	var PAL_COLOR:String;
	
	// --
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		
		if (alive) {
			
			if (_hurtTimer > 0) {
				if ((_hurtTimer -= elapsed)<= 0) {
					setColorTransform(1, 1, 1, 1, 0, 0, 0, 0);
				}
			}
	 		ai.update(elapsed);
			
		}else {
			
			if (spawnTime < 0) return;	// This enemy does not ever respawn
			
			if ( (_spawnTimer += elapsed) >= spawnTime) {
				// Avoid spawning and then running into player while he dead.
				// Will spawn once the player is alive
				if(Reg.st.player.alive)
					respawn();
			}
		}
	}//---------------------------------------------------;

	
	// Called from MAIN when the enemy is to be created 
	// DEV Notes: 
	// - Size is reset by <loadgraphic>
	// - Previous animations are automatically destroyed upon <loadGraphic>
	override public function spawn(o:TiledObject, gid:Int)
	{
		super.spawn(o, gid);
		
		moves = true;			// Override the default false of `MapSprite`
		acceleration.set(0, 0);	// Just in case, this is for the bounce spite
		
		// These are the defaults, can be overriden by AI init.
		speed = PAR.speed;
		startHealth = PAR.health;
		spawnTime = PAR.spawntime;
		
		// Default ORIGIN to all enemies is center, unless an AI sets this again
		spawn_origin_set(0);
				
		_loadGraphic(gid);
		
		halfWidth = Std.int(width / 2);
		halfHeight = Std.int(height / 2);
		
		// :: Set Enemy AI, and parameters depending on `type`
		switch(o.type)
		{
			case "move_x": ai = new AI_Move_X(this);
			case "move_y": ai = new AI_Move_Y(this); 
			case "bounce": ai = new AI_Bounce(this);
			case "final":  // Final Boss
				startHealth = PAR.health_phase1;
				spawnTime = -1;	// Boss can never respawn, And will be killed for good when is dead
				ai = new AI_Final_Boss(this);
			case "chase": 
				startHealth = PAR.health_chase;
				ai = new AI_Chase(this); 
			case "big_chase" : 
				startHealth = PAR.health_big;
				spawnTime = PAR.spawntime_big;
				speed = PAR.speed_big;
				ai = new AI_BigChase(this);
			case "big_tall" :
				startHealth = PAR.health_tall;
				spawnTime = PAR.spawntime_big;
				ai = new AI_Turret(this, 1);
			case "big_bounce": 
				startHealth = PAR.health_long;
				speed = PAR.speed_long;
				ai = new AI_BigBounce(this);
			case "turret" : 
				startHealth = Enemy.PAR.health_turret;
				ai = new AI_Turret(this, 0);
			case _: 
				ai = new Enemy_AI(this); // Immobile
		}
		
		// :: Lastly check for overrides from TILED
		if (o.prop != null && o.prop.speed != null)
		{
			speed = speed * o.prop.speed;
		}
		
		respawn();
	}//---------------------------------------------------;
	
	// --
	function respawn() 
	{
		setColorTransform(1, 1, 1, 1, 0, 0, 0, 0);	// Reset color in case it was altered
		_hurtTimer = 0;
		health = startHealth;
		visible = alive = moves = solid = true;
		animation.play('main', true);
		ai.respawn();	// The AI will actually place it
		
		// Check if confuser is active
		if (Reg.st.ROOMSPR.counter > 0) {
			moves = false;
		}
		
		// DEV: I could send the enemy_respawn signal to another handler?
		//      but for now it is just a confuser so I am checking here
	}//---------------------------------------------------;
	
	// --
	override public function hurt(Damage:Float):Void 
	{
		if (_hurtTimer > 0) return;
		
		health -= Damage;
		
		if (health <= 0)
		{
			D.snd.play(SND.hit[0], 0.7);
			softKill();
		}else{
			
			D.snd.playR(SND.hit);
			setColorTransform(1, 1, 1, 1, 180, 180, 180, 0);
			_hurtTimer = HURT_I_TIME;
		}
	}//---------------------------------------------------;
	
	// - This is the function to call when an enemy is destroyed in gameplay
	// - Score, Explosion, and Prepare to be respawned
	// - Note the Final Boss does not call this
	public function softKill()
	{
		if (_gfxtype > 0) {
			Reg.st.HUD.score_add(Reg.SCORE.big_enemy_kill);
		}else{
			Reg.st.HUD.score_add(Reg.SCORE.enemy_kill);
		}
		
		_spawnTimer = 0;
		// DEV: Could I just do active=false?
		alive = solid = visible = moves = false;
		
		ai.softkill(); 	// < responsible for triggering the explode function
						// . This is because some enemies do not explode right away

	}//---------------------------------------------------;
	
	// -- This is for killing an enemy internally. When it is to be removed
	override public function kill():Void 
	{
		ai.kill();
		super.kill();
	}//---------------------------------------------------;
	
	/** 
	 * - Kill normal enemy for good and delete from the map
	 * - If enemy is Final_boss, just damage it 
	 **/
	public function kill_bomb()
	{
		if (O.gid == MapTiles.EDITOR_FINAL && alive) {
			hurt(Reg.P_DAM.bomb_damage);
			return;
		}
				
		// Normal enemy:
		if (alive) {
			softKill();
		}
		
		spawnTime = -1;	// Force no respawn
		Reg.st.map.killObject(O, true);
	}//---------------------------------------------------;
	
	/**
	   Create Particles and Sound for current Enemy
	   - This is called by the enemyAI
	**/
	public function explode()
	{
		// NOTE:
		// Normal sound + if enemy is big extra explosion sound:
		
		D.snd.playR(SND.die);
		
		switch(_gfxtype)
		{
			case 1: // 4 particles box
				Reg.st.PM.createAt(0, x + halfWidth - 11, y + halfHeight - 12, velocity.x, velocity.y, PAL_COLOR);
				Reg.st.PM.createAt(0, x + halfWidth - 11, y + halfHeight + 12, velocity.x, velocity.y, PAL_COLOR);
				Reg.st.PM.createAt(0, x + halfWidth + 11, y + halfHeight - 12, velocity.x, velocity.y, PAL_COLOR);
				Reg.st.PM.createAt(0, x + halfWidth + 11, y + halfHeight + 12, velocity.x, velocity.y, PAL_COLOR);
				D.snd.playR(SND.big_die);
				
			case 2: // 2 in height
				Reg.st.PM.createAt(0, x + halfWidth, y + halfHeight - 12, velocity.x, velocity.y, PAL_COLOR);
				Reg.st.PM.createAt(0, x + halfWidth, y + halfHeight + 12, velocity.x, velocity.y, PAL_COLOR);
				D.snd.playR(SND.big_die);
				
			case 3: // 3 in width
				for(i in 0...3) // (0,1,2)
				Reg.st.PM.createAt(0, (x + 11) + (i * 22), y + halfHeight, velocity.x, velocity.y, PAL_COLOR);
				D.snd.playR(SND.big_die);
				
			case _: // 1 particle or default
				Reg.st.PM.createAt(0, x + halfWidth, y + halfHeight, velocity.x, velocity.y, PAL_COLOR);
		};
	}//---------------------------------------------------;
	
	
	// - Load graphic
	// - Plus some tweaks to custom health
	function _loadGraphic(i:Int)
	{
		if (O.name != null) 
			PAL_COLOR = O.name; 
		else
			PAL_COLOR = Reg.IM.getRandomSprColor();
		
		switch(i){
			
			// :: Normal Sized Enemy
			case a if (i < 10): 
				_gfxtype = 0;
				i--; // Make it start from 0
				Reg.IM.loadGraphic(this, 'enemy_sm', PAL_COLOR);
				animation.add('main', [(i * ANIM_FRAMES), (i * ANIM_FRAMES) + 1], ANIM_FPS);
				
				// Alter the bounds of SOME enemies
				if (a == 3){ // Slime
					height = 8;
					offset.y = 10;
				}else
				if (a == 6){ // Ball
					height = 18;
					offset.y = 4;
				}
				else{
					setSize(22, 22);
					centerOffsets();
				}
				
				spawn_origin_set(0);
				
			// :: Player Sprite
			case 10:
				// enemy_clone
				_gfxtype = 0;
				startHealth = PAR.health * 2;
				Reg.IM.loadGraphic(this, 'enemy_clone', PAL_COLOR);
				animation.add("main", [1, 2, 1, 0], ANIM_FPS + 2);
				setSize(8, 22);
				offset.set(11, 4);
				spawn_origin_set(0); // Will be calculated later also because clone is always FLOOR_BOUND
				
			// :: Big Enemy
			case 13, 14, 15, 16:
				_gfxtype = 1;
				i -= 13;
				Reg.IM.loadGraphic(this, 'enemy_big', PAL_COLOR);
				animation.add('main', [(i * ANIM_FRAMES), (i * ANIM_FRAMES) + 1], ANIM_FPS);
				if (i == 3){ // Long enemy 
					_gfxtype = 2;
					setSize(22, 44);
				}else{	// Normal big enemy
					setSize(44, 44);
				}
				centerOffsets();
				spawn_origin_set(0);
				SPAWN_POS.y = (SPAWN_TILE.y * 8) + 8;	// This is a good placement for BIG enemies
				
			// :: Tall Legs
			case 17, 18:
				_gfxtype = 1;
				i -= 17;
				Reg.IM.loadGraphic(this, 'enemy_tall', PAL_COLOR);
				animation.add('main', [(i * ANIM_FRAMES), (i * ANIM_FRAMES) + 1], ANIM_FPS);
				setSize(50, 50);
				centerOffsets();
				spawn_origin_set(1);// Always floor bound
				
			
			// :: Worms
			case 19, 20:
				i -= 19;
				_gfxtype = 3;
				startHealth = PAR.health_worm;
				Reg.IM.loadGraphic(this, 'enemy_worm', PAL_COLOR);
				if (i == 0){
					animation.add('main', [0, 1, 0, 2, 0, 3], ANIM_FPS - 2);
					height = 22;
					offset.y = 2;
				}else{
					animation.add('main', [4, 5, 6, 5], ANIM_FPS);
					height = 20;
					offset.y = 2;
				}
				centerOffsets();
				spawn_origin_set(1);// Always floor bound
			
			case _:
				throw "Invalid GID in The Enemy Type" + i;
		}
	}//---------------------------------------------------;
	
}// --