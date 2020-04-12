/**
	FUTURE KNIGHT MAP OBJECT
	========================
	
	
	- Loads and Creates the TileMap
	- Handles camera scrolling
	- Reads room entities and pushes them to user for creation
	- Follows Player (from Game.player global) and scrolls rooms
	- Offers some tile checks functions to be used from Sprites
	
	
	DEBUG:
	========
	
	- Press (SHIFT + DIRECTION) to scroll to new rooms
	- Press (SHIFT + MOUSE) to position player
	
	
**/


package;

import MapTiles.FG_TILE_TYPE;
import MapTiles.EDITOR_TILE;

import tools.TilemapGeneric;
import gamesprites.Player;

import djA.types.SimpleCoords;
import djfl.util.TiledMap.TiledObject;
import djFlixel.D;
import djFlixel.core.Dcontrols.DButton;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.tile.FlxTilemap;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.tweens.misc.VarTween;


enum MapEvent 
{
	scrollStart;
	scrollEnd;
	roomEntities(v:Array<TiledObject>);	// Pushes ALL tiledObject the room has, even player
	loadMap;
}


class MapFK extends TilemapGeneric
{
	// :: No not touch
	static inline var MAP_SPACE = 0;
	static inline var MAP_FOREST = 1;
	static inline var MAP_CASTLE = 2;
	static inline var TILE_SIZE = 8;
	
	// The layer names as declared in TILED 
	static inline var LAYER_BG 			= 'Background';
	static inline var LAYER_PLATFORM 	= 'Platforms';
	static inline var LAYER_ENTITIES 	= 'Entities';
	
	// DEV: 8 BIG tiles (easier to grasp) Every big tile is 4 normal tiles
	inline static var ROOM_TILE_WIDTH:Int  = 8 * 4;	// How many tiles make up a room view
	inline static var ROOM_TILE_HEIGHT:Int = 4 * 4;	// How many tiles make up a room view
	
	/// CHANGE THESE TWO:
	static inline var DRAW_START_X:Int = 32;  	// Pixels from screen left to draw map
	static inline var DRAW_START_Y:Int = 20;  	// Pixels from screen top to draw map
	
	/// CHANGE THIS OR MAKE IT INLINE?
	// :: CAMERA
	static var CAMERA_TRANSITION_TIME = 0.2;
	static var CAMERA_EASE:EaseFunction = FlxEase.quintIn;
	
	public var ROOM_WIDTH  = TILE_SIZE * ROOM_TILE_WIDTH; 
	public var ROOM_HEIGHT = TILE_SIZE * ROOM_TILE_HEIGHT; 
	
	// #USER SET, MUST BE SET
	public var onEvent:MapEvent->Void;
	
	// How many rooms on the x/y axis
	public var roomTotal(default, null):SimpleCoords;
	// Current room the camera is in. STARTING from (0,0) for the top-left
	public var roomCurrent(default, null):SimpleCoords;
	// Current room tile coordinets of top left corner. Useful in enemy AI tile collisions
	public var roomCornerTile(default, null):SimpleCoords;
	// Current room pixel coordinates of the top left corner.
	public var roomCornerPixel(default, null):SimpleCoords;
	
	// Pixel Coordinates of the player
	public var PLAYER_SPAWN(default, null):SimpleCoords;
	
	var tweenCamera:VarTween;
	
	// Set this to load the appropriate BG+FG Tiles
	var MAP_TYPE = 0;
	var MAP_NAME = "";
	//====================================================;
	
	public function new() 
	{
		super(2);	// Two layers, BG and Platforms
		
		setCameraViewport(DRAW_START_X, DRAW_START_Y, ROOM_WIDTH, ROOM_HEIGHT);
		
		roomTotal = new SimpleCoords();
		roomCurrent = new SimpleCoords();
		roomCornerTile = new SimpleCoords();
		roomCornerPixel = new SimpleCoords();
		
		_tiledParams = {
			object_tiles_to_center_points:true
		}
		
		// DEV:
		var CPAR = Reg.INI.getObjEx("room_camera");
		CAMERA_EASE = Reflect.field(FlxEase, CPAR.ease);
		CAMERA_TRANSITION_TIME = CPAR.time;	
	}//---------------------------------------------------;
	

