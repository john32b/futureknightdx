/**
 Game related logic and vars
 ========================
 
 - Mostly game related global functions
 
*/


package;

import djA.DataT;
import gamesprites.AnimatedTile;
import gamesprites.Player;
import gamesprites.Item.ITEM_TYPE;
import haxe.EnumTools;


class Game 
{
	public static var START_MAP = 'assets/maps/level_01.tmx';
	
	// Note: BOMB1,BOMB2,BOMB3, all will get the data key => BOMB
	// Icon Number is what <hud_items.png> index - 4
	public static var ITEM_DATA:Map<ITEM_TYPE,Hud.ItemHudInfo> = [
	
			BOMB1 => { name:"Bomb", desc:"You have a Berm (Francais)", icon:4 },
			BOMB2 => { name:"Bomb", desc:"You have a Berm (Francais)", icon:4 },
			BOMB3 => { name:"Bomb", desc:"You have a Berm (Francais)", icon:4 },
			GLOVE => { name:"Glove", desc:"Glove", icon:8 },
			
			SAFE_PASS => { name:"Safe Pass", desc:"It says `Safe pass`", icon:1},
			EXIT_PASS => { name:"Exit Pass", desc:"Looks like an exit pass", icon:6 },
			CONFUSER_UNIT => { name:"Confuser", desc:"Hey, you`ve found a confuser", icon:2 },			
			PLATFORM_KEY => { name:"Platform Key", desc:"You have a platform key", icon:5 },
			SECURO_KEY => { name:"Securo Key", desc:"This is a Securo key", icon:3 },
			BRIDGE_SPELL => { name:"Bridge Spell", desc:"--", icon:1 },
			
			FLASH_BANG_SPELL => { name:"Flashbang Spell", desc:"--", icon:1 },
			RELEASE_SPELL => { name:"Release Spell", desc:"--", icon:1 },
			DESTRUCT_SPELL => { name:"Destruct Spell", desc:"--", icon:1 },
			SHORTENER_SPELL => { name:"Shortener Spell", desc:"--", icon:1 },
	];
	
	
	public static function init()
	{
	}//---------------------------------------------------;
	
	
	// -- This exit has all the data I need to know
	// Called from player, pressing up an any exit
	static public function exit_activate(e:AnimatedTile)
	{
		trace("-- Activating Exit --");
		
		var locked = e.type.getParameters()[0];
		if (locked)
		{
			var d = cast(e.O.prop.req, String).split(':');
			if (d[0].toLowerCase() == "item")
			{
				trace("Needs item", EnumTools.createByName(ITEM_TYPE, d[1]));
			}
			// play sound
			// message on what it requires to unlok
		}else
		{
			var d = cast(e.O.prop.goto, String).split(':');
			//d[0] is level id, d[1] is exit ID to spawn player
			trace("OK. WILL GOTO :: ", d);
		}
		
		
	}//---------------------------------------------------;
	
}// --