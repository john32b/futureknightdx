/**
   Quick and dirty add some debugging functions to the game
  
   - Press [`] to open up the debugger
   - In the console you can access this object with [D]
   
------------------------------------------*/


package;
import djFlixel.D;
import flixel.FlxG;
import gamesprites.Item.ITEM_TYPE;
import states.StatePlay;

#if debug

class Debug 
{
	// Written by MAPFK. Used for when reloading maps
	static public var LAST_MAP_LOADED:String = "";
	
	public function new() 
	{
		FlxG.console.registerObject("D", this);
		
		if (Reg.INI.exists('DEBUG', 'startPlay'))
			FlxG.switchState(new StatePlay());
			
		if (Reg.INI.exists('DEBUG', 'delsave')){
			D.save.deleteSave();
			trace("INI File Trigger > Save Deleted");
		}
		
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
	
	public function pl_health(v:Int)
	{
		Reg.st.player.health = v;
		@:privateAccess Reg.st.player.healthSlow = v;
		Reg.st.HUD.set_health(v);
	}//---------------------------------------------------;
	
	
	@:access(gamesprites.Player)
	public function pl_weapon(a:Int)
	{
		Reg.st.player.bullet_type = a;
		Reg.st.HUD.bullet_pickup(a);
	}//---------------------------------------------------;
	
	public function item(i:Int=-1)
	{
		if (i ==-1)
		{
			var items = ITEM_TYPE.createAll();
		
			for (c in 0...items.length )
			{
				FlxG.log.add( { ind:c, name:items[c] } );
			}
			
		}else{
			
			var item = ITEM_TYPE.createByIndex(i);
			FlxG.log.notice("Adding item " + item);
			Reg.st.INV.addItem(item);
		}
	}//---------------------------------------------------;
	
	public function load(lData:String)
	{
		Reg.st.map.loadMap(lData);
	}//---------------------------------------------------;
	
	public function flash()
	{
		Reg.st.map.flash(20);
	}//---------------------------------------------------;
	
	public function save()
	{
		Reg.SAVE_GAME();
	}//---------------------------------------------------;
	
	public function saveDel()
	{
		D.save.deleteSlot(0);
		D.save.deleteSlot(1);
	}
	
	public function map_append()
	{
		Reg.st.map.appendMap();
	}
	public function map_append_remove()
	{
		Reg.st.map.appendRemove();
	}
	
	public function showKilled()
	{
		trace("List globally killed entities");
		var kg = @:privateAccess Reg.st.map._killed_global;
		trace(kg);
	}//---------------------------------------------------;
	
}// --


#end