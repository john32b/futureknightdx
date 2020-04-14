/**
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
	
	var ai:Enemy_AI;
	var _spawnTimer:Float;
	var spawnTime:Float;
	
	// --
	public function new() 
	{
		super();
	}//---------------------------------------------------;
	
	// --
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		
		if (alive) {
	 		ai.update(elapsed);
		}else {
			if (spawnTime < 0) return;	// This enemy does not ever respawn
			_spawnTimer+= elapsed;
			if ( _spawnTimer >= spawnTime) {
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
		
		spawnTime = Reg.P.en_spawn_time;	// Separate because some enemies might want to spawn later?
		
		// Default ORIGIN to all enemies is center, unless an AI sets this again
		spawn_origin_set(0);
				
		_loadGraphic(gid);
		halfWidth = Std.int(width / 2);
		
		// :: AI
		ai = Enemy_AI.getAI(o.type, this);
		
		// --
		respawn();
	}//---------------------------------------------------;
	
	// --
	function respawn() 
	{
		visible = alive = moves = solid = true;
		animation.play('main', true);
		ai.respawn();	// The AI will actually place it
	}//---------------------------------------------------;
	
	// --
	override public function hurt(Damage:Float):Void 
	{
		//softKill();
	}//---------------------------------------------------;
	
	// --
	public function softKill()
	{
		ai.softkill();
		D.snd.play("en_die");
		_spawnTimer = 0;
		alive = false;
		solid = false;
		visible = false;
		moves = false;
	}//---------------------------------------------------;
	
	
	function _loadGraphic(i:Int)
	{
		switch(i){
			
			// :: Normal Sized Enemy
			case a if (i < 10): 
				i--; // Make it start from 0
				Reg.IM.loadGraphic(this, 'enemy_sm');
				animation.add('main', [(i * ANIM_FRAMES), (i * ANIM_FRAMES) + 1], ANIM_FPS);
				
				// Alter the bounds of SOME enemies
				if (a == 3){ // Slime
					height = 12;
					offset.y = 6;
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
				Reg.IM.loadGraphic(this, 'player');
				animation.add("main", [2, 3, 2, 1], ANIM_FPS + 2);
				setSize(8, 22);
				offset.set(11, 4);
				spawn_origin_set(0); // Will be calculated later also because clone is always FLOOR_BOUND
				
			// :: Big Enemy
			case 13, 14, 15, 16:
				i -= 13;
				Reg.IM.loadGraphic(this, 'enemy_big');
				animation.add('main', [(i * ANIM_FRAMES), (i * ANIM_FRAMES) + 1], ANIM_FPS);
				if (i == 3){ // Long enemy 
					setSize(22, 44);
				}else{	// Normal big enemy
					setSize(44, 44);
				}
				centerOffsets();
				spawn_origin_set(0);
				SPAWN_POS.y = (SPAWN_TILE.y * 8) + 8;	// This is a good placement for BIG enemies
				
			// :: Tall Legs
			case 17, 18:
				i -= 17;
				Reg.IM.loadGraphic(this, 'enemy_tall');
				animation.add('main', [(i * ANIM_FRAMES), (i * ANIM_FRAMES) + 1], ANIM_FPS);
				setSize(50, 50);
				centerOffsets();
				spawn_origin_set(1);// Always floor bound
			
			// :: Worms
			case 19, 20:
				i -= 19;
				Reg.IM.loadGraphic(this, 'enemy_worm');
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