/**
	DEV:
	--------------
	Every enemy has an AI component
	It is read from the TiledEditor Objects <type> field | check `EnemyAI_getAI()
	Some types can have extra parameters, (defined in the TiledObject) as parameters
		
	
	NOTES:
	--------------
		- Parameter in REG object
	
	AI TYPES:
	--------------
	
		move_x : 
			distance:Int			; Move by this much tiles, goes through walls
			platform_bound:Bool		; Place on the nearest platform and bound to it
			-no param-				; Move until hits wall or room end
			
		move_y
			distance:Int			; Move by this much tiles, goes through walls
			same_x:Bool				; Spawn to player X pixel
			-no param				; Move until hits wall or room end
			
		bounce						; Bounces and follows player
		
		chase						; chase the player and bump into him
		
		turret						;

		big_chase					; 
		
		big_bounce					;
		
	
**/


package gamesprites;

import djA.DataT;
import djA.Fsm;
import djA.types.SimpleVector;
import djFlixel.D;
import flixel.tweens.FlxTween;
import flixel.tweens.misc.VarTween;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.animation.FlxAnimation;
import flixel.math.FlxAngle;

@:access(gamesprites.Enemy)
class Enemy_AI 
{
	// Pixel padding to center of chase target
	static inline var CHASE_CORRECTION = 2;
	
	var e:Enemy;
	var startVel:SimpleVector;
	
	public function new(E:Enemy) 
	{
		e = E;
		startVel = new SimpleVector(0, 0);
	}//---------------------------------------------------;	
	// --
	// - This is called everytime it is respawned
	public function respawn()
	{
		e.velocity.set(startVel.x, startVel.y);
		e.facing = e.velocity.x >= 0?FlxObject.RIGHT:FlxObject.LEFT;
		e.spawn_origin_move();
	}//---------------------------------------------------;
	// --
	public function update(elapsed:Float)
	{
	}//---------------------------------------------------;
	public function softkill():Bool
	{
		return true;
	}//---------------------------------------------------;
	// --
	function turnAround()
	{
		if (e.facing == FlxObject.LEFT) {
			e.facing = FlxObject.RIGHT;
		} else {
			e.facing = FlxObject.LEFT;
		}
	}//---------------------------------------------------;
	
	// Set velocity X to follow player
	function chase_x()
	{
		if (e.x + e.halfWidth < Reg.st.player.x + Reg.st.player.halfWidth - CHASE_CORRECTION) {
			e.velocity.x = e.speed;
			e.facing = FlxObject.RIGHT;
		}else
		if (e.x + e.halfWidth > Reg.st.player.x + Reg.st.player.halfWidth + CHASE_CORRECTION ) {
			e.velocity.x = -e.speed;
			e.facing = FlxObject.LEFT;
		}
		else
			e.velocity.x = 0;
		
	}//---------------------------------------------------;
	
	// Set velocity Y to follow player
	function chase_y()
	{
		if (e.y + e.halfHeight < Reg.st.player.y + Reg.st.player.halfHeight - CHASE_CORRECTION) {
			e.velocity.y = e.speed;
		}else
		if (e.y + e.halfHeight > Reg.st.player.y + Reg.st.player.halfHeight + CHASE_CORRECTION ) {
			e.velocity.y = -e.speed;
		}
		else
			e.velocity.y = 0;
	}//---------------------------------------------------;
	
	// From TILED MAP enemy type to an AI
	public static function getAI(type:String, E:Enemy):Enemy_AI
	{
		var ai:Enemy_AI;
		switch(type)
		{
			case "final": 
				E.startHealth = Enemy.PAR.health_final1;
				E.spawnTime = -1;	// never respawn
				ai = new AI_Final_Boss(E);
			case "move_x": ai = new AI_Move_X(E);
			case "move_y": ai = new AI_Move_Y(E); 
			case "bounce": ai = new AI_Bounce(E);
			case "chase": 
				E.startHealth = Enemy.PAR.health_chase;
				ai = new AI_Chase(E); 
			case "big_chase" : 
				E.startHealth = Enemy.PAR.health_big;
				E.spawnTime = Enemy.PAR.spawntime_big;
				E.speed = Enemy.PAR.speed_big;
				ai = new AI_BigChase(E); 
			case "big_tall" :
				E.startHealth = Enemy.PAR.health_tall;
				E.spawnTime = Enemy.PAR.spawntime_big;
				ai = new AI_Turret(E, 1);
			case "big_bounce": 
				E.startHealth = Enemy.PAR.health_long;
				E.speed = Enemy.PAR.speed_long;
				ai = new AI_BigBounce(E); 
			case "turret" : 
				E.startHealth = Enemy.PAR.health_turret;
				ai = new AI_Turret(E);
			case _: 
				ai = new Enemy_AI(E);
		}
		return ai;
	}//---------------------------------------------------;
	
}//--


