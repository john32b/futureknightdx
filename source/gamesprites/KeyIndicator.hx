/**
 
   Specialized UI Indicator for button prompts
   
   - setAt(Frame,X,Y) to activate
   - It will auto-kill when not got a call in <KILL_CHECK_TIME>
   
-----------------------------------------------**/
  
package gamesprites;
import djFlixel.ui.UIIndicator;
import flixel.FlxG;
import flixel.FlxSprite;


class KeyIndicator extends UIIndicator
{

	static inline var KILL_CHECK_TIME = 250;
	
	var lastTime:Int = 0;
	
	public function new() 
	{
		super();
		Reg.IM.loadGraphic(this, 'keys');
		scrollFactor.set(1, 1);
		setSize(1, 1);
		centerOffsets(true);
		setAnim(1, {axis:'-y', steps:3});
	}//---------------------------------------------------;

	/**
	   @param	type 0:Arrow UP
	   @param	X 
	   @param	Y
	**/
	public function setAt(type:Int, X:Float = 0, Y:Float = 0)
	{
		lastTime = FlxG.game.ticks;
		if (alive) return;
		
		X = (Std.int(X / 32) * 32) + 16;
		Y = Reg.st.player.y - (frameHeight / 2) - 2;
		
		trace("Activating key ind >>");
		setPosition(X, Y);
		lockPos();
		revive();
		setEnabled();
		animation.frameIndex = type;
	}//---------------------------------------------------;
		
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		if (FlxG.game.ticks - lastTime > KILL_CHECK_TIME) kill();
	}//---------------------------------------------------;
	
}// --