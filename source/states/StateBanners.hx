package states;

import djFlixel.D;
import djFlixel.fx.BoxFader;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import djFlixel.gfx.pal.Pal_DB32;
import flixel.FlxCamera;

class StateBanners extends FlxState
{
	static inline var FADE_TIME = 0.9;
	static inline var IMAGE = "assets/images/banner_controls.png";
	
	//---------------------------------------------------;
	var nextState:Class<FlxState> = StateTitle;
	var im:FlxSprite;
	var isAnim:Bool = true;
	var pfader:BoxFader;
	var _t:Float = 0;
	//---------------------------------------------------;

	override public function create():Void 
	{
		super.create();
		FlxG.camera.bgColor = Pal_DB32.COL_03;
		FlxCamera.defaultCameras = [camera];
		// --
		im = cast add(new FlxSprite(0, 0, IMAGE ));
		D.align.screen(im, "center", "center");
		// --
		pfader = new BoxFader(0, 0, FlxG.width, FlxG.height);
		pfader.setColor(Pal_DB32.COL_03);
		pfader.fadeOff(()->{isAnim = false; }, {time:FADE_TIME});
		add(pfader);
		
		add(Reg.get_overlayScreen());
	}//---------------------------------------------------;
	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		_t += elapsed;
		if (!isAnim) {
			if (_t >= Reg.BANNER_DELAY || D.ctrl.justPressed(_START_A))  {
				// FadeIn and Leave the state to the next state
				isAnim = true;
				pfader.fadeColor(Pal_DB32.COL_02, {
					time:FADE_TIME,
					callback:()->{
						if (Reg.checkProtection()) {
							FlxG.switchState(cast (Type.createInstance(nextState, [])));
						}else{
							//FlxG.switchState(new State_Block("p.climb"));
							/// TODO STATE_BLOCKED
						}
					}
				});
			}//- end if
		}//- end if
	}//---------------------------------------------------;
}// -- end -- //