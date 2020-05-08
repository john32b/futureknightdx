/**
 Game related logic and vars
 ========================
 
 - Mostly game related global functions
 
*/


package;

import gamesprites.Item.ITEM_TYPE;

class Game 
{
	
	// Note: BOMB1,BOMB2,BOMB3, all will get the data key => BOMB
	// Icon Number is what <hud_items.png> index - 4
	public static var ITEM_DATA:Map<ITEM_TYPE,Hud.ItemHudInfo> = [
	
			BOMB1 => { name:"Bomb", desc:"A bomb! Destroys enemies and refills HP", icon:5 },
			BOMB2 => { name:"Bomb", desc:"A bomb! Destroys enemies and refills HP", icon:5 },
			BOMB3 => { name:"Bomb", desc:"A bomb! Destroys enemies and refills HP", icon:5 },
			CONFUSER_UNIT => { name:"Confuser", desc:"Hey, you`ve found a confuser", icon:8 },
			
			GLOVE => { name:"Glove", desc:"This is an asbestos glove", icon:12 },
			
			SAFE_PASS => { name:"Safe Pass", desc:"It says `Safe pass`", icon:6},
			EXIT_PASS => { name:"Exit Pass", desc:"Looks like an exit pass", icon:7 },			
			SECURO_KEY => { name:"Securo Key", desc:"This is a Securo key", icon:9 },
			
			PLATFORM_KEY => { name:"Platform Key", desc:"You have a platform key", icon:10 },
			BRIDGE_SPELL => { name:"Bridge Spell", desc:"This is a Bridge spell", icon:11 },
			
			FLASH_BANG_SPELL => { name:"Flash-Bang Spell", desc:"A Flash-Bang spell!", icon:13 },
			RELEASE_SPELL => { name:"Release Spell", desc:"You found the Release spell", icon:13 },
			DESTRUCT_SPELL => { name:"Destruct Spell", desc:"You have found the Destruct Spell", icon:14 },
			SCEPTER => { name:"Scepter", desc:"You've found the scepter!", icon:15 }, 
	];
	
	
	
	public static function use_current_item()
	{		
		var item = Reg.st.HUD.equipped_item;
		if (item == null) return;
		
		switch (item) {
			
			case BOMB1, BOMB2, BOMB3:
				trace("USING A BOMB");
				Reg.st.flash(10);
				Reg.st.HUD.item_pickup();
				Reg.st.ROOMSPR.enemies_killAll(); // ok kills spawn-off as well
				// > kill all enemies for good,
				// - also checkout enemies that are already dead with a timer, and killthose too
				
			case CONFUSER_UNIT:
				trace("USING CONFUSER");
				Reg.st.flash(2);
				Reg.st.HUD.item_pickup();
				Reg.st.ROOMSPR.enemies_freeze(true);	// countdown to restore ?
				// Ok the above^ will freeeze ALIVE enemies,
				// I need to have a flag, so when an enemy is respawed, it will NOT move
				// respect the global freeze flag ok?
				
			case GLOVE:
				trace("With this equipped you can pick up something hot");
				Reg.st.HUD.set_text("With this you are able to pick up hot objects");
				
			case FLASH_BANG_SPELL:
				trace("Flash Bang");
				Reg.st.flash(5);
				Reg.st.HUD.item_pickup();
				
			case DESTRUCT_SPELL:
				trace("DESTRUCT_SPELL");
				
			case SCEPTER:
				trace("Scepter");
				Reg.st.HUD.set_text("Does not do anything.");
				
			case RELEASE_SPELL:
				trace("Release spell");
				
			case _:
				trace("Cant use this here");
				Reg.st.HUD.set_text("Can`t use this here");

		}
	}//---------------------------------------------------;
	
	
}// --