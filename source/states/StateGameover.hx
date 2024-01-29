/**
	Gameover screen
	-------------

	*v1.5*
	- Option to continue the game or quit

 **/

package states;

import djFlixel.other.DelayCall;
import djFlixel.ui.MPlug_Audio;
import djFlixel.ui.FlxMenu;
import djFlixel.D;
import djFlixel.core.Dcontrols;
import djFlixel.gfx.TextBouncer;
import djFlixel.gfx.pal.Pal_CPCBoy;
import djFlixel.gfx.FilterFader;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;


class StateGameover extends FlxState
{
	override public function create():Void 
	{
		super.create();
		
		D.snd.stopMusic();
		D.snd.playV('gameover');
		
		// Static fx
		var fx = new djFlixel.gfx.StaticNoise(0, 0, cast FlxG.width / 2, FlxG.height );
		fx.color_custom([0xff141313, 0xff292727]);
		fx.centerOrigin();
		fx.scale.x = 2;
		fx.x = 80;
		add(fx);
		
		// --
		var pl = new FlxSprite();

		Reg.IM.loadGraphic(pl, "player", Reg.FLAG_SECOND_CHANCE > 0 ? 'pink' : gamesprites.Player.COLOR_COMBO);
		pl.animation.frameIndex = 17;
		D.align.screen(pl);
		pl.y -= 32;
		add(pl);
		
		// --
		var tb = new TextBouncer("GAME OVER", 78, 108, 
			{s:12, f:"fnt/score.ttf", bc:Pal_CPCBoy.COL[2], c:Pal_CPCBoy.COL[26], bs:2, bt:2});
		add(tb);
		tb.start();
		

		// -- Ask to continue
		var m = new FlxMenu(40, 142, -1, 3);
		m.PAR.start_button_fire = true;
		m.plug(new MPlug_Audio({
			pageCall:"cursor_ok",
			back:"cursor_back",
			it_fire:"cursor_ok",
			it_focus:"cursor_tick",
			it_invalid:"gen_no",
		}));

		// same style as pause menu, should I share code?
		m.overlayStyle({
			cursor:{
				tween:{x0: -16, x1:0, ease:"quadOut", time:0.14}
			},
			align:"center",
			vt_OUT:"0:8|0.1:0",
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
		
		m.createPage('main','').add('
			-| End | link | end |
			-| Continue | link | cont | AF');

		m.onItemEvent = (a, b)->{
			switch([a,b.ID]){
			case [fire,'end']:
				D.save.deleteSlot(1);
				trace("Save Slot (1) Deleted");
				FlxG.switchState(new StateTitle());
			case [fire,'cont']:
				m.unfocus();
				Reg.FLAG_SECOND_CHANCE = 1;
				new FilterFader(true, ()->{
					FlxG.switchState(new StatePlay());
				});	
				// > Loads previous save but with full health 
			default:
				return;
			}
		};

		add(m);
		
		// Wait 2 seconds, then show the menu
		new DelayCall(2.5,()->{
			m.goto('main');
		});

	}//---------------------------------------------------;
	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
	}//---------------------------------------------------;
	
}// --
