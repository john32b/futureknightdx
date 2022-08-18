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

import djA.Fsm;
import djFlixel.gfx.FilterFader;
import djFlixel.ui.MPlug_Audio;
import flash.ui.Keyboard;
import tools.KeyCapture;
import tools.SprDirector;

import djA.DataT;
import djA.types.SimpleRect;

import djFlixel.D;
import djFlixel.core.Dcontrols;
import djFlixel.core.Dtext.DTextStyle;
import djFlixel.gfx.StarfieldSimple;
import djFlixel.gfx.pal.Pal_CPCBoy;
import djFlixel.other.FlxSequencer;
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
		im_title_art: 	"im/game_art.png",
		im_title : 		"im/title_01.png",
		im_dx : 		"im/title_02.png",
		im_gamepad: 	"im/controller_help.png",
		title_fg 	: Pal_CPCBoy.COL[24],
		title_tick	: 0.125,
		title_cols 	: [1, 2, 11, 15, 6, 18, 21, 5, 8, 25],	// CPC Boy palete codes for title to loop
		art_delay : 4.0	// Wait this much on the graphic,
	};
	
	// --
	var stars:StarfieldSimple;
	var starsTimer:Float = 0;	// Change stars angle on timer
	
	// This is new, a group that handles sprites for the gui
	var dir0:SprDirector;
	var seq:FlxSequencer;
	
	var menu:FlxMenu;
	var slides:FlxSlides;		// Help Slides
	
	// --
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
		var _tb = Assets.getBitmapData(P.im_title, false);
			_tb = D.bmu.replaceColor(_tb, Pal_CPCBoy.COL[28], P.title_fg);
		var title_01_spr = new FlxSprite(_tb.clone());
		var title_02_spr = new FlxSprite(P.im_dx);
		title_tick = new FlxTimer();
		title_tick.start(P.title_tick, (t)->{
			var l = t.elapsedLoops % P.title_cols.length;
			title_01_spr.pixels = D.bmu.replaceColor(_tb.clone(), Pal_CPCBoy.COL[31], Pal_CPCBoy.COL[P.title_cols[l]]);
			title_01_spr.dirty = true;
			title_02_spr.color = Pal_CPCBoy.COL[P.title_cols[l]];
		}, 0);
		title_tick.active = false;

		// :: With a sprite director you can add and animate sprites easily
		dir0 = new SprDirector();		
		dir0.on(P.im_title_art).v(0);
		dir0.on('title', title_01_spr).p(0, -20).v(0);
		dir0.on('dx', title_02_spr).v(0); // Positioned later
	
		add(stars);
		add(dir0);
		
		// --
		sub_create_menu();
		
		// :: Fade the screen from black and call seq.nextv()
		new FilterFader(false, seq.nextV, {time:0.6});
		
		// ::
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
		if (updateFunction != null) {
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
		var txt_by  = D.text.get("by John32B", {c:color});
		D.align.inLine(line.x, line.y, line.width, [txt_ver, txt_by], 'j');
		var grp = new FlxSpriteGroup();
			grp.add(txt_by); grp.add(txt_ver); grp.add(line);
		return grp;
	}//---------------------------------------------------;

	
	// -- Creates and Adds the menu
	function sub_create_menu()
	{
		menu = new FlxMenu(32, 90, FlxG.width);
		menu.PAR.start_button_fire = true;
		menu.PAR.page_anim_parallel = true;
		add(menu);
		
		menu.plug(new MPlug_Audio({
			pageCall:"cursor_ok",
			back:"cursor_back",
			it_fire:"cursor_ok",
			it_focus:"cursor_tick",
			it_invalid:"gen_no"
		}));
		
		menu.overlayStyle({
			focus_nudge:2,
			vt_IN:"-20:0|0.2:0.1",
			vt_OUT:"20:0|0.12:0.06",
			align:"left",
			item:{
				text:{
					s:16, bt:1, so:[2, 2] 
				},
				col_t:{
					focus:Pal_CPCBoy.COL[24],
					accent:Pal_CPCBoy.COL[6],
					idle:Pal_CPCBoy.COL[27]
				},
				col_b:{
					idle:Pal_CPCBoy.COL[1]
				}
			}
		});
		
		menu.createPage("main").add("
			-| New Game   | link | g_new | ?fs=Save exists.\nstart a new game?:yes:no
			-| Resume     | link | g_res
			-| Options    | link | @options
			-| Help       | link | help
		");
			
		menu.createPage("options", "Options").add("
			-| Keyboard Redefine  | link  | keyredef
			-| Volume             | range | vol | 0,100 | step=5
			-| Border Toggle      | toggle| bord | c=false
			-| Back               | link  | @back
		");
			
		
		menu.onMenuEvent = (a, b)->{
			if (a == page && b == "options") {	// Options page just came on
				
				// Alter the first index of the current
				menu.item_update(1, (t)->t.set(Std.int(FlxG.sound.volume * 100)));
				menu.item_update(2, (t)->t.set(Reg.border.visible));
			}else
			
			if (a == page && b == "main") {
				var S = Reg.SAVE_EXISTS();
				menu.item_update(1, (t)->{ t.disabled = !S; }); // resume
				menu.item_update(0, (t)->{ // new game
					if (S) { // Fullpage Confirmation
						// <HACK>
						// t.data.type = 3; errors on <HASHLINK>. why wtf.
						Reflect.setProperty(t.P, "ltype", 3);
					}else{
						Reflect.setProperty(t.P, "ltype", 1);
					}
					
				});
			}
		};
		
		menu.onItemEvent = (a, b)->{
			D.ctrl.flush();	// Just in case
			if (a == fire) switch(b.ID) {
				case "g_res":
					startGame(false);
				case "g_new":
					startGame(true);
				case "vol":
					FlxG.sound.volume = cast(b.get(),Int) / 100;
				case "softpix":
					D.SMOOTHING = b.get();
				case "bord":
					Reg.border.visible = b.get();
				case "keyredef":
					menu.close(true);
					sub_get_keys( ()->menu.open() );
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
		};
		
		
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
		var st_p  = {f:'fnt/score.ttf', s:6, c:COL[26]};
		var st_p2 = {f:'fnt/score.ttf', s:6, c:COL[23]};
		D.text.markupClear();
		D.text.markupAdd('<r>', COL[6]);
		D.text.markupAdd('<g>', COL[21]);
		D.text.fix(); // clear 
		var AL = D.align;
		AL.pInit(AREA.x, AREA.y, AREA.w, AREA.h);
		
		var h = new FlxSlides({delay:0.08, time:0.12, offset:"-18:0"});
			h.setArrows(8, AREA.x, AREA.y + AREA.h / 2, AREA.w);
		
		// : Slide - Gamepad
		h.newSlide();
		h.a(AL.pT("Gamepad Controls", {ta:"c"}, st_h1));
		h.a(AL.p(new FlxSprite(P.im_gamepad), {a:"c"}));
			
		// : Slide - Keys
		h.newSlide();
		AL.pCol("120|60,16", -1);
		h.a(AL.pT("Keyboard Controls", {ta:"c"}, st_h1));
		D.text.fix(st_p);
		AL.pPad(6);
			// - Build keys
			var ACTIONS = ['move', 'shoot / <r>cancel<r>', 'jump / <g>ok<g>', 'use item', 'inventory / pause'];
			var KEYS = [DButton.UP, DButton.X, DButton.A, DButton.Y, DButton.START];
			for (i in 0...ACTIONS.length) {
				var keys:String =  i == 0 ? 
					D.ctrl.getKeymapName(UP) + D.ctrl.getKeymapName(LEFT) + D.ctrl.getKeymapName(DOWN) + D.ctrl.getKeymapName(RIGHT)
					: D.ctrl.getKeymapName(KEYS[i]);
				h.a(AL.pT('~' + ACTIONS[i], {c:1, ta:"r"}));
				h.a(AL.pT('[' + keys.toLowerCase() + ']', {c:2}));
			}
		// DEV: There is a volume bar in the options, don't overcrowd the slides, -- remove --
		// h.a(AL.pT('volume up / down', {c:1, ta:"r"}));
		// h.a(AL.pT('[-] [+]', {c:2}));
		h.a(AL.pT('you can redifine in options', {ta:'c', oy:6}, st_p2));
		
		// :: Slide :: General infos
		h.newSlide();
		var key_up = D.ctrl.getKeymapName(UP).toLowerCase();
		var key_ok = D.ctrl.getKeymapName(A).toLowerCase();
		AL.pClear();
		h.a(AL.pT('~press UP <g>[$key_up]<g> to interact with objects', {a:'c', oy:8}));
			// Create 4 animated tile sprites, place 3 of them in a row NOW
			var spr:Array<FlxSprite> = [for (i in 0...4) Reg.IM.getSprite(0, 0, 'animtile')];
			spr[0].animation.add('1', [10, 11], 8);
			spr[1].animation.add('1', [4, 5, 6, 7], 8);
			spr[2].animation.add('1', [28, 29], 8);
			spr[3].animation.add('1', [12, 13], 8);
			AL.pM([spr[0], spr[1], spr[2]]);
			for (i in 0...4) {
				spr[i].animation.play('1');
				if (i < 3) h.a(spr[i]); // do not add [3]
			}
		h.a(AL.pT('to unlock an exit, you need to \nhave the required item equipped', {ta:'c'}));
		h.a(AL.p(spr[3], {a:'c'}));
		h.a(AL.pT('~Progress is <g>saved<g> automatically.', {ta:'c', oy: -2}));
		// :: Slide :: Some Items
		h.newSlide();
		AL.pCol('40|200,16');
		h.a(AL.pT('SOME ITEMS YOU CAN FIND', {a:'c', oy:8}, {c:COL[21]}));
		AL.pPad(12);
		h.a(AL.p(Reg.IM.getSprite(0, 0, 'items', 1), {c:1, a:'r',oy:4}));
		h.a(AL.pT('~<r>BOMB<r>\nkill enemies and restore HP', {c:2,oy:8}));
		AL.pClear(false);
		h.a(AL.p(Reg.IM.getSprite(0, 0, 'items', 6), {c:1, a:'r', oy:4}));
		h.a(AL.pT('~<r>CONFUSER<r>\nimmobilize enemies for a while', {c:2,oy:8}));
		// -- END SLIDES
		
		h.finalize();
		D.text.fix();
		return h;
	}//---------------------------------------------------;
	
	
	/**
	   Redefine Keys 
	   - Asks for keys
	   - Sets in D.ctrl and Saves Settings
	**/
	function sub_get_keys(onComplete:Void->Void)
	{
		// This is the same order as the Dcontrols 360 layout
		var ACTIONS = ['up', 'right', 'down', 'left', 'ok / jump', '', 'cancel / shoot', 'use item', '', 'pause / inventory'];
		var KEYS = [];	// The actual FlxKeycodes that map to ACTIONS[]		
		var COL = Pal_CPCBoy.COL; // Quick typing
		
		D.text.markupClear();
		D.text.markupAdd('<m>', COL[24], COL[3]);
		D.align.pInit(0, 100);
		D.align.PLACE_ADD = true;
		
		var txt1 = D.align.pT('-', {ta:'c'}, {f:'fnt/score.ttf', s:6, c:COL[26], bt:1, bc:COL[2]});
		var txt2 = D.align.pT('-', {ta:'c', oy:20}, {f:'fnt/score.ttf', s:6, c:COL[7]});
		
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
		
		if (newGame) {
			D.save.deleteSlot(1);
			new FilterFader(true, ()->{
				FlxG.switchState(new StateIntro());
			});
			
		}else{
			new FilterFader(true, ()->{
				FlxG.switchState(new StatePlay());
			});				
		}
	}//---------------------------------------------------;
	
}//-- end --//