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
	- Uses <Game.map> for tile checking
	- Is being sent <event_collide_slide> from the map
	- Graphic declared in <Reg.hx>
  
======================================== */

package gamesprites;


import djA.Fsm;
import djA.types.SimpleCoords;
import djFlixel.D;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.tile.FlxTile;


enum PlayerState
{
	ONFLOOR;	// walking standing
	ONAIR;
	ONLADDER;
	ONSLIDE;
}


class Player extends FlxSprite
{
	inline static var PLAYER_IDLE_TIME_ANIMATION = 6.0;		// at how many seconds to idle anim
	
	// Graphic Tile Size
	inline static var TW = 28;
	inline static var TH = 26;
	// Bounding box
	inline static var BOUND_W = 8;
	inline static var BOUND_H = 22;
	inline static var BOUND_OFF_X = 11;
	inline static var BOUND_OFF_Y = 4;
	inline static var BOUND_CROUCH_OFF = 8;
	
	inline static var LADDER_SNAP_Y = 8;		// Move player this much downwards when mounts a ladder
	inline static var LADDER_MOUNT_PIXELS = 4;	// For this many traveled pixels the mount frame will be displayd
	
	inline static var SLIDE_MOUNT_PIXELS_Y_ON = 4;	// Offset when mounting the slide
	inline static var SLIDE_MOUNT_PIXELS_Y_OFF = 8;	// Offset to check when getting off
	
	// Keys states
	var _pressingUp:Bool;
	var _pressingDown:Bool;
	var _pressingLeft:Bool;
	var _pressingRight:Bool;
	var _pressingFire:Bool;
	
	// All these are autocalculated on creation
	var MAX_FALLSPEED:Int;			// autoset, based on PLAYER_JUMP_STRENGTH
	var CLIMB_SPEED:Int;			// autoset, based on PLAYER_SPEED
	var SLIDE_SPEED:Int;			// autoset, based on PLAYER_SPEED
	var AIR_NUDGE_SPEED:Int;		// Air movement if on air vertical, autoset from PLAYER_SPEED
	var AIR_NUDGE_SPEED_LESS:Int;	// Air movement if walked jumped, autoset from PLAYER_SPEED

	// -- Animation/state vars
	public var isOnFloor(default, null):Bool;
	public var isCrouching(default, null):Bool;
	public var isWalking(default, null):Bool;
	public var isFalling(default, null):Bool;
	public var isSliding(default, null):Bool;
	public var isClimbing(default, null):Bool;
	
	
	// -- States
	
	var fsm:Fsm;
	
	var _walkLastFrame = 0;			// The last walk frame index
	var _verticalJump:Bool;			// Slower left-right movement on the air if vertical jump
	var _specialTileY:Int;			// Either TOP LADDER TILE, or SLIDE FREE TILE
	var _break_after:Bool;			// Useful to keep track whether I need to exit an update function sometimes
	
