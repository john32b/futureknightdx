/**
	
 FUTURE KNIGHT GENERIC MAP SPRITE
 ===========================
 - Item
 - Hazard
 - Decorative
 
 - Handled by <RoomSprites>

**/


package gamesprites;
import djA.types.SimpleCoords;
import djfl.util.TiledMap.TiledObject;
import flixel.FlxObject;
import flixel.FlxSprite;



class MapSprite extends FlxSprite
{
	// Pointer to Tiled Object Data.
	public var O(default, null):TiledObject;
	
	// The original Spawn Coordinates in pixels
	// IF NULL will re-spawn to where it was when it died
	var SPAWN_POS:SimpleCoords;
	
	// This is useful to have or AI calculating walls etc
	// it is the 8x8 tile the sprite belongs to
	var SPAWN_TILE:SimpleCoords;
	
	// --
	public function new()
	{
		super();
		setFacingFlip(FlxObject.LEFT, true, false);
		setFacingFlip(FlxObject.RIGHT, false, false);
	}//---------------------------------------------------;
	
	// --
	// This is called by a manager when this item is created.
	public function spawn(o:TiledObject, gid:Int):Void
	{
		O = o;
		// In case there were altered I am resetting
		velocity.set(0, 0);
		acceleration.set(0, 0);
		offset.set(0, 0);
		moves = false;
	}//---------------------------------------------------;
	
	
	// - Properly places the sprite in the map based on SpawnData
	// - This is a separate function because some <Enemy> objects call it over and over when they respawn
	function spawn_origin_move()
	{
		// Dev: I need the null check because some enemies null this
		if (SPAWN_POS != null)
		{
			x = SPAWN_POS.x;
			y = SPAWN_POS.y;
			last.x = x;
			last.y = y;
		}
	}//---------------------------------------------------;
	
	
	/**
	   Based on TILEDDATA of this object, set the SPAWN ORIGIN point of a sprite to:
		- the Center of the BIG TILE (32x32 pixel based)
		- the nearest floor (x is first fixed to the 32x32 tile)
	   @param	type 0:Center, 1:Floor
	   @return  If (type==1) returns the FLOOR Y TILE it landed on
	**/
	function spawn_origin_set(type:Int):Int
	{
		// DEV: Remember O.x.y are the MIDDLE of the sprite
		
		// The top left tile of the 32tile in 8pixel tile dimensions
		SPAWN_TILE = new SimpleCoords(Std.int(O.x / 32) * 4, Std.int(O.y / 32) * 4);
		
		SPAWN_POS = new SimpleCoords(
						Std.int((SPAWN_TILE.x * 8) + ((32 - width) / 2)),
						Std.int((SPAWN_TILE.y * 8) + ((32 - height) / 2)) );
			
		if (type == 1)
		{
			var floory = Reg.st.map.getFloor(SPAWN_TILE.x + 2, SPAWN_TILE.y + 1);
			if (floory >= 0) {
				SPAWN_POS.y = (floory * 8) - Std.int(height);
				return floory;
			}else{
				trace("Error: Floor not found for entity", O);
			}
		}
		
		// Either type0 or did not find any floor, so center it ::
		return 0;
	}//---------------------------------------------------;

}// --