package;

import djFlixel.core.Dtext.DTextStyle;
import djFlixel.fx.BoxFader;
import djFlixel.fx.StarfieldSimple;
import djFlixel.other.FlxSequencer;
import djFlixel.D;
import djFlixel.ui.FlxSlides;
import djFlixel.ui.VList;
import tools.SprDirector;

import djFlixel.gfx.pal.Pal_DB32;


import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxDestroyUtil;
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
 */

class StateTitle extends FlxState
{
	// :: Various State Parameters
	var P = {
		art_delay : 4.0,
		im_title_art: "im/game_art.png",
		im_title : 	"im/title_art.png",
		font_title_2 : "assets/pixelberry.ttf",	// the "remake" text below the title
	};
	
	
	// :: HELP PAGE :
	var tstyle1:DTextStyle = {c:Pal_DB32.COL_02};
	var tstyle2:DTextStyle = {c:Pal_DB32.COL_19};
	var help_slides:FlxSlides;
	
	
	function _create_helpSlides():FlxSlides
	{
		var h = new FlxSlides();
		// (0) : Controls, Keyboard
		h.newSlide();
		
		// (1) : Controls, Gamepad
		h.newSlide();
		
		// (2) : Tiles
		h.newSlide();
		
		// (3) : Items
		h.newSlide();
		
		// (4) : Enemies
		h.newSlide();
		
		//var dd = new FlxSprite();
		//dd.loadGraphic();
		
		//h.a();
		//h.finalize();
		return h;
	}//---------------------------------------------------;
	
	
	
	

	var stars:StarfieldSimple;
	var starsTimer:Float = 0;	// Change stars angle on timer
	
	// This is new, a group that handles sprites for the gui
	var dir0:SprDirector;
	var pFader:BoxFader;
	var seq:FlxSequencer;
	
	// Where the pages will start on the screen in pixels
	//var pageScrPos:SimpleCoords;
	
	//// Simple staging sequence
	//var seq:Sequencer;
	
	//// Add misc sprites here.
	//var groupMisc:FlxGroup; 
	
	// --
	// -- Controller banner
	//var popup_controller:FlxSpriteGroup;
	//var popup_controllerIsOn:Bool = false;
	// -- Pages
	//var helpPages:FlxMenuPages;
	// -- The menu
	//var menu:FlxMenu;
	// --
	
	//// -- Display some info, like if it's connected to an API and HighScore?
	//var infoGroup:FlxSpriteGroup = null; // Goes in groupMisc

	//// -- cheats 
	//var flag_cheat_step1:Bool;
	
	
	// --
	//var trophiesList:VListNav<TrophyBigBox,Trophy> = null;
	
	// I want a dynamic function because in some cases I need to check different things
	var updateFunction:Void->Void;

	//====================================================;
	// FUNCTIONS
	//====================================================;
	
	// --
	// Quick Fade out the state to another stage
	function fadeSwitch(state:FlxState) 
	{
		// Save settings upon leaving this state.
		//Reg.settingsSave();
		//
		//menu.unfocus();
		//pfader.fadeColor(Palette_DB32.COL_01, function() {
			//FlxG.switchState(state);
		//});
	}//---------------------------------------------------;
		