	public function new() 
	{
		super();
		
		// Auto set physics based on WALK SPEED and JUMP_STR
		// Physics, and speed parameters
		MAX_FALLSPEED = Reg.PH.pl_jump + 50;
		CLIMB_SPEED = Math.ceil(Reg.PH.pl_speed * 0.8 );
		SLIDE_SPEED = Math.ceil(Reg.PH.pl_speed * 1.1 );
		AIR_NUDGE_SPEED = Math.ceil(Reg.PH.pl_speed / 8);
		AIR_NUDGE_SPEED_LESS = Math.ceil(AIR_NUDGE_SPEED / 3);
		
		maxVelocity.y = MAX_FALLSPEED;
		maxVelocity.x = Reg.PH.pl_speed;
		
		// Graphics
		loadGraphic(Reg.IM.player, true, TW, TH);
		setFacingFlip(FlxObject .LEFT, false, false);
		setFacingFlip(FlxObject.RIGHT, true, false);
		
		// Animations
		animation.add("idle", 	[1], 1, false);
		animation.add("walk", 	[2, 3, 2, 1], 14);
		animation.add("fall", 	[3], 1, false);
		animation.add("jump", 	[4],1, false);
		animation.add("crouch", [0],1, false);
		animation.add("slide", 	[5],1, false);
		animation.add("climb", 	[7, 8], 10);
		animation.add("mount",  [6], 1, false);
		animation.add("wave", [ 9, 10, 11, 10, 11, 9, 1], 8, false);
		animation.add("die", [14, 15, 16, 17], 4, false);
		animation.add("spin", [12, 13], 8);
		
		_walkLastFrame = animation.getByName('walk').numFrames - 1;
	
		// Bounding Box
		setSize(BOUND_W, BOUND_H);
		offset.set(BOUND_OFF_X, BOUND_OFF_Y);
		
		// --
		fsm = new Fsm();
		fsm.addState(PlayerState.ONFLOOR , state_onfloor_enter, state_onfloor_update, state_onfloor_exit);
		fsm.addState(PlayerState.ONAIR   , state_onair_enter, state_onair_update);
		fsm.addState(PlayerState.ONLADDER, null, state_onladder_update);
		fsm.addState(PlayerState.ONSLIDE, null , state_onslide_update);
		
	}//---------------------------------------------------;
	

	
	function state_onslide_update()
	{
		// Check when it reaches the final slide tile
		if (y > _specialTileY - SLIDE_MOUNT_PIXELS_Y_OFF)
		{
			physics_start();
			velocity.x = 0;
			_verticalJump = true;
			_break_after = false;
			fsm.goto(ONAIR);
		}
	}//---------------------------------------------------;
	
