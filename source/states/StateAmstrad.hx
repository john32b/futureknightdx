/**
	Amstrad Loading State
	---------------------
	- Simulates the Amstrad CPC loading screen
	- Loads text from ini file (REG.INI)
	- Next state = StateTitle
================================================= */

package states;

import djFlixel.D;
import djFlixel.gfx.pal.Pal_CPCBoy;
import djFlixel.gfx.RainbowStripes;
import djFlixel.ui.FlxAutoText;
import djFlixel.other.FlxSequencer;
import flixel.FlxG;
import flixel.FlxState;
import flixel.system.FlxSound;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;


class StateAmstrad extends FlxState
{
	static inline var _NEXT_MIN_TIME = 1;	// Wait this much until you can press enter to go to next state
	var _time:Float = 0;
	//----------------------------------------------------;
	
	override public function create():Void 
	{
		super.create();
		
		var COL = [ 0xff0a2645, 0xff6be2eb, 0xff0b2139 ];	// Variation blue
		//var COL = [ 0xff0a2645, 0xfffeae34, 0xff181425 ];	// Variation orange
		//var COL = [ 0xFF062241, 0xFFd2e7ff, 0xFF24244d ];	// Variation --
		
		FlxG.camera.bgColor = COL[0];
		
		var snd_load:FlxSound = null;
		
		add(new FlxSequencer((seq)->{
			switch(seq.step) {
				case 1:
				var textBoot = new FlxAutoText(24	, 0, 290, 0);
					textBoot.style = {f:"fnt/arcade.ttf", s:10, c:COL[1], bc:COL[2], bt:1};
					textBoot.alpha = 0.3;
					textBoot.setCarrier('_', 0.2);
					textBoot.onComplete = seq.nextV;
					textBoot.setText(Reg.INI.get('text', 'amstrad'));
					add(textBoot);
				FlxTween.tween(textBoot, { alpha:1, y:32 }, 0.33, { ease:FlxEase.quadOut } );
				
			case 2:
				var rainbow = new RainbowStripes();
					rainbow.queueModes(["1:0.4", "2:0.6", "3:0.6", "1:0.2"], seq.nextV);
					rainbow.setOn();
				snd_load =  D.snd.play("amstrad_load");
				add(rainbow);
				
			case 3:
				snd_load.stop();
				FlxG.switchState(new StateTitle());
			default:
			}
		}, 0.15));
	}//---------------------------------------------------;

	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		_time += elapsed;
		D.ctrl.gamepad_poll();
		if (D.ctrl.justPressed(_START_A) && _time > _NEXT_MIN_TIME) {
			FlxG.switchState(new StateTitle());
		}
	}//---------------------------------------------------;
	
}//-- end --//