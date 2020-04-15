/**
   FUTURE KNIGHT PLAYER CLASS
   -========================-
  - Current version 2020, (updated from 2015 version)
  - Tries to emulate the original game but with some improvements
  
  
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


import djA.Fsm;
import djA.types.SimpleCoords;
import flixel.effects.FlxFlicker;

import djFlixel.D;

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
}


class Player extends FlxSprite
{
	inline static var PLAYER_IDLE_TIME_ANIMATION = 6.0;		// At how many seconds to idle anim

	inline static var BOUND_W = 8; 		// Bounding box 
	inline static var BOUND_H = 22;
	inline static var BOUND_OFF_X = 11;
	inline static var BOUND_OFF_Y = 4;
	inline static var BOUND_CROUCH_OFF = 8;
	
	inline static var LADDER_SNAP_Y = 8;			// Move player this much downwards when mounts a ladder
	inline static var LADDER_MOUNT_PIXELS = 4;		// For this many traveled pixels the mount frame will be displayd
	inline static var SLIDE_MOUNT_PIXELS_Y_ON = 4;	// Offset when mounting the slide
	inline static var SLIDE_MOUNT_PIXELS_Y_OFF = 8;	// Offset to check when getting off
	inline static var SOUND_sndTick_WALK = 0.2857;	// This is ANIMATION FRAMES (1/FPS) * TOTAL_FRAMES
	inline static var SOUND_sndTick_CLIMB = 0.30;
	inline static var IDLE_STEP_TIME = 8;			// Seconds to go to the next idle stage (there are 3 idle stages)
	inline static var FALL_DAMAGE_HEIGHT = 32 * 5;	// If it falls from 5x(bigtiles) do fall damage
	inline static var FALL_DAMAGE_TIME = 3;			// Stun for 3 seconds
	inline static var FALL_DAMAGE_HP = 200;			// Lose this much HP on fall damage
	
	// Precalculated to avoid width/2 all the time
	public var halfWidth:Int;

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
	var _idle:Float;				// Track timer for IDLE and STUN
	var _idle_stage:Int;
	
	
	// - Sounds
	var snd =  {
		walk:"pl_walk",		// ok
		jump:"pl_jump2",	// ok
		climb:"pl_climb",	// ok
		slide:"pl_slide",	// ok
		land:"pl_land",		// ok
		step:"pl_step",		// ok
		die:"pl_die",
		hurt:"pl_hurt",
		shoot:"p_shoot",
	}
	
	
	public function new() 
	{
		super();
		
		// Auto set physics based on WALK SPEED and JUMP_STR
		// Physics, and speed parameters
		MAX_FALLSPEED = Reg.P.pl_jump + 56;
		CLIMB_SPEED = Math.ceil(Reg.P.pl_speed * 0.8 );
		SLIDE_SPEED = Math.ceil(Reg.P.pl_speed * 1.1 );
		AIR_NUDGE_SPEED_0 = Math.ceil(Reg.P.pl_speed / 8);
		AIR_NUDGE_SPEED_1 = Math.ceil(AIR_NUDGE_SPEED_0 / 3);
		
		maxVelocity.y = MAX_FALLSPEED;
		maxVelocity.x = Reg.P.pl_speed;
		
		// Graphics
		Reg.IM.loadGraphic(this,'player');
		setFacingFlip(FlxObject .LEFT, true, false);
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
		
		_walkLastFrame = animation.getByName('walk').numFrames - 1;
	
		// Bounding Box
		setSize(BOUND_W, BOUND_H);
		offset.set(BOUND_OFF_X, BOUND_OFF_Y);
		
		halfWidth = Std.int(width / 2);
		
		// --
		fsm = new Fsm();
		fsm.addState(PlayerState.ONFLOOR , state_onfloor_enter, state_onfloor_update, state_onfloor_exit);
		fsm.addState(PlayerState.ONAIR   , state_onair_enter, state_onair_update);
		fsm.addState(PlayerState.ONLADDER, null, state_onladder_update);
		fsm.addState(PlayerState.ONSLIDE, state_onslide_enter , state_onslide_update, state_onslide_exit);
		fsm.addState(PlayerState.STUNNED, null , state_stunned_update);
		
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
		_sndTemp = D.snd.play(snd.slide, 0.7);
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
		if (_sndTick >= SOUND_sndTick_CLIMB)
		{
			_sndTick = 0;
			D.snd.play(snd.climb);
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
			_sndTick = SOUND_sndTick_CLIMB * 0.75;
			velocity.y = 0;
			animation.pause();
		}
	}//---------------------------------------------------;

	
	function state_onair_enter()
	{
		// Start with this to false, even if it is not jumping
		// and it will be processed in the update cycle
		isFalling = false;
	}//---------------------------------------------------;
	
	
	function state_onair_update()
	{
		// NOTE : Collide Check NEEDS to be before anything else here for it to work
		// DEV  : This will trigger all tile-callbacks, including TRIGGER_SLIDE
		FlxG.collide(this, Reg.st.map.layers[1]);
		
		if (_hack_break) { // (exit if some collide/overlap functions occur)
			_hack_break = false;
			return;
		}
		
		if (justTouched(FlxObject.CEILING))
		{
			D.snd.play("pl_ceil", 0.6);
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
				D.snd.play(snd.land, 0.8);
				last.y = y = Std.int(y);
				

				if (y - _specialTileY > FALL_DAMAGE_HEIGHT)
				{
					_idle = 0;
					animation.play('fallstun');
					physics_stop();
					D.snd.play(snd.hurt, 0.2);
					//hurt(FALL_DAMAGE_HP);
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
		_sndTick = SOUND_sndTick_WALK * 0.8;	// Don't wait a fill TICK to make the sound
		isFalling = false;
		animation.play("idle");
		_walkBlockDir = -1;
		_jumpForceFull = false;
		_idle = _idle_stage = 0;
	}//---------------------------------------------------;
		
	
	function state_onfloor_exit()
	{
		isWalking = false;
		animation.callback = null;
	}//---------------------------------------------------;
	
	
	
	function state_onfloor_update()
	{
		// DEV: This will trigger all tile-callbacks, including TRIGGER_SLIDE
		//	  : Collide Check NEEDS to be before anything else here for it to work
		FlxG.collide(this, Reg.st.map.layers[1]);
		
		if (_hack_break) { // (exit if some collide/overlap functions occur)
			_hack_break = false;
			return;	
		}
		
		// :: UPDATE
		if (!isTouching(FlxObject.FLOOR)) // Was the player walked off a platform?
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
		
		if (_sndTick >= SOUND_sndTick_WALK)
		{
			_sndTick = 0;
			D.snd.play(snd.step);
		}
		
		// 3 Idle states, Wave, Wave, Dance
		// The CPC version would dance, but this requires me to create another graphic for the sprite
		// because haxeflixel doesnot support to mirror a specific animation frame. So no spin for now
		if (_idle >= IDLE_STEP_TIME)
		{
			_idle = 0;
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
			velocity.x = Reg.P.pl_speed;
			_walk_start_req();
		}
		else if (_pressingLeft)
		{
			facing = FlxObject.LEFT;
			velocity.x = -Reg.P.pl_speed;
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
			velocity.y = -Reg.P.pl_jump;
			touching = 0;
		
			if (isCrouching) standUp();
			
			if (isWalking)
			{
				_verticalJump = false; // Keep the walk animation going in the jump state
			}else{
				_verticalJump = true;
				animation.play("jump");
			}
			
			_sndTemp = D.snd.play(snd.jump, 0.8);
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
		
	}//---------------------------------------------------;
	
	/**
	   - New Map, spawn to enter tile
	   - First level, spawn to start of area
	**/
	public function spawn(X:Float, Y:Float)
	{
		alive = true;
		
		// :: Position ::
		_snapToFloor(X, Y);
		
		// Reset physics with a stop,start
		physics_stop();
		physics_start();
		
		_pressingDown = _pressingLeft = _pressingRight = _pressingUp = false;
		
		// --
		_hack_break = false;
		isCrouching = false;
		isWalking = false;
		isFalling = false;	// Init here does not matter, gets inited before use.
		
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
		_idle = _idle_stage = 0;
	}//---------------------------------------------------;
	

	// Check current position for ladder UP . Return if it mounted a ladder
	function ladder_checkUp():Bool
	{
		var tc = Reg.st.map.getTileCoordsFromP(x + 4, y + height - 2);
		var tile = Reg.st.map.layers[1].getTile(tc.x, tc.y);
		if (Reg.st.map.tileIsType(tile, LADDER) || Reg.st.map.tileIsType(tile, LADDER_TOP))
		{
			last.x = x = (Std.int(x / 32) * 32) + (32 - width) / 2;
			// Search for a ladder TOP.
			#if debug var _t = 0; #end
			while (!Reg.st.map.tileIsType(Reg.st.map.layers[1].getTile(tc.x, tc.y), LADDER_TOP)) {
				tc.y--;
				#if debug
				if ( (_t++) > 64 || tc.y < 0) throw 'Ladder tile, does not have a ladder top. ${tc}';
				#end
			}
			_specialTileY = tc.y * 8;
			physics_stop();
			animation.play("climb");
			_sndTick = SOUND_sndTick_CLIMB * 0.75;
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
			_sndTick = SOUND_sndTick_CLIMB * 0.75;
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
		switch(B.type)
		{
			case HAZARD:
				// Can't hit a hazard on the way up / Don't hit same hazard more than once
				if (velocity.y < 0) return;	
				D.snd.play(snd.hurt);
				FlxFlicker.flicker(this, 0.5);
				velocity.y = -Reg.P.pl_jump;
				touching = 0;
				_jumpForceFull = true;
				_verticalJump = false;	// Help player escape if falls from above
				fsm.goto(ONAIR);
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
		// if (fsm.currentStateName == ONSLIDE) return; // << Can never happen since I don't check for collisions
		
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
		_sndTick = SOUND_sndTick_WALK * 0.8;	// Don't wait a full tick to make the sound.
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
		_idle = _idle_stage = 0;
		
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
	
}// --