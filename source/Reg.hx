package;

import djA.cfg.ConfigFileB;
import djFlixel.D;
import djFlixel.ui.FlxMenu;
import djFlixel.ui.menu.MItemData;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.system.FlxAssets;
import flixel.system.scaleModes.PixelPerfectScaleMode;
import openfl.display.Bitmap;
import states.StatePlay;
import states.SubStatePause;


/**
 * Various Global Vars/Functiona
 */
class Reg 
{
	
	public static inline var VERSION = "1.4";
	
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
								// e.g. when player collides with BOSS, both will get hurt by this much3
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
	
	// Keeps what sound is supposed to be playing right now
	// Useful for when Muting/Unmuting the sounds. It will play this one
	static var musicIndex:Int = -1;
	
	// All states default BG color,
	public static var BG_COLOR:Int = 0xFF000000;
	
	// This is the first level that a new game will start with
	public static var START_MAP = 'level_01';
	
	// This is for quick access to game elements
	public static var st:StatePlay;
	
	// Decorative Amstrad CPC screen border
	// This is an openfl object, not flixel
	public static var border:Bitmap;
	
	// Called from anywhere to send small messages to the Play State
	public static var sendGameEvent:String->?gamesprites.AnimatedTile->Void;
	
	// Basic Smoothing Helper >> toreplace
	// public static var BLUR:GF_Blur;
	
	//====================================================;
	
	// Gets called once After FLXGame and before first State
	public static function init()
	{
		trace(" >>> Reg init() ");
		
		D.ui.initIcons([8]);
		D.assets.HOT_LOAD = [PATH_INI];
		D.assets.onLoad = onAssetLoad;
		D.assets.loadNow();
		
		//BLUR = new GF_Blur(0.5, 1.7, 2);
		
		#if debug
			new Debug();
		#end
		
		#if html5
			// Font size fix for autotext mostly
			D.text.HTML_FORCE_LEADING.set('fnt/text.ttf', [16, -8]);
			D.text.HTML_FORCE_LEADING.set('fnt/arcade.ttf', [10, -3]);
		#end
		
		// -- Game things:
		IM = new ImageAssets();
		
		// -- Add the border
		var b = border = new Bitmap(FlxAssets.getBitmapData(Reg.IM.STATIC.overlay_scr), "always", true);
		//b.smoothing = true;
		FlxG.game.addChild(b);
		#if FLX_DEBUG
		FlxG.game.swapChildren(b, FlxG.game.debugger); // Put the debugger on top of the overlay
		#end
		FlxG.signals.gameResized.add(onResize);
		onResize(0, 0);
		
		// -- Restore Settings
		D.save.setSlot(0);
		var _LS = D.save.load('settings');
		if (_LS != null) {
			//D.SMOOTHING = _LS.aa; >>
			border.visible = _LS.bord;
			D.snd.setVolume("master", _LS.vol);
			trace(" -- Settings Restored", _LS);
		}
		
		// -- Restore keys
		var _LK = D.save.load('keys');
		if (_LK != null) {
			D.ctrl.keymap_set(_LK);
			trace(" -- Keys Restored", _LK);
		}
		
		FlxG.scaleMode = new PixelPerfectScaleMode();	// This makes the HL target graphics nice.
		FlxG.sound.soundTrayEnabled = false;
		
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
		border.width = FlxG.scaleMode.gameSize.x;
		border.height = FlxG.scaleMode.gameSize.y;
	}//---------------------------------------------------;
		
	public static function openPauseMenu()
	{
		st.openSubState(new SubStatePause());
	}//---------------------------------------------------;
	
	// --
	// DEV: Settings restored in REG.init();
	public static function SAVE_SETTINGS()
	{
		D.save.setSlot(0);
		D.save.save('settings', {
			bord:  border.visible,
			vol: FlxG.sound.volume
		});
		D.save.flush();
		trace("-- Settings Saved", D.save.load('settings'));
	}//---------------------------------------------------;
	
	// --
	public static function SAVE_GAME()
	{
		D.save.setSlot(1);
		var OBJ = {
			ver:Reg.VERSION,
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
	   Plays a track from the {musicData} Table, applies Looping infos
	   @param	i
	**/
	public static function playMusicIndex(i:Int)
	{
		musicIndex = i;
		if (musicIndex >-1)
		D.snd.playMusic(musicData[i].a, musicData[i].loop);
	}//---------------------------------------------------;
	
	
	/**
	   DOUBLE FUNCTION - SETS initial Values and READS from ItemData
	   Handle some common options of the FlxMenu
	   Shared between the Main Title Menu and the Gameplay Menu
	   The Ordering matters , because I am doing it by index
	   @param	m the Menu
	   @param	m If set, then this is in SET MODE. Else READ MODE
	   @return
	**/
	public static function menu_handle_common(m:FlxMenu, ?b:MItemData)
	{
		if (b == null) // SET DATA, when the Page Opens
		{
			m.item_update(0, (t)->t.set(Std.int(FlxG.sound.volume * 100)));
			m.item_update(1, (t)->t.set(D.snd.MUSIC_ENABLED));
			m.item_update(2, (t)->t.set(Reg.border.visible));
			//menu.item_update(3, (t)->t.set(Reg.border.visible)); // SHADER, TODO
		}else{
			
			// READ and apply DATA from the item
			switch (b.ID)
			{
				case "c_bord":
					Reg.border.visible = b.get();
						
				case "c_shad":
					trace("TODO");
						
				case "c_vol":
					FlxG.sound.volume = cast(b.get(), Int) / 100;
					
				case "c_mus":
					D.snd.MUSIC_ENABLED = b.get();
					playMusicIndex(musicIndex);
					
				default:
			}
			
		}
	
	}
	
	
}//--



