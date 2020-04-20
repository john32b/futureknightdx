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
	
	
	//var cache:Map<String,BitmapData>;
	
	// These colors are read from the source image and replaces
	// with custom colors in getBitmap()
	var TEMPLATE_COLORS:Array<Int> = [
		Pal_DB32.COL_23,
		Pal_DB32.COL_25,
		Pal_DB32.COL_01
	];

	public function new() 
	{
		//cache = [];
	}//---------------------------------------------------;
	
	
	/**
	   Load a graphic to a sprite from the predefined ones
	   @param	sprite 
	   @param	name Name in "GFX" map
	   @param	O Color options TODO
	**/
	public function loadGraphic(sprite:FlxSprite, name:String, ?O:Dynamic)
	{
		var d = GFX.get(name);
		sprite.loadGraphic(getbitmap(d.im, d.col?1:0), true, d.tw, d.th);
	}//---------------------------------------------------;
	
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
	public function getMapTiles(type:Int, layer:String, ?O:Dynamic):BitmapData
	{
		var bit = getbitmap('im/tiles_${layer}_${type}.png', 0);
		return bit;
	}//---------------------------------------------------;
	
	
	/**
	   Get Bitmap and colorize if the image supports it
	   @param	assetName
	   @param	C 0 for no colorization
	**/
	function getbitmap(assetName:String, C:Int = 0)
	{
		var source = Assets.getBitmapData(assetName, false);
		
		if (C == 0) {
			return source;
		}
		
		return source;
		// Colorize and Return
		//var dest = D.bmu.replaceColors(source, TEMPLATE_COLORS, [ 
			//Pal_DB32.COL_20, Pal_DB32.COL_09, Pal_DB32.COL_30 /// TODO: colors to be replaced with:
		//]);
		//return dest;
	}//---------------------------------------------------;
		
	
}// --