package states;
import djFlixel.D;
import djFlixel.fx.BoxFader;
import djFlixel.fx.StarfieldSimple;
import djFlixel.gfx.pal.Pal_CPCBoy;
import djFlixel.other.FlxSequencer;
import djFlixel.tool.DelayCall;
import djFlixel.ui.FlxAutoText;
import djfl.util.TiledMap;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.effects.FlxFlicker;
import flixel.tweens.FlxTween;
import gamesprites.Player;
import lime.system.BackgroundWorker;
using Lambda;

class StateIntro extends FlxState
{
	var pl:Player;
	var map:MapFK;
	var obj:Map<String,TiledObject>;
	
	override public function create() 
	{
		super.create();
		var textst1 = {f:'fnt/score.ttf', s:6, c:Pal_CPCBoy.COL[24], bc:Pal_CPCBoy.COL[2], bt:2};
		var textst2 = {f:'fnt/text.ttf', s:16, c:Pal_CPCBoy.COL[26], a:'center',bc:Pal_CPCBoy.COL[2] };
		
		// :: STARS
		var stars = new StarfieldSimple(FlxG.width, FlxG.height, [	
			Pal_CPCBoy.COL[0],
			Pal_CPCBoy.COL[31],
			Pal_CPCBoy.COL[30],
			Pal_CPCBoy.COL[29]
		]);
		stars.WIDE_PIXEL = true;
		stars.STAR_SPEED = 0.4;
		stars.STAR_ANGLE = 90;
		add(stars);
		
		Reg.add_border();
		
		// --
		var t1 = D.text.get('INCOMING DISTRESS SIGNAL', textst1);
			D.align.screen(t1);
			add(t1);
		
		var t2 = new FlxAutoText(0, 0, 265);
			t2.sound.char = 'pl_climb';
			t2.style = textst2;
			t2.height;
			D.align.screen(t2);
			t2.y -= 40; // Flxautotext when screen center, the height is just one line, so compensate

		add(new FlxSequencer((seq)-> {
			switch(seq.step){
				case 1:
				FlxFlicker.flicker(t1, 2, 0.4, true, true, null, (_)->{
					D.snd.playV('exit_unlock');
				});
				seq.next(3.5);
				case 2:
				remove(t1);
				add(t2);
				t2.setText(Reg.INI.get('text', 'intro'));
				t2.onComplete = seq.nextV;
				case 3:
				seq.next(2);
				case 4:
				remove(t2);
				remove(seq);
				P_00();
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
		new DelayCall(()->{
			map.flash(2);
			D.snd.play('en_hit_1');
		} , 0.8);
	}//---------------------------------------------------;
		
	function P_03(_)
	{
		map.flash(10);
		D.snd.play('en_hit_2');
		FlxFlicker.flicker(pl, 1.2, 0.04, false, true, (_)->{
			D.snd.play('teleport2');
			D.snd.play('en_hit_2');
		});
		new DelayCall(P_04, 2);
	}//---------------------------------------------------;
	
	function P_04()
	{
		var b = new BoxFader();
		add(b);
		b.fadeColor(0xFF000000, P_05, {delayPost:1});
	}//---------------------------------------------------;
	
	function P_05()
	{
		FlxG.switchState(new StatePlay());
	}//---------------------------------------------------;

}//--