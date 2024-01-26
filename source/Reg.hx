package;

import djA.parser.ConfigFileB;
import djFlixel.D;
import djFlixel.other.DelayCall;
import djFlixel.ui.FlxMenu;
import djFlixel.ui.menu.MItemData;
import flixel.FlxG;
import flixel.system.FlxAssets;
import openfl.display.Bitmap;
import states.StatePlay;
import states.SubStatePause;
import tools.CRTShader;


/**
 * Static Globals, functions and vars
*/
class Reg 
{
	// Read version from project.xml
	public static inline var VERSION = djA.Macros.getDefine("APP_VER");
	
	// :: External parameters
	static inline var PATH_INI  = "assets/fkdx.ini";
	
	// :: Image Asset Manager
	public static var IM:ImageAssets;

	// :: External Parameters parsed objects
	public static var INI:ConfigFileB;
	
	// :: DAMAGE VALUES 
	// I am using this simple naming style, first is who takes damage _ from whom
	// [INI FILE]
	public static var P_DAM = {
		from_hazard		: 30,	// [CPC] is 30
		fall_damage		: 90,
		from_ceil		: 1,	// [CPC] is 1
		i_time			: 0.5,	// Player invisibility times after being hit
		max_damage 		: 60,	// Maximum amount of damage per hit, to enemy or player. 
								// This is because entities take damage equal to the health of the other entity when collided
								// e.g. when player collides with BOSS, both will get hurt by this much
		bomb_damage		: 250	// Mostly damage to the final boss. other enemies are insta kill forever
	};

	// :: General Global Parameters 
	public static var P = {
		flicker_rate: 0.06,	// Used for player and HUD text
		gravity : 410,
		confuse_time: 8	// Seconds
	};
	
	// ::
	public static var SND = {
		exit_unlock:"exit_unlock",	// long vibrato effect medium
		exit_travel:"exit_go",
		error:"gen_no",
		weapon_get:"gen_tick",
		item_equip:"gen_tick",	// on inventory select
		item_pickup:"it_pick",
		item_bomb:"it_bomb",
		item_confuser:"it_confuser",
		item_flash:"it_confuser",
		item_destruct:"it_destruct",
		item_keyhole:"map_key",	// Used with "platform key", "bridge spell", "release spell"
	};
	
	
	public static var SCORE = {
		enemy_hit:7,
		item_bomb:150,
		item_confuser:100,
		item_flashbang:200,
		item_destruct:100,
		item_scepter:200,
		big_enemy_kill:90,
		enemy_kill:15,
		final_boss:1500,
	};

	// Music per stage type + loop milliseconds
	// Indexes 0,1,2 ARE FIXED, They share IDs with MAP_TYPES
	public static var musicData = [
		{a:"01", loop:15572},	// type:0 - space
		{a:"02", loop:23000}, 	// type:1 - forest
		{a:"03", loop:10661},	// type:2 - castle
		{a:"04", loop:11245},	// boss music
		{a:"FK_Title", loop:0}	// Main Title Music
	];
	

	// Decorative Amstrad CPC screen border
	// This is an openfl object, not flixel
	static var border:Bitmap;	
	
	// -
	static var SHADER:CRTShader;
	
	// Keeps what sound is supposed to be playing right now
	// Useful for when Muting/Unmuting the sounds. It will play this one
	static var musicIndex:Int = -1;
	
	// All states default BG color,
	public static var BG_COLOR:Int = 0xFF000000;
	
	// This is the first level that a new game will start with
	public static var START_MAP = 'level_01';
	
	// This is for quick access to game elements
	public static var st:StatePlay;
	
	// Called from anywhere to send small messages to the Play State
	public static var sendGameEvent:String->?gamesprites.AnimatedTile->Void;
	
	// Filter type for the SHADER with setter ( 0:None | 1:Blur | 2:CRT )
	public static var FILTER_TYPE(default, set):Int = 0;
	
	// In any time during the lifetime did it show the controller connected toast?
	public static var CONTROLLER_TOAST:Bool = false;
	
	//====================================================;
	
