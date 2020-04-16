package tools ;
import djfl.tool.Geom;
import djfl.util.TiledMap;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.tile.FlxTilemap;
import lime.graphics.opengl.ext.IMG_program_binary;

/**
 * Generic TileMap
 * 
 * - Loads and handles `TILED` maps
 * - Basic cameras and TiledObject load functions
 * - MUST BE EXTENDED !!!
 */
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
	
	/** 
	  TiledLoader optional load parameters, see <TiledMap.PARAMS>.
	  Set this on the extended object */
	var _tiledParams:Dynamic;
	
	public function new(numLayers:Int = 1)
	{
		super();
		layers = [];
		while (numLayers-->0) {
			var l = new FlxTilemap();
			l.active = false;	// Do not call update?
			layers.push(l);
			add(l);
		}
		
		COLLISION_LAYER = layers.length - 1;
		
	}//---------------------------------------------------;
	
	/**
	   Set a camera viewport. Do this right after new()
	**/
	function setCameraViewport(X:Int, Y:Int, W:Int, H:Int)
	{
		camera.x = X;
		camera.y = Y;
		camera.width = W;
		camera.height = H;
	}//---------------------------------------------------;
	
	/**
	   
	   - Camera is set to top-left, camera bounds are set
	   - World Boundaries are set
	   @param	s Asset to Load OR the xml data file
	   @param asData, if you put the XML DATA set this to true
	**/
	public function load(s:String, asData:Bool = false)
	{
		T = new TiledMap(null, _tiledParams);
		
		if (asData){
			trace("LOADING DATA MAP");
			T.loadData(s);
		}else{
			trace("LOADING ASSET >>> MAP");
			T.load(s);
		}
		
		width = T.mapW * T.tileW;
		height = T.mapH * T.tileH;
		
		if (layers[0].graphic != null ) { // Check to see if this is the first time ever
			for (l in layers) {
				l.graphic.bitmap.dispose();
				l.graphic.destroy();			
			}
		}
		
		// Init other
		FlxG.worldBounds.set(0, 0, width, height);
		camera.scroll.set(0, 0);
		camera.setScrollBoundsRect(0, 0, width, height);
	}//---------------------------------------------------;
	
	
	/**
	   Get a list of Tiled Objects by Checking CENTER POINTS, or (X,Y) of objects ONLY
	   Returns TILE OBJECTS Only (not polygons,text,etc)
	   DEV : SEARCHES SERIALLY, no quad_tree yet. If there are less han ~20 entities per map, and you
	         don't call this at every frame. THIS IS OK FOR NOW. Don't worry
	   @param	id Name of the Object Layer
	**/
	function get_objectTilesAt(id:String, x:Float, y:Float, w:Float, h:Float):Array<TiledObject>
	{
		var list:Array<TiledObject> = [];
		for (i in T.getObjLayer(id)) 
		{
			if (i.gid != null && Geom.rectHasPoint(x, y, w, h, i.x, i.y)){
				list.push(i);
			}
		}
		return list;
	}//---------------------------------------------------;
	
	
	/** 
	   Convert map serial to (x,y)
	   The TiledMAP needs to have been loaded */
	function serialToTileCoords(i:Int)
	{
		return {x:i % T.mapW, y:Std.int(i / T.mapW)};
	}//---------------------------------------------------;
	
	/**
	   Convert world pixel coords to tile coords */
	public function getTileCoordsFromP(x:Float, y:Float)
	{
		return { x:Std.int(x / T.tileW), y:Std.int(y / T.tileH) };
	}//---------------------------------------------------;
	
	/** 
	   Get tile collision data at (x,y) Tile coordinates */
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
}// --