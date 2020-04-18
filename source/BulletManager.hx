/**
	
  FUTURE KNIGHT BULLETS
  ======================================
  - Player bullets and Enemy bullets
  - All graphics from a single tilesheet
  - Graphic size (20x20);

*/


package;
import djFlixel.D;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.group.FlxGroup;
import flixel.FlxSprite;
import flixel.math.FlxAngle;
import flixel.tile.FlxTile;
import gamesprites.Player;



/**
   
 - All bullets auto kill when off screen
 
**/
class BulletManager extends FlxGroup
{
	public inline static var OWNER_PLAYER = 1;
	public inline static var OWNER_ENEMY = 2;
	
	inline static var POOL_MIN = 3; // Keep this much bullets when resetting
	
	// Number of player bullets on screen
	// I need this because there is a limit to how many are allowed.
	public var count_player = 0;
	
	var _halfUpdate:Bool = true;
	
	/** Kill all bullets and remove them. keep (POOL_MIN) */
	public function reset()
	{
		D.dest.groupKeep(this, POOL_MIN);
		count_player = 0;
	}//---------------------------------------------------;
	
	// Quickly kill all particles, but not group itself
	override public function kill():Void 
	{
		super.kill();
		alive = true;	// If I don't do this, then the group will not be drawn/rendered
		exists = true;
		count_player = 0;
	}//---------------------------------------------------;

	// Create a bullet at center point and direction
	function createAt(anim:String, x:Float, y:Float, vx:Float = 0, vy:Float = 0,owner:Int = 0):Bullet
	{
		var b:Bullet = cast recycle(Bullet);
		b.x = x - Bullet.halfWidth;
		b.y = y - Bullet.halfHeight;
		b.velocity.set(vx, vy);
		b.animation.play(anim, true);
		b.facing = b.velocity.x > 0?FlxObject.RIGHT:FlxObject.LEFT; // Autoface
		b.manager = this;
		b.owner = owner;
		b._chase = false;
		return b;
	}//---------------------------------------------------;
	
	
	/**
	   Create a player bullet
	   @param type 1,2,3
	   @param x,y,face (center point, facing)
	   @return Did it actually create a bullet?
	**/
	public function shootFromPlayer(type:Int, x:Float, y:Float, face:Int):Bool
	{
		if (count_player >= Reg.P.pl_bl_onscreen)
		{
			return false;
		}
		
		var anim = 'p_$type';
		var velx = (face == FlxObject.RIGHT?Reg.P.pl_bl_speed: -Reg.P.pl_bl_speed);
		var b = createAt(anim, x, y, velx, 0, OWNER_PLAYER);
		count_player++;
		
		b._phasing = (type == 3);	// Type 3 goes through wall
		return true;
	}//---------------------------------------------------;
	
	/**
	   Create enemy bullet. All enemy bullets are homing bullets
	   @param	type 1:Fat, 2:Jitter
	**/
	public function shootFromEnemy(type:Int, x:Float, y:Float)
	{
		var anim = 'e_$type';
		var b = createAt(anim, x, y, 0, 0, OWNER_ENEMY);
		b._phasing = true;
		b._chase = true;
	}//---------------------------------------------------;
	
	
	/** Remove the bullet, Optionally create a particle where it died */
	public function killBullet(b:Bullet, particle:Bool = false)
	{
		b.kill();
		if (b.owner == OWNER_PLAYER) count_player--;
		if (particle) {
			Reg.st.PM.createAt(1, b.x + Bullet.halfWidth, b.y + Bullet.halfHeight, 0, 0);
		}
	}//---------------------------------------------------;
	
	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		_halfUpdate = !_halfUpdate;
		
		// I don't need fullframe map collision checks
		if (_halfUpdate)
		{
			// DEV:
			// I can't use FLXG.collide because I need the bullets to go through walls
			// This works ok:
			for (b in this)
			{
				if(b.alive)
				Reg.st.map.layers[1].overlapsWithCallback(cast b, cast _collideMap);
			}
		}
	}//---------------------------------------------------;
	
	
	function _collideMap(A:FlxTile, B:Bullet):Bool
	{
		if (B._phasing) return false;
		if (A.allowCollisions == FlxObject.ANY) {
			killBullet(B, true);
			D.snd.play("hit_01");
			return true;
		}
		return false;	
	}//---------------------------------------------------;
	
	
}// --







/**
   Graphic Notes
   - All bullets face right
   - 20x20 
**/
@:allow(BulletManager)
class Bullet extends FlxSprite
{
	
	inline static var JITTER_TIME = 0.18;
	inline static var JITTER_PIX = 1;
	inline static var FPS = 10;
	
	public inline static var halfWidth = 2;	// bullet game size is 5x5
	public inline static var halfHeight = 2;
	
	// 0:None, 1:Player, 2:Enemy
	public var owner:Int = 0;

	
	// This is set directly from the manager
	var manager:BulletManager;
	
	var _chase:Bool = false;
	var _timer:Float = 0;
	var _phasing:Bool = false; // Go through walls
	
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
		setFacingFlip(FlxObject.LEFT, true, false);
		setFacingFlip(FlxObject.RIGHT, false, false);
		facing = FlxObject.RIGHT;
	}//---------------------------------------------------;
	
	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		
		if (_chase)
		{
			var r1 = FlxAngle.angleBetween(this, Reg.st.player);
			velocity.x = Reg.P.en_bl_speed * Math.cos(r1);
			velocity.y = Reg.P.en_bl_speed * Math.sin(r1);
			
			if ((_timer += elapsed) >= JITTER_TIME)
			{
				_timer -= 0;
				x += FlxG.random.int( -JITTER_PIX, JITTER_PIX);
				y += FlxG.random.int( -JITTER_PIX, JITTER_PIX);
			}
		}
		
		if (Reg.st.map.isOffRoom(this))
		{
			manager.killBullet(this);
		}
	}//---------------------------------------------------;
	
}//--