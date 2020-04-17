/**
	
	FUTURE KNIGHT ITEM
	===================
	
	== Graphics:
		Size = 20x20 
		Total = 12
		
	- Bouncing up and down using a very simple sin() on the y axis

**/


package gamesprites;

import djFlixel.D;
import djfl.util.TiledMap.TiledObject;
import flixel.FlxSprite;



class Item extends MapSprite
{
	inline static var BOUNCE = 2; // pixels bounce
	inline static var STEP = 0.12;
	
	public var item_id:Int = 0;

	var inc:Float = 0;	// Move-Loop counter
	
	// Get an item for use in UI
	public static function getItemSprite(gid:Int = 1):Item
	{
		var i = new Item();
		i.setItemID(gid);
		i.moves = false;
		i.active = false;
		return i;
	}//---------------------------------------------------;
	
	public function new() 
	{
		super();
		Reg.IM.loadGraphic(this, 'items');
	}//---------------------------------------------------;
	
	
	/**
	   Kill this and also remove it from the map
	**/   
	public function killExtra()
	{
		Reg.st.map.killObject(O);
		kill();
	}//---------------------------------------------------;
	
	/** 
	  Set a new item graphic 
	  - separate function because this is used from the inventory also
	  */
	public function setItemID(gid:Int)
	{
		item_id = gid;
		animation.frameIndex = gid - 1;
	}//---------------------------------------------------;
	
	override public function spawn(o:TiledObject, gid:Int):Void 
	{
		super.spawn(o, gid);
		setItemID(gid);
		spawn_origin_set(1);
		spawn_origin_move();
		inc = Math.PI;	// Alter the bouncing starting direction
	}//---------------------------------------------------;
	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		y = -1 + SPAWN_POS.y+ Math.sin(inc) * BOUNCE;
		inc += STEP;
	}//---------------------------------------------------;
	
}// --