	override public function load(s:String) 
	{
		// :: Init:
		// It was scrolling -- not supposed to -- but check anyway
		if (tweenCamera != null) {tweenCamera.cancel(); tweenCamera = null; }	
		
		super.load(s);
		
		MAP_TYPE = T.properties.TYPE;
		MAP_NAME = T.properties.NAME;
		
		 _scanProcessTiles();	// <- Read FG tiles

		layers[0].loadMapFromArray(T.getLayer(LAYER_BG), T.mapW, T.mapH,
			Reg.COLORIZER.getBitmap((MAP_TYPE * 2), 0),
			T.tileW, T.tileH, null, 1, 1, 1);
			
		layers[1].loadMapFromArray(T.getLayer(LAYER_PLATFORM), T.mapW, T.mapH,
			Reg.COLORIZER.getBitmap((MAP_TYPE * 2) + 1, 0),
			T.tileW, T.tileH, null, 1, 2, 1);
			
		_setTileProperties();	// <- Declare tile collision properties
		
		_scanProcessEntities();	// <- Figure out exits and player spawn points
		
		// -- Init POST things,
		roomTotal.set(Math.floor(T.mapW / ROOM_TILE_WIDTH), Math.floor(T.mapH / ROOM_TILE_HEIGHT));
		roomCurrent.set( -1, -1);	// -1 allows it to be inited later when requested to go to 0,0
		
		onEvent(MapEvent.loadMap);	// DEV: Purpose is for user to de-init all entities
		
		// DEV:
		// loadMap-> User should check for PLAYER spawn or EXIT POINTS and move camera
		
		// INFO and DEV CHECKS ------
		#if debug
			trace(' -- Loaded Map "$s"');
			trace(' TYPE: $MAP_TYPE, NAME: $MAP_NAME');
			trace(' . MAP : Rooms Total ' , roomTotal);
			trace(' . MAP : Rooms Current ' , roomCurrent);
			T.debug_info();
			trace('-------------------------------');
		#end
	}//---------------------------------------------------;
	
	
	// -- Call this to push to user
	function roomcurrent_pushEntities()
	{
		var batch = get_objectTilesAt(LAYER_ENTITIES, roomCurrent.x  * ROOM_WIDTH, roomCurrent.y * ROOM_HEIGHT, ROOM_WIDTH, ROOM_HEIGHT);
		onEvent(MapEvent.roomEntities(batch));	// Pushes out to user the new entities of the new room
	}//---------------------------------------------------;
	
	/**
	   - Set roomCurrent var
	   @param	x Room Coords, 0 index
	   @param	y Room Coords, 0 index
	   @return
	**/
	function roomcurrent_set(x:Int, y:Int):Bool
	{
		if (x < 0) x = 0; else if(x>=roomTotal.x) x=roomTotal.x-1;
		if (y < 0) y = 0; else if(y>=roomTotal.y) y=roomTotal.y-1;
		if (roomCurrent.isEqualWith(x, y)) return false;	// Already there
		roomCurrent.set(x, y);
		roomCornerTile.set(ROOM_TILE_WIDTH * x, ROOM_TILE_HEIGHT * y);
		roomCornerPixel.set(roomCurrent.x * ROOM_WIDTH, roomCurrent.y * ROOM_HEIGHT);
		return true;
	}//---------------------------------------------------;
	
	
	
	/**
	   Move camera to the room position containing a (X,Y) coords
	**/
	public function camera_teleport_to_room_containing(x:Float, y:Float)
	{
		camera_teleport_to_room(Std.int(x / ROOM_WIDTH), Std.int(y / ROOM_HEIGHT));
	}//---------------------------------------------------;
	
	/**
		Snap Camera to ROOM COORDINATES. (0,0) for top left room
	*/
	public function camera_teleport_to_room(x:Int, y:Int)
	{
		if (roomcurrent_set(x, y))
		{
			camera.scroll.set( roomCurrent.x * ROOM_WIDTH, roomCurrent.y * ROOM_HEIGHT);
			roomcurrent_pushEntities();
		}
	}//---------------------------------------------------;
	
	
	/**
	   Scroll camera to RELATIVE ROOM COORDINATES
	   (1,0) will move 1 to the right. (0,-1) will move one above
	**/
	public function camera_move_rel(x:Int = 0, y:Int = 0):Bool
	{
		if (roomcurrent_set(roomCurrent.x + x, roomCurrent.y + y))
		{
			if (tweenCamera != null){
				tweenCamera.cancel();
			}
			onEvent(MapEvent.scrollStart);
			roomcurrent_pushEntities();
			tweenCamera = FlxTween.tween(camera.scroll, {
				x:roomCurrent.x * ROOM_WIDTH,
				y:roomCurrent.y * ROOM_HEIGHT,
			}, CAMERA_TRANSITION_TIME, {
				ease:CAMERA_EASE,
				onComplete:_on_camera_tween_end
			});
			return true;
		}
		return false;
	}//---------------------------------------------------;
	
	
	
