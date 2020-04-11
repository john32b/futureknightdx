package;
import djFlixel.D;
import djFlixel.gfx.pal.Pal_DB32;
import djfl.util.Atlas;
import flash.display.BitmapData;
import openfl.utils.Assets;

/**
 * Future Knight Specific
 * 
 * - Colorizes some assets
 * - CACHE? I don't really need it.
 * 
 */
class AssetColorizer
{
	static var IM_TILES = [
		'im/tiles_bg_0.png',	// SPACE
		'im/tiles_fg_0.png',	// -
		
		'im/tiles_bg_0.png',	// JUNGLE
		'im/tiles_fg_1.png',	// -
		
		'im/tiles_bg_2.png',	// CASTLE
		'im/tiles_fg_2.png',	// -
		
		'im/enemies_32.png',	// Enemies
		
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
	   @param	index
	   @param	O
	**/
	public function getBitmap(index:Int , ?O:Dynamic):BitmapData
	{
		//var ID = '$index';
		//if (cache.exists(ID)) return cache.get(ID);
		var source = Assets.getBitmapData(IM_TILES[index]);
		var dest = D.bmu.replaceColors(source.clone(), TEMPLATE_COLORS, [ 
			/// TODO: colors to be replaced with:
			Pal_DB32.COL_20, Pal_DB32.COL_09, Pal_DB32.COL_30
			]);
		//cache.set(ID, dest);
		return dest;
	}//---------------------------------------------------;
	
	
		
}