	// Split for readability
	function _createMainMenu()
	{
		//menu = new FlxMenu(32, 86, 230, 6);	// #param
		//menu.styleOption.fontSize = 16;
		//// -- Page Main --
		//var p:PageData = new PageData("main");
			//p = menu.newPage("main");
			//p.link("New game", "start");
			//p.add("Resume", { type:"link", sid:"resume", selectable:hasSaveDataAt(1) } );
			//p.link("Options", "@options");
			//p.link("Demo play", "vcr");
			//#if FLASHONLINE
			//p.link("Leaderboards", "leader");
			//#end
			//p.link("Trophies", "trophies");
			//p.link("Help", "help");
		//// -- Page Options --
		//p = menu.newPage("options");
			//#if (!FLASHONLINE)
			//p.add("Window Size", { type:"oneof", sid:'wsize', pool:["1", "2", "3"], current:1 } );
			//#end
			//p.add("Graphics", { type:"oneof", sid:"palette", pool:["Original", "Updated"], current: (Reg.COLORSCHEME == "cpc"?0:1) } );
			//p.add("Smoothing", { type:"toggle", sid:"antialias", current:FLS.ANTIALIASING } );
			//p.add("Fullscreen", { type:"toggle", sid:"fullscreen", current:FLS.FULLSCREEN } );
			//p.add("Roll Colors at Exits", { type:"toggle", sid:"rndcol", current:Reg.RANDOM_COLORS } );
			//p.add("Music", { type:"toggle", sid:"music", current:SND.MUSIC_ENABLED } );
			//p.add("Music Version", { type:"oneof", sid:"musicver", pool:["C64", "CPC"], current:Reg.musicVer } );
			//#if debug
			//p.link("Del Save", "delsave");
			//#end
			//p.add("Trophy Indicator", { type:"toggle", sid:"tropp", current:Reg.api.flag_trophy_popup } );
			//p.link("back", "@back");
			//
		//// --	
		//p = menu.newPage("delete");
			//p.question("Delete existing save?", "del");
			//
		//// --
		//menu.callbacks_option = callback_options;
		//menu.callbacks_menu = callback_menu;
		//
		//Reg.menuP = menu;
			
	}//---------------------------------------------------;
	
	// --
	function callback_options(msg:String, o:Dynamic)
	{
		//switch(msg) { 
			//default: Reg.callbacks_options_global(msg, o);
			//case "optFire": //- OPTION FIRE
			//switch(o.SID) {
			//case "start":
				//if (hasSaveDataAt(1))
					//menu.showPage("delete");
				//else 
					//fadeSwitch(new StateMain("new"));
			//case "vcr":	startDemoPlay();
			//case "resume": 	fadeSwitch(new StateMain("resume"));
			//case "help":
				//Controls.RESET();
				//menu.close();
				//helpPages.showPage(0);
				//updateFunction = null;
				//infoGroup.visible = false;
			//case "trophies":
				//showTrophies();
			//case "del_yes":
				//fadeSwitch(new StateMain("new"));
			//case "del_no":
				//menu.goBack();
			//case "delsave":
				//SAVE.deleteSave();
				//FlxG.resetGame();
			//
			//#if FLASHONLINE
			//case "leader":
				//// LEADERBOARDS
				//showLeaderBoards();
			//#end
			//}
		//}
	}//---------------------------------------------------;
	
