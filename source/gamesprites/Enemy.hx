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
	static inline var ANIM_FRAMES = 2; // Every enemy has 2 frames. In the future I could change it to 3 or 4
	static inline var HURT_I_TIME = 0.1;	// Invinvibility time after being hurt
	
	var ai:Enemy_AI;
	var spawnTime:Float;
	var _spawnTimer:Float;	// Checked against <spawnTime> and when it triggers it respawns the enemy
	
	// Precalculated to avoid width/2 all the time.
	public var halfWidth:Int = 0;
	public var halfHeight:Int = 0;
	
	// GFXType, used for creating appropriate explosions
	// 0:Normal, 1:Big, 2:Long, 3:Worm
	var _gfxtype:Int = 0;
	
	// Time since last hurt. I count so it doesn't get hurt at each frame. Counts down to 0
	var _hurtTimer:Float = 0;

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
		
		health = Reg.P.en_health;
		spawnTime = Reg.P.en_spawn_time;	// Separate because some enemies might want to spawn later?
		
		// Default ORIGIN to all enemies is center, unless an AI sets this again
		spawn_origin_set(0);
				
		_loadGraphic(gid);
		
		halfWidth = Std.int(width / 2);
		halfHeight = Std.int(height / 2);
		
		// :: AI
		ai = Enemy_AI.getAI(o.type, this);
		
		respawn();
	}//---------------------------------------------------;
	
	// --
	function respawn() 
	{
		setColorTransform(1, 1, 1, 1, 0, 0, 0, 0);	// Reset color in case it was altered
		_hurtTimer = 0;
		visible = alive = moves = solid = true;
		animation.play('main', true);
		ai.respawn();	// The AI will actually place it
	}//---------------------------------------------------;
	
	// --
	override public function hurt(Damage:Float):Void 
	{
		if (_hurtTimer > 0) return;
		
		health -= Damage;
		
		if (health <= 0)
		{
			softKill();
		}else{
			
			//setColorTransform(1, 1, 1, 1, 0, 0, 0, 0);
			this.color = 0xFFedd446; /// TODO, other color or bitmap?
			D.snd.play("hit_02");	/// TODO RANDOM 02,03,04
			_hurtTimer = HURT_I_TIME;
		}
	}//---------------------------------------------------;
	
	// --
	public function softKill()
	{
		ai.softkill();
		_explode();
		_spawnTimer = 0;
		alive = false;
		solid = false;
		visible = false;
		moves = false;
	}//---------------------------------------------------;
	
	
	/**
	   Create Particles and Sound for current Enemy
	**/
	function _explode()
	{
		/// todo, big bosses make another sound?
		D.snd.playV("en_die");
		
		switch(_gfxtype)
		{
			case 1: // 4 particles box
				Reg.st.PM.createAt(0, x + halfWidth - 11, y + halfHeight - 12, velocity.x, velocity.y);
				Reg.st.PM.createAt(0, x + halfWidth - 11, y + halfHeight + 12, velocity.x, velocity.y);
				Reg.st.PM.createAt(0, x + halfWidth + 11, y + halfHeight - 12, velocity.x, velocity.y);
				Reg.st.PM.createAt(0, x + halfWidth + 11, y + halfHeight + 12, velocity.x, velocity.y);
				
			case 2: // 2 in height
				Reg.st.PM.createAt(0, x + halfWidth, y + halfHeight - 12, velocity.x, velocity.y);
				Reg.st.PM.createAt(0, x + halfWidth, y + halfHeight + 12, velocity.x, velocity.y);
				
			case 3: // 3 in width
				for(i in 0...3) // (0,1,2)
				Reg.st.PM.createAt(0, (x + 11) + (i * 22), y + halfHeight, velocity.x, velocity.y);
				
			case _: // 1 particle or default
				Reg.st.PM.createAt(0, x + halfWidth, y + halfHeight, velocity.x, velocity.y);				
		};
	}//---------------------------------------------------;
	
	
	function _loadGraphic(i:Int)
	{
		var COL:String;
		
		if (O.name != null) 
			COL = O.name; 
		else
			COL = Reg.IM.AVAILABLE_COLOR_COMBO[Std.random(Reg.IM.AVAILABLE_COLOR_COMBO.length)];
		
		switch(i){
			
			// :: Normal Sized Enemy
			case a if (i < 10): 
				_gfxtype = 0;
				i--; // Make it start from 0
				Reg.IM.loadGraphic(this, 'enemy_sm', COL);
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
				_gfxtype = 0;
				Reg.IM.loadGraphic(this, 'player');
				animation.add("main", [2, 3, 2, 1], ANIM_FPS + 2);
				setSize(8, 22);
				offset.set(11, 4);
				spawn_origin_set(0); // Will be calculated later also because clone is always FLOOR_BOUND
				
			// :: Big Enemy
			case 13, 14, 15, 16:
				_gfxtype = 1;
				i -= 13;
				Reg.IM.loadGraphic(this, 'enemy_big', COL);
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
				Reg.IM.loadGraphic(this, 'enemy_tall');
				animation.add('main', [(i * ANIM_FRAMES), (i * ANIM_FRAMES) + 1], ANIM_FPS);
				setSize(50, 50);
				centerOffsets();
				spawn_origin_set(1);// Always floor bound
			
			// :: Worms
			case 19, 20:
				i -= 19;
				_gfxtype = 3;
				Reg.IM.loadGraphic(this, 'enemy_worm', COL);
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