/**
 * Future Knight Main Menu
 * ----------------------
 * - Display title, background FX
 * - Main Menu
 * - Help Pages
 * - Fire off DEMOPLAY
 * - Connect to onlineAPI?
 * - Controller Indication POPUP
 * - Cheat Code
 * 
 * =============================================== */

 
package states;

import djA.DataT;
import djA.types.SimpleRect;
import tools.KeyCapture;
import tools.SprDirector;

import djFlixel.core.Dcontrols;

import djFlixel.core.Dtext.DTextStyle;
import djFlixel.fx.BoxFader;
import djFlixel.fx.StarfieldSimple;
import djFlixel.gfx.pal.Pal_CPCBoy;
import djFlixel.other.FlxSequencer;
import djFlixel.D;
import djFlixel.ui.FlxMenu;
import djFlixel.ui.FlxSlides;
import djFlixel.ui.VList;

import flixel.util.FlxTimer;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;

import openfl.display.BitmapData;
import openfl.Assets;

class StateTitle extends FlxState
{	
	// :: Various State Parameters
	var P = {
		im_title_art: "im/game_art.png",
		im_title : "im/title_01.png",
		im_dx : "im/title_02.png",
		im_gamepad: "im/controller_help.png",
		art_delay : 4.0,	// Wait this much on the graphic,
		title_fg : Pal_CPCBoy.COL[24],
		title_tick: 0.125,
		title_cols : [1, 2, 11, 15, 6, 18, 21, 5, 8, 25]	// CPC Boy palete codes for title to loop
	};
	
	// --
	var stars:StarfieldSimple;
	var starsTimer:Float = 0;	// Change stars angle on timer
	
	// This is new, a group that handles sprites for the gui
	var dir0:SprDirector;
	var pFader:BoxFader;
	var seq:FlxSequencer;
	
	// The main menu
	var menu:FlxMenu;
	
	// Help slides
	var slides:FlxSlides;
	
	// --
	var title_01_spr:FlxSprite;	// Title sprite
	var title_02_spr:FlxSprite; // DX sprite
	var title_tick:FlxTimer;	// Timer for the title flash
	
	// I want a dynamic function because in some cases I need to check different things
	var updateFunction:Void->Void;

	
	// -
	override public function create():Void 
	{
		super.create();
		
		bgColor = Reg.BG_COLOR;
		
		// -- Data init
		updateFunction = null;
		
		// --
		seq = new FlxSequencer();
		seq.onStep = sequence_title_start;
		add(seq);

		// :: STARS
		stars = new StarfieldSimple(FlxG.width, FlxG.height, [	
			Pal_CPCBoy.COL[0],
			Pal_CPCBoy.COL[7],
			Pal_CPCBoy.COL[20],
			Pal_CPCBoy.COL[24]
		]);
		stars.WIDE_PIXEL = true;
		stars.STAR_SPEED = 1.9;
			
		
		// :: Setup the animated Title stuff
		title_02_spr = new FlxSprite(P.im_dx);
		var _tb = Assets.getBitmapData(P.im_title, false);
			_tb = D.bmu.replaceColor(_tb, Pal_CPCBoy.COL[28], P.title_fg);
		title_01_spr = new FlxSprite(_tb.clone());
		title_tick = new FlxTimer();
		title_tick.start(P.title_tick, (t)->{
			var l = t.elapsedLoops % P.title_cols.length;
			title_01_spr.pixels = D.bmu.replaceColor(_tb.clone(), Pal_CPCBoy.COL[31], Pal_CPCBoy.COL[P.title_cols[l]]);
			title_01_spr.dirty = true;
			title_02_spr.color = Pal_CPCBoy.COL[P.title_cols[l]];
		}, 0);
		title_tick.active = false;

		
		// -- With a sprite director you can add and animate sprites easily
		dir0 = new SprDirector();		
		dir0.on(P.im_title_art).v(0);
		dir0.on('title', title_01_spr).p(0, -20).v(0);
		dir0.on('dx', title_02_spr).v(0); // Positioned later
	
		add(stars);
		add(dir0);
		
		sub_create_menu();
		
		// :: Fade the screen from black and call seq.nextv()
		pFader = new BoxFader();
		pFader.setColor(Pal_CPCBoy.COL[0]);
		pFader.fadeOff(seq.nextV, {time:0.33});
		add(pFader);
		
		// :: Border
		Reg.add_border();
		
		// --
		D.snd.playMusic('FK_Title');
	}//---------------------------------------------------;	
	
	
	// --
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		
		// :: Change the star angle over time
		//    Easter egg, pressing (LB) , (RB) 
		if ((starsTimer += elapsed) > 0.1) {
			starsTimer = 0;
			stars.STAR_ANGLE += 0.1;
		}else{
			if (D.ctrl.pressed(LB)) {
				stars.STAR_ANGLE -= 0.8;
			}else
			if (D.ctrl.pressed(RB)) {
				stars.STAR_ANGLE += 0.8;
			}
		}
		