	// --
	function callback_menu(msg:String,param:String)
	{
		// Reset the demo time, regardless of the event
		//Reg.callbacks_menu_global(msg, param);
		//switch(msg) { 
			//default:
			//case "pageOn": if (param == "main" && infoGroup != null) infoGroup.visible = true;
			//case "pageOff": if (param == "main" && infoGroup != null) infoGroup.visible = false;
			//case "rootback":
				//FlxG.resetState();	// Go back to the start of the state
		//}
	}//---------------------------------------------------;	
	
	
	// --
	#if TROPHIES
	function showTrophies()
	{
		//if (trophiesList == null) // create it
		//{
			//TrophyBigBox.IMAGE = "assets/images/trophy_box.png";
			//TrophyBigBox.SIZE = 32;
			//trophiesList = new VListNav(TrophyBigBox, 64, 40, 0, 4);
			//trophiesList.styleBase = Styles.newStyle_Base();
			//trophiesList.styleBase.instantScroll = true;
			//trophiesList.styleList = Styles.newStyle_List();
			//trophiesList.styleList.focus_nudge = 3;
			//trophiesList.setDataSource(Reg.api.trophiesAr);
			//trophiesList.callbacks = function(s:String, opt:Dynamic)
			//{
				//if (opt == null) Reg.callbacks_menu_global(s);
			//}
		//}
		//// -- other --
		//var t1 = Gui.getQText("Trophies", 16, Palette_DB32.COL[8], Palette_DB32.COL[1], Reg.JSON.mmenu.tr1.x, Reg.JSON.mmenu.tr1.y);
			//add(t1);
			//
		//var t2 = Gui.getQText('Unlocked ${Reg.api.trophiesUnlocked}/${Reg.api.trophiesTotal}', 8, Palette_DB32.COL[21], Palette_DB32.COL[1], Reg.JSON.mmenu.tr2.x, Reg.JSON.mmenu.tr2.y);
			//add(Align.screen(t2, "center", "none"));
	//
		//menu.close();
		//if (infoGroup != null) infoGroup.visible = false;
		//remove(groupMisc);
		//
		//add(trophiesList);
		//trophiesList.setViewIndex(0); // scroll to top
		//trophiesList.onScreen();
		//
		//Controls.RESET();
		//FlxG.mouse.reset();
		//updateFunction = function() {
			//if (Controls.CURSOR_CANCEL() || Controls.CURSOR_START() || FlxG.mouse.justPressed) {
				//// close
					//t1.destroy();
					//t2.destroy();
					//remove(trophiesList);
					//updateFunction = null;
					//menu.showPage("main");
					//add(groupMisc);
					//if (infoGroup != null) infoGroup.visible = true;				
			//}
		//}//-- updtfn
	//

	}//---------------------------------------------------;
	#else
	function showTrophies(){}
	#end
	
	
	// --
	#if FLASHONLINE
	var LB:LeaderBoards;
	function showLeaderBoards()
	{
		//if (LB == null) {
		//LB = new LeaderBoards(Reg.JSON.mmenu.lb, false);
		//}
		//add(LB);
		//menu.close();
		//if (infoGroup != null) infoGroup.visible = false;
		//LB.fetch(5, function() {
			//trace("Can now exit the leaderboards");
			//updateFunction = function() {
				//if (Controls.CURSOR_CANCEL() || Controls.CURSOR_START() || FlxG.mouse.justPressed) {
					//remove(LB);
					//updateFunction = null;
					//menu.showPage("main");
					//if (infoGroup != null) infoGroup.visible = true;
				//}
			//};
		//});
		//
	}//---------------------------------------------------;
	#end

	// --
	function startDemoPlay()
	{	
		//// Map to Load
		//var str:String = Script.demo_maps[(Script.demo_count * 2) + 1] + ".fgr";
		//
		//menu.unfocus();
		//pfader.fadeColor(Palette_DB32.COL_01, function() {
			//FlxG.vcr.loadReplay(
				//Assets.getText("assets/replay/" + str), new StateMain("demo"),
					//["ENTER", "SPACE", "K", "J"], null, function() {
					//FlxG.switchState(new StateTitle()); }
			//);
		//});
		
		/**
		 * WARNING, IN ORDER TO WORK WITH JOYSTICK.
		 * 
		 * ADD THIS TO FlxGamepadManager.hx 
		 * 
				private function handleButtonDown(FlashEvent:JoystickEvent):Void
				#if FLX_RECORD
				if (FlxG.game.replaying) {
					FlxG.vcr.cancelReplay();
				}
				#end
		 */

	}//---------------------------------------------------;
	
	
	
