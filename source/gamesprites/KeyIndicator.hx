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
	   Show the indicator, the Y position is autocalculated 
	   @param	type 0:Arrow UP | todo more?
	   @param	X Pixel position
	**/
	public function setAt(T:AnimatedTile)
	{
		lastTime = FlxG.game.ticks;
		if (alive) return;
		
		var X = (Std.int(T.x / 32) * 32) + 16;
		//var Y = Reg.st.player.y - (frameHeight / 2);
		
		var Y = Reg.st.player.y - (frameHeight / 2);
		var Y = T.y - (frameHeight / 2);
		
		if ( (Y - frameHeight / 2) < Reg.st.map.roomCornerPixel.y)
		{
			Y += 32;
		}
		
		setPosition(X, Y);
		lockPos();
		revive();
		setEnabled();
		animation.frameIndex = 0;
	}//---------------------------------------------------;
		
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		if (FlxG.game.ticks - lastTime > KILL_CHECK_TIME) kill();
	}//---------------------------------------------------;
	
}// --