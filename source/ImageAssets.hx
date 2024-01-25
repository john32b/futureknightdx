/**
Future Knight Image Assets
==============================


- Declare all image tilesets along with metadata
- Colorizes some assets, the sprite should not have to worry about colorizing assets

== Color Templates Should be 4 colors
	Based on the Aseprite CPC BOY palette
	- 0xFF293941 (dark)
	- 0xFF485d48
	- 0xFF859550
	- 0xFFbac375 (light)

 ------------------------------------------- */

package;

import djFlixel.D;
import djFlixel.gfx.pal.Pal_CPCBoy;
import djfl.util.Atlas;
import flixel.FlxSprite;
import openfl.display.BitmapData;
import openfl.utils.Assets;



class ImageAssets
{
	// Static images:
	public var STATIC = {
		overlay_scr:"im/monitor_overlay1.png",
		hud_inventory:"im/hud_inventory.png",
		hud_bottom:"im/hud_bg.png",
		tiles_shadow:"im/tiles_sh.png",
		minimap:"im/minimap.png"
	};

	/*
	 Sprite Assets
	 asset_id -> { 	im:Actual openfl asset path,
			tw: tilewidth, th: tileheight
			col: Color Templated? True will be colorized
	 } */
	static var GFX:Map<String,{im:String,tw:Int,th:Int,col:Bool}> = [
		"player" => { im:"im/ts_player.png", tw:28, th:26, col:true},
		"enemy_sm" =>  {im:"im/ts_enemy_sm.png", tw:24, th:24, col:true},
		"enemy_big" => {im:"im/ts_enemy_big.png", tw:50, th:46, col:true},
		"enemy_tall" => {im:"im/ts_enemy_tall.png", tw:56, th:52, col:true},
		"enemy_worm" => {im:"im/ts_enemy_worm.png", tw:70, th:24, col:true},
		"enemy_clone" => {im:"im/ts_enemy_pl.png", tw:28, th:26, col:true},
		"ts_enemy_pl" => {im:"im/ts_enemy_worm.png", tw:70, th:24, col:true},
		"animtile" => {im:"im/ts_tiles.png", tw:32, th:32, col:false},
		"items" => {im:"im/ts_items.png", tw:20, th:20, col:false},
		"bullets" => {im:"im/ts_bullets.png", tw:20, th:20, col:false}, 
		"particles" => {im:"im/ts_particles.png", tw:22, th:24, col:true},
		"static" => {im:"im/hud_static.png", tw:64, th:24, col:false},
		"huditem" => {im:"im/hud_items.png", tw:17, th:17, col:false},
		"digital" => {im:"im/digital.png", tw:11, th:17, col:false},
		"keys" => {im:"im/ts_keys.png", tw:16, th:16, col:false},
		"friend" => {im:"im/ts_friend.png", tw:26, th:28, col:true},
		"teleporter" => {im:"im/ts_teleport.png", tw:52, th:42, col:false}
	];
	
	
	// Color Combo Template Colors
	// 3 colors on the template graphics
	// When loading a templated bitmap, these colors are to be replaced
	var CC_TEMPL:Array<Int> = [
		Pal_CPCBoy.COL[28],
		Pal_CPCBoy.COL[29],
		Pal_CPCBoy.COL[31]
	];
	
	
	// Color Names to Color Combinations
	// Colors are Pal_CPCBoy Indexes
	// At object init, all indexes are going to be replaced with Real Color Values.
	var CC_MAP:Map<String,Array<Int>> = [
	
		// SPRITE COLORS:
		"red" => [15, 6, 3],
		"red2" => [27, 16, 3],
		"green" => [21, 18, 9],
		"green2" => [25, 18, 31],
		"blue" => [23, 11, 1],
		"blue2" => [23, 10, 31],
		"yellow" => [25, 24, 31],
		"yellow2" => [27, 24, 12],
		"pink" => [27, 17, 6],
		"gray" => [27, 13, 31],
		
		// MAP COLORS: (2 is dark) -- Color Combo
		"cc_yellow" => [25, 24, 15],
		"cc_orange" => [24, 15, 6],
		"cc_brown" => [25, 12, 3],
		"cc_green" => [25, 18, 9],
		"cc_purple" => [27, 17, 7],
		"cc_purple2" => [17, 5, 4], // dark
		"cc_blue" => [23, 20, 10],
		"cc_blue2" => [23, 10, 1],
		"cc_red" => [16, 6, 3],
		"cc_red2" => [6, 3, 1], // dark
		"cc_gray" => [27, 13, 31],
		"cc_green2" => [21, 9, 31], // or 31 instead of 3
		
		"cc_forest1" => [24, 9, 12],
		"cc_forest2" => [16, 3, 31]
	];
	
	
	// This is for the enemy class to get a random color
	// a copy of `CC_MAP` keys
	var COLORS_SPRITE = [
		"red", "green", "blue", "yellow", "pink", "red2", "green2", "blue2", "yellow2", "gray"
	];
	
