/**
	
  FUTURE KNIGHT BULLETS
  ======================================
  - Player bullets and Enemy bullets
  - All graphics from a single tilesheet
  - Graphic size (20x20);

*/


package;
import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.group.FlxGroup;
import flixel.FlxSprite;




class BulletManager extends FlxGroup
{
	
	public static var POOL_MIN = 2; // Keep this much bullets when resetting
	
	/**
	   Kill all bullets and remove them.
	**/
	public function reset()
	{
		var keep:Array<FlxBasic> = [];
		
		for (i in members) {
			i.kill();
			if (keep.length < POOL_MIN) {
				keep.push(i);
				trace("adding a bullet to keep");
			}else{
				i.destroy();
				trace(" -- destroying");
			}
		}
		
		clear(); // remove all
		
		for (i in keep) add(i); // add the ones I kept
		
		trace("NEW LEN", length);
	}//---------------------------------------------------;
	

	public function createAt(type:Int, x:Float, y:Float, vx:Float = 0, vy:Float = 0)
	{
		var b:Bullet = cast recycle(Bullet);
		b.x = x - Bullet.halfWidth;
		b.y = y - Bullet.halfHeight;
		b.velocity.set(vx, vy);
		b.animation.play('p1');
		
		trace("Created Bullet, new group len", length);
	}//---------------------------------------------------;
	
	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		#if debug
		if (FlxG.mouse.justPressed && FlxG.keys.pressed.TWO) {
			createAt(0, FlxG.mouse.x, FlxG.mouse.y, 60, 0);
		}
	
		if (FlxG.keys.justPressed.M)
		{
			reset();
		}
		
		#end
	}//---------------------------------------------------;
}// --




/**
   Graphic Notes
   - All bullets face right
   - 20x20 
   - effective area around 5x5
**/
class Bullet extends FlxSprite
{
	inline static var FPS = 10;
	inline public static var halfWidth = 2;	// bullet game size is 5x5
	inline public static var halfHeight = 2;
		
	public function new()
	{
		super();
		Reg.IM.loadGraphic(this, "bullets");
		animation.add("p1", [0, 1], FPS);
		animation.add("p2", [2, 3], FPS);
		animation.add("p3", [4, 5], FPS);
		animation.add("e1", [6, 7], FPS);
		animation.add("e2", [8, 9], FPS);
		setSize(5, 5);
		centerOffsets();
		setFacingFlip(FlxObject.LEFT, true, false);
		setFacingFlip(FlxObject.RIGHT, false, false);
		facing = FlxObject.RIGHT;
	}//---------------------------------------------------;
	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		if (Reg.st.map.isOffRoom(this))
		{
			trace("BULLET OFF SCREEN, killing");
			kill();
		}
	}//---------------------------------------------------;
	
}//--