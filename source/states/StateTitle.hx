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

import tools.SprDirector;

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
	

	// :: HELP PAGE :
	var tstyle1:DTextStyle = {c:Pal_CPCBoy.COL[20]};
	var tstyle2:DTextStyle = {c:Pal_CPCBoy.COL[2]};
	var help_slides:FlxSlides;
	
	
	
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
	var title_tickr:FlxTimer;	// Timer for the title flash
	
	// I want a dynamic function because in some cases I need to check different things
	var updateFunction:Void->Void;

	// -
	override public function create():Void 
	{
		super.create();
		
		//FlxG.vcr.stopReplay(); // In case it was called from a replay from the game???
		
		// -- Data init
		updateFunction = null;
		
		// --
		seq = new FlxSequencer(sequence_title_start);
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
		title_tickr = new FlxTimer();
		title_tickr.start(P.title_tick, (t)->{
			var l = t.elapsedLoops % P.title_cols.length;
			title_01_spr.pixels = D.bmu.replaceColor(_tb.clone(), Pal_CPCBoy.COL[31], Pal_CPCBoy.COL[P.title_cols[l]]);
			title_01_spr.dirty = true;
			title_02_spr.color = Pal_CPCBoy.COL[P.title_cols[l]];
		}, 0);
		title_tickr.active = false;

		
		// -- With a sprite director you can add and animate sprites easily
		dir0 = new SprDirector();		
		dir0.on(P.im_title_art).v(0);
		dir0.on('title', title_01_spr).p(0, -20).v(0);
		dir0.on('dx', title_02_spr).v(0); // Positioned later
		
		
		
		// --
		//popup_controller = new FlxSpriteGroup();
		// - Create it and leave it alone, until the GAMEAPI calls it
		
		//infoGroup = new FlxSpriteGroup();
		//infoGroup.visible = false;

		//// -- Create toast info on connect, now or later
		//
		//// In case it was skipped on the preloader?
		//if (Reg.api.connectStatus == "offline" && Reg.api.SERVICE_NAME != "Offline") {
			//trace("-- Trying to connect to ONLINE API");
			//Reg.api.connect();
		//}
		//Reg.api.callOnConnect(callback_ApiConnected);

		//// -- Menu
		//sub_create_menu();
		//
		//// --
		//// -- Pages
		//pageScrPos = new SimpleCoords(32, 86);
		//helpPages = new FlxMenuPages(16, 86, 256 + 32, 154);
		//helpPages.callback_action = function(ev:String) {
			//if (ev == "change") {
				//SND.play("cursor");
			//}else { // must be Back, since nothing else can be triggered
				//infoGroup.visible = true;
				//helpPages.visible = false;
				//menu.showPage("main");
				//menu.option_highlight("help");
			//}
		//};
		//
		//sub_createHelp();
		//
		//// Start the sequence
		
		add(stars);
		add(dir0);
		
		sub_create_menu();
		
		//add(groupMisc);
		//add(menu);
		//add(helpPages);

		// :: Fade the screen from black and call seq.nextv()
		pFader = new BoxFader();
		pFader.setColor(Pal_CPCBoy.COL[0]);
		pFader.fadeOff(seq.nextV, {time:0.33});
		add(pFader);
		
		// :: Border
		Reg.add_border();
		
		// --
		// D.snd.playMusic(Reg.musicVers[Reg.musicVer]);
		
		//flag_cheat_step1 = false;
		
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
		
		
		//
		//// Check for a gamepad at an interval,
		//// Can only trigger once
		//if (Controls.poll())
		//{
			//showControllerPopup();
		//}
		//
		//// -- CHEATS :: -------------::
		//
		//if (!flag_cheat_step1 && FlxG.keys.pressed.ALT && FlxG.keys.pressed.CONTROL && FlxG.keys.pressed.SEMICOLON )
		//{
			//trace("Warning: Level Skip, Ready to go.");	
			//SND.play("fx_exit3");
			//flag_cheat_step1 = true;
		//}// --
		//
		//if (flag_cheat_step1) 
		//{
			//// SKIP TO LEVEL CHEAT
			//if (FlxG.keys.pressed.CONTROL && FlxG.keys.pressed.L)
			//{
				//var lvlToSkip:Int = 0;
		//
				//if (FlxG.keys.pressed.TWO) lvlToSkip = 2;
				//else if (FlxG.keys.pressed.THREE) lvlToSkip = 3;
				//else if (FlxG.keys.pressed.FOUR) lvlToSkip = 4;
				//else if (FlxG.keys.pressed.FIVE) lvlToSkip = 5;
				//else if (FlxG.keys.pressed.SIX) lvlToSkip = 6;
				//else if (FlxG.keys.pressed.SEVEN) lvlToSkip = 7;
	//
				//if (lvlToSkip > 0) {
					//trace("Warning: Skip to level ",lvlToSkip);
					//fadeSwitch(new StateMain("skip", lvlToSkip));
				//}
			//}
		//}
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
			//SND.playFile("title");
			dir0.on('title').a(0.5).v(1).tween({alpha:1, y:32}, 0.5, { ease:FlxEase.elasticOut } );
			title_tickr.active = true;
			seq.next(0.2);
		case 5:
			dir0.on('dx').v(1).a(0.5).p(274, 32).tween({alpha:1, y:62}, 0.3, { ease:FlxEase.elasticOut } );
			seq.next(0.300);
		case 6:
			dir0.on('footer', sub_getFooterGroup()).p(0, 20).a(0.3).tween({y:0, alpha:1}, 0.2);
			dir0.on('dx').tween({alpha:1, y:65}, 0.3, { ease:FlxEase.quadOut, type:4 } );
			menu.goto('main');
		case 7:

		default:
		}
	}//---------------------------------------------------;

	
	// --
	// -- Create the help pages
	function sub_createHelp()
	{		
		//var startX = pageScrPos.x;
		//var startY = pageScrPos.y;
		//var lineH = 10;
		//var page:Array<FlxSprite>;
		//
		//// PAGE 0,1 CONTROLS
		//page = helpPages.createPage(0);
		//page.push(new FlxSprite(startX, startY, "assets/images/help_controller_02.png"));
		//page = helpPages.createPage(1);
		//startY = pageScrPos.y;
		//page.push(new FlxSprite(startX, startY, "assets/images/help_controller_01.png")); startY += 80;
		//page.push(getStyledTextH("Press a button on a gamepad to activate it.", startX + 20, startY)); 
//
		////PAGE - Tiles
		//page = helpPages.createPage(2);
		//startY = pageScrPos.y;
		//spriteLabelX_offset = 32;
		//spriteLabelY_size = 42;
		//addSpriteLabelToPage(page, 0, 0, AnimatedTile.getSprite(AnimatedTile.HAZARD), "Hazard", "Avoid!");
		//addSpriteLabelToPage(page, 0, 1, AnimatedTile.getSprite(AnimatedTile.EXIT), "Exit", "Press up to go through it");
		//addSpriteLabelToPage(page, 0, 2, AnimatedTile.getSprite(AnimatedTile.WEAPON_2), "Weapon Station", "Press up to change weapons");
		//
		////PAGE - Items
		//page = helpPages.createPage(3);
		//startY = pageScrPos.y;
		//spriteLabelX_offset = 12;
		//spriteLabelY_size = 30;
		//// -- add items programmatically --
		//var cc = 0;
		//for (i in [ItemType.BOMB, ItemType.SUPERBOMB, ItemType.HEALTH, ItemType.CONFUSER]) {
			//var iData = Item.getItemDataByID(i);
			//addSpriteLabelToPage(page, 0, cc++, Item.getSprite(i), iData.name, iData.desc);
		//}
		//
		////PAGE - Enemies
		//page = helpPages.createPage(4);
		//startY = pageScrPos.y;
		//spriteLabelX_offset = 24;
		//spriteLabelY_size = 40;
		//addSpriteLabelToPage(page, 0, 0, new Enemy().setAsSprite(EnemySprite.GHOST), "Ghost", "");
		//addSpriteLabelToPage(page, 1, 0, new Enemy().setAsSprite(EnemySprite.SLIME), "Slime", "");
		//addSpriteLabelToPage(page, 0, 1, new Enemy().setAsSprite(EnemySprite.ROBOT), "Robot", "");
		//addSpriteLabelToPage(page, 1, 1, new Enemy().setAsSprite(EnemySprite.TURRET), "Turret", "Shoots bullets");
		//addSpriteLabelToPage(page, 0, 2, new Enemy().setAsSprite(EnemySprite.SKULL),  "Skull", "");
		//addSpriteLabelToPage(page, 1, 2, new Enemy().setAsSprite(EnemySprite.BIGROBOT1), "Big Robot", "");
		
	}//---------------------------------------------------;
	
	
	// -- These vars are for quick hack modifications to positions
	//var spriteLabelX_offset:Int = 0;
	//var spriteLabelX_size:Int = 112;
	//var spriteLabelY_size:Int = 32;
	// --
	// -- Add a sprite with some description text to a page
	function addSpriteLabelToPage(page:Array<FlxSprite>, col:Int, row:Int, spr:FlxSprite, txt1:String = "", txt2:String = "")
	{
		//var startY = pageScrPos.y + ( spriteLabelY_size * row );
		//var startX = spriteLabelX_offset + pageScrPos.x + ( spriteLabelX_size * col );
		//
		//spr.setPosition(startX, startY);
		//page.push(spr);
		//
		//startX += Std.int(spr.width) + 8;
	//
		//if (txt1 != "")
		//{
			//page.push(getStyledTextH(txt1, startX, startY));
		//}
		//
		//if (txt2 != "")
		//{
			//page.push(getStyledText(txt2, startX, startY + 12));
		//}
	}//---------------------------------------------------;
	
	// --
	inline function getStyledTextH(text:String, x:Float = 0, y:Float = 0 ):FlxText
	{
		//var t = new FlxText(x, y, 0, text, 8);
		//t.color = Palette_DB32.COL_20;
		//t.borderColor = Palette_DB32.COL_02;
		//t.borderQuality = 1;
		//t.borderStyle = FlxTextBorderStyle.OUTLINE_FAST;
		//return t;
		return null;
	}//---------------------------------------------------;	
	// --
	inline function getStyledText(text:String, x:Float = 0, y:Float = 0 ):FlxText
	{
		//var t = new FlxText(x, y, 0, text, 8);
		//t.color = Palette_DB32.COL_23;
		//return t;
		return null;
	}//---------------------------------------------------;
	
	
	
	
	/** Create footer objects **/
	function sub_getFooterGroup():FlxSpriteGroup
	{
		var color = Pal_CPCBoy.COL[30];
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
		//menu = new FlxMenu(32, 86, 200);
		menu = new FlxMenu(32, 90, FlxG.width);
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
		
		menu.createPage("main").addM([
			"Start|link|new_game",
			"Options|link|@options",	// Goto another page
			"Help|link|help"
		]);
		
		menu.createPage("options","options").addM([
			//"Options:|label",
			"Sound Effects|toggle",
			"Graphic Style|list|list=old,new",
			"Back|link|@back"
		]);
		
		menu.onItemEvent = (a, b)->{
			
			D.ctrl.flush();
			
			if (a == fire) {
				switch(b.ID){
					case "new_game":
						FlxG.switchState(new StatePlay());
						return;
					case "help":
						trace("going to help");
						slides = sub_get_help_slides();
						menu.close();
						add(slides);
						slides.onEvent = (e)->{
							trace("SLides event", e);
							if (e == "close"){
								remove(slides);
								slides = null;
								menu.open();
							}
						};
						slides.goto(0);
					case _:
				}
			}
		};
		
		add(menu);
	}//---------------------------------------------------;
	
	// --
	function sub_get_help_slides():FlxSlides
	{
		var h = new FlxSlides();
		
		D.text.fix({f:'fnt/text.ttf', s:16});
		
		// : Joystick present show the gamepad help
		h.newSlide();
		h.a(new FlxSprite(P.im_gamepad));
		D.align.screen(h.last);
		
		h.newSlide();
		h.a(D.text.get("Keyboard controls", 40, 100));
		h.a(D.align.down(D.text.get("[A] - JUMP", 40, 100), h.last));
		h.a(D.align.down(D.text.get("[B] - SHOOT", 40, 100), h.last));
		
		D.text.fix();
		h.finalize();
		return h;
	}//---------------------------------------------------;
	
}//-- end --//