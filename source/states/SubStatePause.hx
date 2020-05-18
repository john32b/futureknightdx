package states;
import djFlixel.D;
import djFlixel.fx.BoxScroller;
import djFlixel.gfx.pal.Pal_CPCBoy;
import djFlixel.ui.FlxMenu;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;

import djFlixel.gfx.pal.Pal_CPCBoy.COL as COL;

class SubStatePause extends FlxSubState
{
	var POS_Y0 = 0;
	var POS_Y1 = (32 * 4) - 12;
	var SCROLL_SPEED = 0.6;
	
	override public function create():Void 
	{
		super.create();
		
		camera = Reg.st.camera;
		
		var COL = Pal_CPCBoy.COL;
		bgColor = COL[0];
		
		// :: Top/Bottom Test Scrollers
		var t1 = D.text.get('FUTURE KNIGHT DX - FUTURE KNIGHT DX - FUTURE KNIGHT DX - ', {f:'fnt/score.ttf', s:6});
		var sourcePixels = t1.pixels.clone();
			// Because text.pixels, does not get color data, I am coloring manually
			D.bmu.replaceColor(sourcePixels, 0xFFFFFFFF, COL[31]);
		var bs1 = new BoxScroller(sourcePixels, 0, POS_Y0, 280);
		var bs2 = new BoxScroller(sourcePixels, 0, POS_Y1, 280);
		bs1.autoScrollX = SCROLL_SPEED;
		bs2.autoScrollX = -SCROLL_SPEED;
		bs1.scrollFactor.set(0, 0);
		bs2.scrollFactor.set(0, 0);
		add(bs1);
		add(bs2);
		
		
		// ::
		var menu = new FlxMenu(64, 48, -1, 6);
			menu.stI.col_t.focus = Pal_CPCBoy.COL[24];
			menu.stI.col_t.accent = Pal_CPCBoy.COL[6];
			menu.stI.col_t.idle = Pal_CPCBoy.COL[27];
			menu.stI.col_b.idle = Pal_CPCBoy.COL[1];
			menu.stL.align = "center";
			menu.stI.text = { f:'fnt/score.ttf', s:6, bt:1, so:[2, 2] };
			menu.stHeader = { f:'fnt/score.ttf', s:6, c:COL[23], bt:2, bc:COL[1]};
			menu.PARAMS.header_offset_y = -4;
			
			menu.createPage("main", "PAUSED").addM([
				"resume|link|resume",
				"options|link|@options",
				"quit|link|!quit|cfm=Quit to the main menu?:yes:no"
			]);
			
			menu.createPage("options","OPTIONS").addM([
				"Volume|range|id=vol|range=0,100|step=5",
				"Soft Pixels|toggle|id=softpix|c=" + Std.string(D.ANTIALIASING),
				"Back|link|@back"
			]);
			
			menu.onMenuEvent = (a, b)->{
				if (a == page && b == "options") {
				menu.item_update(0, (t)->{t.data.c = Std.int(FlxG.sound.volume * 100); });
				menu.item_update(1, (t)->{t.data.c = D.ANTIALIASING; });
				}
				else if (a == start) {
					close();
				}
				else if (a == rootback){
					menu.mpActive.setSelection(0);	// move to the top element
				}
			}//---------------------------------------------------;
			
			menu.onItemEvent = (a, b)->{
				if (a == fire) switch(b.ID)
				{
					case "vol":
						FlxG.sound.volume = b.data.c / 100;
					case "resume":
						close();
					case "quit":
						FlxG.switchState(new StateTitle());
					case "softpix": 
						D.ANTIALIASING = b.data.c;
					case _:
				}
			};
			
			add(menu);
			menu.goto('main');

	}//---------------------------------------------------;
	
	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		if (FlxG.keys.justPressed.ESCAPE){
			close();
		}
	}//---------------------------------------------------;
	// --
	override public function close():Void 
	{
		Reg.SAVE_SETTINGS();
		D.ctrl.flush();
		Reg.st.INV.close();
		super.close();
	}//---------------------------------------------------;
	
	
}// --