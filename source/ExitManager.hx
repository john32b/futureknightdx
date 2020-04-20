/**
   FUTURE KNIGHT EXIT MANAGER
   ============================
   
   - Keeps track of locked/open exits across all maps
   - AnimatedTiles (exittype) talk to this to get exit status
   - Unlock Exit requirements, like an item, etc
   
   :: TILED EXIT PROPERTIES
   
		name , is just an ID
		goto, where to go "mapname,ID"
		req, requirements to unlock, "item:ITEM_ENUM"
		e.g.
		- name = A
		- prop.goto = "level_03:B"
		- prot.req = "item:EXIT_PASS"
   
--------------------------------------------  */

package;
import djfl.util.TiledMap.TiledObject;


class ExitManager 
{
	
	/// TODO: Whenever an exit has been unlocked, put its ID here.
	var UNLOCKED_EXITS:Array<Dynamic>;
	
	
	public function new() 
	{
		
	}
	
	// -- Called by an exit when it is spawned
	public function isLocked(o:TiledObject):Bool
	{
		if (o.prop == null) throw "Exit should have properties defined";
		if (o.prop.req == null || o.prop.req == "") return false;
		
		//>> Check the UNLOCKED_EXITS and if it has been unlocked, just return true
		
		return true;
	}//---------------------------------------------------;
	
	
	// -- This is called when a requirement is met, or an item is used?????
	public function unlockExit()
	{
		
	}//---------------------------------------------------;
	
}