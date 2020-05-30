/**
	Amstrad Loading State
	---------------------
	- Simulates the Amstrad CPC loading screen
	- Loads text from ini file (REG.INI)
	- Next state = StateTitle
================================================= */

package states;

import djFlixel.D;
import djFlixel.fx.RainbowStripes;
import djFlixel.gfx.pal.Pal_CPCBoy;
import djFlixel.ui.FlxAutoText;
import djFlixel.other.FlxSequencer;
import flixel.FlxG;
import flixel.FlxState;
import flixel.group.FlxGroup;
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
		
		FlxG.camera.bgColor = Pal_CPCBoy.COL[31];
		
		var l0 = new FlxGroup();
		add(l0);
		
		var rainbow = new RainbowStripes();
		add(rainbow);
		
		Reg.add_border();
		
		var snd_load:FlxSound;
		add(new FlxSequencer((seq)->{
			switch(seq.step) {
				case 1:
				var textBoot = new FlxAutoText(18, 0, 290, 0);
					textBoot.style = {f:"fnt/amstrad.ttf", s:8, c:Pal_CPCBoy.COL[20]};
					textBoot.alpha = 0.3;
					textBoot.setCarrier('_', 0.15);
					textBoot.setText(Reg.INI.get('text', 'amstrad'));
					textBoot.onComplete = seq.nextV;
					l0.add(textBoot);
				FlxTween.tween(textBoot, { alpha:1, y:32 }, 0.33, { ease:FlxEase.quadOut } );
			case 2:
				rainbow.queueModes(["1:0.4", "2:0.6", "3:0.6", "1:0.2"], seq.nextV);
				rainbow.setOn();
				snd_load =  D.snd.play("amstrad_load");
			case 3:
				snd_load.stop();
				FlxG.switchState(new StateTitle());
			default:
			}
		}, 0.1));
	}//---------------------------------------------------;

	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		_time += elapsed;
		if (D.ctrl.justPressed(_START_A) && _time > _NEXT_MIN_TIME) {
			FlxG.switchState(new StateTitle());
		}
	}//---------------------------------------------------;
	
}//-- end --//