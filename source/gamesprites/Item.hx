/**
	
	FUTURE KNIGHT ITEM
	===================
	
	= Item Graphics: {
		Size = 20x20 
		Total = 12
	}
		
	- Item Types defined here (ITEM_TYPE)
	
	- Item Sprite for placing on the MAP
	- Bouncing up and down using a very simple sin() on the y axis
	- For USING ITEMS , see StatePlay.use_current_item()
	
************************************************************/

package gamesprites;

import djFlixel.D;
import djfl.util.TiledMap.TiledObject;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import haxe.EnumTools;


/**

	Item Definitions
	- Ordering Matters!
      . The order must be the same as the sprite image `ts_items` 
	  . And the same order in 'editor_entity'
	  . Remember `MapTiles.hx` translates Editor ID  -> Real Item ID
**/
enum ITEM_TYPE
{
	NONE; 	// 0
	BOMB1;	
	BOMB2;
	BOMB3;
	GLOVE;
	SAFE_PASS; 			// Used in level_06
	EXIT_PASS;			// Used in level_08		
	CONFUSER_UNIT;
	PLATFORM_KEY;		// Used in level_07
	SECURO_KEY; 
	BRIDGE_SPELL; // 10
	FLASH_BANG_SPELL;
	RELEASE_SPELL;
	DESTRUCT_SPELL; 
	SCEPTER;
	MAP;		// 15
}//---------------------------------------------------;


class Item extends MapSprite
{
	// Note: BOMB1,BOMB2,BOMB3, all will get the data key => BOMB
	// 
	public static var ITEM_DATA:Map<ITEM_TYPE,Hud.ItemHudInfo> = [
	
			BOMB1 => { name:"Bomb", desc:"This is a bomb!", icon:5 },
			BOMB2 => { name:"Bomb", desc:"You have found a bomb!", icon:5 },
			BOMB3 => { name:"Bomb", desc:"A Bomb!", icon:5 },
			CONFUSER_UNIT => { name:"Confuser", desc:"You have found a confuser.", icon:8 },
			GLOVE => { name:"Glove", desc:"This is an asbestos glove", icon:12 },
			SAFE_PASS => { name:"Safe Pass", desc:"It says `Safe pass`", icon:6},
			EXIT_PASS => { name:"Exit Pass", desc:"Looks like an exit pass", icon:7 },			
			SECURO_KEY => { name:"Securo Key", desc:"This is a Securo key", icon:9 },
			PLATFORM_KEY => { name:"Platform Key", desc:"You have a platform key", icon:10 },	// Use on keylock
			BRIDGE_SPELL => { name:"Bridge Spell", desc:"This is a Bridge spell", icon:11 },
			FLASH_BANG_SPELL => { name:"Flash-Bang Spell", desc:"A Flash-Bang spell!", icon:13 },
			RELEASE_SPELL => { name:"Release Spell", desc:"You found the Release spell", icon:13 },
			DESTRUCT_SPELL => { name:"Destruct Spell", desc:"You have found the Destruct Spell", icon:14 },
			SCEPTER => { name:"Scepter", desc:"You've found the scepter!", icon:15 }, 
			MAP => { name:"Map", desc:"You found a map", icon:16 }
	];
	
	inline static var BOUNCE = 2; 	// Vertical Pixel bounce on the Map
	inline static var STEP = 0.12;	// Bounce Speed
	
	public var item_id:ITEM_TYPE;

	var inc:Float = 0;	// Move-Loop counter
	
	// Get an item for use in UI
	public static function getItemSprite(gid:Int = 1):Item
	{
		var i = new Item();
		i.setItemID(gid);
		i.moves = false;
		i.active = false;
		return i;
	}//---------------------------------------------------;
	
	public function new() 
	{
		super();
		Reg.IM.loadGraphic(this, 'items');
	}//---------------------------------------------------;
	
	
	/**
	   Kill this and also remove it from the map
	**/   
	public function killExtra()
	{
		Reg.st.map.killObject(O, true);
		kill();
	}//---------------------------------------------------;
	
	/** 
	  Set a new item graphic and enum data
	  - separate function because this is used from the inventory also
	  - GID is int (1->maxitems)
	  */
	public function setItemID(gid:Int)
	{
		item_id = EnumTools.createByIndex(ITEM_TYPE, gid);
		animation.frameIndex = gid - 1;
	}//---------------------------------------------------;
	
	override public function spawn(o:TiledObject, gid:Int):Void 
	{
		super.spawn(o, gid);
		setItemID(gid);
		spawn_origin_set(1);
		spawn_origin_move();
		inc = Math.PI;	// Alter the bouncing starting direction
	}//---------------------------------------------------;
	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		y = -1 + SPAWN_POS.y+ Math.sin(inc) * BOUNCE;
		inc += STEP;
	}//---------------------------------------------------;
	
	
	public function cant_pick_up()
	{
		FlxFlicker.flicker(this, 2, 0.15);
		D.snd.play(Reg.SND.error);
	}//---------------------------------------------------;
}// --