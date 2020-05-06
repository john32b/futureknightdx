/**
   Quick and dirty add some debugging functions to the game
  
   - Press [`] to open up the debugger
   - In the console you can access this object with [D]
   
------------------------------------------*/


package;
import flixel.FlxG;
import gamesprites.Item.ITEM_TYPE;

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
	
	@:access(gamesprites.Player)
	public function pl_weapon(a:Int)
	{
		Reg.st.player.bullet_type = a;
		Reg.st.HUD.bullet_pickup(a);
	}//---------------------------------------------------;
	
	public function item_add(i:Int)
	{
		FlxG.log.notice('Adding item $i');
	}//---------------------------------------------------;
	
	public function item_all()
	{
		Reg.st.INV.addItem(ITEM_TYPE.SECURO_KEY);
		Reg.st.INV.addItem(ITEM_TYPE.PLATFORM_KEY);
		Reg.st.INV.addItem(ITEM_TYPE.EXIT_PASS);
		Reg.st.INV.addItem(ITEM_TYPE.SAFE_PASS);
	}//---------------------------------------------------;
	
	
	public function load(lData:String)
	{
		Reg.st.map.loadMap(lData);
	}//---------------------------------------------------;
	
	public function flash()
	{
		Reg.st.flash(20);
	}//---------------------------------------------------;
	
	public function appendMap()
	{
		Reg.st.map.appendMap(true);
	}//---------------------------------------------------;
}// --