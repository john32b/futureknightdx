/**
   FUTURE KNIGHT PLAYER CLASS
   -========================-
  - Current version 2020, (updated from 2015 version)
  - Tries to emulate the original game but with some improvements
  
  
  = NOTES:
	- Invincinble when flickering
	

  
  = Changes from the CPC version
	- Moves a bit faster
	- Can move while on air
	- Can latch on ladders on air
	- Can drop off ladders
	
	
  = Interactions :
	- Reads physics parameters from <REG>
	- Uses <Reg.st.map> for tile checking
	- Is being sent <event_collide_slide> from the map
	- Graphic declared in <Reg.hx>
  
======================================== */

package gamesprites;

import Reg;

import djA.Fsm;
import djA.types.SimpleCoords;
import djFlixel.core.Dcontrols;

import djFlixel.D;

import flixel.effects.FlxFlicker;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.system.FlxSound;
import flixel.tile.FlxTile;



enum PlayerState
{
	ONFLOOR;
	ONAIR;
	ONLADDER;
	ONSLIDE;
	STUNNED;
	DEAD;
}// --------------------;



class Player extends FlxSprite
{

	static inline var SPEED = 70;
	static inline var JUMP = 220; 
	
	static inline var START_HEALTH = 999;
	static inline var START_LIVES  = 3;
	
	static inline var COLOR_COMBO = "blue";
	
	static inline var I_TIME_REVIVE = 1.4;
	
	static inline var INTERACT_MIN_TIME = 350;		// Minimum time allowed to interact with an animated tile (exit or weapon)
	
	static inline var HEALTH_TICK = 0.05;			// Refresh life every this much
	static inline var HEALTH_LOSS = 2;				// Loss per tick
	
	inline static var BOUND_W = 8; 					// Bounding box 
	inline static var BOUND_H = 22;
	inline static var BOUND_OFF_X = 11;
	inline static var BOUND_OFF_Y = 4;
	inline static var BOUND_CROUCH_OFF = 4;			// Make top side this much smaller when crouching
	
	inline static var BULLET_X_PAD = 2;				// Push this much away from player when shooting (default is right at bounding box)
	
	inline static var LADDER_SNAP_Y = 8;			// Move player this much downwards when mounts a ladder
	inline static var LADDER_MOUNT_PIXELS = 4;		// For this many traveled pixels the mount frame will be displayd
	inline static var SLIDE_MOUNT_PIXELS_Y_ON = 4;	// Offset when mounting the slide
	inline static var SLIDE_MOUNT_PIXELS_Y_OFF = 8;	// Offset to check when getting off
	inline static var SOUND_TICK_WALK  = 0.2857;	// This is ANIMATION FRAMES (1/FPS) * TOTAL_FRAMES
	inline static var SOUND_TICK_CLIMB = 0.30;
	inline static var IDLE_STEP_TIME = 7;			// Seconds to go to the next idle stage (there are 3 idle stages)
	inline static var FALL_DAMAGE_HEIGHT = 32 * 5;	// If it falls from 5x(bigtiles) do fall damage
	inline static var FALL_DAMAGE_TIME = 3;			// Stun for 3 seconds
	inline static var DEAD_TIME = 4;				// Stay in the dead animation for 4 seconds
	 
	// Precalculated to avoid width/2 all the time
	public var halfWidth:Int;
	public var halfHeight:Int;
	
	
	// Keys states
	var _pressingUp:Bool;
	var _pressingDown:Bool;
	var _pressingLeft:Bool;
	var _pressingRight:Bool;
	
	// All these are autocalculated on creation
	var MAX_FALLSPEED:Int;			// autoset, based on PLAYER_JUMP_STRENGTH
	var CLIMB_SPEED:Int;			// autoset, based on PLAYER_SPEED
	var SLIDE_SPEED:Int;			// autoset, based on PLAYER_SPEED
	var AIR_NUDGE_SPEED_0:Int;		// Air movement if on air vertical, autoset from PLAYER_SPEED
	var AIR_NUDGE_SPEED_1:Int;		// Air movement if walked jumped, autoset from PLAYER_SPEED

