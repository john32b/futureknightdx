/**
 
   Specialized UI Indicator for button prompts
   
   - setAt(Frame,X,Y) to activate
   
   
   
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
	   It places the '^' indicator right above an Animated Tile
	   - Can be called every frame of the overlap.
	   - Once it is no longer called, it will auto kill()
	   @called by Player.event_anim_tile();
	   @param	T The Animated Tile this indicator should align to
	**/
	public function setAt(T:AnimatedTile)
	{
		lastTime = FlxG.game.ticks;
		if (alive) return;
		
		var X = (Std.int(T.x / 32) * 32) + 16;
		var Y = T.y - (frameHeight / 2);
		
		// If it is offscreen lower it a bit
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