		// --
		if (updateFunction != null) 
		{
			updateFunction();
		}
		
	}//---------------------------------------------------;


	// --
	// -- Show the titleArt, then the Title
	function sequence_title_start(step:Int)
	{
		switch(step) {	
		case 1:	//--	show the title
			dir0.on(P.im_title_art).v(1).a(0).tween({alpha:1}, 0.2);
			seq.next(0.4);
		case 2: // --	wait for key or X seconds
			seq.next(Std.int(P.art_delay));
			updateFunction = ()->{
				if(D.ctrl.justPressed(_ANY) || FlxG.mouse.justPressed) {
					seq.next();
				}
			};
		case 3: // --	hide the art
			updateFunction = null;
			dir0.on(P.im_title_art).tween({ alpha:0 }, 0.2);
			seq.next(0.1);
		case 4: // --	show the menu
			D.snd.playV('title');
			dir0.on('title').a(0.5).v(1).tween({alpha:1, y:32}, 0.5, { ease:FlxEase.elasticOut } );
			title_tick.active = true;
			seq.next(0.2);
		case 5:
			dir0.on('dx').v(1).a(0.5).p(274, 32).tween({alpha:1, y:62}, 0.3, { ease:FlxEase.elasticOut } );
			seq.next(0.300);
		case 6:
			dir0.on('footer', sub_get_footer_grp()).p(0, 20).a(0.3).tween({y:0, alpha:1}, 0.2);
			dir0.on('dx').tween({alpha:1, y:65}, 0.3, { ease:FlxEase.quadOut, type:4 } );
			menu.goto('main');
		case 7:

		default:
		}
	}//---------------------------------------------------;
		
	
	/** Create footer objects **/
	function sub_get_footer_grp():FlxSpriteGroup
	{
		var color = Pal_CPCBoy.COL[31];
		// Set a horizontal line and infos below it:
		var line = new FlxSprite(0, 208);
			line.makeGraphic(FlxG.width - 50, 1, color);
			D.align.screen(line, 'c', '');
		var txt_ver = D.text.get("ver " + Reg.VERSION, {c:color});
		var txt_by  = D.text.get("by John Dimi", {c:color});
		D.align.inLine(line.x, line.y, line.width, [txt_ver, txt_by], 'j');
		var grp = new FlxSpriteGroup();
			grp.add(txt_by); grp.add(txt_ver); grp.add(line);
		return grp;
	}//---------------------------------------------------;

	
	// -- Creates and Adds the menu
	function sub_create_menu()
	{
		menu = new FlxMenu(32, 90, FlxG.width);
		menu.PARAMS.start_button_fire = true;
		menu.PARAMS.header_enable = false;
		menu.PARAMS.line_height = 0;
		menu.PARAMS.page_anim_parallel = true;
		menu.stL.focus_nudge = 2;
		menu.stL.vt_in_times = "0.2:0.1";
		menu.stL.vt_out_times = "0.12:0.06";
		menu.stL.vt_in_offset = "-20:0";
		menu.stL.vt_out_offset = "20:0";
		menu.stI.col_t.focus = Pal_CPCBoy.COL[24];
		menu.stI.col_t.accent = Pal_CPCBoy.COL[6];
		menu.stI.col_t.idle = Pal_CPCBoy.COL[27];
		menu.stI.col_b.idle = Pal_CPCBoy.COL[1];
		menu.stL.align = "left";
		menu.stI.text = { s:16, bt:1, so:[2, 2] };
		
		var pg = menu.createPage("main").addM([
			"New Game|link|g_new",
			"Resume|link|g_res",
			"Options|link|@options",	// Goto another page
			"Help|link|help"
		]);
		
		pg.items[0].data.tStyle = {s:8, so:[1, 1], sc:Pal_CPCBoy.COL[31]};	// Alter the font size for the question to fit the screen
		pg.items[0].data.cfm    = "A save exists, start a new game?:yes:no";
		
		menu.createPage("options","options").addM([
			"Keyboard Redefine|link|keyredef",
			"Volume|range|id=vol|range=0,100|step=5",
			"Soft Pixels|toggle|id=softpix|c=false",	// this is going to be altered every time
			"Back|link|@back"
		]);
		
		menu.onMenuEvent = (a, b)->{
		if (a == pageCall) {
				D.snd.playV('cursor_ok');
			}else
			if (a == back){
				D.snd.playV('cursor_back');
			}else				
			if (a == page && b == "options") {
				// Alter the first index of the current
				menu.item_update(1, (t)->{t.data.c = Std.int(FlxG.sound.volume * 100); });	
				menu.item_update(2, (t)->{t.data.c = D.SMOOTHING; });
			}else
			if (a == page && b == "main") {
				var S = Reg.SAVE_EXISTS();
				menu.item_update(1, (t)->{ t.disabled = !S; }); // resume
				menu.item_update(0, (t)->{ // new game
					if (S) { // Fullpage Confirmation
						// <HACK>
						// t.data.type = 3; errors on <HASHLINK>. why wtf.
						Reflect.setProperty(t.data, "type", 3);
					}else{
						Reflect.setProperty(t.data, "type", 1);
					}
				});
			}
		};
		
		menu.onItemEvent = (a, b)->{
			D.ctrl.flush();	// Just in case
			if (a == fire) {
				switch(b.ID){
					case "g_res":
						startGame(false);
					case "g_new":
						startGame(true);
					case "vol":
						FlxG.sound.volume = b.data.c / 100;
					case "softpix":
						D.SMOOTHING = b.data.c;
					case "keyredef":
						menu.close(true);
						sub_get_keys(()->{
							menu.open();
						});
					case "help":
						slides = sub_get_help_slides();
						menu.close();
						add(slides);
						slides.onEvent = (e)->{
							switch(e){
								case "close":
									remove(slides);
									slides = null;
									menu.open();
									D.snd.playV('cursor_back');
								case "next", "previous":
									D.snd.playV('cursor_tick');
								case _:
							}
						};
						FlxG.mouse.reset();	// Just in case
						slides.goto(0);
					case _:
				}
			}
			
			// SOUNDS: 
			switch(a) {
				case fire:
					D.snd.playV('cursor_ok');
					return;
				case focus:
					D.snd.playV('cursor_tick');
					return;
				case _:
			}
		};
		
		add(menu);
	}//---------------------------------------------------;
	
	// :: BUILD and rethrn the help slides
	// - Controls
	// - Item description
	// - Game infos
	function sub_get_help_slides():FlxSlides
	{
		var AREA = new SimpleRect(28, 70, 320 - 28 - 28, 170);
		var COL = Pal_CPCBoy.COL; // Shortcut
		var st_h1 = {f:'fnt/score.ttf', s:12, c:COL[20], bt:1, bc:COL[1]};
		var st_p = {f:'fnt/score.ttf', s:6, c:COL[26]};
		var st_p2 = {f:'fnt/score.ttf', s:6, c:COL[23]};
		D.text.formatAdd('<r>', COL[6]);
		D.text.formatAdd('<g>', COL[21]);
		D.text.fix(); // clear 
		D.ui.pInit(AREA.x, AREA.y, AREA.w, AREA.h);
		
		var h = new FlxSlides({delay:0.08, time:0.12, offset:"-18:0"});
			h.setArrows(8, AREA.x, AREA.y + AREA.h / 2, AREA.w);
		
		// : Slide - Gamepad
		h.newSlide();
		h.a(D.ui.pT("Gamepad Controls", {ta:"c"}, st_h1));
		h.a(D.ui.p(new FlxSprite(P.im_gamepad), {a:"c"}));
			
		// : Slide - Keys
		h.newSlide();
		D.ui.pCol("120|60,16", -1);
		h.a(D.ui.pT("Keyboard Controls", {ta:"c"}, st_h1));
		D.text.fix(st_p);
		D.ui.pPad(6);
			// - Build keys
			var ACTIONS = ['move', 'shoot / <r>cancel<r>', 'jump / <g>ok<g>', 'use item', 'inventory / pause'];
			var KEYS = [DButton.UP, DButton.X, DButton.A, DButton.Y, DButton.START];
			for (i in 0...ACTIONS.length) {
				var keys:String =  i == 0 ? 
					D.ctrl.getKeymapName(UP) + D.ctrl.getKeymapName(LEFT) + D.ctrl.getKeymapName(DOWN) + D.ctrl.getKeymapName(RIGHT)
					: D.ctrl.getKeymapName(KEYS[i]);
				h.a(D.ui.pT('~' + ACTIONS[i], {c:1, ta:"r"}));
				h.a(D.ui.pT('[' + keys.toLowerCase() + ']', {c:2}));
			}
		// DEV: There is a volume bar in the options, don't overcrowd the slides, -- remove --
		// h.a(D.ui.pT('volume up / down', {c:1, ta:"r"}));
		// h.a(D.ui.pT('[-] [+]', {c:2}));
		h.a(D.ui.pT('you can redifine in options', {ta:'c', oy:6}, st_p2));
		
		// :: Slide :: General infos
		h.newSlide();
		var key_up = D.ctrl.getKeymapName(UP).toLowerCase();
		var key_ok = D.ctrl.getKeymapName(A).toLowerCase();
		D.ui.pClear();
		h.a(D.ui.pT('~press UP <g>[$key_up]<g> to interact with objects', {a:'c', oy:8}));
			// Create 4 animated tile sprites, place 3 of them in a row NOW
			var spr:Array<FlxSprite> = [for (i in 0...4) Reg.IM.getSprite(0, 0, 'animtile')];
			spr[0].animation.add('1', [10, 11], 8);
			spr[1].animation.add('1', [4, 5, 6, 7], 8);
			spr[2].animation.add('1', [28, 29], 8);
			spr[3].animation.add('1', [12, 13], 8);
			D.ui.pM([spr[0], spr[1], spr[2]]);
			for (i in 0...4) {
				spr[i].animation.play('1');
				if (i < 3) h.a(spr[i]); // do not add [3]
			}
		h.a(D.ui.pT('to unlock an exit, you need to \nhave the required item equipped', {ta:'c'}));
		h.a(D.ui.p(spr[3], {a:'c'}));
		h.a(D.ui.pT('~Progress is <g>saved<g> automatically.', {ta:'c', oy: -2}));
		// :: Slide :: Some Items
		h.newSlide();
		D.ui.pCol('40|200,16');
		h.a(D.ui.pT('SOME ITEMS YOU CAN FIND', {a:'c', oy:8}, {c:COL[21]}));
		D.ui.pPad(12);
		h.a(D.ui.p(Reg.IM.getSprite(0, 0, 'items', 1), {c:1, a:'r',oy:4}));
		h.a(D.ui.pT('~<r>BOMB<r>\nkill enemies and restore HP', {c:2}));
		D.ui.pClear(false);
		h.a(D.ui.p(Reg.IM.getSprite(0, 0, 'items', 6), {c:1, a:'r', oy:4}));
		h.a(D.ui.pT('~<r>CONFUSER<r>\nimmobilize enemies for a while', {c:2}));
		// -- END SLIDES
		
		h.finalize();
		D.text.fix();
		D.text.formatClear();
		return h;
	}//---------------------------------------------------;
	
	
	/** Redefine keys, sprites and functionality */
	function sub_get_keys(onComplete:Void->Void)
	{
		// This is the same order as the dcontrols 360 layout
		var ACTIONS = ['up', 'right', 'down', 'left', 'ok / jump', '', 'cancel / shoot', 'use item', '', 'pause / inventory'];
		var KEYS = [];	// the actual FlxKeycodes that map to ACTIONS[]		
		var COL = Pal_CPCBoy.COL; // Shortcut
		
		D.text.formatAdd('<m>', COL[24], COL[3]);
		D.ui.pInit(0, 100);
		D.ui.PLACE_ADD = true;
		
		var txt1 = D.ui.pT('-', {ta:'c'}, {f:'fnt/score.ttf', s:6, c:COL[26], bt:1, bc:COL[2]});
		var txt2 = D.ui.pT('-', {ta:'c', oy:20}, {f:'fnt/score.ttf', s:6, c:COL[7]});
		var k = new KeyCapture(ACTIONS);
		k.onEvent = (a, b)->{
			if (a == "wait") {
				D.text.applyMarkup(txt1, "press key for\n<m>[" + b + "]<m>");
				txt2.visible = false;
			}else
			if (a == "error") {
				txt2.text = "key already defined for " + b;
				txt2.visible = true;
				flixel.effects.FlxFlicker.flicker(txt2, 0.5, 0.1);
				D.snd.playV('gen_no');
			}else
			if (a == "ok"){
				D.snd.playV('cursor_ok');
			}
			if (a == "complete") {
				remove(txt1); remove(txt2);
				D.ctrl.keymap_set(k.KEYMAP);
				D.save.setSlot(0);
				D.save.save('keys', k.KEYMAP);
				D.save.flush();
				trace("- SAVED key configuration", k.KEYMAP);
				
				if(onComplete!=null) onComplete();
			}
		};
		k.start();
	}//---------------------------------------------------;
	
	
	function startGame(newGame:Bool)
	{
		menu.unfocus();
		Reg.SAVE_SETTINGS();
		
		if (newGame)
		{
			D.save.deleteSlot(1);
			pFader.fadeColor(0xFF000000, ()->{
				FlxG.switchState(new StateIntro());
			});	
		}else{
			pFader.fadeColor(0xFF000000, ()->{
				FlxG.switchState(new StatePlay());
			});				
		}
	}//---------------------------------------------------;
	
}//-- end --//