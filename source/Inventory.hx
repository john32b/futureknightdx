/**
   FUTURE KNIGHT INVENTORY
   ----------------------
   
	- This class can be generalized easily, just copy paste the entire thing?

	EXAMPLE:
	--------
	
	INV = new Inventory();
	add(INV);
	INV.onItemSelect = (id)->{
		// remove item
		INV.removeItemWithID(id);
		INV.sortItems();
	}
	//--
	if (FlxG.keys.justPressed.ENTER) {
		INV.toggle();
	}
	// --
	INV.addItem(ITEM_ID_HEALTH);
	
================================================= */


package;

import djFlixel.D;
import flixel.group.FlxSpriteGroup;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.tweens.misc.VarTween;
import tools.GridNav;

import gamesprites.Item;

class Inventory extends FlxSpriteGroup
{
	static inline var SCREEN_Y 	   = 32;	// Y pos, The X pos is centered
	static inline var SCREEN_Y_OFF = SCREEN_Y + 12;	// Enter/Exit position
	static inline var GRID_X = 20;			// Pixels offset from Inventory X
	static inline var GRID_Y = 16;			// Pixels offset form Inventory Y
	static inline var GRID_WIDTH  = 6;		// Size in boxes
	static inline var GRID_HEIGHT = 2;		// Size in boxes
	static inline var GRID_PAD = 4;			// Padding between elements
	static inline var GRID_BOX_SIZE = 22;   // How big is the grid box
	static inline var GRID_CURSOR_COLOR = 0xFF485d48;
	static inline var TWEEN_TIME = 0.05;
	
	var box_items:Array<Item> = [];
	var cursor:FlxSprite;
	var _tween:VarTween; 	// Animating on-off screen
	var text:FlxText; 		// Name of the current item.
	var grid:GridNav;
	
	// Item ID, in array with holes (null for hole) Length = grid.length
	public var ITEMS:Array<Null<Int>>;
	// --
	public var isOpen(default, null):Bool;
	// -- SET THIS
	public var onItemSelect:Int->Void;
	
	public var onClose:Void->Void;
	
	public var onOpen:Void->Void;
	
	//====================================================;
	
	public function new()
	{
		super();
		
		this.scrollFactor.set(0, 0);

		// :: Background
		var bg = new FlxSprite(Reg.IM.STATIC.hud_inventory);
		bg.active = false;
		add(bg);

		// --
		text = D.text.get("Dummy Text", 45, 70);
		text.fieldWidth = 104;
		add(text);
		
		// --
		cursor = new FlxSprite();
		cursor.makeGraphic(GRID_BOX_SIZE+2, GRID_BOX_SIZE+2, GRID_CURSOR_COLOR);
		add(cursor);
		
		// --
		grid = new GridNav(GRID_WIDTH, GRID_HEIGHT);
		grid.set_box_size(GRID_BOX_SIZE, GRID_BOX_SIZE, GRID_PAD, GRID_PAD);
		grid.onCursorChange = handle_cursor_change;
	
		// -- Add Box Sprites
		for (c in 0...grid.length)
		{
			var i = Item.getItemSprite(1);	// Just get any sprite
				i.visible = false;			// default not visible
				box_items.push(i);
				add(i);
				// Position based on the grid
				var a = grid.get_box_pos(c);
					i.x = GRID_X + a.x + (GRID_BOX_SIZE-i.width) / 2;
					i.y = GRID_Y + a.y + (GRID_BOX_SIZE-i.height) / 2;
		}
		
		 //- It is important to set the group pos after adding all the objects
		//setPosition(SCREEN_X, SCREEN_Y);
		D.align.screen(this, "c", "");
		y = SCREEN_Y;
		
		// --
		ITEMS = [];
		_tween = null;
		isOpen = visible = active = false;
		
		// LAST:
		// - Fire to place the cursor. Must be called after setPosition()
		handle_cursor_change(grid.index);
	}//---------------------------------------------------;
	
