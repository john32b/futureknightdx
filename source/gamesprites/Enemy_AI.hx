/**
	DEV:
	--------------
	Every enemy has an AI component
	It is read from the TiledEditor Objects <type> field | check `EnemyAI_getAI()
	Some types can have extra parameters, (defined in the TiledObject) as parameters
		
	
	NOTES:
	--------------
		- All chases are HALF the ENEMY_BASE_SPEED by default
	
	
	AI TYPES:
	--------------
	
		move_x : 
			distance:Int			; Move by this much tiles, goes through walls
			platform_bound:Bool		; Place on the nearest platform and bound to it
			-no param-				; Move until hits wall or room end
		move_y
			distance:Int			; Move by this much tiles, goes through walls
			-no param				; Move until hits wall or room end
			
		bounce						; Bounces and follows player
		
		
		chase						; chase the player and bump into him
		
		turret
		
		big_chase					; 
		
		big_bounce
		
	
**/



package gamesprites;

import djA.DataT;
import djfl.util.TiledMap.TiledObject;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.animation.FlxAnimation;
import flixel.math.FlxAngle;

@:access(gamesprites.Enemy)
class Enemy_AI 
{
	var e:Enemy;
	
	public function new(E:Enemy) 
	{
		e = E;
		enter();
	}//---------------------------------------------------;	
	// --
	public function enter()
	{
		e.set_spawn_origin(0);
		e.facing = FlxObject.RIGHT;
	}//---------------------------------------------------;
	// --
	public function update(elapsed:Float)
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
	
	// -- Call on update, will move towards the player
	function chase_x()
	{
		if (e.x < FlxG.mouse.x - 1)
		{
			e.velocity.x = Reg.PH.en_speed;
			e.facing = FlxObject.RIGHT;
		}else
		if (e.x > FlxG.mouse.x + 1)
		{
			e.velocity.x = -Reg.PH.en_speed;
			e.facing = FlxObject.LEFT;
		}
		else
			e.velocity.x = 0;
		
	}//---------------------------------------------------;
	
	function chase_y()
	{
		if (e.y < FlxG.mouse.y - 1)
		{
			e.velocity.y = Reg.PH.en_speed;
		}else
		if (e.y > FlxG.mouse.y + 1)
		{
			e.velocity.y = -Reg.PH.en_speed;
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
	
	
}//-


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
		chase_x();
	}
}


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
		//e.velocity.x = Reg.PH.en_speed * Math.cos(r1);
		//e.velocity.y = Reg.PH.en_speed * Math.sin(r1);
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
	
	static inline var GFX_BOUNCE_RESTORE_TIME = 0.16;
	
	var frames:Array<Int>;
	var t:Float = 0;
	
	override public function enter() 
	{
		super.enter();
		e.velocity.y = Reg.PH.en_speed;
		e.acceleration.y = Reg.PH.gravity;
		e.animation.stop();
		frames = e.animation.getByName("main").frames;
		e.animation.frameIndex = frames[0];
	}//---------------------------------------------------;
	
	override public function update(elapsed:Float) 
	{
		
		// DEV: This also works, but I feel that it is overkill for a simple check?
		//if (e.velocity.y > 0) {
			//if (FlxG.collide(e, Game.map.layers[1])) {
				//e.velocity.y = -220;
			//}
		//}
		
		// DEV: This way I am checking manually:
		//		 This is faster then creating a quadtree at every frame
		if (e.velocity.y > 0)
		{
			var ty = Std.int((e.y + e.height) / 8);
			var tx = Std.int(e.x / 8);
			if( Game.map.getCol(tx, ty) > 0 ||
				Game.map.getCol(tx + 1, ty) > 0)
			{
				e.velocity.y = - Reg.PH.en_bounce;
				// It went through the floor, bring it back where it was
				e.x = e.last.x;
				e.y = e.last.y;
				
				t = GFX_BOUNCE_RESTORE_TIME;
				e.animation.frameIndex = frames[1];
			}
		}else{
			
			// When going up, countdown to a short time then restore the bouncing frame to 0
			if (t > 0) {
				if ((t -= elapsed) <= 0) {
					e.animation.frameIndex = frames[0];
				}
			}
		}
		
		chase_x();
	}//---------------------------------------------------;
}






/**
	- Loop through 2 points in the X axis
	- Pre-sets a start and end point
**/
@:access(gamesprites.Enemy)
class AI_Move_X extends Enemy_AI
{
	var v0:Float;
	var v1:Float;
	
	override public function enter() 
	{
		// Default values 
		var O = DataT.copyFields(e.O.prop, {
			platform_bound:false,
			distance:0			
		});
		
		super.enter();
		
		e.velocity.x = Reg.PH.en_speed;	// This is enemy default base speed
		
		if (O.platform_bound)
		{
			var floorY = e.set_spawn_origin(1);
			var B = Game.map.get2RayCast(e.SPAWN_TILE.x, floorY, true, FlxObject.NONE);
			v0 = B.v0 * 8;
			v1 = (B.v1 * 8) - e.width;
		}else
		if (O.distance != 0)
		{
			// Fixed amount of tiles. Going through walls, also check for negative distance
			v0 = e.SPAWN_POS.x;	// It is going to be spawned here
			if (O.distance < 0) {
				v1 = v0;
				v0 = v1 + (O.distance * 8);
				e.velocity.x = -e.velocity.x;
				e.facing = FlxObject.LEFT;
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
		
	}//---------------------------------------------------;
	
	override public function update(elapsed:Float) 
	{
		if (e.x > v1 || e.x < v0)
		{
			turnAround();
			e.velocity.x = -e.velocity.x;
		}
	}//---------------------------------------------------;
	
}// --





/**
	- Loop through 2 points in the Y axis
	- Pre-sets a start and end point
**/
@:access(gamesprites.Enemy)
class AI_Move_Y extends Enemy_AI
{
	var v0:Float;
	var v1:Float;
	
	override public function enter() 
	{
		super.enter();
		
		// Default values 
		var O = DataT.copyFields(e.O.prop, {
			distance:0
		});
		
		e.velocity.y = Reg.PH.en_speed;	// This is enemy default base speed
		
		if (O.distance != 0)
		{
			v0 = e.SPAWN_POS.y;	// It is going to be spawned here
			if (O.distance < 0) {
				v1 = v0;
				v0 = v1 + (O.distance * 8);
				e.velocity.y = -e.velocity.y;
				e.facing = FlxObject.LEFT;
			}else{
				v1 = v0 + (O.distance * 8);
			}
			
			/// Don't check for borders, trust the editor values
			
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
	
	override public function update(elapsed:Float) 
	{
		if (e.y > v1 || e.y < v0)
		{
			turnAround();
			e.velocity.y = -e.velocity.y;
		}
	}//---------------------------------------------------;


}// --