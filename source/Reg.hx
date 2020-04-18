package;

import djA.ConfigFile;
import djFlixel.D;
import flixel.FlxCamera;
import flixel.FlxG;
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
	
	// :: Sounds
	static var musicVers = ["music_c64", "music_cpc"];
	static var musicVer:Int = 0; // Store index	
	
	// :: External parameters
	static inline var PATH_JSON = "assets/djflixel.json";
	static inline var PATH_INI  = "assets/test.ini";
	
	// How long to wait on each screen on the banners
	static inline var BANNER_DELAY:Float = 12;
	
	//====================================================;
	
	// :: Image Asset Manager
	public static var IM:ImageAssets;

	// This is for quick access to game elements
	public static var st:StatePlay;

	// :: External Parameters parsed objects
	static var INI:ConfigFile;
	static var JSON:Dynamic;
	
	
	// :: DAMAGE VALUES 
	// I am using this simple naming style, first is who takes damage _ from whom
	public static var P_DAM = {
		player_from_en_bullet 	: 25,
		player_from_enemy 		: 40,
		player_from_hazard		: 20,
		player_fall_damage		: 180,
		// --
		enemy_from_player 		: 100,
		enemy_from_pl_bullet 	: 50,
	}

	
	// :: General Parameters 
	// Enemies, Playser, World
	// Other not physic parameters can be found as statics at each class so look over there also
	// Player - jump cut off variables are hard coded in <player.state_onair_update()>
	public static var P = {
		flicker_time:0.4,
		gravity:410,
		
		pl_speed:70,
		pl_jump:220,
		pl_bl_onscreen:2,	// MAX bullets plyer can shoot
		pl_bl_speed:150,	// Player bullet speed
		pl_bl_timer:250,	// Shoot every this much MILLISECONDS
		
		en_health		:100,
		en_bl_speed		:62,
		en_speed		:35,
		en_turret_speed	:2.5,	// Millisecs between shots
		en_bounce		:180,
		en_spawn_time	:3, 
	};
	
	
	static var LEVELS = [
		'assets/maps/level_01.tmx',
		'assets/maps/_debug.tmx',
	];
	
	
	// All states default BG color,
	static var BG_COLOR:Int = 0xFF000000;
	
	
	//====================================================;
	//====================================================;
	
	// >> Called BEFORE FlxGame() is created
	public static function init_pre()
	{
		trace(" == Reg init -pre-");
		D.assets.DYN_FILES = [PATH_JSON, PATH_INI, LEVELS[0]];
		D.assets.onAssetLoad = onAssetLoad;	
		D.snd.ROOT_SND = "snd/";
		D.snd.ROOT_MSC = "mus/";
		D.ui.initIcons([8, 12]);
		
		// -- Game things: might be moved:
		IM = new ImageAssets();
	}//---------------------------------------------------;
	
	// >> Called AFTER FlxGame() is created
	public static function init_post()
	{
		trace(" == Reg init -post-");
		D.snd.setVolume("master", 0.15);
		
		
		//D.text.styles.set('hud_health', );
		
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

		
	
	// Quickly add the monitor border. And set it to be drawn at one camera only
	public static function add_border():FlxSprite
	{
		var st = FlxG.state;
		var a = new FlxSprite(0, 0, IM.STATIC.overlay_scr);
			a.scrollFactor.set(0, 0);
			a.active = false;
			a.camera = st.camera;
		st.add(a);
		return a;
	}//---------------------------------------------------;
	
	// TODO:
	public static function checkProtection():Bool
	{
		return true;
		// !Reg.api.isURLAllowed()
	}//---------------------------------------------------;
	
	
	
	public static var ITEM_DATA:Map<MapTiles.ITEM_TYPE,ItemHudInfo> = [
			SAFE_PASS => { name:"Safe Pass", desc:"It says `Safe pass`", icon:1},
			CONFUSER_UNIT => { name:"Confuser", desc:"Hey, you`ve found a confuser", icon:2 },
			SECURO_KEY => { name:"Securo Key", desc:"This is a Securo key", icon:3 },
			BOMB => { name:"Bomb", desc:"You have a Berm (Francais)", icon:4 },
			PLATFORM_KEY => { name:"Platform Key", desc:"You have a platform key", icon:5 },
			EXIT_PASS => { name:"Exit Pass", desc:"Looks like an exit pass", icon:6 },
			
			BRIDGE_SPELL => { name:"Bridge Spell", desc:"11", icon:1 },
			SHORTERNER_SPELL => { name:"Shortne", desc:"11", icon:1 },
			FLASH_BANG_SPELL => { name:"flashbandg", desc:"11", icon:1 },
			GLOVE => { name:"glov", desc:"", icon:1 },
			RELEASE_SPELL => { name:"reles", desc:"", icon:1 },
			DESTRUCT_SPELL => { name:"dest", desc:"", icon:1 }
	];
	
}//--



// Item HUD information
typedef ItemHudInfo = {
	name:String,
	desc:String,
	icon:Int	// There are 10 unique item icons for the HUD (1-10) values
}