	// -- Animation and States
	var isFalling:Bool;
	var isWalking:Bool;
	var isCrouching:Bool;
	var fsm:Fsm;
	
	// -- Helpers
	var _walkLastFrame = 0;			// The last walk frame index
	var _verticalJump:Bool;			// Slower left-right movement on the air if vertical jump
	var _specialTileY:Int;			// Either TOP LADDER TILE, or SLIDE FREE TILE, or FALL DAMAGE START Y
	var _hack_break:Bool;			// Useful to keep track whether I need to exit an update function sometimes
	var _sndTemp:FlxSound;			// Keeps some sounds that I need to stop manually
	var _sndTick:Float;				// Used in WALK,CLIMB to make a sound at an interval.
	var _walkBlockDir:Int;			// Used for not walking into walls. Last direction that was blocked when walking
	var _jumpForceFull:Bool;		// Force a full jump, with no reduce height check (Used in hazards)
	var _idle:Float;				// Generic timer. Used in IDLE / STUN / DEAD TIME
	var _idle_stage:Int;
	var _htick:Float = 0;			// Count down health tick timer
	
	var _shoot_allow:Bool;			// Whether at this stage firing is supported
	var _shoot_time:Int;			// Time since last shot, IN TICKS, NOT MS
	
	var _interact_time:Int;			// Short pause between interacting with ANIMTILE elements. IN TICKS, NOT MS
	
	// - Sounds
	var snd =  {
		walk:"pl_walk",		// ok
		jump:"pl_jump2",	// ok
		climb:"pl_climb",	// ok
		slide:"pl_slide",	// ok
		land:"pl_land",		// ok
		step:"pl_step",		// ok
		die:"pl_die",	
		hurt:"pl_hurt",		// ok
		shoot:"pl_shoot",	// ok
		ceil:"pl_ceil"		// ok
	}

	// --
	public var lives:Int;
	
	// Current bullet type the player can shoot
	// INDEX in Bullet.TYPES[]
	// 0:Normal, 1:Red, 2:Slime
	public var bullet_type:Int;
	
	// This is the Health Number printed at the HUD
	// This is the one that when reaches ZERO, the player will die
	var healthSlow:Float;
	
	// -----------------------------------------------------------------------;
	public function new() 
	{
		super();
		
		// Auto set physics based on WALK SPEED and JUMP_STR
		// Physics, and speed parameters
		MAX_FALLSPEED = JUMP + 56;
		CLIMB_SPEED = Math.ceil(SPEED * 0.8 );
		SLIDE_SPEED = Math.ceil(SPEED * 1.1 );
		AIR_NUDGE_SPEED_0 = Math.ceil(SPEED / 8);
		AIR_NUDGE_SPEED_1 = Math.ceil(AIR_NUDGE_SPEED_0 / 3);
		
		maxVelocity.y = MAX_FALLSPEED;
		maxVelocity.x = SPEED;
		
		// Graphics
		Reg.IM.loadGraphic(this, 'player', COLOR_COMBO);
		
		setFacingFlip(FlxObject.LEFT, true, false);
		setFacingFlip(FlxObject.RIGHT, false, false);
		
		// Animations
		animation.add("idle", 	[1], 1, false);
		animation.add("walk", 	[2, 3, 2, 1], 14);
		animation.add("fall", 	[3], 1, false);
		animation.add("jump", 	[4],1, false);
		animation.add("crouch", [0],1, false);
		animation.add("slide", 	[5],1, false);
		animation.add("climb", 	[7, 8], 10);
		animation.add("mount",  [6], 1, false);
		animation.add("die", [14, 15, 16, 17], 4, false);
		animation.add("wave", [ 9, 10, 11, 10, 11, 9], 8, false);
		animation.add("dance", [12, 13], 8);
		animation.add("fallstun", [18, 19], 10);
		
		// I want to know the actual last walk frame, so I can callback when it reaches to it
		_walkLastFrame = animation.getByName('walk').numFrames - 1;
	
		// -- Bound, Size
		setSize(BOUND_W, BOUND_H);
		offset.set(BOUND_OFF_X, BOUND_OFF_Y);
		
		halfWidth = Std.int(width / 2);
		halfHeight = Std.int(height / 2);
		
		// --
		// Dev: Some (onenter) conditions are done where the state change occurs
		fsm = new Fsm();
		fsm.addState(PlayerState.ONFLOOR , state_onfloor_enter, state_onfloor_update, state_onfloor_exit);
		fsm.addState(PlayerState.ONAIR   , state_onair_enter, state_onair_update);
		fsm.addState(PlayerState.ONLADDER, null, state_onladder_update);
		fsm.addState(PlayerState.ONSLIDE, state_onslide_enter , state_onslide_update, state_onslide_exit);
		fsm.addState(PlayerState.STUNNED, null , state_stunned_update);
		fsm.addState(PlayerState.DEAD, null, state_dead_update);

		// --
		lives = START_LIVES;
		health = START_HEALTH;
		healthSlow = health;
		_htick = 0;
		
		bullet_type = 0;
		_interact_time = 0;	// this should not be reset at respawn
		
	}//---------------------------------------------------;
	
