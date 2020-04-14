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
import djA.types.SimpleVector;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.animation.FlxAnimation;
import flixel.math.FlxAngle;

@:access(gamesprites.Enemy)
class Enemy_AI 
{	
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
		e.facing = e.velocity.y > 0?FlxObject.RIGHT:FlxObject.LEFT;
		e.spawn_origin_move();
	}//---------------------------------------------------;
	// --
	public function update(elapsed:Float)
	{
	}//---------------------------------------------------;
	public function softkill()
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
		if (e.x + e.halfWidth < Game.player.x + Game.player.halfWidth - CHASE_CORRECTION)
		{
			e.velocity.x = Reg.P.en_speed;
			e.facing = FlxObject.RIGHT;
		}else
		if (e.x + e.halfWidth > Game.player.x + Game.player.halfWidth + CHASE_CORRECTION )
		{
			e.velocity.x = -Reg.P.en_speed;
			e.facing = FlxObject.LEFT;
		}
		else
			e.velocity.x = 0;
		
	}//---------------------------------------------------;
	
	// Set velocity Y to follow player
	function chase_y()
	{
		if (e.y < Game.player.y - 1)
		{
			e.velocity.y = Reg.P.en_speed;
		}else
		if (e.y > Game.player.y + 1)
		{
			e.velocity.y = -Reg.P.en_speed;
		}
		else
			e.velocity.y = 0;
	}//---------------------------------------------------;
	
	// From TILED MAP enemy type to an AI
	public static function getAI(type:String, E:Enemy):Enemy_AI
	{
		return switch(type)
		{
			case "move_x": new AI_Move_X(E);
			case "move_y": new AI_Move_Y(E); 
			case "bounce": new AI_Bounce(E);
			case "chase": new AI_Chase(E);
			case "big_chase" : new AI_BigChase(E);
			case "big_bounce": new AI_BigBounce(E);
			case "turret" : new AI_Turret(E);
			case _: new Enemy_AI(E);
		}
	}//---------------------------------------------------;
	
}//--



/**
   Big Enemy - Follow on the X axis if get too close
**/
class AI_Turret extends Enemy_AI
{
	override public function update(elapsed:Float) 
	{
		// count time and shoot a bullet
	}
}




/**
   Big Enemy - Follow on the X axis if get too close
**/
class AI_BigChase extends Enemy_AI
{
	// Version 1:
	// What the CPC version does
	
	// Version 2:
	// What the C64 version does.
	// Enemy moves around and makes your life difficult
	
	override public function update(elapsed:Float) 
	{
		// Move only if close to player:
		if (Math.abs(e.x - Game.player.x) <= Reg.P.en_chase_dist)
			chase_x();
	}//---------------------------------------------------;
	
	
}// --




/**
   Big Enemy - Bounce right-left
**/
class AI_BigBounce extends Enemy_AI
{
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
		//var r1 = FlxAngle.angleBetweenPoint(e, FlxG.mouse.getPosition());
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
class AI_Bounce extends Enemy_AI
{
	// Count
	static inline var GFX_BOUNCE_RESTORE_TIME = 0.16;
	
	var frames:Array<Int>;
	var t:Float = 0;
	
	public function new(E:Enemy)
	{
		super(E);
		e.acceleration.y = Reg.P.gravity;
		startVel.y = Reg.P.en_speed;
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
			if( Game.map.getCol(tx, ty) > 0 ||
				Game.map.getCol(tx + 1, ty) > 0)
			{
				e.velocity.y = - Reg.P.en_bounce;
				e.last.y = e.y = (ty * 8) - e.height; // Lock y to the floor, because it went through it
				t = GFX_BOUNCE_RESTORE_TIME; // set timer
				e.animation.frameIndex = frames[1];
			}
		}else{
			
			// Check for ceiling. (Rare but can cauase bugs)
			if (e.y < Game.map.roomCornerPixel.y){
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
	
	public function new(E:Enemy)
	{
		super(E);
		
		var O = DataT.copyFields(e.O.prop, {
			platform_bound:false,
			distance:0			
		});
		
		startVel.x = Reg.P.en_speed;
		
		if (O.platform_bound) {
			var floorY = e.spawn_origin_set(1);
			var B = Game.map.get2RayCast(e.SPAWN_TILE.x, floorY, true, FlxObject.NONE);
			v0 = B.v0 * 8;
			v1 = (B.v1 * 8) - e.width;
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
			var B = Game.map.get2RayCast(e.SPAWN_TILE.x , e.SPAWN_TILE.y + 1, true, FlxObject.ANY);
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
	var initV:Float;
	var sameX:Bool;
	
	public function new(E:Enemy)
	{
		super(E);
		
		// Default values
		var O = DataT.copyFields(e.O.prop, {
			distance:0,
			same_x:false
		});
		
		startVel.y = Reg.P.en_speed;	// This is enemy default base speed
		sameX = O.same_x;
		
		// sameX Flag means it will be a ghost enemy, full Y area movement
		if (sameX)
		{
			// velocity facing calculated onspawn()
			v0 = Std.int(E.O.y / Game.map.ROOM_HEIGHT) * Game.map.ROOM_HEIGHT + 8;
			v1 = v0 + Game.map.ROOM_HEIGHT - E.height - 16;
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
			if (Game.map.layers[1].getTile(e.SPAWN_TILE.x, e.SPAWN_TILE.y) > 0) {
				e.SPAWN_POS.y += 8;
			}
			var B = Game.map.get2RayCast(e.SPAWN_TILE.x + 1 , e.SPAWN_TILE.y + 1, false, 1);
			v0 = B.v0 * 8;
			v1 = (B.v1 * 8) - e.width;
		}
		
	}//---------------------------------------------------;
	
	override public function respawn() 
	{
		// Spawn at the opposite side of player Y
		if (sameX) {
			e.x = Game.player.x + (Game.player.width - e.width) / 2;
			if (Game.player.y < Game.map.roomCornerPixel.y + (Game.map.ROOM_HEIGHT / 2) - Game.player.height / 2){
				e.y = v1;
				e.velocity.y = -initV;
			}else{
				e.y = v0;
				e.velocity.y = initV;
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