package;

import djFlixel.D;
import djFlixel.fx.RainbowStripes;
import djFlixel.ui.FlxAutoText;
import djFlixel.other.FlxSequencer;
import flixel.FlxG;
import flixel.FlxState;
import flixel.graphics.FlxGraphic;
import flixel.group.FlxGroup;
import flixel.system.FlxSound;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;


// Intro state
// --------------
// Simulates the Amstrad CPC loading screen
class StateAmstrad extends FlxState
{
	static inline var _NEXT_MIN_TIME = 1;	// Wait this much until you can press enter to go to next state
	static inline var FONT:String = "fnt/amstrad.ttf";
	static inline var LOADSOUND:String = "amstrad_load";
	
	var OS_TEXT:String = 
		"{c:10,w:30}Amstrad 64K Microcomputer (v3)\n\n" +
		"{sp:10}© 1985 {call:one}Amstrad {np}Consumer Electronics\n" +
		"           Locomotive Software Ltd.\n\n" +
		"Basic 1.1\n\n" +
		"Ready\n";

	static inline var COMMAND_TEXT:String = '(s1)(w4)run"(w4)\n(s0)(c0)Press PLAY then any key:(w4)\n';
	
	var nextState:Class<FlxState> = StateBanners;
	var _time:Float = 0;
	//----------------------------------------------------;
	
	override public function create():Void 
	{
		super.create();
		Reg.add_border();
		FlxG.camera.bgColor = 0xFF000080;	// Amstrad Palette Color
		
		var l0 = new FlxGroup();
		add(l0);
		
		var rainbow = new RainbowStripes();
		add(rainbow);
		
		var snd_load:FlxSound;
		var seq = new FlxSequencer();
		add(seq);
		
		seq.onStep = (step:Int)->{
		switch(step) {
			case 1:
				var textBoot = new FlxAutoText(18, 0, 290, 0);
					textBoot.style = {f:FONT, s:8, c:0xFFFF00};
					textBoot.alpha = 0.3;
					textBoot.setCarrier('_', 0.15);
					textBoot.setText(Reg.INI.get('text', 'amstrad'));
					textBoot.onComplete = seq.nextV;
					l0.add(textBoot);
				FlxTween.tween(textBoot, { alpha:1, y:32 }, 0.33, { ease:FlxEase.quadOut } );
			case 2:
				rainbow.queueModes(["1:0.4", "2:0.6", "3:0.6", "1:0.2"], seq.nextV);
				rainbow.setOn();
				snd_load =  D.snd.play(LOADSOUND, 1, true);
			case 3:
				snd_load.stop();
				FlxG.switchState(cast (Type.createInstance(nextState, [])));
			default:
		}
		};
		seq.next(0.1);
	}//---------------------------------------------------;

	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		_time += elapsed;
		if (D.ctrl.justPressed(_START_A) && _time > _NEXT_MIN_TIME) {
			FlxG.switchState(cast (Type.createInstance(nextState, [])));
		}
	}//---------------------------------------------------;
	
}//-- end --//