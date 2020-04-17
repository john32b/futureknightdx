/*

== Future Knight Particles
======================================

	- Particles do not collide with anything
	- Manages sprites from a single image source
	- Note: Sprites are (22x24) size
	
---------------------------------------------  */

package;

import djFlixel.D;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;



class ParticleManager extends FlxGroup
{
	inline static var POOL_MIN = 1; // Keep this much bullets when resetting
	inline public static var halfWidth = 11;
	inline public static var halfHeight = 12;
	
	/** Kill all bullets and remove them. keep (POOL_MIN) */
	public function reset()
	{
		D.dest.groupKeep(this, POOL_MIN);
	}//---------------------------------------------------;

	// Quickly kill all particles, but not group itself
	override public function kill():Void 
	{
		super.kill();
		alive = true;	// If I don't do this, then the group will not be drawn/rendered
		exists = true;
	}//---------------------------------------------------;
	/**
	   Place a particle at CENTER POINT x,y
	   @param	type 0:Enemy Explosion, 1:Bullet Explosion
	   @param	x
	   @param	y
	   @param	vx
	   @param	vy
	**/
	public function createAt(type:Int, x:Float, y:Float, vx:Float = 0, vy:Float = 0)
	{
		var s:FlxSprite = cast recycle(FlxSprite, factory);
		s.velocity.set(vx, vy);
		
		// Center by default
		s.x = x - halfWidth;
		s.y = y - halfHeight;
		
		s.animation.play('$type', true);
		s.animation.finishCallback = (name)->{
			s.kill();
		}
	}//---------------------------------------------------;
	
	public static function factory():FlxSprite
	{
		var s = new FlxSprite();
		Reg.IM.loadGraphic(s, 'particles');
		s.animation.add("0", [0, 1, 2, 3], 8, false);
		s.animation.add("1", [4, 5, 6, 4, 5, 6], 10, false);
		s.solid = false;
		s.acceleration.y = Reg.P.gravity / 5;
		// NOTE: IN the 2015 version I had gravity set to (GLOBAL_GRAVITY/2)
		//		 by 5 feels better
		return s;
	}//---------------------------------------------------;
	
}// --


