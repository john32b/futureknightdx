/*

== Future Knight Particles
======================================

	- Particles do not collide with anything
	- Manages sprites from a single image source
	- Note: Sprites are (22x24) size
	
---------------------------------------------  */

package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;



class ParticleManager extends FlxGroup
{
	inline static var FPS = 8;
	inline public static var halfWidth = 11;
	inline public static var halfHeight = 12;
	
	
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
		s.animation.add("0", [0, 1, 2, 3], FPS, false);
		s.animation.add("1", [4, 5, 6, 4, 5, 6], FPS, false);
		s.solid = false;
		return s;
	}//---------------------------------------------------;
	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		
		#if debug
		if (FlxG.mouse.justPressed && FlxG.keys.pressed.ONE) {
			createAt(0, FlxG.mouse.x, FlxG.mouse.y, 0, 0);
		}
		#end
	}//---------------------------------------------------;
	
}// --


