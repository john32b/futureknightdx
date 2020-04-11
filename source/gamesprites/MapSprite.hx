package gamesprites;
import djA.types.SimpleCoords;
import djfl.util.TiledMap.TiledObject;
import flixel.FlxObject;
import flixel.FlxSprite;



/**
   
	:: DEV ::
	- Handled by <RoomSprites>
	- Only ENEMIES will call respawn() over and over
**/
class MapSprite extends FlxSprite
{
	// Pointer to Tiled Object Data.
	var O:TiledObject;
	
	// TileWidth, TileHeight. Need to keep it for the size to be restored on respawns
	var TW:Int = 32;
	var TH:Int = 32;
	
	// The original Spawn Coordinates in pixels
	// IF NULL will re-spawn to where it was when it died
	var SPAWN_POS:SimpleCoords;
	
	// This is useful to have or AI calculating walls etc
	// it is the 8x8 tile the sprite belongs to (IN BIG TILES)
	var SPAWN_TILE:SimpleCoords;
	
	// --
	public function new()
	{
		super();
		setFacingFlip(FlxObject.LEFT, true, false);
		setFacingFlip(FlxObject.RIGHT, false, false);
		SPAWN_POS = new SimpleCoords();
	}//---------------------------------------------------;
	
	// --
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
	// - Call this MANUALLY at spawn() to place this
	function respawn()
	{
		if (SPAWN_POS != null)
		{
			x = SPAWN_POS.x;
			y = SPAWN_POS.y;
			last.x = x;
			last.y = y;
		}
		// (if null) it is for enemies that should not return to their spawn points when regenerated
		
		alive = true;
		visible = true;
	}//---------------------------------------------------;
	
	
	
	/**
	   - YOU MUST CALL THIS on every sprite you create
	   Write to the spawn origin var. To be read in respawn() 
	   @param	type 0:Center, 1:Floor
	   @return If FLOOR returns the FLOOR Y TILE (hacky but I need it)
	**/
	function set_spawn_origin(type:Int):Int
	{
		// The top left tile of the 32tile in 8pixel tile dimensions
		SPAWN_TILE = new SimpleCoords(Std.int(O.x / 32) * 4 , Std.int(O.y / 32) * 4);
		
		SPAWN_POS.x = Std.int((SPAWN_TILE.x * 8) + ((32 - width) / 2));
		
		if (type == 1)
		{
			var floory = Game.map.getFloor(SPAWN_TILE.x, SPAWN_TILE.y);
			if (floory >= 0) {
				SPAWN_POS.y = (floory * 8) - Std.int(height);
				return floory;
			}else{
				trace("Error: Floor not found for entity", O);
			}
		}
		
		// Either type0 or did not find any floor, so center it ::
		
		SPAWN_POS.y = Std.int((SPAWN_TILE.y * 8) + ((32 - height) / 2));
		return 0;
	}//---------------------------------------------------;

}// --