	// Gets called once After FLXGame and before first State
	public static function init()
	{
		trace('> Reg init. Game version : ${VERSION}');
		
		D.ui.initIcons([8]);
		D.assets.HOT_LOAD = [PATH_INI];
		D.assets.onLoad = onAssetLoad;
		D.assets.loadNow();	// < Basically triggers onAssetLoad(); to parse the config files
		
		#if debug
			new Debug();
		#end
		
		IM = new ImageAssets();
		SHADER = new CRTShader();

		SAVE_SETTINGS(false);	// restore & apply
		SAVE_KEYS();			// restore & apply keys
		
		// DEV: Do this after setting scalemode.
		// - It is going to be called once now and one more time after this (?)
		FlxG.signals.gameResized.add(onResize);
		
		// --
		FlxG.autoPause = false;
		FlxG.sound.soundTrayEnabled = false;
	}//---------------------------------------------------;
	
	
	/**	Adds an amstrad cpc - like border on top of everything
		@param state true:add , false:remove
	**/
	public static function setBorder(state:Bool)
	{
		if (border == null) {
			border = new Bitmap(FlxAssets.getBitmapData(IM.STATIC.overlay_scr));
			border.smoothing = true;
		}
		if (state){
			if(!FlxG.stage.contains(border))
				FlxG.stage.addChild(border);
		}else{
			if(FlxG.stage.contains(border))
				FlxG.stage.removeChild(border);
		}
	}//---------------------------------------------------;
	
	
	// Whenever D.assets gets reloaded, I need to reparse the data into the objects
	// Then the state will be reset automatically
	static function onAssetLoad()
	{
		INI = new ConfigFileB(D.assets.files.get(PATH_INI));
		D.snd.addSoundInfos(INI.getObj('sounds_vol'));
	}//---------------------------------------------------;

		
	static function onResize(w:Int,h:Int)
	{
		trace(": Game Resized", w, h);
		
		border.x = FlxG.game.x;
		border.y = FlxG.game.y;
		border.width = FlxG.scaleMode.gameSize.x;
		border.height = FlxG.scaleMode.gameSize.y;
		
		#if !flash
		SHADER.setWinSize(w, h);
		#end
		
		// Force a new filter set, if any
		// I need to do this, openfl doesn't like resized textures and it screws the uv
		if (FILTER_TYPE > 0)
		{
			var futureF = FILTER_TYPE;
			FILTER_TYPE = 0; // force a reset
			
			// DEV:
			// For some reason I can't unset-set a filter on the same frame, or even the next one
			// Using a timed delay works.
			// This is a hacky way to do a delay, I can't just do a DelayCall because
			// the first time this is called, there is no state active (right after flxGame is created)
			FlxG.signals.preUpdate.addOnce(()->{
				new DelayCall(0.06, ()->{
					FILTER_TYPE = futureF;
				});
			});
		}
		
	}//---------------------------------------------------;
		
	public static function openPauseMenu()
	{
		st.openSubState(new SubStatePause());
	}//---------------------------------------------------;
	
	/**
		Save/Restore settings
		@param save if true will save, false to restore
	**/
	public static function SAVE_SETTINGS(save:Bool = true)
	{
		D.save.setSlot(0);
		
		if (save)
		{
			D.save.save('settings', {
				vol: Std.int(FlxG.sound.volume * 100),
				bord: FlxG.stage.contains(border),
				filter: FILTER_TYPE
			});
			D.save.flush();
			trace("-- Settings Saved", D.save.load('settings'));
			
		}else
		{
			var SET:Dynamic = D.save.load('settings');

			// Defaults for first run
			if (SET == null) SET = {
					filter:2,
					bord:true,
					vol:85
				};
			FILTER_TYPE = SET.filter;
			setBorder(SET.bord);
			D.snd.setVolume("master", SET.vol / 100);
			trace("-- Settings Applied", SET);
		}
	}//---------------------------------------------------;
	
	
	// - Save or Restore Keyboard Redifined keys
	//   the {keys} object is the one that feeds to D.ctrl.keymap_set(..)
	// - If keys==null, it restores & applies
	public static function SAVE_KEYS(keys:Array<Int> = null)
	{
		D.save.setSlot(0);
		
		if (keys == null)
		{
			// -- Restore keys
			var K = D.save.load('keys');
			if (K == null) return;
			D.ctrl.keymap_set(K);
			trace("-- Keys Restored", K);
		}else{
			D.save.save('keys', keys);
			D.save.flush();
			trace("-- Keys Saved", keys);
		}
	}//---------------------------------------------------;
	
	
	
	
	// --
	public static function SAVE_GAME()
	{
		D.save.setSlot(1);
		var OBJ = {
			ver:VERSION,
			pl:st.player.SAVE(),
			inv:st.INV.SAVE(),
			hud:st.HUD.SAVE(),
			map:st.map.SAVE()
		};
		
		D.save.save('game', OBJ);
		D.save.flush();
		trace("-- GAME SAVED", OBJ);
	}//---------------------------------------------------;
		
