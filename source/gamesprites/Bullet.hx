/**
   Graphic Notes
   - All bullets face right in the tilesheet
   - 20x20 
   
   + Bullets are created by the BulletManager ( StatePlay.BM )
   
**/
  

package gamesprites;

import djFlixel.D;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxDirectionFlags;
import flixel.math.FlxAngle;
import gamesprites.Player;


typedef BulletType = {
	 anim:String,
	 damage:Int,	
	 speed:Float,	
	 distance:Int,	// Distance in pixels allowed to travel before killing. -1 for max distance
	 maxscreen:Int,	// How many allowed on screen
	 timer:Int,		// Can shoot every this much milliseconds
};


@:allow(BulletManager)
class Bullet extends FlxSprite
{
	public inline static var OWNER_PLAYER = 1;
	public inline static var OWNER_ENEMY = 2;
	
	inline static var JITTER_TIME = 0.05;
	inline static var JITTER_PIX = 2;
	inline static var FPS = 10;
	
	public static var SND = {
		wall:"bl_hit"
	};
	
	// All the game bullet data. ENEMY + PLAYER
	public static var TYPES:Array<BulletType> = [
		{ anim:"p_1", speed:150, distance:0, 	maxscreen:2, damage:10, timer:250 }, // dps = 40/sec
		{ anim:"p_2", speed:200, distance:82, 	maxscreen:4, damage:6,  timer:135 }, // dps = 44/sec
		{ anim:"p_3", speed:240, distance:0, 	maxscreen:2, damage:19, timer:450 }, // dps = 42.2/sec
		{ anim:"e_1", speed:110, distance:0, 	maxscreen:2, damage:10, timer:0   }, // Turret
		{ anim:"e_2", speed:80,  distance:0, 	maxscreen:4, damage:12, timer:0   }, // Long legs enemy
		{ anim:"e_2", speed:70,  distance:0, 	maxscreen:3, damage:13, timer:0   }  // Final boss
	];
		
	inline static var halfWidth = 2;
	inline static var halfHeight = 2;
	
	// ------------------------
	
	// Points to the manager this bullet belongs to
	var manager:BulletManager;
		
	// :: These are autoset on  `init()` ::
	public var T(default, null):BulletType;		// Pointer to a bullet type object
	public var owner(default, null):Int;		// 0:None, 1:Player, 2:Enemy.
	public var type(default, null):Int;	
	
	var _chase:Bool;
	var _timer:Float = 0;	   	// chase jitter timer
	var _phasing:Bool; 			// Go through walls (set from type)
	var _travelTarget:Int;		// Travel to here, then die. Only active if T.distance>0
	
	public function new()
	{
		super();
		Reg.IM.loadGraphic(this, "bullets");
		animation.add("p_1", [0, 1], FPS);
		animation.add("p_2", [2, 3], FPS);
		animation.add("p_3", [4, 5], FPS);
		animation.add("e_1", [6, 7], FPS);
		animation.add("e_2", [8, 9], FPS);
		setSize(4, 4);
		centerOffsets();
		setFacingFlip(FlxDirectionFlags.LEFT, true, false);
		setFacingFlip(FlxDirectionFlags.RIGHT, false, false);
		facing = FlxDirectionFlags.RIGHT;
	}//---------------------------------------------------;
	
	/**
	  - Set a bullet parameters
	  @param TYPE, Bullet type, check {TYPES} in this class
	  @param FACE, FlxDirection
	**/
	public function init(TYPE:Int, X:Float, Y:Float, FACE:Int)
	{
		type = TYPE;
		T = TYPES[TYPE];
		last.x = x = X - halfWidth;
		last.y = y = Y - halfHeight;
		velocity.set(0, 0);
		
		if (FACE > 0) {
			if (FACE == FlxDirectionFlags.LEFT) {
				velocity.x = -T.speed;
				_travelTarget = Std.int(x - T.distance);
			}else{
				velocity.x = T.speed;
				_travelTarget = Std.int(x + T.distance);
			}
		}
		animation.play(T.anim, true);
		facing = FACE;
		_chase = (TYPE >= 3);	// enemy bullet
		_phasing = (TYPE == 2 || TYPE == 3);
		owner = (TYPE <= 2)?OWNER_PLAYER:OWNER_ENEMY;
	}//---------------------------------------------------;
	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		
		if (_chase)
		{
			var r1 = FlxAngle.angleBetween(this, Reg.st.player);
			velocity.x = T.speed * Math.cos(r1);
			velocity.y = T.speed * Math.sin(r1);
			
			if ((_timer += elapsed) >= JITTER_TIME)
			{
				_timer = 0;
				x += FlxG.random.int( -JITTER_PIX, JITTER_PIX);
				y += FlxG.random.int( -JITTER_PIX, JITTER_PIX);
			}
		}
		
		// :: Check for off screen
		if (Reg.st.map.isOffRoom(this))
		{
			manager.killBullet(this);
			return;
		}
		
		// :: Check for distance
		if (T.distance > 0)
		{
			if 	( (facing == FlxDirectionFlags.RIGHT && x > _travelTarget) ||
				  (facing == FlxDirectionFlags.LEFT  && x < _travelTarget) ) 
			{
				manager.killBullet(this);
				return;
			}
		}
	}//---------------------------------------------------;
	
}//--