	// Caches all the generated bitmaps
	var cache:Map<String,BitmapData>;
	
	
	public function new() 
	{
		cache = [];
		
		// : Translate the CC_MAP values from palette indexes to real colors
		for (k => v in CC_MAP)
		{
			CC_MAP.set(k, [Pal_CPCBoy.COL[v[0]], Pal_CPCBoy.COL[v[1]], Pal_CPCBoy.COL[v[2]]]);
		}
		
		// I want to cache ENEMIES and PARTICLES with some of the colors
		for (k => v in CC_MAP)
		{
			if (k.indexOf("cc_") == 0) continue;
			getbitmap(GFX['enemy_sm'].im, k, true);
			getbitmap(GFX['particles'].im, k, true);
		}

	}//---------------------------------------------------;
	
	
	public function getRandomSprColor():String
	{
		return COLORS_SPRITE[Std.random(COLORS_SPRITE.length)];
	}//---------------------------------------------------;
	
	
	/**
	   Load a graphic to a sprite from the predefined ones
	   @param	sprite The sprite to load the graphic to
	   @param	name Name/id in the `GFX` map
	   @param	C Color Combo String | CC_MAP key, e.g. `yellow2`
	**/
	public function loadGraphic(sprite:FlxSprite, name:String, ?C:String)
	{
		var d = GFX.get(name);
		
		if (d.col){
			// All colorized will be cached. So I am using 'd.col' to call cache
			sprite.loadGraphic(getbitmap(d.im, C, d.col), true, d.tw, d.th);
		}else{
			sprite.loadGraphic(d.im, true, d.tw, d.th);
		}
	}//---------------------------------------------------;
	
	/** Quickly get a sprite with a tileset loaded at current frame
	 */
	public function getSprite(X:Float = 0, Y:Float = 0, name:String, frame:Int = 1):FlxSprite
	{
		var S = new FlxSprite(X, Y);
		loadGraphic(S, name);
		S.animation.frameIndex = frame;
		return S;
	}//---------------------------------------------------;

	/**
	   Get Map Asset from (type) (fg/bg). E.g. "im/tiles_fg_1.png"
	   @param	type 0:Space, 1:Forest, 2:Castle
	   @param	layer bg , fg
	   @param	C Colors
	   @return Colorized Map Tiles BitmapData
	**/
	public function getMapTiles(type:Int, layer:String, ?C:String):BitmapData
	{
		var asset = 'im/tiles_${layer}_${type}.png';
		return getbitmap(asset, C);
	}//---------------------------------------------------;
	
	
	/**
	   Get Bitmap and colorize if the image supports it
	   @param assetName e.g "im/tiles_fg.png"
	   @param C CC_MAP key | e.g. "cc_green"
	   @param useCache If true, will search cache, if not found will create and put to cache
	**/
	function getbitmap(assetName:String, ?C:String, ?useCache:Bool = false)
	{
		#if debug
		if (C != null && !CC_MAP.exists(C)){
			trace("Error: Wrong color or empty", C);
			C = 'red';
		}
		#end
		
		var source:BitmapData;
		
		if (useCache)
		{
			source = cache.get(assetName + "_" + C);
			
			if (source == null) {
				source = Assets.getBitmapData(assetName).clone();
				if (C != null) D.bmu.replaceColors(source, CC_TEMPL, CC_MAP[C]);
				cache.set(assetName + "_" + C, source);
			}
			return source.clone();
			
		}else
		{
			source = Assets.getBitmapData(assetName).clone();
			if (C != null) D.bmu.replaceColors(source, CC_TEMPL, CC_MAP[C]);
			return source;
		}
		
	}//---------------------------------------------------;
		
}// --
