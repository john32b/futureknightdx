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
import lime.graphics.opengl.ext.OES_EGL_image_external;

import flixel.FlxSprite;

import openfl.display.BitmapData;
import openfl.utils.Assets;



class ImageAssets
{
	// Static images:
	public var STATIC = {
		overlay_scr:"im/monitor_overlay.png",
	};
	
	static var GFX:Map<String,{im:String,tw:Int,th:Int,col:Bool}> = [
		"player" => { im:"im/anim_player.png", tw:28, th:26, col:true},
		"enemy_sm" =>  {im:"im/anim_enemy_sm.png", tw:24, th:24, col:true},
		"enemy_big" => {im:"im/anim_enemy_big.png", tw:50, th:46, col:true},
		"enemy_tall" => {im:"im/anim_enemy_tall.png", tw:56, th:52, col:true},
		"enemy_worm" => {im:"im/anim_enemy_worm.png", tw:70, th:24, col:true},
		"animtile" => {im:"im/anim_tiles.png", tw:32, th:32, col:false},
		"items" => {im:"im/anim_items.png", tw:20, th:20, col:false},
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
		
		// Colorize and Return
		var dest = D.bmu.replaceColors(source, TEMPLATE_COLORS, [ 
			Pal_DB32.COL_20, Pal_DB32.COL_09, Pal_DB32.COL_30 /// TODO: colors to be replaced with:
		]);
		return dest;
	}//---------------------------------------------------;
		
	
}// --