enum BOSS_STATE
{
	DIE;
	PHASE1;
	PHASE2;
}// --------------------;

class AI_Final_Boss extends Enemy_AI
{
	
	inline static var JITTER_TIME = 0.14;
	inline static var JITTER_PIX = 3;
	inline static var JITTER_LOOPS = 16;
	
	var fsm:Fsm;
	var tw:VarTween;
	
	var timer:Float = 0;
	var j0:Int = 0;
	
	public function new(E:Enemy)
	{
		super(E);
		trace(" >> New FINAL BOSS");
		
		fsm = new Fsm();
		fsm.addState(BOSS_STATE.DIE, die_enter, die_update);
		fsm.addState(BOSS_STATE.PHASE1, phase1_enter, phase1_update);
		fsm.goto(PHASE1);
	}//---------------------------------------------------;
	
	override public function update(elapsed:Float) 
	{
		super.update(elapsed);
		fsm.update();
	}//---------------------------------------------------;
	
	function die_enter()
	{
		trace("Entering DIE");
		timer = 0;
		j0 = 0;	// jitter times
	
		// Hack: Because the enemy is still alive, so it can call the updates()
		e.health = 9999;	// Make it virtually indestructible
		// >> Twitch, flash, explode and die
	}//---------------------------------------------------;
	
	function die_update()
	{
		if ((timer += FlxG.elapsed) >= JITTER_TIME)
		{
			e.x += FlxG.random.int( -JITTER_PIX, JITTER_PIX);
			e.y += FlxG.random.int( -JITTER_PIX, JITTER_PIX);
			
			if (j0 % 3 == 0)
			{
				Reg.st.flash(2);
				D.snd.play("hit_02");
				// Sound Effect
			}
			if (++j0 > JITTER_LOOPS)
			{
				D.snd.play("hit_02");
				timer = -1;	// stop updating
				e.visible = false;
				e.alive = false;
				e.explode();
				Reg.st.flash(3);
				Reg.st.handle_boss_die(e);	// Now tell main that the enemy is dead
			}else{
				timer = 0;	// jitter again
			}
		}
	}//---------------------------------------------------;
	
	function phase1_enter()
	{
		trace("Entering phase 1");
	}//---------------------------------------------------;
	
	function phase1_update()
	{
		
	}//---------------------------------------------------;
	
	override public function softkill() 
	{
		trace("-- Final Boss - SoftKill()");
		e.alive = true;
		e.visible = true;
		fsm.goto(DIE);
		return false;	// tell enemy class to not explode FX, will do manually later
	}//---------------------------------------------------;
}// --


/**
   TURRET, Shoots bullets that chase the player
   - NOTE: The turret timer gets randomized a bit
**/
class AI_Turret extends Enemy_AI
{
	// Time to Shoot
	var _timer:Float = 0;
	var _bullet = 3;	// 3 is phasing, 4 is non phasing
	var _waitTime:Float;
	
	// Type 0=Turret, 1=Tall Big
	public function new(e:Enemy, type:Int = 0)
	{
		super(e);
		if (type == 0) {
			_bullet = 3;
			_waitTime = Enemy.PAR.speed_turret;
		}else{
			_bullet = 4;
			_waitTime = Enemy.PAR.speed_bigtall;
		}
	}//---------------------------------------------------;
	
	override public function update(elapsed:Float) 
	{
		if ((_timer += elapsed) > Enemy.PAR.speed_turret)
		{
			_timer = 0;
			if (!Reg.st.player.alive) return;
			Reg.st.BM.createAt(_bullet, e.x + e.halfWidth, e.y + e.halfHeight, 0);
			// <SOUND>
		}
	}//---------------------------------------------------;
	
	override public function respawn() 
	{
		super.respawn();
		// Randomize the start time, so turrets will not fire at the same time
		_timer = Enemy.PAR.speed_turret * Math.random() * 0.85;
	}//---------------------------------------------------;
	
}// --


/**
   Big Enemy - Follow on the X axis if player gets too close
**/
class AI_BigChase extends Enemy_AI
{
	static inline var CHASE_DISTANCE = 4 * 32;
	
	// Version 1 (CPC)
	//  - Chase on the x axis if close enough
	
	// Version 2 (C64)
	//  - Enemy moves around and makes your life difficult, also shoots
	
	override public function update(elapsed:Float) 
	{
		// Move only if close to player:
		if (Math.abs(e.x - Reg.st.player.x) <= CHASE_DISTANCE)
			chase_x();
	}//---------------------------------------------------;
	
}// --