	public static function SAVE_EXISTS():Bool
	{
		D.save.setSlot(1);
		return D.save.exists('game');
	}//---------------------------------------------------;
			
	public static function LOAD_GAME():Dynamic
	{
		D.save.setSlot(1);
		return D.save.load('game');
	}//---------------------------------------------------;
	
	
	/**
	   Plays a track from the `musicData` Table, applies Looping infos
	   @param	i 0...4
	**/
	public static function playMusicIndex(i:Int)
	{
		musicIndex = i;
		if (musicIndex >-1)
		
		// Make the music tracks a bit louder in html5, it has muffled audio
		D.snd.playMusic(musicData[i].a, musicData[i].loop, false #if html5 , 1.4 #end );
	}//---------------------------------------------------;
	
	
	/**
	   DOUBLE FUNCTION - SETS initial Values and READS from ItemData
	   Handle some shared options of the FlxMenu
	   Shared between the Main Title Menu and the Gameplay Menu
	   The Ordering matters , because I am doing it by index
	   @param	m the Menu
	   @param	b If set, then this is in SET MODE. Else READ MODE
	   @return
	**/
	public static function menu_handle_shared(m:FlxMenu, ?b:MItemData)
	{
		if (b == null) // SET DATA, when the Page Opens
		{
			m.item_update(0, (t)->t.set(Std.int(FlxG.sound.volume * 100)));
			m.item_update(1, (t)->t.set(D.snd.MUSIC_ENABLED));
			m.item_update(2, (t)->t.set(FlxG.stage.contains(border)));
			m.item_update(3, (t)->t.set(FILTER_TYPE));
		}else{
			
			// This handles option item calls sent from 
			// the main menu AND the pause menu
			switch (b.ID)
			{
				case "c_bord":
					setBorder(b.get());
						
				case "c_shad":
					FILTER_TYPE = cast b.P.c;
					
				case "c_vol":
					var ss:Float = cast(b.get(), Int) / 100;
					if(FlxG.sound.muted && ss>0) FlxG.sound.toggleMuted();
					FlxG.sound.volume = ss;
					
				case "c_mus":
					D.snd.MUSIC_ENABLED = b.get();
					playMusicIndex(musicIndex);
				default:
			}
		}
	}//---------------------------------------------------;
	
	
	static function set_FILTER_TYPE(val:Int):Int
	{
		#if flash
			// Do nothing.
			return FILTER_TYPE = val;
		#else

		if (val == 0)
		{
			FlxG.game.setFilters([]);
		}else
		{
			if (FILTER_TYPE == 0) {
				FlxG.game.setFilters([new openfl.filters.ShaderFilter(SHADER)]);
			}

			if (val == 1)
			{
				// :: SMOOTH/BLUR
				#if html5
				// HTML is already a bit blurry, since it is 640x480 resized up
				SHADER.STRENGTH = [0.12, 0.12];
				SHADER.CHROMAB = 0.66;
				#else
				SHADER.STRENGTH = [0.8, 0.6];
				SHADER.CHROMAB = 0.125;
				#end
				SHADER.SCANLINES = false;
			}else
			{
				// :: CRT
				#if html5
				SHADER.STRENGTH = [0.5, 0.2];
				SHADER.CHROMAB = 0.75;
				#else
				SHADER.STRENGTH = [0.9, 0.25];
				SHADER.CHROMAB = 0.8;
				#end
				SHADER.SCANLINES = true;
			}
		}
		
		FILTER_TYPE = val;
		return FILTER_TYPE;	

		#end // end if (!flash)
	}//---------------------------------------------------;
	
}//--



