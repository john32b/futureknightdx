package states;
import djFlixel.D;
import djFlixel.gfx.BoxScroller;
import djFlixel.gfx.pal.Pal_CPCBoy;
import djFlixel.ui.FlxMenu;
import djFlixel.ui.MPlug_Header;
import djFlixel.ui.MPlug_Audio;
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
		
		// When I close this at the end, it appears for 1 frame then closes, so close it now
		Reg.st.INV.close(true);
		
		// DEV: For convenience uses the same camera as the game to get the viewport
		camera = Reg.st.camera;
		
		var COL = Pal_CPCBoy.COL;
		bgColor = COL[0];
		
		// :: Top/Bottom Test Scrollers
		var t1 = D.text.get('FUTURE KNIGHT DX - FUTURE KNIGHT DX - FUTURE KNIGHT DX - ', {f:'fnt/score.ttf', s:6});
		var sourcePixels = t1.pixels.clone();
			// DEV: Because test.pixels does not get the color data set in {FlxSprite.color=0xff....}
			// 		I coloring the bitmap manually
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
			add(menu);

			menu.overlayStyle({
				cursor:{
					tween:{x0: -16, x1:0, ease:"quadOut", time:0.14}
				},
				align:"center",
				item:{
					text:{
						f:'fnt/score.ttf', s:6, bt:1, so:[2, 2]
					},
					col_t:{
						focus:Pal_CPCBoy.COL[24],
						accent:Pal_CPCBoy.COL[24],
						idle:Pal_CPCBoy.COL[27]
					},
					col_b:{
						idle:Pal_CPCBoy.COL[1]
					}
				}
			});
			
			menu.plug(new MPlug_Header({
				offsetY: -4,
				text:{f:'fnt/score.ttf', s:6, c:COL[23], bt:2, bc:COL[1], a:"center"}
			}));
						
			menu.plug(new MPlug_Audio({
				pageCall:"cursor_ok",
				back:"cursor_back",
				it_fire:"cursor_ok",
				it_focus:"cursor_tick",
				it_invalid:"gen_no",
				close:"cursor_back"
			}));
		
			menu.createPage("main", "PAUSED").add("
				-| resume  | link | resume
				-| options | link | @options
				-| quit    | link | quit | ?fs=Quit to main menu?:yes:no
			");
			
			menu.createPage("options", "OPTIONS").add("
				-| Volume    | range | c_vol | 0,100 | step=5
				-| Music	 | toggle| c_mus
				-| Border 	 | toggle| c_bord
				-| Shader  	  | list  | c_shad | Off,A,B
				-| Back      | link  | @back
			");
			
			menu.onMenuEvent = (a, b)->{
				if (a == page && b == "options") {
					Reg.menu_handle_common(menu);
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
					case "resume":
						close();
					case "quit":
						Reg.SAVE_SETTINGS();
						FlxG.switchState(new StateTitle());
					default:
						Reg.menu_handle_common(menu, b);
				}
			};
			
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
		super.close();
	}//---------------------------------------------------;
	
	
}// --