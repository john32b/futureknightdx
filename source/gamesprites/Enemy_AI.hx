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
import djA.types.SimpleRect;
import djA.types.SimpleVector;
import flixel.tweens.FlxEase;

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
	public function softkill()
	{
		e.explode();
	}//---------------------------------------------------;
	
	public function kill()
	{

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
				E.startHealth = Enemy.PAR.health_phase1;
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





/** =========================================
 * 
 * 
 * Phase 1, move around and shoot 
 * Phase 2, vulnerable, must use destruct spell
 * Phase 3, Last short stage, more aggressive
 * Die	  , animate die and off
 * =========================================== */
enum BOSS_STATE
{
	DIE;
	PHASE1;
	PHASE2;
	PHASE3;
}// --------------------;




// -- Phase 1: Move around
// -- Phase 2: Entered if damaged enough. Move around faster and shoot more
// -- Phase 3: Flashing and ready to use the destruct spell
//				Does not last forever, returns to phase 2 and repeats
// -- DIE : Flash and explode
// 
class AI_Final_Boss extends Enemy_AI
{
	
	inline static var JITTER_TIME = 0.14;
	inline static var JITTER_PIX = 3;
	inline static var JITTER_LOOPS = 16;
	inline static var PHASE2_FLASH = 0.24;
	
	var fsm:Fsm;
	var tw:VarTween;
	
	var timer:Float = 0;	// General Purpose Timer
	var r0:Int = 0;			// General Purpose Counter
	var r1:Int = 0;			// General Purpose
	
	// Destination Points:
	var dp:SimpleRect;
	
	// Pointer to a sequence
	var current_sequence:Array<Int>;
	var current_speed:Float;
	var current_delay:Float;
	
	public function new(E:Enemy)
	{
		super(E);
		
		// -- This is for the slot/grid placement
		dp = new SimpleRect();
		dp.w = Std.int(Reg.st.map.ROOM_WIDTH / 3);
		dp.h = Std.int(Reg.st.map.ROOM_HEIGHT / 3);
		dp.x = cast (dp.w - e.width) / 2; 
		dp.y = cast (dp.h - e.height) / 2;
		
		// --
		fsm = new Fsm();
		fsm.addState(BOSS_STATE.DIE, die_enter, die_update);
		fsm.addState(BOSS_STATE.PHASE1, phase1_enter, phase1_update);
		fsm.addState(BOSS_STATE.PHASE2, phase2_enter, phase2_update);
		fsm.addState(BOSS_STATE.PHASE3, phase3_enter, phase3_update);
		fsm.goto(PHASE1);
		
	}//---------------------------------------------------;
	
	
	override public function kill() 
	{
		trace("-- Final boss kill()");
		tw = D.dest.tween(tw);
	}//---------------------------------------------------;
	
	override public function update(elapsed:Float) 
	{
		super.update(elapsed);
		fsm.update();
		if (tw != null) {
			tw.active = true;
		}
	}//---------------------------------------------------;
	
	function die_enter()
	{
		trace("-- Entering phase (DIE)");
		e.health = 99999;// Make it virtually indestructible, until It gets killed automatically by a timer
	}//---------------------------------------------------;
	
	
	function die_update()
	{
		//  twitch and flash, and then kill for good
		//  -
		if ((timer += FlxG.elapsed) >= JITTER_TIME)
		{
			timer = 0;
			e.x += FlxG.random.int( -JITTER_PIX, JITTER_PIX);
			e.y += FlxG.random.int( -JITTER_PIX, JITTER_PIX);
			
			if (r0 % 2 == 0) {
				if (r1 == 0) {
					e.setColorTransform(1, 1, 1, 1, 180, 180, 180, 0);
					r1 = 1;
				}else {
					e.setColorTransform(1, 1, 1, 1, 0, 0, 0, 0);
					r1 = 0;
				}
			}
			
			if (r0 % 3 == 0) {
				Reg.st.flash(2);
				D.snd.playR(Enemy.SND.big_die);
				D.snd.play('fb_cry');
			}
			if (++r0 > JITTER_LOOPS)
			{
				D.snd.playR(Enemy.SND.die);	// hit
				D.snd.playV('fb_expl');		// final blow hit
				e.visible = false;
				e.alive = false;
				e.explode();
				Reg.st.flash(3);
				Reg.st.handle_boss_die(e);	// Now tell main that the enemy is dead
			}
		}
	}//---------------------------------------------------;
	
	
	function gotoNext()
	{
		r0 ++;
		if (r0 >= current_sequence.length) {
			r0 = 0;
		}
		var code = current_sequence[r0];
		if (code == 10) {
			// shoot 2 bullets,
			tw = FlxTween.tween(e, {}, 0.4, {
				onComplete:onTweenCompleteFire,
				onUpdate:onTweenUpd,
				type:FlxTweenType.LOOPING
			});
			
		}else
		{
			var dest = getCoords(current_sequence[r0]);
			tw = FlxTween.tween(e, {x:dest.x, y:dest.y}, current_speed, {
				onComplete:onTweenComplete,
				onUpdate:onTweenUpd,
				startDelay:current_delay,
				ease:FlxEase.linear
			});			
		}

	}//---------------------------------------------------;
			// It is counter intuitive but it works:
			function onTweenUpd(_tw:FlxTween)
			{
				// Will trigger ONCE, when this gets false
				_tw.active = Reg.st.ROOMSPR.active;
			}
			function onTweenCompleteFire(_tw:FlxTween)
			{
				Reg.st.BM.createAt(5, e.x + e.halfWidth, e.y + e.halfHeight, 0);
				D.snd.play('fb_shoot');
				if (_tw.executions == 2) { // Shoot 3 bullets
					_tw.cancel();
					gotoNext();
				}
			}
			function onTweenComplete(_tw:FlxTween)
			{
				gotoNext();
			}//---------------------------------------------------;
		
		
	
	function phase1_enter()
	{
		trace("-- Entering phase (1)");
		current_speed = 1.65;
		current_delay = 0.28;
		
		D.snd.play('fb_cry');
		
		r0 = -1; // Because it gets ++ at the beginning and I need [0] to be the first
		timer = 0;
		current_sequence = [ 0, 2, 0, 2, 0, 2, 8, 6, 3, 5, 3, 1, 5, 7, 3, 1, 5, 7, 4];
		gotoNext();
	}//---------------------------------------------------;
	function phase1_update()
	{
		// - Shoot every 2 seconds
		if ((timer += FlxG.elapsed) >= 2.25){
			timer = 0;
			// Shoot bullet
			if (!Reg.st.player.alive) return;
			Reg.st.BM.createAt(5, e.x + e.halfWidth, e.y + e.halfHeight, 0);
			D.snd.play('fb_shoot');
		}
	}//---------------------------------------------------;
	
	
	function phase2_enter()
	{
		trace("-- Entering phase (2)");
		e.solid = true;
		e.setColorTransform(1, 1, 1, 1, 200, 0, 0, 0);
		e.health = Enemy.PAR.health_phase2; // No health down when potion used
		D.snd.playV('fb_aggr');
		current_speed = 1.1;
		current_delay = 0.18;
		r0 = -1; // Because it gets ++ at the beginning and I need [0] to be the first
		timer = 0;
		current_sequence = [ 0, 10, 2, 0, 2, 10, 5, 10, 3, 10, 6, 8, 10, 5, 10, 4, 1, 10, 4, 1];
		Reg.st.flash(2);
		gotoNext();
	}//---------------------------------------------------;
	
	function phase2_update()
	{
		// -- Flash RED 
		if ((timer += FlxG.elapsed) >= JITTER_TIME)	{
			timer = 0;
			r1++;
			if (r1 % 2 == 0) {
				e.setColorTransform(1, 1, 1, 1, 180, 0, 0, 0);
			}else{
				e.setColorTransform(1, 1, 1, 1, 0, 0, 0, 0);
			}
		}
	}//---------------------------------------------------;

	function phase3_enter()
	{
		trace("-- Entering phase (3)");
		e.health = 99999;
		e.solid = false;
		Reg.st.HUD.set_text2("The droid is vulnerable. Use destruct now !");
		D.snd.playV('fb_vuln');
	}//---------------------------------------------------;

	function phase3_update()
	{
		// Just flash
		if ((timer += FlxG.elapsed) >= JITTER_TIME)
		{
			timer = 0;
			r1++;
			switch(r1 % 4){
				case 0:
					e.setColorTransform(1, 1, 1, 1, 180, 180, 180, 0);
					e.y += 3;
				case 1:
					e.setColorTransform(1, 1, 1, 1, 0, 180, 0, 0);
					e.y -= 3;
				case 2:
					e.setColorTransform(1, 1, 1, 1, 180, 0, 0, 0);
					e.x -= 3;
				case _:
					e.setColorTransform(1, 1, 1, 1, 0, 0, 180, 0);
					e.x += 3;
			}
			
			if (r1 == 100) { // If player didn't use potion just do it over
				fsm.goto(PHASE2);
			}
		}
	}//---------------------------------------------------;
	
	

	// -- Called from mainstate when the destruct spell is used 
	// - Return VALID to use
	public function spell_used():Bool
	{
		trace("- Destruct spell used");
		
		if (fsm.currentStateName == BOSS_STATE.PHASE3) 
		{
			softkill();
			Reg.st.HUD.set_text2("Used Destruct.");
			D.snd.playV(Reg.SND.item_destruct);
			return true;
		}
		
		Reg.st.HUD.set_text2("You need to weaken the droid first!");
		D.snd.play(Reg.SND.error);
		return false;
	}//---------------------------------------------------;
	
	
	
	/**
	   Called everytime phase HP is 0
	**/
	override public function softkill() 
	{
		e.alive = true;
		e.visible = true;
		e.solid = true;
		e.moves = true;
		
		tw = D.dest.tween(tw);
		
		timer = 0;		// Start timing for the jitter, handled in update
		r0 = r1 = 0;
		
		trace(" --> Softkill");
		
		if (fsm.currentStateName == PHASE1)
		{
			fsm.goto(PHASE2);
		}else
		if (fsm.currentStateName == PHASE2)	
		{
			fsm.goto(PHASE3);
		}
		else
		if (fsm.currentStateName == PHASE3) // only called by destruct spell
		{
			fsm.goto(DIE);
		}
		
	}//---------------------------------------------------;
	
	
	/** The area divided into 9 portions
	 * 0 1 2
	 * 3 4 5
	 * 6 7 8
	**/
	function getCoords(i:Int):{x:Int, y:Int}
	{
		var o = {
			x:Std.int((i % 3) * dp.w) + dp.x, 
			y:Std.int(Std.int(i / 3) * dp.h) + dp.y
		};
		o.x += Reg.st.map.roomCornerPixel.x;
		o.y += Reg.st.map.roomCornerPixel.y;
		return o;
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
			D.snd.play('fb_shoot', 0.3);
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
		e.explode();
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