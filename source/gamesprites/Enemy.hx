
/**
 * Future Knight Enemy
 * - Assets loaded from `AssetColorizer.hx`
 * - Movement handles by an AI system check <Enemy_AI.hx>
 * 
 */
 
 
package gamesprites;

import djFlixel.D;
import djfl.util.TiledMap.TiledObject;
import flixel.FlxSprite;
import gamesprites.Enemy_AI;


class Enemy extends MapSprite
{
	// :: Some hard coded
	static inline var ANIM_FPS = 8;
	static inline var ANIM_FRAMES = 2; // Every enemy has 2 frames. In the future I could change it to 3 or 4
	
	static var SPAWNTIME = 3;
	
	var ai:Enemy_AI;
	var _spawnTime:Float;
	
	// --
	public function new() 
	{
		super();
		TW = TH = 24;
	}//---------------------------------------------------;
	
	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		
		if (alive)
		{
			ai.update(elapsed);
		}else
		{
			_spawnTime+= elapsed;
			if ( _spawnTime >= SPAWNTIME)
			{
				respawn();
			}
		}
	}//---------------------------------------------------;

	/**
	   Called from MAIN when the enemy is to be created
	**/
	override public function spawn(o:TiledObject, gid:Int)
	{
		super.spawn(o, gid);
		
		moves = true;
		acceleration.set(0, 0);	// Just in case
		
		// Note : size is reset by <loadgraphic>
		loadGraphic(Reg.COLORIZER.getBitmap(6), true, TW, TH);
		
		// DEV: Previous animations are automatically destroyed upon <loadGraphic>
		animation.add('main', [((gid - 1) * ANIM_FRAMES), ((gid - 1) * ANIM_FRAMES) + 1], ANIM_FPS);
		animation.add('kill', [18, 19, 20, 21], 12, false);
		
		// :: Graphics Fix for some enemies
		switch(gid)
		{
			case 3:	// FLOOR SLIME
				height = 12;
				offset.y = 6;
			case 6:	// BALL
				height = 18;
				offset.y = 4;
			//case a if (a < 9):
			case _:
		}
		
		ai = Enemy_AI.getAI(o.type, this);
		
		respawn();
	}//---------------------------------------------------;
	
	override function respawn() 
	{
		trace("RESPAWN", O.id);
		super.respawn();
		animation.play('main', true);
		ai.enter();
	}//---------------------------------------------------;
	
	
	override public function hurt(Damage:Float):Void 
	{
		softKill();
	}//---------------------------------------------------;
	
	public function softKill()
	{
		trace("Start Counting timer");
		alive = false;
		_spawnTime = 0;
		D.snd.play("en_die");
		animation.play('kill');
		animation.finishCallback = (s)->{
			visible = false;
			trace("Animation End");
		}
	}//---------------------------------------------------;
	
	
	
}// --