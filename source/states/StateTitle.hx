/**
 * Future Knight DX Main Menu
 *
 * =============================================== */
 
package states;

import gamesprites.Enemy;
import tools.KeyCapture;
import tools.SprDirector;

import djA.types.SimpleRect;

import djFlixel.D;
import djFlixel.core.Dcontrols;
import djFlixel.core.Dtext.DTextStyle;
import djFlixel.gfx.FilterFader;
import djFlixel.gfx.StarfieldSimple;
import djFlixel.gfx.pal.Pal_CPCBoy.COL as COL;
import djFlixel.other.FlxSequencer;
import djFlixel.ui.MPlug_Audio;
import djFlixel.ui.FlxMenu;
import djFlixel.ui.FlxSlides;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;

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
		title_fg 	: COL[24],
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
	var updateFunction:Void->Void = null;

	// -
	override public function create():Void 
	{
		super.create();
		
		Reg.st = null;
		
		bgColor = Reg.BG_COLOR;
		
		// --
		seq = new FlxSequencer(sequence_title_start);
		add(seq);

		// :: STARS
		stars = new StarfieldSimple(FlxG.width, FlxG.height, [	
			COL[0], COL[7], COL[20], COL[24]
		]);
		stars.WIDE_PIXEL = true;
		stars.STAR_SPEED = 1.9;
			
		
		// :: Setup the animated Title stuff
		var _tb = Assets.getBitmapData(P.im_title, false);
			_tb = D.bmu.replaceColor(_tb, COL[28], P.title_fg);
		var title_01_spr = new FlxSprite(_tb.clone());
		var title_02_spr = new FlxSprite(P.im_dx);
		title_tick = new FlxTimer();
		title_tick.start(P.title_tick, (t)->{
			var l = t.elapsedLoops % P.title_cols.length;
			title_01_spr.pixels = D.bmu.replaceColor(_tb.clone(), COL[31], COL[P.title_cols[l]]);
			title_01_spr.dirty = true;
			title_02_spr.color = COL[P.title_cols[l]];
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
		
		// DEV: This will only play music if D.snd.MUSIC_ENABLED is true
		Reg.playMusicIndex(4);

	}//---------------------------------------------------;	
	
	
	// --
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		
		// :: Change the star angle over time 
		//    *EASTEREGG* pressing (LB) , (RB) 
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
	function sequence_title_start(sequencer:FlxSequencer):Void
	{	
		var step:Int = sequencer.step;
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
			seq.next(0.5);	
		case 7:
			// -- Done animating the menu.
			if (D.ctrl.gamepad != null)
				_showControllerToast();
				
			updateFunction = ()->{
				// This checks for controller and initializes it once it connects
				// Returns true ONCE when a controller connects
				if ( D.ctrl.gamepad_poll()) _showControllerToast();
				#if debug
				if (FlxG.keys.justPressed.F1) _showControllerToast();
				#end
			}
			
		default:
		}
	}//---------------------------------------------------;
	
	
	function _showControllerToast()
	{
		#if !debug
		if (Reg.FLAG_CONTROLLER_TOAST) return;
			Reg.FLAG_CONTROLLER_TOAST = true;
		#end
		
		var s1 = new FlxSprite(265, 170, 'im/controller_thumb.png');
			s1.alpha = 0;
		FlxTween.tween(s1, {y:186, alpha:1}, 0.8, {ease:FlxEase.bounceOut})
			.then(FlxTween.tween(s1, {alpha:0}, 0.5, {startDelay:0.5,onComplete:(_)->{
				remove(s1);
			}}));
		add(s1);
	}//---------------------------------------------------;
		
	
	/** Create footer objects **/
	function sub_get_footer_grp():FlxSpriteGroup
	{
		var color = COL[31];
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
		menu = new FlxMenu(32, 90, -1, 4);
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
			cursor: {
				tween:{x0: -8, x1: 4, ease:"quadOut"}
			},
			focus_anim:{
				x:2, inTime:0.14
			},
			vt_IN:"-20:0|0.2:0.1",
			vt_OUT:"20:0|0.12:0.06",
			align:"left",
			item:{
				text:{
					s:16, bt:1, so:[2, 2] 
				},
				col_t:{
					focus:COL[24],
					accent:COL[6],
					idle:COL[27]
				},
				col_b:{
					idle:COL[1]
				}
			}
		});
		
		menu.createPage("main").add("
			-| New Game   | link | g_new | ?fs=Save exists.\nstart a new game?:yes:no
			-| Resume     | link | g_res
			-| Options    | link | @options
			-| Help       | link | help
		");
			
		// DEV: The ordering of the first (4) MATTERS.
		//		upon entering this page, those items will be
		//		updated to reflect current status. in <REG.menu_handle_shared>
		var p = menu.createPage("options", "Options").add("
			-| Volume     | range | c_vol | 0,100 | step=5
			-| Music	  | toggle| c_mus
			-| Border     | toggle| c_bord
			-| Shader  	  | list  | c_shad | Off,A,B
			-| Keyboard Redefine | link  | keyredef
			-| Back              | link  | @back
		")
			.par({slots:6,pos:"rel",y:-18})
			.stl({loop:true,align:"center"});

		#if desktop
		p.add('
			-| Fullscreen    | toggle | c_fs |
			-| Window Size   | range  | c_win | 1,${D.MAX_WINDOW_ZOOM} |
		',4);
		#end
		
		menu.onMenuEvent = (a, b)->{
			switch([a,b]){
			case [page,"options"]:
				Reg.menu_handle_shared(menu);
			case [page,"main"]:
				var sx = Reg.SAVE_EXISTS();
				menu.item_update(null,'g_res', (t)->{ t.disabled = !sx; });
				menu.item_update(null,'g_new', (t)->{ t.P.ltype = sx?3:1; });
				// ^DEV: hacking a link to be a full page confirm (3)
				//		 or a simple link (1)
			default:
			}
		};
		
		menu.onItemEvent = (a, b)->{
			if (a == fire) switch (b.ID) {
				// - main
				case "g_res":
					startGame(false);
				case "g_new":
					startGame(true);
				
				// - options
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
					
				default:
					// Handle the rest of option buttons here:
					Reg.menu_handle_shared(menu, b);
			}
		};
		
		
	}//---------------------------------------------------;
	
	// :: BUILD and return the help slides
	// - Controls
	// - Item description
	// - Game infos
	function sub_get_help_slides():FlxSlides
	{
		var AREA = new SimpleRect(28, 70, 320 - 28 - 28, 170);
		var st_h1 = {f:'fnt/score.ttf', s:12, c:COL[20], bt:1, bc:COL[1]};
		var st_p  = {f:'fnt/score.ttf', s:6, c:COL[26]}; 
		var hl = {c:COL[24]}; // overlay over st_p | highlight yellow
		D.text.fix(st_p); // Fix this style for all following text generation from djFlixel tools
		D.text.markupClear();
		D.text.markupAdd('<r>', COL[6]);
		D.text.markupAdd('<g>', COL[21]);

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
		AL.pPad(6);
			// - Build the key strings from whatever is defined
			var ACTIONS = ['move', 'shoot / <r>cancel<r>', 'jump / <g>ok<g>', 'use item', 'inventory / pause'];
			var KEYS = [DButton.UP, DButton.X, DButton.A, DButton.Y, DButton.START];
			for (i in 0...ACTIONS.length) {
				var keys:String =  i == 0 ? 
					D.ctrl.getKeymapName(UP) + D.ctrl.getKeymapName(LEFT) + D.ctrl.getKeymapName(DOWN) + D.ctrl.getKeymapName(RIGHT)
					: D.ctrl.getKeymapName(KEYS[i]);
				h.a(AL.pT('~' + ACTIONS[i], {c:1, ta:"r"}));
				h.a(AL.pT('[' + keys.toLowerCase() + ']', {c:2}, hl));
			}
			h.a(AL.pT('you can redefine in options', {ta:'c', oy:6}, {c:COL[4]}));
		
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
		AL.pCol('46|200,8');
		
		var en1 = new Enemy();
			en1.spawn({x:0, y:0, id:0, type:"none",name:"red"}, 4);		
		var en2 = new Enemy();         
			en2.spawn({x:0, y:0, id:0, type:"none",name:"green"}, 2);		
		var en3 = new Enemy();         
			en3.spawn({x:0, y:0, id:0, type:"none", name:"blue"}, 6);
		
		AL.pPad(16);
		h.a( AL.p(en1, {c:1, a:'r',oy:8}));
		h.a( AL.p(en2, {c:1, a:'r',oy:8}));
		h.a( AL.p(en3, {c:1, a:'r',oy:8}));
		h.a( AL.pT('Enemies damage you by', {c:2, oy:8}, {c:COL[26]}));
		h.a( AL.pT('the amount of their health,', {c:2, oy:8}, {c:COL[26]}));
		h.a( AL.pT('so weakened enemies', {c:2, oy:8}, {c:COL[26]}));
		h.a( AL.pT('damage you less.', {c:2, oy:8}, {c:COL[26]}));

			
		// : Slide - Keys 2
		h.newSlide();
		AL.pCol("120|60,16");
		h.a(AL.pT("Shortcuts", {ta:"c"}, st_h1));
		AL.pPad(6);
		h.a(AL.pT('~Toggle Border', {c:1, ta:"r"}));
		h.a(AL.pT('[F7]', {c:2}, hl));
		h.a(AL.pT('~Cycle Shader', {c:1, ta:"r"}));
		h.a(AL.pT('[F8]', {c:2}, hl));
		#if desktop
		h.a(AL.pT('~Smaller Window', {c:1, ta:"r"}));
		h.a(AL.pT('[F9]', {c:2}, hl));
		h.a(AL.pT('~Bigger Window', {c:1, ta:"r"}));
		h.a(AL.pT('[F10]', {c:2}, hl));
		h.a(AL.pT('~Toggle Fullscreen', {c:1, ta:"r"}));
		h.a(AL.pT('[F11]', {c:2}, hl));
		#end
		h.a(AL.pT('Volume mute/down/up', {c:1, ta:"r"}));
		h.a(AL.pT('[0] [-] [+]', {c:2}, hl));
		
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
				Reg.SAVE_KEYS(k.KEYMAP);
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
			Reg.FLAG_SECOND_CHANCE = 0;
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