	override public function create():Void 
	{
		super.create();
		
		//FlxG.vcr.stopReplay(); // In case it was called from a replay from the game???
		FlxCamera.defaultCameras = [camera];
	
		// -- Data init
		updateFunction = null;
		
		// --
		//seq = new Sequencer(sequence_handler);
		seq = new FlxSequencer(sequence_handler);
		add(seq);

		// :: STARS
		stars = new StarfieldSimple(320, 240);	// Default colors, transparent BG
		stars.setBGCOLOR(Pal_DB32.COL_01);
		stars.WIDE_PIXEL = true;
		stars.STAR_SPEED = 1.9;
		
		dir0 = new SprDirector();
		
		// :: Load some static sprites
		dir0.on(P.im_title_art).v(0);
		dir0.on(P.im_title).p(0, -20).v(0);
		dir0.on('remake', D.text.get("remake", 256, 64, {f:P.font_title_2, c:Pal_DB32.COL_30})).v(0);
		
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
//
		//// -- Menu
		//_createMainMenu();
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
		
		//add(groupMisc);
		//add(menu);
		//add(helpPages);

		// --
		pFader = new BoxFader();
		pFader.setColor(Pal_DB32.COL_02);
		pFader.fadeOff(seq.nextV, {time:0.33});
		add(pFader);
		
		// --
		D.snd.playMusic(Reg.musicVers[Reg.musicVer]);
		
		//flag_cheat_step1 = false;
		
		// TEST MENU -----
		
		add(Reg.get_overlayScreen());
	}//---------------------------------------------------;	
	// --
	override public function destroy():Void 
	{
		super.destroy();
	}//---------------------------------------------------;	
	
	
	// --
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		
		// :: STARS 
		if ((starsTimer += elapsed) > 0.1) {
			starsTimer = 0;
			stars.STAR_ANGLE += 0.1;
		}else{
			if (FlxG.keys.pressed.LBRACKET) {
				stars.STAR_ANGLE -= 0.8;
			}else
			if (FlxG.keys.pressed.RBRACKET) {
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
	function sequence_handler(step:Int)
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
			FlxG.camera.bgColor = Pal_DB32.COL_03;
			stars.setBGCOLOR(Pal_DB32.COL_03);
			seq.next(0.1);
		case 4: // --	show the menu
			//SND.playFile("title");
			dir0.on(P.im_title).a(0.5).v(1).tween({alpha:1, y:32}, 0.5, { ease:FlxEase.elasticOut } );
			seq.next(0.2);	
		case 5:
			dir0.on('remake').v(1).a(0.5).p(256, 32).tween({alpha:1, y:64}, 0.3, { ease:FlxEase.elasticOut } );
			seq.next(0.300);
		case 6:
			dir0.on('footer', sub_getFooterGroup()).p(0, 20).a(0.3).tween({y:0, alpha:1}, 0.2);
		case 7:
			
				//
		default:
		}
			//
		//case 6:
			//// --------
			//sub_getFooterGroup();
			//menu.showPage("main");
			//// -- API
			//infoGroup.visible = true;
			//seq.next(0.5);
			//
		//case 7: // -- Show the controller notification a bit later
			//
			//// Check for controller if it was alive from the start once
			//if (Controls.gamepadConnected()) {
				//showControllerPopup();
			//}
		//}//-- switch end --//
		
	}//---------------------------------------------------;

	
	// --
	function showControllerPopup()
	{
		//if (popup_controllerIsOn) return;
	//
		//var tx = new FlxText(0, 12, 120, "Controller connected");
			//tx.alignment = FlxTextAlign.RIGHT;
	//
		//popup_controllerIsOn = true;
		//popup_controller.y = Reg.JSON.mmenu.ctrl.y;
		//popup_controller.x = Reg.JSON.mmenu.ctrl.x;
		//popup_controller.add(new FlxSprite(120, 0, "assets/images/controller_art.png"));
		//popup_controller.add(tx);
		//
		//groupMisc.add(popup_controller);
		//
		//FlxTween.tween(popup_controller, { x:148 }, 0.3, { ease:FlxEase.quadOut } );
//
		//// Hide popup after 2.5 seconds
		//new FlxTimer().start(2.5, function(_) {
			//FlxTween.tween(popup_controller, { x:320 }, 0.3, { ease:FlxEase.quadOut,
				//onComplete:function(_){ popup_controller.destroy(); }
			//});			
		//});

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
	
	
	/** Create footer objects
	 **/
	function sub_getFooterGroup():FlxSpriteGroup
	{
		// Set a horizontal line and infos below it:
		var line = new FlxSprite(0, 216);
			line.makeGraphic(FlxG.width - 50, 1, Pal_DB32.COL_23);
			D.align.screen(line, 'c', '');
			
		var txt_ver = D.text.get("ver " + Reg.VERSION, {c:Pal_DB32.COL_27});
		var txt_by  = D.text.get("by John Dimi", {c:Pal_DB32.COL_27});
		D.align.inLine(line.x, line.y, line.width, [txt_ver, txt_by], 'j');
		
		var grp = new FlxSpriteGroup();
			grp.add(txt_by); grp.add(txt_ver); grp.add(line);
			
		return grp;
		
		/// TODO:
		// -- GET FULL VERSION -- LINK TO DOWNLOAD FULL VERSION
		//#if FLASHONLINE
			//var btnFull = Gui.getFButton("#GET WINDOWS VERSION#", 0, true, function() {
				//FlxG.openURL(FLS.WEBSITE);
			//});
			//btnFull.setPosition(Reg.JSON.mmenu.fv.x, Reg.JSON.mmenu.fv.y);
			//groupMisc.add(btnFull);
			//FlxFlicker.flicker(btnFull, 2, 0.16);
		//#end
	}//---------------------------------------------------;

	
		// --
	// Whethere slot $num has save data written
	public function hasSaveDataAt(num:Int):Bool
	{
		//SAVE.setSlot(num);
		//return (SAVE.load("_exists") == true);
		return false;
	}//---------------------------------------------------;
	

	// - Autocalled
	function callback_ApiConnected()
	{
		//#if FLASHONLINE
	//
		//var _score:Int = 0;
		//var _user:String = "";
		//var _apiName:String = Reg.api.SERVICE_NAME;
	//
		//if (!Reg.api.isConnected)
		//{
			//trace("Warning: Failed to connect to the api");
			//
			//var h0 = new FlxText(0, 0, Reg.JSON.mmenu.cstof.w, "Failed to connect to " + _apiName);
				//h0.alignment = "right";
				//h0.color = Palette_DB32.COL_29;
				//h0.borderColor = Palette_DB32.COL_02;
				//h0.borderQuality = 1;
				//h0.borderStyle = FlxTextBorderStyle.OUTLINE_FAST;
//
			//infoGroup.x = Reg.JSON.mmenu.infogrp.x + Reg.JSON.mmenu.cstof.x;
			//infoGroup.y = Reg.JSON.mmenu.infogrp.y + Reg.JSON.mmenu.cstof.y;
			//infoGroup.add(h0);
			//
		//}
		//else if (Reg.api.isConnected && !Reg.api.userLoggedIn)
		//{
			//trace("Warning: Guest User");
			//
			//var h0 = new FlxText(0, 0, Reg.JSON.mmenu.cstof.w, "Connected as GUEST to " + _apiName);
				//h0.alignment = "right";
				//h0.color = Palette_DB32.COL_11;
				//h0.borderColor = Palette_DB32.COL_02;
				//h0.borderQuality = 1;
				//h0.borderStyle = FlxTextBorderStyle.OUTLINE_FAST;
//
			//infoGroup.x = Reg.JSON.mmenu.infogrp.x + Reg.JSON.mmenu.cstof.x;
			//infoGroup.y = Reg.JSON.mmenu.infogrp.y + Reg.JSON.mmenu.cstof.y;
			//infoGroup.add(h0);
			//
		//}else
		//{
			//// Connect OK
			//_score = 0;
			//_user = Reg.api.getUser();
			//
			//SAVE.setSlot(0);
			//if (SAVE.exists("highscore")) {
				//_score = cast SAVE.load("highscore");
			//}
			//
			//var h1 = new FlxText(0, 0, 0, "Connected to " + _apiName);
				//h1.color = Palette_DB32.COL_20;
				//h1.borderColor = Palette_DB32.COL_02;
				//h1.borderQuality = 1;
				//h1.borderStyle = FlxTextBorderStyle.OUTLINE_FAST;
			//var h2 = new FlxText(0, 12, 0 , "User : " + _user);
				//h2.font = Reg.FONT_MENU;
				//h2.color = Palette_DB32.COL_22;		
			//var h3 = new FlxText(0, 24, 0, 'High Score : $_score');
				//h3.font = Reg.FONT_MENU;
				//h3.color = Palette_DB32.COL_22;
			//
			//infoGroup.add(h1);
			//infoGroup.add(h2);
			//infoGroup.add(h3);
			//
			//infoGroup.x = Reg.JSON.mmenu.infogrp.x;
			//infoGroup.y = Reg.JSON.mmenu.infogrp.y;
		//}
		//
		//groupMisc.add(infoGroup);
		//
		//#end
	}//---------------------------------------------------;
	
	
}//-- end --//