	function _on_camera_tween_end(t:FlxTween)
	{
		tweenCamera = null;
		onEvent(MapEvent.scrollEnd);
		
		#if debug
			// Place player
			if (!Game.player.alive)
			{
				for (tx in 0...ROOM_TILE_WIDTH)
				for (ty in 0...ROOM_TILE_HEIGHT)
				{
					if (getCol(roomCornerTile.x + tx, roomCornerTile.y + ty) == 0)
					{
						Game.player.spawn((roomCornerTile.x + tx) * TILE_SIZE, (roomCornerTile.y + ty) * TILE_SIZE);
						return;
					}
				}
			}
		#end
		
		// DEV:
		// User responsible to freeeze/unfreeze, kill/reapawn
	}//---------------------------------------------------;

	
	
	// -- Called after loading the map and before creating the map
	// Mainly used for translating "HAZARD" fg tiles to Entities so that they can be pushed as entities to user
	// I can skip this and make all hazards live in editor only?
	@:dce
	function _scanProcessTiles()
	{
		// :: SPECIAL OCCASION
		//  - Convert HAZARD tiles from FG layer to be entities
		//  - This is done for easier map designing?
		//  - IMPORTANT Requires hazard tiles to be in x4 groups
		var data = T.getLayer(LAYER_PLATFORM);
		var hazardIndex = MapTiles.TILE_COL[MAP_TYPE][HAZARDTILE][0];
		var i = 0;
		while (i < data.length)
		{
			if (data[i] == hazardIndex) {
				// Create a new TiledObject, put it along the others
				var coords = serialToTileCoords(i);
				T.objects[0].push({
					x:coords.x * T.tileW,
					y:coords.y * T.tileH,
					id:hazardIndex,	// This does not matter right now. So I am putting whatever
					gid:MapTiles.EDITOR_ENTITY[HAZARD][0]
				});
				// Delete the actual tiles
				// DEV: This is fine since the map is read left to right
				data[i]   = 0; 
				data[i+1] = 0;
				data[i+2] = 0;
				data[i+3] = 0;
			}
			i += 4;
		}
	}//---------------------------------------------------;
	
	
	
	
	// -- Scan the room for entities and process them
	// Mainly for <player spawn>
	function _scanProcessEntities()
	{
		PLAYER_SPAWN = null;
		var player_gid = MapTiles.EDITOR_ENTITY[PLAYER][0];
		for (i in T.getObjLayer(LAYER_ENTITIES))
		{
			if (i.gid == player_gid)
			{
				PLAYER_SPAWN = new SimpleCoords(cast i.x, cast i.y);
				break;	// no need to scan for anything else
			}
		}
	}//---------------------------------------------------;
		
	
	// -- Declare tile collision data to tiles in the foreground player
	function _setTileProperties()
	{
		var m = layers[COLLISION_LAYER];
		var C = MapTiles.TILE_COL[MAP_TYPE];		
		// DEV: Declaring SOLIDS is not needed, everytile is solid by default
		m.setTileProperties(C[SOFT][0], FlxObject.CEILING, null, null, C[SOFT][1]);
		m.setTileProperties(C[LADDER][0], FlxObject.NONE, null, null, C[LADDER][1]);
		m.setTileProperties(C[LADDER_TOP][0], FlxObject.CEILING, null, null, C[LADDER_TOP][1]);
		m.setTileProperties(C[SLIDE_LEFT][0], FlxObject.ANY, _tilecol_slide_left, null, C[SLIDE_LEFT][1]);
		m.setTileProperties(C[SLIDE_RIGHT][0], FlxObject.ANY, _tilecol_slide_right, null, C[SLIDE_RIGHT][1]);
		//m.setTileProperties(C[HAZARDTILE][0], FlxObject.NONE, _tilecol_hazard, null, C[HAZARDTILE][1]);
	}//---------------------------------------------------;
	
	
	// DEV: Two versions of <_tilecol_slide> because I don't want to recalculate (LEFT/RIGHT) later
	// -- Send player a slide collision event
	function _tilecol_slide_left(a:FlxObject,b:FlxObject)
	{
		if (Std.is(b, Player)) {
			var t = cast (a, flixel.tile.FlxTile);
			Game.player.event_slide_tile(cast a, FlxObject.LEFT);
		}
	}//---------------------------------------------------;
	function _tilecol_slide_right(a:FlxObject,b:FlxObject)
	{
		if (Std.is(b, Player)) {
			var t = cast (a, flixel.tile.FlxTile);
			Game.player.event_slide_tile(cast a, FlxObject.RIGHT);
		}
	}//---------------------------------------------------;	
	
	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
	
		// The camera is currently scrolling.
		if (tweenCamera != null) return;
		
		#if debug
			_update_debug();
			if (!Game.player.alive) return;	// Do not track player for debug purposes
		#end
		
