
/** --------------------------------------------------------
	Editor Tiles Infos
	- Describe the tile Indexes that come from the TILED MAPS.
	
   == TILED EXIT PROPERTIES

		-name , is just an ID
		-goto, where to go "mapname,ID"
		req, requirements to unlock, "item:ITEM_ENUM"
		e.g.
		- name = A
		- prop.goto = "level_03:B"
		- prot.req = "item:EXIT_PASS"
		
-------------------------------------------------------- */


package;

enum FG_TILE_TYPE {
	//	SOLID; ; Not needed, all tiles in FG layer are declared as SOLID by default, unless overriden
	SOFT;
	SLIDE_LEFT;
	SLIDE_RIGHT;
	LADDER;
	LADDER_TOP;
	HAZARD_TILE;
}


// - Mostly used in <RoomSprites> , which Class instance to create for each Tile Family Type
enum EDITOR_TILE {
	PLAYER;
	ENEMY;
	ITEM;
	ANIM;	// > This has sub ids. Specifics defined in <AnimatedTile.hx>
	FRIEND;
}



class MapTiles
{
	
	// TILE ID as they are in the FOREGROUND layer
	// Every MAP_TYPE has its own set indexes for tiles, thus the array of maps
	// :: "tiletype" => [start_index, range]  | NOTE : RANGE/LENGTH not final index
	public static var TILE_COL(default, null):Array<Map<FG_TILE_TYPE,Array<Int>>> = [
		
		// TYPE (0) : SPACE ::
		
		/// TIP: Place the tile on TILED and rollover it, at the status bar
		///      it is what is says + 1
		[   
			SLIDE_RIGHT => [8, 3],
			SLIDE_LEFT => [11, 3],
			SOFT => [99, 8],
			LADDER_TOP => [107, 2],
			LADDER => [109, 2],
			HAZARD_TILE => [112, 1]
		],
		
		// TYPE (1) : FOREST
		[   
			SOFT => [4, 9],
			LADDER => [15, 6],
			LADDER_TOP => [13, 2],
			HAZARD_TILE => [3, 1],
			//SLIDE_LEFT => [],
			//SLIDE_RIGHT => []
		],
		
		// TYPE (2) : CASTLE
		[   
			SOFT => [5, 12],
			LADDER => [51, 4],
			LADDER_TOP => [49, 2],
			HAZARD_TILE => [2, 1],
			SLIDE_LEFT => [],
			SLIDE_RIGHT => []
		]
	];
	
	
	// Start drawing indexes for the FG layer
	// 2 means that tiles(1) will be skipped. etc
	public static var FG_START_DRAW = [2, 5, 5];
	
	
	// TILE ID as they are in the EditorEntity layer "editor_entity.png"
	// These apply for all MAP_TYPES
	// :: "tiletype" => [start_index, ?range]
	public static var EDITOR_ENTITY(default, null):Map < EDITOR_TILE, Array<Int> > = [
		ENEMY => [1, 20],	// Includes bosses and long enemies
		FRIEND => [24,1],
		PLAYER => [25,1],
		ANIM => [26, 8],	// Animtiles are pushed to <AnimatedTile.hx> and handled from there
		ITEM => [34, 15]
	];
	
	
	// These globals are just for quick reference.
	public static var EDITOR_PLAYER = 25;
	public static var EDITOR_HAZARD = 29;
	public static var EDITOR_EXIT   = 26;
	public static var EDITOR_FINAL  = 15;	// Final Boss
	
	/**
	   From EDITOR_ENTITY.GID index (the index used in TILED editor)
	   => to {type , index} | type is EDITOR_TILE and INDEX starts with 0
	   , reads from 'EDITOR_ENTITY' array
			e.g. GID:26 would translate to {GID:1,TYPE:ANIMATED_TILE}
			     ^ ANIM tiles start at 26, so this is the first (1) ANIMATED_TILE
	   - Called by RoomSprites.spawn()
	   @param	gid Raw Index, Tiled Object GID
	**/
	public static function convert_TiledGID_to_Proper(gid:Int):{type:EDITOR_TILE, gid:Int}
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
		return null;
	}//---------------------------------------------------;
	
	
	/**
	   Checks if a tileID from the collision layer is of a specific type 
	   @param	gid Tile ID to check
	   @param	map MapID, 0:spaceship, 1:forest, 2:dungeon
	   @param	type SOFT; SLIDE_LEFT; SLIDE_RIGHT; LADDER; LADDER_TOP; HAZARD_TILE;
	   @return
	**/
	public inline static function fgTileIsType(gid:Int, map:Int, type:FG_TILE_TYPE):Bool
	{
		return ( 
			 gid >= TILE_COL[map][type][0]  && 
			 gid <  TILE_COL[map][type][0] + TILE_COL[map][type][1]
		);
	}//---------------------------------------------------;
	
}// --