/**
   Big Enemy - Bounce right-left
**/
class AI_BigBounce extends AI_Move_X
{
	static inline var BOUNCE_HEIGHT = 32;			// pixel
	
	var Y:Float;		// Start PI
	var distpi:Float;
	var L:Float;
	
	public function new(E:Enemy)
	{
		super(E);
		var delta = Std.int(v1 - v0);
		var blocks = (E.O.prop.distance / 4);	// big blocks it is travelling
		Y = E.y; // This is set on the parent
		// One pi is one cycle, so slice it
		distpi = (Math.PI * blocks) / delta;
	}//---------------------------------------------------;
	
	override public function update(elapsed:Float) 
	{
		super.update(elapsed);
		e.y = Y - Math.abs(Math.sin(distpi * (e.x - v1))) * BOUNCE_HEIGHT;
	}//---------------------------------------------------;
}



/**
	- Go through blocks
	- Chase the player and bump into hi,
**/
class AI_Chase extends Enemy_AI
{
	override public function update(elapsed:Float) 
	{
		// :: ORIGINAL CPC WAY
		chase_x();
		chase_y();
		
		// :: ANGLE WAY
		//var r1 = FlxAngle.angleBetween(e, Reg.st.player);
		//e.velocity.x = Reg.P.en_speed * Math.cos(r1);
		//e.velocity.y = Reg.P.en_speed * Math.sin(r1);
		//if (e.velocity.x > 0)
			//e.facing  = FlxObject.RIGHT;
		//else
			//e.facing = FlxObject.LEFT;
	}//---------------------------------------------------;
	
}// --






/**
	- Will check each frame for collision against floor (when falling)
	- Put it in rooms where there are no holes in the ground or it could fall
	- Stops Animation and handles it manually
**/
@:access(gamesprites.Enemy)
class AI_Bounce extends Enemy_AI
{
	// Count
	static inline var GFX_BOUNCE_RESTORE_TIME = 0.16;
	
	static inline var BOUNCE_SPEED = 180;
	
	var frames:Array<Int>;
	var t:Float = 0;
	
	public function new(E:Enemy)
	{
		super(E);
		e.acceleration.y = Reg.P.gravity;
		startVel.y = e.speed;
		frames = e.animation.getByName("main").frames;
	}//---------------------------------------------------;
	
	override public function respawn() 
	{
		super.respawn();
		e.animation.stop();
		e.animation.frameIndex = frames[0];
	}//---------------------------------------------------;
	
	override public function update(elapsed:Float) 
	{
		// DEV: I could check against map.layer[1] but it is an overkill
		//      But here I am checking the florr tiles manually
		//		This is faster then creating a quadtree at every frame
		if (e.velocity.y > 0)
		{
			var ty = Std.int((e.y + e.height) / 8);
			var tx = Std.int(e.x / 8);
			if( Reg.st.map.getCol(tx, ty) > 0 ||
				Reg.st.map.getCol(tx + 1, ty) > 0) 
				//e.y + e.height > Reg.st.map.roomCornerPixel.y + Reg.st.map.ROOM_HEIGHT)
			{
				e.velocity.y = - BOUNCE_SPEED;
				e.last.y = e.y = (ty * 8) - e.height; // Lock y to the floor, because it went through it
				t = GFX_BOUNCE_RESTORE_TIME; // set timer
				e.animation.frameIndex = frames[1];
			}
		}else{
			
			// Check for ceiling. (Rare but can cauase bugs)
			if (e.y < Reg.st.map.roomCornerPixel.y){
				e.velocity.y = 0;
			}
			
			// When going up, countdown to a short time then restore the bouncing frame to 0
			if (t > 0) {
				if ((t -= elapsed) <= 0) {
					e.animation.frameIndex = frames[0];
				}
			}
		}
		
		chase_x();
	}//---------------------------------------------------;
	
	
	override public function softkill() 
	{
		// Visual bug fix. When it dies the particle moves too fast sometimes
		e.velocity.y = e.velocity.y / 10;
		return true;
	}//---------------------------------------------------;
}// --






/**
	- Loop through 2 points in the X axis
	- Pre-sets a start and end point
**/
@:access(gamesprites.Enemy)
class AI_Move_X extends Enemy_AI
{
	var v0:Float;
	var v1:Float;
	