	// --
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);

		if (D.ctrl.justPressed(LEFT))  grid.cursor_move( -1,  0); else
		if (D.ctrl.justPressed(RIGHT)) grid.cursor_move(  1,  0); else
		if (D.ctrl.justPressed(DOWN))  grid.cursor_move(  0,  1); else
		if (D.ctrl.justPressed(UP))    grid.cursor_move(  0, -1); else

		if (D.ctrl.justPressed(A)) {
			if (ITEMS[grid.index] != null) {
				if (onItemSelect != null) onItemSelect(ITEMS[grid.index]);
			}
		}
		
		else if (D.ctrl.justPressed(X) || D.ctrl.justPressed(START)) {
			close();
		}
		
	}//---------------------------------------------------;
	// --
	override public function destroy():Void 
	{
		super.destroy();
		D.dest.tween(_tween);
	}//---------------------------------------------------;
	// --
	// Override these two to disable deep setting into the children
	override function set_active(Value:Bool):Bool 
	{
		return active = Value;
	}//---------------------------------------------------;
	// --
	override function set_visible(Value:Bool):Bool 
	{
		return visible = Value;
	}//---------------------------------------------------;
	// --
	public function open()
	{
		if (isOpen || _tween != null) return;
		isOpen = true;
		visible = true;
		
		y = SCREEN_Y_OFF;
		_tween = FlxTween.tween(this, {y:SCREEN_Y}, TWEEN_TIME, { onComplete:(_)->{
			// DEV: I need to destroy and null, because it will not immediately be nulled
			_tween.destroy();
			_tween = null;
			active = true;
		}});
		
		if (onOpen != null) onOpen();
	}//---------------------------------------------------;
	// --
	public function close()
	{
		if (!isOpen || _tween != null) return;
		isOpen = false;
		active = false;
		y = SCREEN_Y;
		_tween = FlxTween.tween(this, {y:SCREEN_Y_OFF}, TWEEN_TIME, { onComplete:(_)->{
			// DEV: I need to destroy and null, because it will not immediately be nulled
			_tween.destroy();
			_tween = null;
			visible = false;
			if (onClose != null) onClose();
		}});
	}//---------------------------------------------------;
	// --
	public function toggle()
	{
		if (isOpen) close(); else open();
	}//---------------------------------------------------;
	// --
	public function addItem(it:Int):Bool
	{
		var i = get_available_index();
		
		if (i ==-1) {
			return false;
		}
		
		ITEMS[i] = it;
		
		var item = box_items[i];
		item.setItemID(it);
		item.visible = true;
		
		// The new item was added on the cursor, so change the text
		if (grid.index == i)
		{
			_refresh_text();
		}
		
		return true;
	}//---------------------------------------------------;
	// --
	public function removeItemWithID(it:Int):Bool
	{
		var i = ITEMS.indexOf(it);
		if (i==-1) {
			return false;
		}
		
		ITEMS[i] = null;
		box_items[i].visible = false;
		
		// Removed the item the cursor was in, so empty the text
		if (grid.index == i)
		{
			text.text = "";
		}
		
		return true;
	}//---------------------------------------------------;
	
	// Sort array and rebuild items. 
	// - Remove holes
	public function sortItems()
	{
		var AR2:Array<Null<Int>> = [];
		for (i in ITEMS) {
			if (i != null) AR2.push(i);
		}
		ITEMS = AR2;
		for (c in 0...grid.length)
		{
			var item = box_items[c];
			if (ITEMS[c] != null){
				item.visible = true;
				item.setItemID(ITEMS[c]);
			}else{
				item.visible = false;
			}
		}
		_refresh_text();	// because the cursor could now point to another item
	}//---------------------------------------------------;
	
	
	// Quickly get current item, -1 for no item
	function get_current_item():Int
	{
		if (ITEMS[grid.index] == null) return -1;
		return ITEMS[grid.index];
	}//---------------------------------------------------;
		
	
	// Get ITEMS free index, -1 if none available
	function get_available_index():Int
	{
		for (c in 0...grid.length) {
			if (ITEMS[c] == null) return c;
		}
		return -1;
	}//---------------------------------------------------;
	
	
	// Callback from whenever grid cursor changes
	function handle_cursor_change(ind)
	{
		var p = grid.get_current_pos();
		cursor.setPosition(x + GRID_X + p.x - 1, y + GRID_Y + p.y - 1);
		_refresh_text();
	}//---------------------------------------------------;
	
	function _refresh_text()
	{
		// The item ID the cursor is pointing to
		var i = get_current_item();
		if (i >= 0){
			text.text = Reg.ITEM_DATA.get(cast i).name;
		}else{
			text.text = "";
		}
	}//---------------------------------------------------;
	
	
}// --