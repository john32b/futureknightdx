/**
ROOM SPRITES MANAGER
======================== 

 Manager for all Tiled Map Entities that scroll in and out of rooms
 
 - Enemies
 - Items
 - Animated Tiles
 
 ------------------------------- */

 

package;

import djFlixel.D;
import flixel.FlxBasic;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import djA.parser.TiledMap;
import djA.parser.TiledMap.TiledObject;
import MapTiles.EDITOR_TILE;
import flixel.util.FlxDestroyUtil;
import gamesprites.AnimatedTile;
import gamesprites.Enemy;
import gamesprites.Item;
import gamesprites.MapSprite;



class RoomSprites extends FlxGroup
{
	// Easy access :
	public var gr_enemy:FlxTypedGroup<MapSprite>;
	public var gr_item:FlxTypedGroup<MapSprite>;
	public var gr_anim:FlxTypedGroup<MapSprite>;
	
	// Here go the sprites are are to be killed once the screen transition ends
	var stash:Array<FlxBasic>;
	
	// Sub Groups. Holds all the inner groups
	var sg:Array<FlxTypedGroup<MapSprite>>;
	
	// Counts down, mainly used for Confuser Item Effect, where the aliens stop moving for a bit
	// -- Direct Access set to >0 to start counting down to 0, when it reaches 0 it will unfreeze enemies
	public var counter:Float = 0;
		
	
	public var has_final_boss(get, never):Bool;
	
	//====================================================;
	
	public function new() 
	{
		super();
		
		sg = [];
		for (i in 0...3) {
			sg[i] = new FlxTypedGroup<MapSprite>();
			add(sg[i]);
		}
		
		gr_item = sg[0];
		gr_anim = sg[1];
		gr_enemy = sg[2];
		
		stash = [];	
	}//---------------------------------------------------;
	
	/**
	   Creates/Spawns an Entity, based off an EntityData (fed from the Map)
	**/
	public function spawn(en:TiledObject)
	{
		// DEV: en.gid is real Tiled Editor GID
		// going to be converted to {type, gid}
		var data = MapTiles.convert_TiledGID_to_Proper(en.gid);
	
		if (data == null)
		{
			trace("ERROR: No Entity Data for ", en);
			trace("CHECK YOUR MAP IN THE EDITOR FOR EMPTY ENTITIES");
			return;
		}
		
		var s:MapSprite;
		switch(data.type)
		{
			case EDITOR_TILE.ITEM:
				s = gr_item.recycle(Item);
			case EDITOR_TILE.ANIM:
				s = gr_anim.recycle(AnimatedTile);
			case EDITOR_TILE.ENEMY:
				s = gr_enemy.recycle(Enemy);
			case EDITOR_TILE.FRIEND:
				s = gr_anim.recycle(AnimatedTile);
				// Normally the gid would be (1), but that is taken, so I am hacking a unique value
				data.gid = 100;
			case _: 
				//trace('Error ${data.type} cannot be spawned from <RoomSprites>');
				return;
		}
		
		s.spawn(en, data.gid);
	}//---------------------------------------------------;
	
	
	public function stashSave()
	{
		for (I in sg) for (i in I) {
			// DEV: I need to check for (exists) because else it will also put in the killed sprites
			// 		and the new ones when they get created, they would be already in the stash
			//		and would be destroyed on stashkill()
			//      -- I am logging this because I had an issue --
			if (i.exists) stash.push(i);
		}
	}//---------------------------------------------------;
	
	public function stashKill()
	{
		for (i in stash) {
			i.kill();
		}
		stash = [];
	}//---------------------------------------------------;
	
	/** Call this after a map load to clear/kill all sprites */
	public function reset()
	{
		for (I in sg) for (i in I) {
			i.kill();
		}
		stash = [];
		counter = 0;
	}//---------------------------------------------------;
	
	/**
	   Freeze/Unfreeze all enemies 
	   @param	freeze True to Freeze. False to Unfreeze
	**/
	public function enemies_freeze(freeze:Bool)
	{
		for (i in gr_enemy)
		{
			if (i.alive) {
				i.moves = !freeze;
			}
		}
	}//---------------------------------------------------;
	
	/**
	   Get all AnimatedTiles of a Type
	   > Used to check if a particular thing is on screen, like FRIEND, or LASERS
	   @param	type see AnimTileType.hx
	   @return Array that can by empty
	**/
	public function getAnimTiles(type:AnimTileType):Array<AnimatedTile>
	{
		var ar:Array<AnimatedTile> = [];
		for (i in gr_anim) {
			if (!i.alive) continue;
			var tile = cast(i, AnimatedTile);
			if (tile.type == type) ar.push(tile);
		}
		return ar;
	}//---------------------------------------------------;
	
	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		// This should not be called when the game is paused.
		if (counter > 0) {
			if ((counter -= elapsed) <= 0) {
				enemies_freeze(false);
				counter = 0;
			}
		}
	}//---------------------------------------------------;
	
	// Return the boss if it exists in this room, null for not found
	public function getFinalBoss():Enemy
	{
		for (i in gr_enemy)
		{
			if (!i.alive) continue;
			var en = cast(i, Enemy);
			if (en.O.gid == MapTiles.EDITOR_FINAL) {
				return en;
			}
		}
		return null;
	}//---------------------------------------------------;
	
	
	// Getter
	function get_has_final_boss():Bool
	{
		var b = getFinalBoss();
		return b != null;
	}//---------------------------------------------------;

	
}// --