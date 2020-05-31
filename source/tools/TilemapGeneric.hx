/**
 == Generic TileMap
 --------------------
 
 - MUST BE EXTENDED !!!
 - Loads and handles `TILED` maps
 - Basic cameras and TiledObject load functions 
 - Keeps track of "KILLED" TiledObjects, so <get_objectTilesAt()> will not push them again to user
 
 CAMERA TIP:
 ----------
 - You can create a new camera for the tilemap and have all the sprites follow the camera
 - First create a new camera. e.g.:
   	var CAM = new FlxCamera(DRAW_START_X, DRAW_START_Y, ROOM_WIDTH, ROOM_HEIGHT);
	camera = CAM;
	
 - Then you can either make this the `default` camera or make all sprites to use this camera
	FlxCamera.defaultCameras = [CAM];
	// or
	player.cameras = [CAM]
 
 ===============================*/

package tools ;

import djfl.tool.Geom;
import djfl.util.TiledMap;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.tile.FlxTilemap;
import lime.graphics.opengl.ext.IMG_program_binary;


class TilemapGeneric extends FlxGroup
{
	/** The .tmx tiled map. Short name for quick access */
	public var T(default, null):TiledMap;
	
	/** Width in pixels */
	public var width(default, null):Int;	// Pixel Width
	/** Height in pixels */
	public var height(default, null):Int; 	// Pixel Height
	
	/** All the FlxTilemaps */
	public var layers:Array<FlxTilemap>;
	
	// Set this to the correct layer index that does collisions.
	// Autoset to last layer by default
	var COLLISION_LAYER:Int;
	
	// TiledLoader optional load parameters, see <TiledMap.PARAMS>.
	// Set this on the extended object
	var _tiledParams:Dynamic;
	
	// Killed Objects. Entities here will not return process on 'get_objectTilesAt'
	// Use with "killObject()" | INT = object.id;
	var _killed:Array<Int>;
	
	// Globally Killed Objects.
	// Keeps the _killed objects across loading maps
	// When loading maps, <_killed> will be constructed with this data
	// Format Stored = "assetmap::object.ID" e.g. "level01.tmx:";
	var _killed_global:Array<String>;
	
	public function new(numLayers:Int = 1)
	{
		super();
		layers = [];
		while (numLayers-->0) {
			var l = new FlxTilemap();
			l.useScaleHack = false;
			l.active = false;	// Do not call update?
			layers.push(l);
			add(l);
		}
		
		COLLISION_LAYER = layers.length - 1;
		
		_killed_global = [];
		
	}//---------------------------------------------------;


	/**
	   - Camera is set to top-left, camera bounds are set
	   - World Boundaries are set
	   @param s <Asset Path> or <XML Data as Text>.
	   @param asData, if you pass XML DATA set this to True
	**/
	public function load(s:String, asData:Bool = false)
	{
		T = new TiledMap(null, _tiledParams);
		
		if (asData){
			T.loadData(s);
		}else{
			T.load(s);
		}
		
		_killed = [];
		
		// -- Check for global kills and store
		if (T.assetLoaded != null) // In case user loads a dynamic map. Dynamic maps don't have an asset name
		for (i in _killed_global) {
			if (i.indexOf(T.assetLoaded) == 0){
				var d = i.split(":");
				_killed.push(Std.parseInt(d[1]));
			}
		}
		
		width = T.mapW * T.tileW;
		height = T.mapH * T.tileH;
		
		//:: Useful in dynamic bitmaps, but for assets it will destroy them forever
		//:: This causes problems, do not activate.
		//if (layers[0].graphic != null ) { 
			//for (l in layers) {
				//l.graphic.bitmap.dispose(); 
				//l.graphic.destroy();	
			//}
		//}
		
		// Init other
		FlxG.worldBounds.set(0, 0, width, height);
		camera.scroll.set(0, 0);
		camera.setScrollBoundsRect(0, 0, width, height);
	}//---------------------------------------------------;
	
	/**
	   Flag an object as "killed" so in the next "get_objectTiles" function it
	   will not get passed to the array.
	   
	   @param	o The Object to kill
	   @param	global If TRUE, then it will stay killed in all map loads. False will only stay dead until map is reloaded
	**/
	public function killObject(o:TiledObject, global:Bool = false)
	{
		if (_killed.indexOf(o.id) == -1)
		{
			_killed.push(o.id);
			
			if (global)
			{
				var id = T.assetLoaded + ":" + o.id;
				_killed_global.push(id);
			}
		}
			
	}//---------------------------------------------------;
	
	
	/**
	   Get a list of Tiled Objects by Checking CENTER POINTS, or (X,Y) of objects ONLY
	   Returns TILE OBJECTS Only (not polygons, text,etc )
	   DEV : SEARCHES ALL OBJECTS, no quad_tree yet. If there are less han ~20 entities per map, and you
	         don't call this at every frame. THIS IS OK FOR NOW. Don't worry.
	   @param id Name of the Object Layer
	**/
	function get_objectTilesAt(id:String, x:Float, y:Float, w:Float, h:Float):Array<TiledObject>
	{
		var list:Array<TiledObject> = [];
		for (i in T.getObjLayer(id)) 
		{
			if (_killed.indexOf(i.id) >= 0) {
				continue;
			}
			
			if (i.gid != null && Geom.rectHasPoint(x, y, w, h, i.x, i.y)){
				list.push(i);
			}
		}
		return list;
	}//---------------------------------------------------;
	
	
	/** Convert world pixel coords to tile coords */
	public function getTileCoordsFromP(x:Float, y:Float):{x:Int, y:Int}
	{
		return { x:Std.int(x / T.tileW), y:Std.int(y / T.tileH) };
	}//---------------------------------------------------;
	
	/** Get tile collision data at (x,y) Tile coordinates */
	public function getCol(x:Int, y:Int):Int
	{
		var t = layers[COLLISION_LAYER].getTile(x, y);
		return t > 0?layers[COLLISION_LAYER].getTileCollisions(t):0;
	}//---------------------------------------------------;

	/** Get tile collision data at (x,y) Pixel coordinates */
	public function getColP(x:Float, y:Float):Int
	{
		return getCol(Std.int(x / T.tileW), Std.int(y / T.tileH));
	}//---------------------------------------------------;
	
	/** Quickly get the collision layer itself */
	inline public function layerCol():FlxTilemap
	{
		return layers[COLLISION_LAYER];
	}//---------------------------------------------------;
	
	/**  
	   Convert map serial to (x,y)
	   The TiledMAP needs to have been loaded */
	function serialToTileCoords(i:Int)
	{
		return {x:i % T.mapW, y:Std.int(i / T.mapW)};
	}//---------------------------------------------------;
	

}// --