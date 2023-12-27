package states;
import djFlixel.D;
import djFlixel.core.Dcontrols.DButton;
import djFlixel.gfx.FilterFader;
import djFlixel.gfx.StarfieldSimple;
import djFlixel.gfx.pal.Pal_CPCBoy;
import djFlixel.other.DelayCall;
import djFlixel.other.FlxSequencer;
import djFlixel.ui.FlxAutoText;
import flixel.FlxG;
import flixel.FlxState;
import flixel.effects.FlxFlicker;
import flixel.tweens.FlxTween;
import gamesprites.Player;
import djA.parser.TiledMap.TiledObject;
//using Lambda;

class StateIntro extends FlxState
{
	var pl:Player;
	var map:MapFK;
	var obj:Map<String, TiledObject>;
	var onbtn:Void->Void = null;
	
	override public function create() 
	{
		super.create();
		var textst1 = {f:'fnt/arcade.ttf', s:10, c:Pal_CPCBoy.COL[27] };
		var textst2 = {f:'fnt/text.ttf', s:16, c:Pal_CPCBoy.COL[26], a:'center',bc:Pal_CPCBoy.COL[2] };
		
		// Static fx
		var fx = new djFlixel.gfx.StaticNoise(0, 0, cast FlxG.width / 2, FlxG.height );
		fx.color_custom([0xff000000, 0xff101010]);
		fx.centerOrigin();
		fx.scale.x = 2;
		fx.x = 80;
		add(fx);
		
		// --
		var t1 = D.text.get('INCOMING DISTRESS SIGNAL', textst1);
			t1.textField.backgroundColor = Pal_CPCBoy.COL[6];
			t1.textField.background = true;
			D.align.screen(t1);
			add(t1);
		
		var t2 = new FlxAutoText(0, 0, 265);
			t2.sound.char = 'pl_climb';
			t2.style = textst2;
			D.align.screen(t2);
			t2.y -= 40; // Flxautotext when screen center, the height is just one line, so compensate

		add(new FlxSequencer((seq)-> {
			switch(seq.step){
				case 1:
				FlxFlicker.flicker(t1, 2, 0.4, true, true, null, (_)->{
					D.snd.playV('exit_unlock');
				});
				seq.next(3.5);
				onbtn = ()->{
					FlxFlicker.stopFlickering(t1);
					seq.next();
				}
				case 2:
				remove(t1);
				add(t2);
				t2.setText(Reg.INI.get('text', 'intro'));
				t2.onComplete = seq.nextV;
				onbtn = ()->{
					t2.stop(true);
					seq.next();
				}
				case 3:
				// pause to read the text?
				onbtn = seq.nextV;
				seq.next(2);
				case 4:
				onbtn = null;
				remove(t2);
				remove(seq);
				P_00();
				onbtn = ()->{
					onbtn = null;
					P_05();
				};
				case _:
			}
		},0));
	}//---------------------------------------------------;
	
	
	function P_00()
	{
		// -- Dummy player, need this to work for map to work
		pl = new Player();
		// --
		map = new MapFK(pl);
		FlxG.cameras.reset(map.camera);	// << Make the default camera
		camera.y += 29;
		
		add(map);
		map.onEvent = (e)-> { if (e == loadMap) P_01(); };
		map.loadMap('intro');
	}//---------------------------------------------------;
	
	function P_01()
	{
		// Position datas
		obj = map.T.getObjMap('Entities');
		
		// -- Teleporter sprite
		var tp = Reg.IM.getSprite(obj['teleporter'].x, obj['teleporter'].y, 'teleporter', 0);
		tp.animation.add('main', [0, 1], 12);
		tp.animation.play('main');
		add(tp);
		
		// -- Init and place the player
		//  - I am hacking some player variables to make him un-interactible
		pl.setPosition(obj['player'].x, obj['player'].y);
		pl.animation.play('walk');
		@:privateAccess pl.fsm.switchTo(null);	// force no state
		pl.flipX = true;
		pl.alive = false;
		add(pl);
		
		// -- Tween the player to reach the teleporter :
		FlxTween.tween(pl, {x:obj['p1'].x}, 1.8, {onComplete:P_02});
		D.snd.playV('teleport1');
	}//---------------------------------------------------;
	
	function P_02(_)
	{
		pl.animation.play('wave');
		FlxTween.tween(pl, {y:obj['p1'].y}, 2, {onComplete:P_03, startDelay:1.4});
		new DelayCall(0.8, ()->{
			map.flash(2);
			D.snd.play('en_hit_1');
		});
	}//---------------------------------------------------;
		
	function P_03(_)
	{
		map.flash(10);
		D.snd.play('en_hit_2');
		FlxFlicker.flicker(pl, 1.2, 0.04, false, true, (_)->{
			D.snd.play('teleport2');
			D.snd.play('en_hit_2');
		});
		new DelayCall(2, P_04);
	}//---------------------------------------------------;
	
	function P_04()
	{
		new FilterFader(true, P_05, {delayPost:1});
	}//---------------------------------------------------;
	
	function P_05()
	{
		FlxG.switchState(new StatePlay());
	}//---------------------------------------------------;
	
	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		if (D.ctrl.justPressed(DButton._START_A)) {
			if (onbtn != null) onbtn();
		}
	}

}//--