	function state_onladder_update()
	{
		if (_pressingUp)
		{
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
			// :: -- (old 2015 code note) --
			// TODO: Different thresholds to drop
			// 1. Ladder reaches a platform, small threshold
			// 2. Ladder ends on air, larger threshold
			// -- (end note)
			
			// :: OK but currently it works ok, with just one threshold
			
			if ( !Game.map.tileIsType(Game.map.getTileP(x + 2, y + height + 4), LADDER) || 
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
			velocity.y = 0;
			animation.pause();
		}
	}//---------------------------------------------------;

	
	function state_onair_enter()
	{
		if (velocity.y >= 0) {
			animation.play("fall");
			isFalling = true;
		}else{
			animation.play("jump");
			isFalling = false;
		}
	}//---------------------------------------------------;
	
	
	function state_onair_update()
	{
		
		// DEV: This will trigger all tile-callbacks, including TRIGGER_SLIDE
		//		- this has caused some headaches
		//	  : Collide Check NEEDS to be before anything else here for it to work
		FlxG.collide(this, Game.map.layers[1]);
		if (_break_after) return;	// This fixes the slide problem
		
		// :: UPDATE
	
		if (velocity.y >= 0) // Going DOWN
		{
			if (!isFalling)
			{
				isFalling = true;
				animation.play("fall");
			}
			
			if (justTouched(FlxObject.FLOOR))	// landed
			{
				y = Std.int(y);
				velocity.set(0, 0);
				//steppedOnHazzard = false;	// LATER
				//_lastWallBlockedDir = 0;	// LATER
				fsm.goto(ONFLOOR);
				return;
				/// <SOUND> land
			}
		}else{ 
			
			// :: Check for button release to reduce jump velocity
			// :: HARD_CODED
			if ( !D.ctrl.pressed(A) && velocity.y >=-200 && velocity.y <= -100)
			{
				velocity.y = -80;
				// DEV: Should I parameterize all these??
			}
		}
		
		// :: INPUT
		if (_pressingRight)
		{
			if (_verticalJump) {
				velocity.x = AIR_NUDGE_SPEED;
			}
			else {
				velocity.x += AIR_NUDGE_SPEED_LESS;
			}
			
		}else
		if (_pressingLeft)
		{
			if (_verticalJump) {
				velocity.x =- AIR_NUDGE_SPEED;
			}
			else {
				velocity.x -= AIR_NUDGE_SPEED_LESS;
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
		isFalling = false;
		animation.play("idle");
	}//---------------------------------------------------;
		
	
	function state_onfloor_exit()
	{
		isWalking = false;
		animation.callback = null;
	}//---------------------------------------------------;
	
	
	function state_onfloor_update()
	{
		
		// DEV: This will trigger all tile-callbacks, including TRIGGER_SLIDE
		//		- this has caused some headaches
		//	  : Collide Check NEEDS to be before anything else here for it to work
		FlxG.collide(this, Game.map.layers[1]);
		if (_break_after) return;	// This fixes the slide problem
		
		// :: UPDATE
		if (!isTouching(FlxObject.FLOOR)) // Was the player walked off a platform?
		{
			_verticalJump = true;
			fsm.goto(ONAIR);
			return;
		}
		else
		{
			// (This comment is copied from the older 2015 release) ::
			// BUG :
			// Sometimes when the player touches the floor hr jitters.
			// player.y is a real number (10.0000001)
			// NOTE:
			// This seems to be present in framerates larger than 40.
			// I am running with a 40 framerate right now
			// y = Std.int(y); or Math.round?
		}
		
		// :: INPUT : Ordering is important
		
		if (_pressingRight)
		{
			if (isCrouching) standUp();
			facing = FlxObject.RIGHT;
			velocity.x = Reg.PH.pl_speed;
			
			// start walk animation ONLY if it is not up against a wall
			isWalking = true;
			animation.play("walk"); // Restart animation
			
		}
		else if (_pressingLeft)
		{
			if (isCrouching) standUp();
			facing = FlxObject.LEFT;
			velocity.x = -Reg.PH.pl_speed;
			// start walk animation ONLY if it is not up against a wall
			isWalking = true;
			animation.play("walk"); // Restart animation
		}
		else
		{
			// : NO DIRECTION IS HELD
			
			if (isWalking)
			{
				velocity.x = 0;
				isWalking = false;
				// : Finish the walk animation then go to idle
				animation.callback = (a, b, c)->{
					if (b == _walkLastFrame) {
						animation.callback = null;	// Dev. need to null, doesn't reset on new anims
						animation.play("idle");
					}
				};
			}
		}
		
		// :: Break the else
		
		if (D.ctrl.justPressed(A))
		{
			velocity.y = -Reg.PH.pl_jump;
			touching = 0;
		
			if (isCrouching) standUp();
			
			if (isWalking)
			{
				_verticalJump = false; // Keep the walk animation going in the jump state
			}else{
				_verticalJump = true;
			}
			
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
		// :: Position ::
		_snapToFloor(X, Y);
		last.x = x; last.y = y;
		
		// Reset physics with a stop,start
		physics_stop();
		physics_start();
		
		input_reset();
		
		// --
		_break_after = false;
		isCrouching = false;
		isWalking = false;
		isOnFloor = true;	// Not Needed
		isFalling = false;	// Does not matter, gets inited before use
		isSliding = false;	// Not needed
		isClimbing = false; // Not needed
		
		fsm.goto(ONFLOOR);
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
	}//---------------------------------------------------;
	
	
	
	/** Check current position for ladder UP . Return if it mounted a ladder*/
	function ladder_checkUp():Bool
	{
		var tc = Game.map.getTileCoordsFromP(x + 4, y + height - 2);
		var tile = Game.map.layers[1].getTile(tc.x, tc.y);
		if (Game.map.tileIsType(tile, LADDER) || Game.map.tileIsType(tile, LADDER_TOP))
		{
			x = (Std.int(x / 32) * 32) + (32 - width) / 2;
			last.x = x;
			// Search for a ladder TOP.
			#if debug var _t = 0; #end
			while (!Game.map.tileIsType(Game.map.layers[1].getTile(tc.x, tc.y), LADDER_TOP)) {
				tc.y--;
				#if debug
				if ( (_t++) > 64 || tc.y < 0) throw 'Ladder tile, does not have a ladder top. ${tc}';
				#end
			}
			_specialTileY = tc.y * 8;
			physics_stop();
			fsm.goto(ONLADDER);
			return true;
		}
		return false;
	}//---------------------------------------------------;
	
	/** Check current position for ladder DOWN . Return if it mounted a ladder */
	function ladder_checkDown():Bool
	{
		// The playeris 8 pixels wide, so a tile length, check + 4 to get the middle point of X
		// Check + 4 in Y to get the middle point of the tile below his feet
		if (Game.map.tileIsType(Game.map.getTileP(x + 4, y + height + 4), LADDER_TOP))
		{
			// SNAP to 32pixels BIG tile, and center
			_specialTileY = Std.int((y + height + 4) / 8) * 8;
			x = (Std.int(x / 32) * 32) + (32 - width) / 2;
			y += LADDER_SNAP_Y;	// Order lock. After (_specialTileY set)
			last.x = x;
			last.y = y;
			animation.play("mount");
			physics_stop();
			fsm.goto(ONLADDER);
			return true;
		}
		return false;
	}//---------------------------------------------------;
	
	
		
	
	/**
	   =Called externally - from <MapFK.hx>
	   When the player collides with a SLIDE tile at any side, so I need to check
	   
	   == WARNING== This Function takes place inside a `Flxg.collision` check 
	   so the function stack is inside an 'onair_update' or 'onfloor_update' here !!
	   
	**/
	public function event_slide_tile(tile:FlxTile, tileDir:Int)
	{	
		// if (fsm.currentStateName == ONSLIDE) return; // << Can never happen since I don't check for collisions
		//	if (!isFalling) return;	// << I want to be able to collide even when walking
		
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
		last.x = x;
		last.y = y;
		
		var t = 0;
		do{
			tx += xdir;
			ty ++;
			t = Game.map.getCol(tx, ty);
		}while (t != 0);
		
		_specialTileY = ty * 8;	// This is the free TILE, not the last tile
		
		/// NOTE: 2015 version it could end slide on a floor tile, this cannot
		
		_break_after = true;	// Fix function stack 
		physics_stop();
		velocity.set(xdir * SLIDE_SPEED, SLIDE_SPEED);
		facing = tileDir;
		animation.play("slide");
		fsm.goto(ONSLIDE);
	}//---------------------------------------------------;
	
	// -- Code BORROWED from <MapSprite.hx>
	// X,Y are world coordinates
	function _snapToFloor(X:Float, Y:Float)
	{
		var SP_TILE = new SimpleCoords(Std.int(X / 32) * 4 , Std.int(Y / 32) * 4);
		x = Std.int((SP_TILE.x * 8) + ((32 - width) / 2));
		var floory = Game.map.getFloor(SP_TILE.x + 1, SP_TILE.y + 1);
		if (floory >= 0) {
			y = (floory * 8) - Std.int(height);
		}else{
			throw "Player can`t land on floor";
		}
	}//---------------------------------------------------;
	
	
	// Called when climbing or sliding
	function physics_stop()
	{
		velocity.set(0, 0);
		acceleration.y = 0;
		touching = 0;
		wasTouching = 0;
		solid = false;
	}//---------------------------------------------------;
	
		// --
	// Resume state to normal
	function physics_start()
	{
		acceleration.y = Reg.PH.gravity;
		solid = true;
		//idleTimer = 0;
	}//---------------------------------------------------;
	
	function input_reset()
	{
		_pressingDown = _pressingFire = _pressingLeft = _pressingRight = _pressingUp = false;
	}//---------------------------------------------------;
	
}