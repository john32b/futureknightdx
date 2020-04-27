/**
Future Knight Image Assets
==============================


- Declare all image tilesets along with metadata
- Colorizes some assets, the sprite should not have to worry about colorizing assets
- CACHE? I don't really need it. (TODO)

== Color Templates Should be 4 colors
	Based on the Aseprite CPC BOY palette
	- 0xFF293941 (dark)
	- 0xFF485d48
	- 0xFF859550
	- 0xFFbac375 (light)

 */
 

package;

import djFlixel.D;
import djFlixel.gfx.GfxTool;
import djFlixel.gfx.pal.Pal_CPCBoy;
import djFlixel.gfx.pal.Pal_DB32;

import djfl.util.Atlas;

import flixel.FlxSprite;

import openfl.display.BitmapData;
import openfl.utils.Assets;


class ImageAssets
{
	// Static images:
	public var STATIC = {
		overlay_scr:"im/monitor_overlay.png",
		hud_inventory:"im/hud_inventory.png",
		hud_bottom:"im/hud_bg.png",
	};
	
	static var GFX:Map<String,{im:String,tw:Int,th:Int,col:Bool}> = [
		"player" => { im:"im/ts_player.png", tw:28, th:26, col:true},
		"enemy_sm" =>  {im:"im/ts_enemy_sm.png", tw:24, th:24, col:true},
		"enemy_big" => {im:"im/ts_enemy_big.png", tw:50, th:46, col:true},
		"enemy_tall" => {im:"im/ts_enemy_tall.png", tw:56, th:52, col:true},
		"enemy_worm" => {im:"im/ts_enemy_worm.png", tw:70, th:24, col:true},
		"animtile" => {im:"im/ts_tiles.png", tw:32, th:32, col:false},
		"items" => {im:"im/ts_items.png", tw:20, th:20, col:false},
		"bullets" => {im:"im/ts_bullets.png", tw:20, th:20, col:false}, 
		"particles" => {im:"im/ts_particles.png", tw:22, th:24, col:true},
		"static" => {im:"im/hud_static.png", tw:64, th:24, col:false},
		"huditem" => {im:"im/hud_items.png", tw:17, th:17, col:false},
	];
	
	
	// Template Colors
	// 3 colors on the template graphics
	var T_COL:Array<Int> = [
		Pal_CPCBoy.COL[28],
		Pal_CPCBoy.COL[29],
		//Pal_CPCBoy.COL[30],
		Pal_CPCBoy.COL[31]
	];
	
	
	public var AVAILABLE_COLOR_COMBO = [
		"red", "green", "blue", "yellow", "pink", "red2", "green2", "blue2", "yellow2", "gray"];
	
	// This MAP will be translated on NEW() --from CPC_INDEX to REAL COLOR--
	// - Check "_DRAFT_DESIGN.ase"
	var D_COL_NAME:Map<String,Array<Int>> = [
	
		// SPRITE COLORS:
		"red" => [15, 6, 3],
		"green" => [21, 18, 9],
		"blue" => [23, 11, 1],
		"yellow" => [25, 24, 31],
		"pink" => [27, 17, 6],
		"red2" => [27, 16, 3],
		"green2" => [25, 18, 31],
		"blue2" => [23, 10, 31],
		"yellow2" => [27, 24, 12],
		"gray" => [27, 13, 31],
		
		// MAP COLORS:
		"1" => [1,2,3],
	];
	
	
	//var cache:Map<String,BitmapData>;
	
	public function new() 
	{
		//cache = [];
		for (k => v in D_COL_NAME)
		{
			D_COL_NAME.set(k, [Pal_CPCBoy.COL[v[0]], Pal_CPCBoy.COL[v[1]], Pal_CPCBoy.COL[v[2]]]);
		}
	}//---------------------------------------------------;
	
	
	/**
	   Load a graphic to a sprite from the predefined ones
	   @param	sprite 
	   @param	name Name in "GFX" map
	   @param	O Color options TODO
	**/
	public function loadGraphic(sprite:FlxSprite, name:String, ?C:String)
	{
		var d = GFX.get(name);
		
		if (d.col){
			sprite.loadGraphic(getbitmap(d.im, C), true, d.tw, d.th);
		}else{
			sprite.loadGraphic(d.im, true, d.tw, d.th);
		}
	}//---------------------------------------------------;
	
	// --
	// Quickly get a sprite with a tileset loaded at current frame
	public function getSprite(X:Float = 0, Y:Float = 0, name:String, frame:Int = 1)
	{
		var S = new FlxSprite(X, Y);
		loadGraphic(S, name);
		S.animation.frameIndex = frame;
		return S;
	}//---------------------------------------------------;

	/**
	   @param	type 0:Space, 1:Forest, 2:Castle
	   @param	layer bg , fg
	   @param	O Colors
	   @return
	**/
	public function getMapTiles(type:Int, layer:String, ?C:String):BitmapData
	{
		var bit = getbitmap('im/tiles_${layer}_${type}.png', C);
		return bit;
	}//---------------------------------------------------;
	
	
	/**
	   Get Bitmap and colorize if the image supports it
	   @param	assetName
	   @param	C 0 for no colorization
	**/
	function getbitmap(assetName:String, ?C:String)
	{
		var source = Assets.getBitmapData(assetName, false);
		
		if (C == null) {
			return source;
		}
		
		var dest = D.bmu.replaceColors(source, T_COL, D_COL_NAME[C] );
		return dest;
	}//---------------------------------------------------;
		
	
}// --