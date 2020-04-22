/**
   FUTURE KNIGHT EXIT MANAGER
   ============================   

   - Keeps track of locked/open exits across all maps
   - AnimatedTiles (exittype) talk to this to get exit status
   - Unlock Exit requirements, like an item, etc
   
   - LIFETIME : same as a playstate, does not reset between map loads.
  
   
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
import gamesprites.Item.ITEM_TYPE;
import gamesprites.AnimatedTile;
import haxe.EnumTools;


class ExitManager 
{
	// All unlocked exits throughout the game
	// < "LEVEL:EXIT_NAME" >
	var UNLOCKED_EXITS:Array<String>;
	
	// Load a map at the end of an update cycle
	// Main checks this
	public var loadRequest:String;
	
	// --
	public function new() 
	{
		UNLOCKED_EXITS = [];
		loadRequest = null;
	}//---------------------------------------------------;
	
	// -- Called by an exit when it is spawned
	public function isLocked(o:TiledObject):Bool
	{
		//if (o.prop == null) throw "Exit should have properties defined";
		
		if (o.prop == null) return false;
		if (o.prop.req == null || o.prop.req == "") return false;
		
		//>> Check the UNLOCKED_EXITS and if it has been unlocked, just return true
		
		return true;
	}//---------------------------------------------------;
	
	
	// -- This is called when a requirement is met, or an item is used ?????
	public function unlockExit()
	{
		
	}//---------------------------------------------------;
	
	// - Called from player, pressing up an any exit
	// Note: The animatedTile, has all the data I need to know
	public function activate(e:AnimatedTile)
	{
		trace("-- Activating Exit --", e.type);
		
		var locked = e.type.getParameters()[0];

		if (locked)
		{
			// Check Requirements: 
			var d = cast(e.O.prop.req, String).split(':');
			if (d[0].toLowerCase() == "item")
			{
				var it = EnumTools.createByName(ITEM_TYPE, d[1]);
				trace("Needs item", it);
				
				if (Reg.st.HUD.equipped_item == it)
				{
					trace("YOU HAVE THE ITEM. EXIT UNLOCK KNOW");
				}else{
					Reg.st.HUD.set_text("Needs item " + it, true, 3);
				}
			}
			// play sound
			// message on what it requires to unlok
		}else
		{
			loadRequest = e.O.prop.goto;
		}
	}//---------------------------------------------------;
	
}// --