	// DEV: forceDistance is used by the big bounce AI
	public function new(E:Enemy)
	{
		super(E);
		
		var O = DataT.copyFields(e.O.prop, {
			platform_bound:false,
			distance:0			
		});
		
		startVel.x = e.speed;
		
		if (O.platform_bound) {
			var floorY = e.spawn_origin_set(1);
			// Check where platform ends:
			var B = Reg.st.map.get2RayCast(e.SPAWN_TILE.x, floorY, true, FlxObject.NONE);
			// Check for walls:
			var C = Reg.st.map.get2RayCast(e.SPAWN_TILE.x, floorY - 1, true, FlxObject.ANY);
			v0 = Math.max(B.v0, C.v0) * 8;
			v1 = (Math.min(B.v1, C.v1) * 8) - e.width;
			
		}else
		if (O.distance != 0) {
			// Fixed amount of tiles. Going through walls, also check for negative distance
			v0 = e.SPAWN_POS.x;	// It is going to be spawned here
			if (O.distance < 0) {
				v1 = v0;
				v0 = v1 + (O.distance * 8);
				startVel.x = -startVel.x;
			}else{
				v1 = v0 + (O.distance * 8);
			}
			/// Don't check for borders, trust the editor values
		}else{
			// Move until end of room or collides
			var B = Reg.st.map.get2RayCast(e.SPAWN_TILE.x , e.SPAWN_TILE.y + 1, true, FlxObject.ANY);
			v0 = B.v0 * 8;
			v1 = (B.v1 * 8) - e.width;
		}
		
		super.respawn();
	}//---------------------------------------------------;
	
	override public function respawn() 
	{
		// Override and do nothing
	}//---------------------------------------------------;
	
	override public function update(elapsed:Float) 
	{
		if (e.x > v1 || e.x < v0) {
			turnAround();   
			e.velocity.x = -e.velocity.x;
		}
	}//---------------------------------------------------;
	
}// --






/**
	- Loop through 2 points in the Y axis
	- Pre-sets a start and end point
	- `same_x` flag, will spawn same X but Furthest Away Y
**/
@:access(gamesprites.Enemy)
class AI_Move_Y extends Enemy_AI
{
	var v0:Float;
	var v1:Float;
	var sameX:Bool;
	
	public function new(E:Enemy)
	{
		super(E);
		
		// Default values
		var O = DataT.copyFields(e.O.prop, {
			distance:0,
			same_x:false
		});
		
		startVel.y = e.speed;	// This is enemy default base speed
		sameX = O.same_x;
		
		// sameX Flag means it will be a ghost enemy, full Y area movement
		if (sameX)
		{
			// velocity facing calculated onspawn()
			v0 = (Std.int(E.O.y / Reg.st.map.ROOM_HEIGHT) * Reg.st.map.ROOM_HEIGHT) + 8;
			v1 = (v0 + Reg.st.map.ROOM_HEIGHT - E.height) - 8;
			return;
		}
		
		if (O.distance != 0) 
		{
			v0 = e.SPAWN_POS.y;	// It is going to be spawned here
			if (O.distance < 0) {	// Negative distance only works if no sameX defined
				v1 = v0;
				v0 = v1 + (O.distance * 8);
				startVel.y = -startVel.y;
			}else{
				v1 = v0 + (O.distance * 8);
			}
		}else{
			
			// HACK (Special Occasion)
			// Check if overlapping some tile and move it a bit out of the way to snap
			if (Reg.st.map.layerCol().getTile(e.SPAWN_TILE.x, e.SPAWN_TILE.y) > 0) {
				e.SPAWN_POS.y += 8;
			}
			// Get free area to move
			var B = Reg.st.map.get2RayCast(e.SPAWN_TILE.x + 1 , e.SPAWN_TILE.y + 1, false, 1);
			v0 = B.v0 * 8;
			v1 = (B.v1 * 8) - e.width;
		}
		
	}//---------------------------------------------------;
	
	override public function respawn() 
	{
		// Spawn at the opposite side of player Y
		if (sameX) {
			D.align.XAxis(e, Reg.st.player);
			// When the player comes from a side, don't spawn too close to the edge
			if (e.x - e.offset.x < Reg.st.map.roomCornerPixel.x) e.x += 10; else
			if (e.x + e.width + e.offset.x >= Reg.st.map.roomCornerPixel.x + Reg.st.map.ROOM_WIDTH) e.x -= 10;
			
			if (Reg.st.player.y < Reg.st.map.roomCornerPixel.y + (Reg.st.map.ROOM_HEIGHT / 2) - Reg.st.player.halfHeight){
				e.y = v1;
				e.velocity.y = -startVel.y;
			}else{
				e.y = v0;
				e.velocity.y = -startVel.y;
			}
			e.facing = e.velocity.y > 0?FlxObject.RIGHT:FlxObject.LEFT;
			return;
		}
		
		super.respawn();
	}//---------------------------------------------------;
	
	override public function update(elapsed:Float) 
	{
		if (e.y > v1 || e.y < v0) {
			turnAround();
			e.velocity.y = -e.velocity.y;
		}
	}//---------------------------------------------------;


}// --