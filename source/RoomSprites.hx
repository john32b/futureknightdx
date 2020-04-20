/**
ROOM SPRITES MANAGER
======================== 

 Manager for all Tiled Map Entities that scroll in and out of rooms
 
 - Enemies
 - Items
 - Animated Tiles
 
 - Pause/delete the ones that go off screen
 - Create and place the new entities for each screen
 
 ------------------------------- */

 

package;

import flixel.FlxBasic;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import djfl.util.TiledMap;
import djfl.util.TiledMap.TiledObject;
import MapTiles.EDITOR_TILE;
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
	
	
	public function spawn(en:TiledObject)
	{
		var data = MapTiles.translateEditorEntity(en.gid);
		var s:MapSprite;
		
		switch(data.type)
		{
			case EDITOR_TILE.ITEM:
				s = gr_item.recycle(Item);
			case EDITOR_TILE.ANIM:
				s = gr_anim.recycle(AnimatedTile);
			case EDITOR_TILE.ENEMY:
				s = gr_enemy.recycle(Enemy);
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
			//      -- I am logging this because I has an issue --
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
	}//---------------------------------------------------;
	
	
	public function enemies_freeze(freeze:Bool)
	{
		for (i in gr_enemy)
		{
			if (i.alive) {
				i.moves = !freeze;
			}
		}
	}//---------------------------------------------------;
}// --