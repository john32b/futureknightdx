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
	
	// :: Image Asset Manager
	public static var IM:ImageAssets;

	// This is for quick access to game elements
	public static var st:StatePlay;
	

	// :: Sounds
	static var musicVers = ["music_c64", "music_cpc"];
	static var musicVer:Int = 0; // Store index	
	
	// :: External parameters
	static inline var PATH_JSON = "assets/djflixel.json";
	static inline var PATH_INI  = "assets/test.ini";

	// :: External Parameters parsed objects
	static var INI:ConfigFile;
	static var JSON:Dynamic;
	
	
	// All DAMAGE Numbers here
	public static var P_DAM = {
		player_to_enemy : 100,
		player_fall_damage:200,
		
		enemy_to_player : 50,
		enemy_bullet	: 25,
		player_bullet   : 50,
		hazard:40,
	}

	// Parameters for entities
	// -- Enemies, Playser, World
	// :: Other not physic parameters can be found as statics at each class so look over there also
	// :: Player - jump cut off variables are hard coded in <player.state_onair_update()>
	public static var P = {
		flicker_time:0.4,
		gravity:410,
		
		pl_speed:70,
		pl_jump:220,
		pl_bl_onscreen:2,	// MAX bullets plyer can shoot
		pl_bl_speed:150,	// Player bullet speed
		pl_bl_timer:250,	// Shoot every this much MILLISECONDS
		
		en_bl_speed:62,			// Enemy bullet speed
		en_speed:35,
		en_turret_speed:2.5,	// Shoot every this
		en_bounce:180,
		en_spawn_time:3, 
		en_health:100,			// Base enemy health
	};
	
	
	static var LEVELS = [
		'assets/maps/level_01.tmx',
		'assets/maps/_debug.tmx',
	];
	
	
	
	// --
	// -- This is going to be called right before FLXGAME being created
	public static function init()
	{
		trace(" == Reg init");
		D.assets.DYN_FILES = [PATH_JSON, PATH_INI, LEVELS[0]];
		D.assets.onAssetLoad = onAssetLoad;	
		D.snd.ROOT_SND = "snd/";
		D.snd.ROOT_MSC = "mus/";
		D.ui.initIcons([8, 12]);
		
		// -- Game things: might be moved:
		IM = new ImageAssets();
	}//---------------------------------------------------;
	
	
	// Whenever D.assets gets reloaded, I need to reparse the data into the objects
	// Then the state will be reset automatically
	static function onAssetLoad()
	{
		trace(" -- Reg Dynamic Asset Load");
		INI = new ConfigFile(D.assets.files.get(PATH_INI));
		JSON = Json.parse(D.assets.files.get(PATH_JSON));
		
		//INI.getObj('REG_P', P);	// Read 
		
		if (++_dtimes == 1)
		{
			D.snd.addMetadataNode(JSON.soundFiles);
		}
	}//---------------------------------------------------;
		static var _dtimes:Int = 0; // Asset loaded times

		
	
	/** This is to be overlayed on top of every state */
	static function get_overlayScreen():FlxSprite
	{
		var a = new FlxSprite(0, 0, IM.STATIC.overlay_scr);
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
	
	
	public static var ITEM_DATA:Map<MapTiles.ITEM_TYPE,ItemInfo> = [
			SAFE_PASS => { name:"Safe Pass", desc:"It says Safe pass"},
			BOMB => { name:"Bomb" },
			PLATFORM_KEY => { name:"Platkey" },
			CONFUSER_UNIT => { name:"Conf" },
			SECURO_KEY => { name:"SEcuro" },
			EXIT_PASS => { name:"Exitp" },
			BRIDGE_SPELL => { name:"Bridge" },
			SHORTERNER_SPELL => { name:"Shortne" },
			FLASH_BANG_SPELL => { name:"flashbandg" },
			GLOVE => { name:"glov" },
			RELEASE_SPELL => { name:"reles" },
			DESTRUCT_SPELL => { name:"dest" }
	];
	
}//--



// Basic Item structure
typedef ItemInfo = {
	name:String,
	?desc:String
}