	// :: kill() will enable this state
	function state_dead_update()
	{
		_idle+= FlxG.elapsed;
		if (_idle > DEAD_TIME)
		{
			lives--;
			Reg.st.HUD.set_lives(lives, true);
			
			if (lives == 0)
			{
				Reg.st.on_player_no_lives();
			}else
			{
				Reg.st.ROOMSPR.enemies_freeze(false);
				revive();
				physics_start();
				fsm.goto(ONFLOOR);
			}
		}
	}//---------------------------------------------------;
	
	function state_stunned_update()
	{
		// Nothing, just wait
		_idle+= FlxG.elapsed;
		if (_idle > FALL_DAMAGE_TIME)
		{
			physics_start();
			fsm.goto(ONFLOOR);
		}
	}//---------------------------------------------------;
	
	
	function state_onslide_enter()
	{
		_sndTemp = D.snd.playV(snd.slide);
		animation.play('slide');
	}//---------------------------------------------------;
	
	function state_onslide_exit()
	{
		if (_sndTemp != null) {
			_sndTemp.fadeOut(0.05, 0);	// The sound will be auto-destroyed by default
		}
	}//---------------------------------------------------;
	
	function state_onslide_update()
	{
		// Check when it reaches the final slide tile
		if (y > _specialTileY - SLIDE_MOUNT_PIXELS_Y_OFF)
		{
			physics_start();
			velocity.x = 0;
			_verticalJump = true;
			fsm.goto(ONAIR);
		}
	}//---------------------------------------------------;
	
