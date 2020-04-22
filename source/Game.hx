/**
 Game related logic and vars
 ========================
 
 - Mostly game related global functions
 
*/


package;

import gamesprites.Item.ITEM_TYPE;

class Game 
{
	// This is the first level that a new game will start with
	public static var START_MAP = 'level_01';
	
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
	
	
	
	
}// --