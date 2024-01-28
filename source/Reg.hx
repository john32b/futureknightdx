package;

import flixel.FlxGame;
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
import openfl.Lib;

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
	// Debug: overriden in `fkdx.ini`
	public static var START_MAP = 'level_01';
	
	// This is for quick access to game elements
	public static var st:StatePlay;
	
	// Called from anywhere to send small messages to the Play State
	public static var sendGameEvent:String->?gamesprites.AnimatedTile->Void;
	
	/** Setter - Sets the current shader (0:None | 1:Blur | 2:CRT ) + edges loop **/
	public static var SHADER_INDEX(default, set):Int = 0;

	/** Setter - enables/disables the CPC Border */
	public static var BORDER_STATUS(default, set):Bool = false;

	/** Setter - Sets window size, integer scaling.**/
	public static var WINDOW_SIZE(default, set):Int = 2;	// 2 is the FlxGame zoom, default
	
	/** In any time during the lifetime did it show the controller connected toast? */
	public static var FLAG_CONTROLLER_TOAST:Bool = false;
	
	//====================================================;
	
	// Gets called once After FLXGame and before first State
	public static function init()
	{
		trace('> Reg init. Game version : ${VERSION}');

		D.ui.initIcons([8]);
		D.assets.HOT_LOAD = [PATH_INI];
		D.assets.onLoad = ()->{
			INI = new ConfigFileB(D.assets.files.get(PATH_INI));
			D.snd.addSoundInfos(INI.getObj('sounds_vol'));
		};
		D.assets.loadNow();	// Triggers onLoad()^^ to parse the config files for the first boot
		
		#if debug
			new Debug();
		#end
		
		IM = new ImageAssets();

		SHADER = new CRTShader();
		#if !flash
		FlxG.game.setFilters([new openfl.filters.ShaderFilter(SHADER)]);
		#end
		FlxG.game.filtersEnabled = false;

		SAVE_SETTINGS(false);	// restore & apply
		SAVE_KEYS();			// restore & apply keys
		
		// DEV: declare onResize after setting scalemode.
		// 		it is going to be called once now and one more time after this (?)
		FlxG.signals.gameResized.add(onResize);
		
		// --
		FlxG.autoPause = false;
		FlxG.sound.soundTrayEnabled = false;

		D.ctrl.hotkey_add(F7, _cycle_border);
		D.ctrl.hotkey_add(F8, _cycle_shader);
		D.ctrl.hotkey_add(F9, _cycle_window_size.bind(true));
		D.ctrl.hotkey_add(F10,_cycle_window_size.bind(false));
		D.ctrl.hotkey_add(F11,_cycle_fs);
	}//---------------------------------------------------;
	
	
	// == Flixel Signal
	// - handle shader/border resize
	static function onResize(w:Int,h:Int)
	{
		// trace(": Game Resized", w, h);
		border.x = FlxG.game.x;
		border.y = FlxG.game.y;
		border.width = FlxG.scaleMode.gameSize.x;
		border.height = FlxG.scaleMode.gameSize.y;
		
		SHADER.setWinSize(w, h);

		// == OPENFL QUIRK (BUG?)
		// The filters need to regenerate
		// For some reason I can't unset-set a filter on the same frame, or even the next one
		// Using a timed delay for 2 frames works.
		FlxG.game.filtersEnabled = false;

		if (SHADER_INDEX > 0) 
		{
			// DEV: The very first call, right after FlxGame creates
			// elapsed is 0, but this still works fine
			new DelayCall(FlxG.elapsed * 2, ()->{
				FlxG.game.filtersEnabled = true;
			});
		}
		
	}//---------------------------------------------------;

	// - Called from Inventory / player
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
				fs: FlxG.fullscreen,
				win: WINDOW_SIZE,
				filter: SHADER_INDEX
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
					fs:false,
					win:2,
					vol:85
				};
			SHADER_INDEX = SET.filter;
			BORDER_STATUS = SET.bord;
			D.snd.setVolume("master", SET.vol / 100);
			FlxG.fullscreen = SET.fs;
			WINDOW_SIZE = SET.win;
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
			m.item_update(3, (t)->t.set(SHADER_INDEX));
			#if desktop
			m.item_update(4, (t)->t.set(FlxG.fullscreen));
			m.item_update(5, (t)->{
					t.disabled = FlxG.fullscreen;
					t.set(WINDOW_SIZE);
				});
			#end
		}else{
			
			// This handles option item calls sent from 
			// the main menu AND the pause menu
			switch (b.ID)
			{
				#if desktop
				case "c_fs":
					FlxG.fullscreen = b.get();
					m.item_update(5, (t)->{
						t.disabled = FlxG.fullscreen;
					});
				case "c_win":
					WINDOW_SIZE = b.get();
				#end
				case "c_bord":
					BORDER_STATUS = b.get();
				case "c_shad":
					SHADER_INDEX = cast b.P.c;
					
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

	// -- called from hotkey
	static function _cycle_fs()
	{
		FlxG.fullscreen = !FlxG.fullscreen;
	}// -------------------------;

	// -- called from hotkey
	static function _cycle_border()
	{
		BORDER_STATUS = !BORDER_STATUS;
	}// -------------------------;

	// -- called from hotkey
	static function _cycle_shader()
	{
		SHADER_INDEX++;	// Should automatically loop
	}// -------------------------;

	// -- called from hotkey
	static function _cycle_window_size(down:Bool = false)
	{
		if(down) WINDOW_SIZE--; else WINDOW_SIZE++;
	}// -------------------------;
	
	// - Setter
	static function set_SHADER_INDEX(val:Int):Int
	{
		#if flash
			return SHADER_INDEX = 0;
		#else

		// Loop, for easy cycling
		if(val<0) val=2; else 
		if(val>2) val=0;
		if (SHADER_INDEX == val) return val;

		if (val == 0) {
			FlxG.game.filtersEnabled = false;
		} else {
			FlxG.game.filtersEnabled = true;
			if (val == 1) {
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
			} else {
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
		
		SHADER_INDEX = val;
		return SHADER_INDEX;	

		#end // end if (!flash)
	}// -------------------------;

	// - Setter
	public static function set_BORDER_STATUS(val:Bool):Bool
	{
		if (border == null) {
			border = new Bitmap(FlxAssets.getBitmapData(IM.STATIC.overlay_scr));
			border.smoothing = true;
		}

		if(BORDER_STATUS==val) return val;

		if (val){
			if(!FlxG.stage.contains(border))
				FlxG.stage.addChild(border);
		}else{
			if(FlxG.stage.contains(border))
				FlxG.stage.removeChild(border);
		}
		return (BORDER_STATUS = val);
	}// -------------------------;


	// - Setter
	public static function set_WINDOW_SIZE(val:Int):Int
	{
		if(val<1) val=1; else if(val>D.MAX_WINDOW_ZOOM) val=D.MAX_WINDOW_ZOOM;
		if(val==WINDOW_SIZE) return val;
		if(!FlxG.fullscreen) {
			D.setWindowed(val);
			// trace("-- Windowed mode set : " + WINDOW_SIZE);
		}
		return WINDOW_SIZE=val;
	}// -------------------------;
	

}//--



