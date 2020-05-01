/**
   Quick and dirty add some debugging functions to the game
  
   - Press [`] to open up the debugger
   - In the console you can access this object with [D]
   
------------------------------------------*/


package;
import flixel.FlxG;

class Debug 
{

	public function new() 
	{
		FlxG.console.registerObject("D", this);
	}//---------------------------------------------------;

	public function pl_kill()
	{
		Reg.st.player.health = 0;
		@:privateAccess Reg.st.player.healthSlow = 2;
		FlxG.log.notice('Player Heath = 0');
	}//---------------------------------------------------;
	
	
	public function pl_fulldamage()
	{
		Reg.st.player.hurt(999);
		FlxG.log.notice('Player Hurt 999');
	}//---------------------------------------------------;
	
	
	public function item_add(i:Int)
	{
		FlxG.log.notice('Adding item $i');
	}//---------------------------------------------------;
	
	
	public function load(lData:String)
	{
		Reg.st.map.loadMap(lData);
	}//---------------------------------------------------;
	
}// --