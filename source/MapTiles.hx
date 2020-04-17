
/**
	Editor Tiles Infos
	- Describe the tile Indexes that come from the TILED MAPS.
**/


package;

enum FG_TILE_TYPE {
	//	SOLID; ; Not needed, all tiles in FG layer are declared as SOLID by default, unless overriden
	SOFT;
	SLIDE_LEFT;
	SLIDE_RIGHT;
	LADDER;
	LADDER_TOP;
	HAZARDTILE;
}


// - Mostly used in <RoomSprites> , which Class instance to create at each tile type
enum EDITOR_TILE {
	PLAYER;
	ENEMY;
	ITEM;
	ANIM;
	HAZARD;
}


// This is ALSO the itemID as it is on the EDITOR
enum abstract ITEM_TYPE(Int)
{
	var NONE; // 0
	var SAFE_PASS;
	var BOMB;
	var PLATFORM_KEY;
	var CONFUSER_UNIT;
	var SECURO_KEY;
	var EXIT_PASS;
	var BRIDGE_SPELL;
	var SHORTERNER_SPELL;
	var FLASH_BANG_SPELL;
	var GLOVE;
	var RELEASE_SPELL;
	var DESTRUCT_SPELL;
}//---------------------------------------------------;


class MapTiles
{
	
	// TILE ID as they are in the FOREGROUND layer
	// Every MAP_TYPE has its own set indexes for tiles, thus the array of maps
	// :: "tiletype" => [start_index, range]  | NOTE : RANGE/LENGTH not final index
	public static var TILE_COL(default, null):Array<Map<FG_TILE_TYPE,Array<Int>>> = [
		
		// TYPE (0) : SPACE ::
		/// TIP: What tiled editor says + 1, or look at the JSON
		[   
			SLIDE_RIGHT => [15, 3],
			SLIDE_LEFT => [18, 3],
			SOFT => [21, 4],
			LADDER_TOP => [26, 2],
			LADDER => [28, 2],
			HAZARDTILE => [30, 1]
		],
		
		// TYPE (1) : FOREST
		[   
			SOFT => [2, 10],
			SLIDE_LEFT => [1, 1],
			SLIDE_RIGHT => [1, 1],
			LADDER => [1, 1],
			LADDER_TOP => [1, 1],
			HAZARDTILE => [-1]	// no hazard tiles there
		]
		// TYPE (2) : CASTLE
	];
	
	
	
	// TILE ID as they are in the EditorEntity layer
	// These apply for all MAP_TYPES
	// :: "tiletype" => [start_index, ?range]
	public static var EDITOR_ENTITY(default, null):Map < EDITOR_TILE, Array<Int> > = [
		ENEMY => [1,20],
		PLAYER => [25, 1],
		ANIM => [26, 6],
		HAZARD => [29,1],	// Declare it again
		ITEM => [34, 12]
	];
	
	
	
	
	
	
	
	
	
	
	//====================================================;
	
	
	/**
	   From EDITOR_ENTITY.PNG index (the index used in TILED editor)
	   => to {type , index} type is EDITOR_ENUM and index starts with 0
	   , read from 'EDITOR_ENTITY' array
	   @param	gid As it is on the Tled Object GID
	**/
	   
	public static function translateEditorEntity(gid:Int):{type:EDITOR_TILE, gid:Int}
	{
		for (k => v in EDITOR_ENTITY)
		{
			if (gid >= v[0] && gid < (v[0] + v[1]))
			{
				return {
					type:k,
					gid:gid - v[0] + 1
				};
			}
		}
		
		throw 'ERROR. Editor Tile with gid $gid, IS NOT DEFINED';
		return null;
	}//---------------------------------------------------;
	
}// --