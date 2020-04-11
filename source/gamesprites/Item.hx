package gamesprites;
import djFlixel.D;
import djfl.util.TiledMap.TiledObject;
import flixel.FlxSprite;

/**
 * ...
 */
class Item extends MapSprite
{

	public function new() 
	{
		super();
		TW = TH = 20;
		loadGraphic(Reg.IM.items, true, 20, 20);
		
	}//---------------------------------------------------;
	
	
	override public function spawn(o:TiledObject, gid:Int):Void 
	{
		super.spawn(o, gid);
		animation.frameIndex = Std.random(5);
		set_spawn_origin(1);
		respawn();
	}//---------------------------------------------------;
	
}