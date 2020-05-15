package states;

import djFlixel.*;
import djA.types.SimpleRect;
import djFlixel.core.*;
import djFlixel.core.Dcontrols;
import djFlixel.gfx.pal.*;
import djFlixel.ui.*;
import flixel.*;
import djFlixel.ui.menu.MIconCacher;
import djFlixel.ui.menu.MItem;
import djFlixel.ui.menu.MPage;
import djFlixel.ui.menu.MPageData;
import flash.display3D.textures.CubeTexture;
import flixel.effects.FlxFlicker;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import gamesprites.AnimatedTile;
import gamesprites.Enemy;
import gamesprites.Item;
import gamesprites.Player;
import haxe.Log;
import openfl.Assets;
import tools.KeyCapture;
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
	
	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		if (FlxG.keys.justPressed.ENTER) {
		}
		
		if (FlxG.keys.justPressed.I){
			// add a random item
			//if (!INV.addItem(cast Std.random(10) + 1)) trace("Cannot add item");
		}
	}//---------------------------------------------------;
	
	
	
	
	
	// --
	
	override public function create() 
	{
		super.create();
		
		
		D.ui.pInit();
		D.ui.pCol("100|100,32");
		
		var COL = Pal_CPCBoy.COL; // Shortcut
		D.text.fix({f:'fnt/amstrad.ttf', s:8, c:COL[23], bt:1, bc:COL[2]});
		D.ui.FLAG_PLACE_ADD = true;
		D.ui.pT("TEXT1", {c:1, ta:'center'});
		D.ui.pT("TEXT2", {c:2, ta:'center'});
		D.ui.pT("HELLO WORLD 1,2,3,4,5,6,6,7,8,98,7,6,5", {ta:'center',oy:10});
		D.ui.pT("And another one", {ta:'center', oy:10});
		D.ui.pT("0001", {c:1,ta:'right'},{c:COL[24]});
		D.ui.pT("0002", {c:2}, {c:COL[24]});
		
		
		//sub_get_keys(()->{});
		return;
		
		
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
		
		var mp = new MPage(64, 64, 126, 8);
		//mp.styleC = {
			//bitmap:D.ui.getIcon(8, 'home'),
			//offset:[0, 2],
			//color:{c:Pal_DB32.COL_30, bt:1, bc:Pal_DB32.COL_29},
			//text:"-",
		//};
		
		//var pd = new MPageData('p1', "Main", {
				//part1W:80, stL:Reg.INI.getObj('style1')
		//}).addM([
			//'Label test|label',
			//'Link Test|link|@page',
			//'Link Test|link|call1',
			//'Link Test|link|customcall|icon=8:options',
			//'Toggle Test|toggle',
			//'Toggle Test|toggle',
			//'List Test|list|list=low,mediurm,high',
			//'List Test|list|list=low,medium,high',
			//'Range Int|range|range=0,10|c=0',
			//'Range Int|range|range=0,10|c=0',
			//'Range Step|range|range=0,15|c=5|step=5',
			//'Range Float|range|range=0,1|step=0.2'
		//]);
		
		var pd = new MPageData('controls', "Configure Controls");
		pd.add('Jump|label2|[k]');
		pd.add('Shoot|label2|[l]');
		pd.add('Inventory|label2|[o]');
		pd.add('Pause|link|[enter]');
		mp.setPage(pd);
		mp.viewOn();
		

		mp.onItemEvent = (a, b)->{
			if (a == fire){
				trace("FIRE", a, b);
				var it = mp.item_getCurrent();
				it.data.text = " .. Press Key";
				mp.item_update(it);
				mp.active = false;
				//new KeyCapture((k)->{
					//it.data.text = "[" + k.toString() + "]";
					//mp.item_update(it);
					//mp.active = true;
				//});
			}
		}
		
		add(mp);
		return;
		
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
		
	 		
		var menu = new FlxMenu(43, 80, 200, 3);
		Reg.INI.getObj("style1", menu.stL);
		menu.stI.text.f = "fnt/text.ttf";
		menu.stI.text.s = 16;
		menu.PARAMS.page_anim_parallel = true;
		menu.stHeader = {
			s:16
		};
	
		//menu.stI.text.f = "assets/amstrad.ttf";
		
		menu.createPage("main","- MAIN -").addM([
			"New Game|link|new_game",
			"Options|link|@options",	// Goto another page
			"Help|link|help",
			"Quit|link|!quit|cfm=Do you really want to quit?:Get me out:Stay",
			"Quit|link|#quit|cfm=:yes:no"
		]);
		menu.createPage("options","Options").addM([
			"Options:|label",
			"Sound Effects|toggle",
			"Graphic Style|list|list=sh,new and long,05",
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