	function state_onladder_update()
	{
		if (_sndTick >= SOUND_TICK_CLIMB)
		{
			_sndTick = 0;
			D.snd.playV(snd.climb);
		}
		
		if (_pressingUp)
		{
			_sndTick += FlxG.elapsed;
			// DEV: No need to check for free tile,I already know where the ladder ends
			if(y < _specialTileY - height + LADDER_MOUNT_PIXELS + 3)
			{
				physics_start();
				y = _specialTileY - height;
				velocity.y = 0;
				fsm.goto(ONFLOOR); return;
			}else{
			
				velocity.y = -CLIMB_SPEED;
				
				if (y > (_specialTileY - height + LADDER_MOUNT_PIXELS + LADDER_SNAP_Y)) {
					animation.play("climb");
				}else{
					animation.play("mount");
				}
			}
				
		}else if (_pressingDown)
		{
			_sndTick += FlxG.elapsed;
			if ( !Reg.st.map.tileIsType(Reg.st.map.getTileP(x + 2, y + height + 4), LADDER) || 
				D.ctrl.pressed(A) )
			{
				physics_start();
				// DEV: The y velocity should be 0 here. So ONAIR will properly make it fall
				fsm.goto(ONAIR); return;
			}else{
				
				velocity.y = CLIMB_SPEED;
				
				if (y > (_specialTileY - height + LADDER_MOUNT_PIXELS + LADDER_SNAP_Y)) {
					animation.play('climb');
				}else{
					animation.play('mount');
				}
			}
		}
		else
		{
			_sndTick = SOUND_TICK_CLIMB * 0.75;
			velocity.y = 0;
			animation.pause();
		}
	}//---------------------------------------------------;

	
	function state_onair_enter()
	{
		// Start with this to false, even if it is not jumping
		// and it will be processed in the update cycle
		isFalling = false;
		_shoot_allow = true;
	}//---------------------------------------------------;
	
	
	function state_onair_update()
	{
		// NOTE : Collide Check NEEDS to be before anything else here for it to work
		// DEV  : This will trigger all tile-callbacks, including TRIGGER_SLIDE
		FlxG.collide(this, Reg.st.map.layerCol());
		
		if (_hack_break) { // (exit if some collide/overlap functions occur)
			_hack_break = false;
			return;
		}
		
		if (justTouched(FlxObject.CEILING))
		{
			health -= Reg.P_DAM.from_ceil;
			if (health < 0) health = 0;
			D.snd.playV(snd.ceil);
			if (_sndTemp != null){
				_sndTemp.stop();
			}
		}
		
		// :: UPDATE
		if (velocity.y >= 0) // Going DOWN
		{
			if (!isFalling)
			{
				_specialTileY = Std.int(y); // For calculating fall height
				isFalling = true;
				animation.play("fall");
			}
			
			if (justTouched(FlxObject.FLOOR))	// landed
			{
				velocity.set(0, 0);
				D.snd.playV(snd.land);
				// DEV: Sometimes (y) is 9.99999999, so I need to round it
				last.y = y = Math.ceil(y);

				if (y - _specialTileY > FALL_DAMAGE_HEIGHT)
				{
					_idle_stop();
					animation.play('fallstun');
					physics_stop();
					D.snd.playV(snd.hurt);
					// HACK: I want the damage to happen even if player flickers
					//       e.g. just hit by a bullet before landing
					FlxFlicker.stopFlickering(this);

					hurt(Reg.P_DAM.fall_damage);
					_shoot_allow = false;
					fsm.goto(STUNNED);
				}else{
					fsm.goto(ONFLOOR);
				}
				return;
			}
			
		}else{ 
			
			// :: Check for button release to reduce jump velocity
			if ( !_jumpForceFull && !D.ctrl.pressed(A) && velocity.y >=-200 && velocity.y <= -100)
			{
				velocity.y = -80;
				// DEV: Should I parameterize all these??
			}			
		}
		
		// :: INPUT
		if (_pressingRight)
		{
			if (_verticalJump) {
				velocity.x = AIR_NUDGE_SPEED_0;	// NOTE: Speed is not appended
			}
			else {
				velocity.x += AIR_NUDGE_SPEED_1;
			}
			
		}else
		if (_pressingLeft)
		{
			if (_verticalJump) {
				velocity.x =- AIR_NUDGE_SPEED_0;	// NOTE: Speed is not appended
			}
			else {
				velocity.x -= AIR_NUDGE_SPEED_1;
			}
		}
		
		// :: Check for ladder mount
		if (_pressingUp)
		{
			if (ladder_checkUp()) return;
		}
		
	}//---------------------------------------------------;
	
	
	function state_onfloor_enter()
	{
		_sndTick = SOUND_TICK_WALK * 0.8;	// Don't wait a fill TICK to make the sound. It sounds better this way.
		isFalling = false;
		animation.play("idle");
		_walkBlockDir = -1;
		_jumpForceFull = false;
		_shoot_allow = true;
		_idle_stop();
	}//---------------------------------------------------;
		
	
	function state_onfloor_exit()
	{
		isWalking = false;
		animation.callback = null;
	}//---------------------------------------------------;
	
	
	function state_onfloor_update()
	{
		// Only check for death when on the floor
		if (healthSlow <= 0) 
		{
			kill();
			return;
		}
		
		// DEV: This will trigger all tile-callbacks, including TRIGGER_SLIDE
		//	  : Collide Check NEEDS to be before anything else here for it to work
		FlxG.collide(this, Reg.st.map.layerCol());
		
		if (_hack_break) { // (exit if some collide/overlap functions occur)
			_hack_break = false;
			return;	
		}
		
		// :: UPDATE
		if (!isTouching(FlxObject.FLOOR)) // Has the player walked off a platform?
		{
			_verticalJump = true;
			velocity.x = 0;	// drop flat
			fsm.goto(ONAIR);
			return;
			
		}else if (justTouched(FlxObject.WALL))
		{
			_walkBlockDir = facing;	// At this face I just hit a wall in this cycle
			_walk_stop_cycle();
		}
		
		if (_sndTick >= SOUND_TICK_WALK)
		{
			_sndTick = 0;
			D.snd.playV(snd.step);
		}
		
		// 3 Idle states, Wave, Wave, Dance
		// The CPC version would dance, but this requires me to create another graphic for the sprite
		// because haxeflixel doesnot support to mirror a specific animation frame. So no spin for now
		if (_idle >= IDLE_STEP_TIME)
		{
			_idle_stop();
			if (++_idle_stage < 3){
				animation.play("wave");
			}else{
				animation.play("dance");
				/// OK also start taking damage like the CPC
			}
		}
		
		// :: INPUT : Ordering is important
		if (_pressingRight)
		{
			facing = FlxObject.RIGHT;
			velocity.x = SPEED;
			_walk_start_req();
		}
		else if (_pressingLeft)
		{
			facing = FlxObject.LEFT;
			velocity.x = -SPEED;
			_walk_start_req();
		}
		else
		{
			// : NO DIRECTION IS HELD
			if (isWalking) 
			{
				_walk_stop_cycle();
			}
			
			_idle+= FlxG.elapsed;
		}
		
		// DEV: No break here. Check A, UP, DOWN separately
		
		if (D.ctrl.justPressed(A))
		{
			velocity.y = -JUMP;
			touching = 0;
		
			if (isCrouching) standUp();
			
			if (isWalking)
			{
				_verticalJump = false; // Keep the walk animation going in the jump state
			}else{
				_verticalJump = true;
				animation.play("jump");
			}
			
			_sndTemp = D.snd.playV(snd.jump);
			fsm.goto(ONAIR);
			return;	// <- prevent the update portion to be called later in this function;
			
		}
		else if (_pressingDown)
		{
			// :: Check for ladder. This changes the state
			if (isCrouching || ladder_checkDown()) return;
			
			if (!_pressingLeft && !_pressingRight)
			{
				crouch();
			}
			
		}
		else if (_pressingUp)
		{
			// :: Check for ladder. This changes the state
			if (ladder_checkUp()) return;
			
		}else
		{
			// Not UP or DOWN, OR JUMP
			if (isCrouching)
			{
				standUp();
			}
		}
		
	}//---------------------------------------------------;
	
	
	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);

		_pressingUp = D.ctrl.pressed(UP);
		_pressingLeft = D.ctrl.pressed(LEFT);
		_pressingRight = D.ctrl.pressed(RIGHT);
		_pressingDown = D.ctrl.pressed(DOWN);
		
		// -- Cancel keys out
		if (_pressingLeft && _pressingRight) {
			_pressingLeft = _pressingRight = false;
		}

		if (_pressingDown && _pressingUp) {
			_pressingDown = _pressingUp = false;
		}
		
		// -------
		
		// DEV: Map collision takes place in FSM states, because not all of them need it
		
		fsm.update();
		
		if (_shoot_allow)
		{
			update_shoot();
		}

		// Player can open the menu
		if (D.ctrl.justPressed(DButton.START))
		{
			Reg.st.INV.open();
		}
		
		// Check Health
		if ((_htick += elapsed) >= HEALTH_TICK) {
			_htick = 0;
			if (healthSlow > health) {
				healthSlow -= Math.min(HEALTH_LOSS, healthSlow - health);
				Reg.st.HUD.set_health(healthSlow);
			}
		}
	}//---------------------------------------------------;
	
	
	override public function kill():Void 
	{
		if (!alive) return;
		alive = false;
		_idle_stop();
		_shoot_allow = false;
		physics_stop();
		animation.play("die");
		D.snd.playV(snd.die);
		Reg.st.ROOMSPR.enemies_freeze(true);
		fsm.goto(DEAD);
	}//---------------------------------------------------;
	
	/**
	   Check for key and create bullet.
	**/
	function update_shoot()
	{
		#if SHOOT_HOLD
		if (D.ctrl.pressed(X))
		#else
		if (D.ctrl.justPressed(X))
		#end
		{
			if (FlxG.game.ticks - _shoot_time < Bullet.TYPES[bullet_type].timer) return;
			
			var X = (facing == FlxObject.RIGHT?x + width + BULLET_X_PAD:x - BULLET_X_PAD);
			if (Reg.st.BM.createAt(bullet_type, X, y + halfHeight, facing))
			{
				// bullet shot OK
				D.snd.playV(snd.shoot);
				_shoot_time = FlxG.game.ticks;
				
				if (_idle_stage > 0) {
					animation.play('idle');
				}
				_idle_stop();
			}
		}
	}//---------------------------------------------------;
	
	
	override public function hurt(Damage:Float):Void 
	{
		if (!alive) return;	// e.g. a bullet hits the player on dying animation
		if (FlxFlicker.isFlickering(this)) return;
		
		health -= Damage;
		D.snd.playV(snd.hurt);
		
		if (health < 0) {
			health = 0;
			// Do not kill, SlowHealth counter will kill the player
		}
		
		FlxFlicker.flicker(this, Reg.P_DAM.i_time, Reg.P.flicker_rate);
	}//---------------------------------------------------;
	
	// -- Revives when dead, also at the first time for initialization
	override public function revive():Void 
	{
		super.revive();
		
		health = START_HEALTH;
		healthSlow = health;
		Reg.st.HUD.set_health(health);
		_htick = 0;
		
		if (lives < START_LIVES) FlxFlicker.flicker(this, I_TIME_REVIVE, Reg.P.flicker_rate);
		
	}//---------------------------------------------------;
	
	/**
	   - New Map, spawn to enter tile
	   - First level, spawn to start of area
	**/
	public function spawn(X:Float, Y:Float)
	{
		alive = true;
		
		// > Do not touch slowHealth, as it could be counting down, even if changing levels
		
		// :: Position ::
		_snapToFloor(X, Y);
		
		// Reset physics with a stop,start
		physics_stop();
		physics_start();
		
		_pressingDown = _pressingLeft = _pressingRight = _pressingUp = false;
		
		// --
		_shoot_allow = false;	// < FSM States will change this
		_shoot_time = 0;
		_hack_break = false;
		isCrouching = false;
		isWalking = false;
		isFalling = false;		// Init here does not matter, gets inited before use.
		
		if (x > Reg.st.map.roomCornerPixel.x + (Reg.st.map.ROOM_WIDTH / 2)) {
			facing = FlxObject.LEFT;
		}else{
			facing = FlxObject.RIGHT;
		}
		
		fsm.goto(ONFLOOR);
	}//---------------------------------------------------;
	
	
	// Called when climbing or sliding
	function physics_stop()
	{
		velocity.set(0, 0);
		acceleration.y = 0;
		touching = 0;
		wasTouching = 0;
	}//---------------------------------------------------;
	
		// --
	// Resume state to normal
	function physics_start()
	{
		acceleration.y = Reg.P.gravity;
	}//---------------------------------------------------;
	
	function crouch()
	{
		isCrouching = true;
		
		height -= BOUND_CROUCH_OFF;
		offset.y += BOUND_CROUCH_OFF;
		y += BOUND_CROUCH_OFF;
		animation.play("crouch");

		if (isWalking) {
			velocity.x = 0;
			animation.callback = null;
			isWalking = false;
		}
		
	}//---------------------------------------------------;
	
	function standUp()
	{
		isCrouching = false;
		height += BOUND_CROUCH_OFF;
		offset.y -= BOUND_CROUCH_OFF;
		y -= BOUND_CROUCH_OFF;
		animation.play("idle");
		_idle_stop();
	}//---------------------------------------------------;
	

	// Check current position for ladder UP . Return if it mounted a ladder
	function ladder_checkUp():Bool
	{
		var tc = Reg.st.map.getTileCoordsFromP(x + 4, y + height - 2);
		var tile = Reg.st.map.layerCol().getTile(tc.x, tc.y);
		if (Reg.st.map.tileIsType(tile, LADDER) || Reg.st.map.tileIsType(tile, LADDER_TOP))
		{
			last.x = x = (Std.int(x / 32) * 32) + (32 - width) / 2;
			// Search for a ladder TOP.
			#if debug var _t = 0; #end
			while (!Reg.st.map.tileIsType(Reg.st.map.layerCol().getTile(tc.x, tc.y), LADDER_TOP)) {
				tc.y--;
				#if debug
				if ( (_t++) > 64 || tc.y < 0) throw 'Ladder tile, does not have a ladder top. ${tc}';
				#end
			}
			_specialTileY = tc.y * 8;
			physics_stop();
			animation.play("climb");
			_sndTick = SOUND_TICK_CLIMB * 0.75;
			_shoot_allow = false;
			fsm.goto(ONLADDER);
			return true;
		}
		return false;
	}//---------------------------------------------------;
	
	// Check current position for ladder DOWN . Return if it mounted a ladder
	function ladder_checkDown():Bool
	{
		// The playeris 8 pixels wide, so a tile length, check + 4 to get the middle point of X
		// Check + 4 in Y to get the middle point of the tile below his feet
		if (Reg.st.map.tileIsType(Reg.st.map.getTileP(x + 4, y + height + 4), LADDER_TOP))
		{
			// SNAP to 32pixels BIG tile, and center
			_specialTileY = Std.int((y + height + 4) / 8) * 8;
			x = (Std.int(x / 32) * 32) + (32 - width) / 2;
			y += LADDER_SNAP_Y;	// Order lock. After (_specialTileY set)
			last.x = x;
			last.y = y;
			physics_stop();
			animation.play("mount");
			_sndTick = SOUND_TICK_CLIMB * 0.75;
			_shoot_allow = false;
			fsm.goto(ONLADDER);
			return true;
		}
		return false;
	}//---------------------------------------------------;
	
	
	/**
	   == Overlap Check Handler with Animated Tiles ==
	**/
	public function event_anim_tile(A:Player, B:AnimatedTile)
	{
		// Because this can trigger while the inventory is open
		if (!active) return;
		
		switch(B.type)
		{
			
			case HAZARD:
				// Can't hit a hazard on the way up / Don't hit same hazard more than once
				if (velocity.y < 0) return;	
				hurt(Reg.P_DAM.from_hazard);
				velocity.y = -JUMP;
				touching = 0;
				_jumpForceFull = true;
				_verticalJump = false;	// Help player escape if falls from above
				fsm.goto(ONAIR);
				
				
			case KEYHOLE:
				Reg.st.key_ind.setAt(0, B.x);
				if (_interact_anim_request()) 
				{
					Reg.st.map.keyhole_activate(B);
				}
			
			case WEAPON(i):
				Reg.st.key_ind.setAt(0, B.x);
				if (_interact_anim_request()) 
				{
					if (bullet_type == i) bullet_type = 0; else bullet_type = i; // Toggle
					Reg.st.HUD.bullet_pickup(bullet_type);
					D.snd.play(Reg.SND.weapon_get);					
				}
				
			case EXIT(locked):
				Reg.st.key_ind.setAt(0, B.x);
				if (_interact_anim_request()) 
				{
					// > This will check if exit is locked etc, also will unlock and go to the new map.
					Reg.st.map.exit_activate(B);
				}
			case _:
		}
	
	}//---------------------------------------------------;
	
	/**
	   == Called externally  (from <MapFK.hx>)
	   When the player collides with a SLIDE tile at any side, so I need to check
	   == WARNING== This Function takes place inside a `Flxg.collision` check 
	   so the function stack is inside an 'onair_update' or 'onfloor_update' here !!
	   == DEV == 2015 version it could end slide on a floor tile, this cannot
	**/
	public function event_slide_tile(tile:FlxTile, tileDir:Int)
	{	
		if (velocity.y < 0) return;
		if (!isTouching(FlxObject.DOWN | FlxObject.WALL)) return;
		
		// :: Get where the slide ends, Will search for an EMPTY TILE
		var tx = Std.int(tile.x / 8);
		var ty = Std.int(tile.y / 8);
	
		if (y >= (ty * 8) - height + SLIDE_MOUNT_PIXELS_Y_OFF) return;	// tile too high and I come from the sides
		
		var xdir:Int = tileDir == FlxObject.RIGHT?1: -1;
		
		// Snap player to tile
		x = (tx * 8);
		y = (ty * 8) - height + SLIDE_MOUNT_PIXELS_Y_ON;
		
		// Find where the slide ends, (tx,ty) now are the empty tile
		var t = 0;
		do{
			tx += xdir;
			ty ++;
			t = Reg.st.map.getCol(tx, ty);
		}while (t != 0);
		
		_specialTileY = ty * 8;	// This is the free TILE, not the last tile
		
		_hack_break = true;	// Fix function stack 
		physics_stop();
		velocity.set(xdir * SLIDE_SPEED, SLIDE_SPEED);
		facing = tileDir;
		fsm.goto(ONSLIDE);
	}//---------------------------------------------------;

	
	
	
	// - USED IN <state_onfloor_update>
	// - Stop walking and end current walk cycle
	function _walk_stop_cycle()
	{
		isWalking = false;
		velocity.x = 0;
		_sndTick = SOUND_TICK_WALK * 0.8;	// Don't wait a full tick to make the sound.
		// : Finish the walk animation then go to idle
		animation.callback = (a, b, c)->{
			if (b == _walkLastFrame) {
				animation.callback = null;	// Dev. need to null, doesn't reset on new anims
				animation.play("idle");
			}
		};
	}//---------------------------------------------------;
	
	// - USED IN <state_onfloor_update>
	// - Request to start walking. Checks if already against a wall
	function _walk_start_req()
	{
		_idle_stop();
		
		if (_walkBlockDir == facing) {
			return;
		}
		
		if (!isWalking) {
			if (isCrouching) standUp();
			_walkBlockDir = -1;
			isWalking = true;
			animation.callback = null;
			animation.play("walk");
		}
		
		// Continue walking
		_sndTick += FlxG.elapsed;
	}//---------------------------------------------------;
	
		
	// -- Code BORROWED from <MapSprite.hx>
	// X,Y are world coordinates
	function _snapToFloor(X:Float, Y:Float)
	{
		var SP_TILE = new SimpleCoords(Std.int(X / 32) * 4 , Std.int(Y / 32) * 4);
		last.x = x = Std.int((SP_TILE.x * 8) + ((32 - width) / 2));
		var floory = Reg.st.map.getFloor(SP_TILE.x + 1, SP_TILE.y + 1);
		if (floory >= 0) {
			last.y = y = (floory * 8) - Std.int(height);
		}else{
			trace("Warning: Can't find a floor. Dropping");
			last.y = y = Y;
		}
	}//---------------------------------------------------;
	
	
	// -- Check if player is on floor and can interact with animated tile
	// - Takes into account timings etc
	// - Produces INTERACT symbol
	function _interact_anim_request():Bool
	{
		if (fsm.currentStateName != ONFLOOR) return false;
		
		if (D.ctrl.justPressed(UP)) 
		{
			if (_idle_stage > 0) animation.play('idle');
			_idle_stop();
			if (FlxG.game.ticks - _interact_time <= INTERACT_MIN_TIME) return false;
			_interact_time = FlxG.game.ticks;
			return true;
		}
		
		return false;
	}//---------------------------------------------------;

	
	inline function _idle_stop()
	{
		_idle = _idle_stage = 0;
	}//---------------------------------------------------;
	
}// --

