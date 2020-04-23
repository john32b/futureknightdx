
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


// - Mostly used in <RoomSprites> , which Class instance to create at each tile type
enum EDITOR_TILE {
	PLAYER;
	ENEMY;
	ITEM;
	ANIM;	// > This has sub ids. Specifics defined in <AnimatedTile.hx>
}






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
			HAZARD_TILE => [30, 1]
		],
		
		// TYPE (1) : FOREST
		[   
			SOFT => [2, 10],
			SLIDE_LEFT => [1, 1],
			SLIDE_RIGHT => [1, 1],
			LADDER => [1, 1],
			LADDER_TOP => [1, 1],
			HAZARD_TILE => [-1]	// no hazard tiles there
		]
		
		// TYPE (2) : CASTLE
	];
	
	
	
	// TILE ID as they are in the EditorEntity layer
	// These apply for all MAP_TYPES
	// :: "tiletype" => [start_index, ?range]
	public static var EDITOR_ENTITY(default, null):Map < EDITOR_TILE, Array<Int> > = [
		ENEMY => [1,20],
		PLAYER => [25, 1],
		ANIM => [26, 6],	// Animtiles will pused in <AnimatedTile.hx> and handled from there
		ITEM => [34, 12]
	];
	
	
	// Also declare these for easy access.
	// ^ they are included in `EDUTOR_ENTITY` but I need it here as well
	public static var EDITOR_HAZARD = 29;
	public static var EDITOR_EXIT   = 26;
	
	
	/**
	   From EDITOR_ENTITY.PNG index (the index used in TILED editor)
	   => to {type , index} type is EDITOR_ENUM and index starts with 0
	   , read from 'EDITOR_ENTITY' array
	   e.g. GID:100 would translate to {GID:1,TYPE:ANIMATED_TILE}
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