		// HARD_CODED Padding
		if (Game.player.x + 4 > roomCornerPixel.x + ROOM_WIDTH){
			camera_move_rel(1, 0);
		}else
		if (Game.player.x + 4 < roomCornerPixel.x){
			camera_move_rel( -1, 0);
		}else
		if (Game.player.y + 8 > roomCornerPixel.y + ROOM_HEIGHT){
			camera_move_rel(0, 1);
		}else
		if (Game.player.y + 8 < roomCornerPixel.y){
			camera_move_rel(0, -1);
		}
		
	}//---------------------------------------------------;
	
	
	/** Return Y for floor, -1 if not found */
	public function getFloor(x:Int, y:Int):Int
	{
		// Max Search = (8) tiles down
		for (i in 0...8) {
			var y1 = y + i;
			var t = layers[1].getTile(x, y1);	// No check is needed?
			if (t > 0 && (layers[1].getTileCollisions(t) & FlxObject.ANY > 0))
			{
				return y1;
			}
		}
		return -1;	// nothing found
	}//---------------------------------------------------;
	
	
	
	/**
	   Double (2) Ray Cast (casts left-right, or up-down)
	   Cast rays in the tilemap Horizontal, or Vertical, stopping at Any Tile Collision or Empty Tile (CHECK)
	   Useful to calculate The Edges of a platform or the Empty area between walls
	   Also checks for ROOM screen borders and limits inside them
	   @param X In 8x8 tile coords
	   @param Y In 8x8 tile coords
	   @param AxisX True to check for X axis, false to check for Y axis
	   @param CHECK 0 to check Until no Tile, 1 to check Until Any Collision Tile
	   @return {v0,v1} Minimum Maximum
	 */
	/// DEV: This is almost ready to be put on the generic class.
	///		  Need to  room limits into consideration? Make it optional or whatever.
	public function get2RayCast(X:Int, Y:Int, AxisX:Bool = true, CHECK:Int = 0)
	{
		var o = {v0:0, v1:0};
		var B0 = AxisX?roomCornerTile.x:roomCornerTile.y;
		var B1 = AxisX?roomCornerTile.x + ROOM_TILE_WIDTH:roomCornerTile.y + ROOM_TILE_HEIGHT;
		var xx = X;
		var yy = Y;
		var v = 0;
		var i = 1;
		while (true) // Check RIGHT/DOWN
		{
			if (AxisX) v = xx = X + i; else v = yy = Y + i;
			var t = getCol(xx, yy);
			if ((v >= B1) || ( CHECK == 0?t == 0:t > 0)) {
				o.v1 = v; break;
			} i++;
		}	
		
		i = 1; while (true) // Check LEFT/UP
		{
			if (AxisX) v = xx = X - i; else v = yy = Y - i;
			var t = getCol(xx, yy);
			if ((v < B0) || ( CHECK == 0?t == 0:t > 0) ) {
				o.v0 = v + 1; break;
			} i++;
		}
		
		return o;
	}//---------------------------------------------------;
	
	
	/** Get the ENUM type of an FG tile */
	public function tileIsType(id:Int, type:FG_TILE_TYPE):Bool
	{
		var AR = MapTiles.TILE_COL[MAP_TYPE].get(type);
		return (id >= AR[0] && id < AR[0] + AR[1]);
	}//---------------------------------------------------;
	
	/**
	   Get a tile id by Pixel Coordinates */
	public function getTileP(X:Float, Y:Float):Int
	{
		return layers[COLLISION_LAYER].getTile(Std.int(X / T.tileW), Std.int(Y / T.tileH));
	}//---------------------------------------------------;
	
	
	
	
	#if debug
	
	function _update_debug()
	{
		// Click somewhere to put player there
		
		if (FlxG.keys.pressed.SHIFT)
		{
			//Game.player._teleport(FlxG.mouse.x, FlxG.mouse.y);
			if (FlxG.mouse.justPressed)
			{
				Game.player.spawn(FlxG.mouse.x, FlxG.mouse.y);
				return;
			}
			
			var vec = {x:0, y:0};
			
			if (D.ctrl.justPressed(DButton.LEFT)) {
				vec.x = -1;
			}else if (D.ctrl.justPressed(DButton.RIGHT)) {
				vec.x = 1;
			}else if (D.ctrl.justPressed(DButton.UP)) {
				vec.y = -1;
			}else if (D.ctrl.justPressed(DButton.DOWN)) {
				vec.y = 1;
			}
			if (camera_move_rel(vec.x, vec.y)){
				Game.player.alive = false; // Skip auto-positioning in update()
			}
		}
		
	}//---------------------------------------------------;
		
	#end
	
}// --