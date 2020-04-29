package;

import djA.ConfigFile;
import djFlixel.D;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import haxe.Json;
import states.StatePlay;


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
		player_from_enemy 		: 30,	// Depends on enemy
		player_from_hazard		: 28,	
		player_fall_damage		: 180,
		player_from_big			: 240,
		player_from_ceil		: 1,
		// --
		enemy_from_player 		: 100,
	}

	
	// :: General Parameters 
	// Enemies, Playser, World
	// Other not physic parameters can be found as statics at each class so look over there also
	// Player - jump cut off variables are hard coded in <player.state_onair_update()>
	public static var P = {
		flicker_rate:0.06,
		gravity:410,
		pl_speed:70,
		pl_jump:220,
		//-
		en_health			:20,	// Depends on enemy
		en_health_chase		:30,	// Depends on enemy
		en_speed		:35,
		en_turret_speed	:2.5,	// Millisecs between shots
		en_bounce		:180,
		en_spawn_time	:3, 
	};

	
	// All states default BG color,
	static var BG_COLOR:Int = 0xFF000000;
	
	//====================================================;
	//====================================================;
	
	// >> Called BEFORE FlxGame() is created
	public static function init_pre()
	{
		trace(" == Reg init -pre-");
		D.assets.DYN_FILES = [PATH_JSON, PATH_INI, Game.DEBUG_MAP];
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
		
		#if debug
		new Debug();
		#end
		
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
	
	
	
	// -- TODO :
	public static function checkProtection():Bool
	{
		return true;
		// !Reg.api.isURLAllowed()
	}//---------------------------------------------------;
	
	
	
}//--



