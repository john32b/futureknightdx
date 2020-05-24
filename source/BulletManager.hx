/**
	
  FUTURE KNIGHT BULLETS
  ======================================
  - Player bullets and Enemy bullets
  - Everything bullet related
  - All graphics from a single tilesheet
  - Graphic size (20x20);

  
  NOTES:
	- All bullets auto kill when off screen
	- Get 'Player.bullet_type' for the current bullet type
	- Sound when colliding with the MAP
-------------------------------------------------------------------*/


package;
import djFlixel.D;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.group.FlxGroup;
import flixel.tile.FlxTile;
import gamesprites.Bullet;

 

class BulletManager extends FlxGroup
{
	inline static var POOL_MIN = 3; // Keep this much bullets when resetting
	
	// Every bullet type what color is it, 
	// This is passed to the particle it creates on impact
	static var BULLET_COLORS:Array<String> = [
		'blue', 'red', 'green', 'yellow', 'yellow'
	];
	
	// Number of player bullets on screen
	// I need this because there is a limit to how many are allowed.
	public var count_player = 0;

	// Hack, check for bullets/wall collision every other update.
	var _halfUpdate:Bool = true;
	
	// Kill all bullets and remove them. keep (POOL_MIN)
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
	public function createAt(TYPE:Int, X:Float, Y:Float, FACE:Int):Bool
	{
		if (TYPE <= 2) // Player bullet, check
		{
			if (count_player >= Bullet.TYPES[Reg.st.player.bullet_type].maxscreen)
			{
				return false;
			}
			
			count_player++;
		}
		
		var b:Bullet = cast recycle(Bullet);
			b.init(TYPE, X, Y, FACE);
			b.manager = this;
		return true;
	}//---------------------------------------------------;

	
	/** Remove the bullet, Optionally create a particle where it died */
	public function killBullet(b:Bullet, particle:Bool = false)
	{
		b.kill();
		if (b.owner == Bullet.OWNER_PLAYER) count_player--;
		if (particle) {
			Reg.st.PM.createAt(1, b.x + Bullet.halfWidth, b.y + Bullet.halfHeight, 0, 0, BULLET_COLORS[b.type]);
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
					Reg.st.map.layerCol().overlapsWithCallback(cast b, cast _collideMap);
			}
		}
	}//---------------------------------------------------;
	
	
	function _collideMap(A:FlxTile, B:Bullet):Bool
	{
		if (B._phasing || !B.alive) return false;
		if (A.allowCollisions == FlxObject.ANY) {
			killBullet(B, true);
			D.snd.play(Bullet.SND.wall, 0.8);
			return true;
		}
		return false;	
	}//---------------------------------------------------;
	
	
}// --






