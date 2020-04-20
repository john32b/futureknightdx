package states;

import djFlixel.*;
import djFlixel.core.*;
import djFlixel.gfx.pal.*;
import djFlixel.ui.*;
import flixel.*;
import flixel.group.FlxGroup;
import gamesprites.AnimatedTile;
import gamesprites.Enemy;
import gamesprites.Item;
import gamesprites.Player;
import haxe.Log;
import openfl.Assets;
//import djFlixel.gui.PanelPop;


//import tools.TrophyBigBox;
//import tools.TrophyPopup;

/**
 * ...
 */
class StateTest extends FlxState
{
	//var trophy:TrophyPopup;
	//var list:VList<ITEMTEST,Int>;
	
	var INV:Inventory;

	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		if (FlxG.keys.justPressed.ENTER) {
			INV.toggle();
		}
		
		if (FlxG.keys.justPressed.I){
			// add a random item
			if (!INV.addItem(cast Std.random(10) + 1)) trace("Cannot add item");
		}
	}//---------------------------------------------------;
	
	
	override public function create() 
	{
		super.create();
		
		INV = new Inventory();
		INV.onItemSelect = (it)->{
			INV.removeItemWithID(it);
			INV.sortItems();
		}
		add(INV);
		return;
		
		//
		//var stars:StarfieldSimple = new StarfieldSimple();
		//stars.color_bg = 0xFF76428a;
		//add(stars);
		//// --
		//
		//trophy = new TrophyPopup(64, 64);
		//add(trophy);
		bgColor = Pal_DB32.COL_15;
		
		
		//var c = new FlxSprite(X, Y, new BitmapData(100, 100, true, 0xFF005566));
		//add(c);

		//add(new FlxSprite(40, 200, D.ui.getIcon(12, 1)));
		//add(new FlxSprite(52, 200, D.ui.getIcon(12, 10)));
		//add(new FlxSprite(64, 200, D.ui.getIcon(12, "heart")));
		
		//add(Reg.get_overlayScreen());
		
		
		//var st:MItemStyle =  {
			//text:{
				//s:8,f:"assets/amstrad.ttf",
				////s:16,
				//bc:Pal_DB32.COL_02, c:Pal_DB32.COL_10, so:[0, 1]
			//},
			//col_t:{idle:Pal_DB32.COL_18, accent:Pal_DB32.COL_28, focus:Pal_DB32.COL_09},
			//col_b:{idle:Pal_DB32.COL_02, accent:Pal_DB32.COL_02, focus:Pal_DB32.COL_02},
			//box_bm:[D.ui.getIcon(8, 'ch_off'), D.ui.getIcon(8, 'ch_on') ],
			//ar_bm:[D.ui.getIcon(8, 'ar_left'), D.ui.getIcon(8, 'ar_right'), D.ui.getIcon(8, 'minus'), D.ui.getIcon(8, 'plus') ],
			////ar_txt:['<', '>'],
			////box_txt:['[ ]', '[x]'],
		//};
		
		
		
		//mp = new MPage(64, 64, 126, 8);
		//mp.styleC = {
			////bitmap:D.ui.getIcon(8, 'home'),
			////offset:[0, 2],
			//text:"_-=",
			//color:{c:Pal_DB32.COL_30}
		//};
		//mp.style_tweakDef({
			//item_pad: -4,
			//align:Reg.INI.get('style','align')
		//});
		//mp.setPage(new MPageData('p1', "Main").addM([
			//'Label test|label',
			//'Link Test|link|@page',
			//'Link Test|link|call1',
			//'Link Test|link|customcall|icon=8:options',
			//'Toggle Test|toggle',
			//'Toggle Test|toggle',
			//'List Test|list|list=low,medium,high',
			//'List Test|list|list=low,medium,high',
			//'Range Int|range|range=0,10|c=0',
			//'Range Int|range|range=0,10|c=0',
			//'Range Step|range|range=0,15|c=5|step=5',
			//'Range Float|range|range=0,1|step=0.2'
		//]));
		//mp.viewOn();
		//add(mp);
		
		//add(new FlxSprite(32, 40, 
			//MItem.ICONCACHE.get(st.box_bm[0], "accent")));
		//add(new FlxSprite(50, 40, 
			//MItem.ICONCACHE.get(st.box_bm[0], "focus")));
		//add(new FlxSprite(60, 40, 
			//MItem.ICONCACHE.get(st.box_bm[0], "accent")));	
			
		//var stimer = new StepLoop(1, 2, 2, (d)->{
			//mp.visible = !mp.visible;
		//});
		//add(stimer);		
		
	 		
		var menu = new FlxMenu(43, 80, 100, 10);
		Reg.INI.getObj("style1", menu.stL);
		//menu.PARAMS.page_anim_parallel = true;
		menu.stHeader = {
			s:16
		};
	
		menu.stI.text.f = "assets/amstrad.ttf";
		
		menu.createPage("main","-M-").addM([
			"New Game|link|new_game",
			"Options|link|@options",	// Goto another page
			"Help|link|help",
			"Quit|link|!quit|cfm=Do you really want to quit?:Get me out:Stay",
			"Quit|link|#quit|cfm=:yes:no"
		]);
		menu.createPage("options","Options").addM([
			"Options:|label",
			"Sound Effects|toggle",
			"Graphic Style|list|list=old,new",
			"Back|link|@back"
		]);
		menu.onItemEvent = (a, b)->{
			trace("MENU EVENT", a, b);
			
			if (a == fire){
				
				if (b.ID == "help")
				{
					//var p = new PanelPop(100, 100);
					//add(p);
					//p.
				}
				
				if (b.ID == "quit")
				{
					trace("REQUEST TO QUIT");
					menu.close();

				}
				if (b.ID == "new_game")
				{
					menu.item_update(1, (i)->{
						i.disabled = !i.disabled;
					});
					
					menu.item_update("options", 0, (i)->{
						i.label = "New Label ::";
					});
				}
				//trace("FIRED ", a);
				//trace(b.get());
			}
		};
		
		add(menu);
		menu.goto("main");	// will focus it?
		
		// >>>>>>>>
		var slides = new FlxSlides(Reg.INI.getObjEx('slides')); // Yes it can work with string object
		
		slides.newSlide();
		slides.a(D.text.get("HELLO WORLD", 24, 24));
		slides.a(D.align.down(D.text.get("-----------"), slides.last));
		slides.a(D.align.down(D.text.get("Holy shit does this work?"), slides.last));
		slides.a(D.align.right(D.text.get(">>>>>>>>", {c:Pal_DB32.COL_19, bc:Pal_DB32.COL_03}), slides.last));
		slides.a(D.align.right(D.text.get("YES", {c:Pal_DB32.COL_04, bc:Pal_DB32.COL_01, bt:2, bs:2}), slides.last, 4));
	
		//
		slides.newSlide();
		slides.a(D.text.get("HELLO WORLD 222222", 44, 24));
		slides.a(D.align.down(D.text.get("-----------"), slides.last));		
		
		//
		slides.newSlide();
		slides.a(D.text.get("HELLO WORLD  3333", 54, 24));
		slides.a(D.align.down(D.text.get("-----------"), slides.last));
		//
		slides.finalize();
		slides.setArrows(8, 20, 100, 200);
		
		//slides.goto(0);
		//slides.onEvent = cast Log.trace;
		//add(slides);
		
		
		// >>>>>>
		
			var A = new AnimatedTile();
				A.setPosition(32, 32);
				A.animation.play("_HAZARD");
				add(A);
		
		// >>>>> Uiindicators
		
		//var ar1 = new UIIndicator("8:ar_left", 100, 100).setAnim(1, {steps:3});
		//add(ar1);
		//var ar2 = new UIIndicator(150, 100).setAnim(1, {axis:"-x", steps:3, time:0.2});
			//ar2.loadGraphic(D.ui.getIcon(8, "heart").clone());
			//ar2.applyFX({c:Pal_DB32.COL_13, sc:Pal_DB32.COL_02});
			//
		//add(ar2);
		//ar2.syncFrom(ar1);
	}//---------------------------------------------------

		

	
}