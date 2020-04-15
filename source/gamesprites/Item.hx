/**
	
	FUTURE KNIGHT ITEM
	===================
	
	== Graphics:
		Size = 20x20 
		Total = 12

**/

package gamesprites;
import djFlixel.D;
import djfl.util.TiledMap.TiledObject;
import flixel.FlxSprite;

class Item extends MapSprite
{

	public function new() 
	{
		super();
		Reg.IM.loadGraphic(this, 'items');
	}//---------------------------------------------------;
	
	override public function spawn(o:TiledObject, gid:Int):Void 
	{
		super.spawn(o, gid);
		animation.frameIndex = gid - 1;
		spawn_origin_set(1);
		spawn_origin_move();
	}//---------------------------------------------------;
	
}// --