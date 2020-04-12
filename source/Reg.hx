package;

import djA.ConfigFile;
import djFlixel.D;
import flixel.FlxSprite;
import haxe.Json;


/**
 * Various Parameters
 * - Everything is public
 */
@:publicFields
class Reg 
{
	static inline var VERSION = "1.5";
	
	// How long to wait on each screen on the banners
	static inline var BANNER_DELAY:Float = 12;
	
	// :: Images in Assets
	//    Rest of assets in "AssetColorizer"
	static var IM = {
		overlay_scr : "im/monitor_overlay.png",
		anim_tile : "im/tiles_anim.png",
		items : "im/items_20px.png",
		player : "im/anim_player.png" 
	}
	
	// :: Sounds
	static var musicVers = ["music_c64", "music_cpc"];
	static var musicVer:Int = 0; // Store index	
	
	// :: External parameters
	static inline var PATH_JSON = "assets/djflixel.json";
	static inline var PATH_INI  = "assets/test.ini";

	// :: External Parameters parsed objects
	static var INI:ConfigFile;
	static var JSON:Dynamic;
	
	
	// PHYSICS Related Variables
	// -- Enemies, Playser, World
	// :: Other not physic parameters can be found as statics at each class so look over there also
	// :: Player - jump cut off variables are hard coded in <player.state_onair_update()>
	static var PH = {
		gravity:410,
		pl_speed:70,
		pl_jump:220,
		en_speed:30,
		en_bounce:180
	};
	
	static var LEVELS = [
		'assets/maps/level_01.tmx',
		'assets/maps/_debug.tmx',
	];
	
	
	// :: OBJECTS ::
	static var COLORIZER:AssetColorizer;
	
	
	// Asset loaded times
	static var _dtimes:Int = 0;
	
	
	// --
	// -- This is going to be called right before FLXGAME being created
	public static function init()
	{
		trace(" == Reg init");
		D.assets.DYN_FILES = [PATH_JSON, PATH_INI];	// Reload on F12
		D.assets.onAssetLoad = onAssetLoad;	
		D.snd.ROOT_SND = "snd/";
		D.snd.ROOT_MSC = "mus/";
		D.ui.initIcons([8, 12]);
		
		// -- Game things: might be moved:
		COLORIZER = new AssetColorizer();
		
	}//---------------------------------------------------;
	
	// Whenever D.assets gets reloaded, I need to reparse the data into the objects
	// Then the state will be reset automatically
	static function onAssetLoad()
	{
		trace(" -- Reg Dynamic Asset Load");
		INI = new ConfigFile(D.assets.files.get(PATH_INI));
		JSON = Json.parse(D.assets.files.get(PATH_JSON));
		
		if (++_dtimes == 1)
		{
			D.snd.addMetadataNode(JSON.soundFiles);
		}
	}//---------------------------------------------------;

	
	/** This is to be overlayed on top of every state */
	static function get_overlayScreen():FlxSprite
	{
		var a = new FlxSprite(0, 0, IM.overlay_scr);
			a.scrollFactor.set(0, 0);
			a.active = false;
			return a;
	}//---------------------------------------------------;
	
	
	// TODO:
	public static function checkProtection():Bool
	{
		return true;
		// !Reg.api.isURLAllowed()
	}//---------------------------------------------------;
	
	
}