/**
   FUTURE KNIGHT INVENTORY
   ----------------------
   
================================================= */


package;

import djFlixel.D;
import djFlixel.gfx.pal.Pal_CPCBoy;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.group.FlxSpriteGroup;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.tweens.misc.VarTween;
import haxe.EnumTools;
import tools.GridNav;

import gamesprites.Item;
import gamesprites.Item.ITEM_TYPE;


class Inventory extends FlxSpriteGroup
{
	static inline var SCREEN_Y 	= 16;		// Y pos, The X pos is centered
	static inline var SCREEN_Y_OFF = SCREEN_Y + 12;	// Enter/Exit position
	static inline var GRID_X = 20;			// Pixels offset from Inventory X
	static inline var GRID_Y = 25;			// Pixels offset form Inventory Y
	static inline var GRID_WIDTH  = 6;		// Size in boxes
	static inline var GRID_HEIGHT = 2;		// Size in boxes
	static inline var GRID_PAD = 4;			// Padding between elements
	static inline var GRID_BOX_SIZE = 22;   // How big is the grid box
	static        var GRID_CURSOR_COLOR = Pal_CPCBoy.COL[30];
	static inline var TWEEN_TIME = 0.05;
	
	var SND = {
		tick:"cursor_tick",
		ok:"cursor_ok",
		open:"inv_open",
		close:"inv_close"
	}
	
	var box_items:Array<Item> = [];
	var cursor:FlxSprite;
	var grid:GridNav;
	
	var _tween:VarTween; 	// Animating on-off screen
	
	var text:FlxText; 		// Name of the current item.
	var text_level:FlxText;	// Name of level
	
	/// FUTURE, These should go in a Button Class
	var options:FlxText;		// Options text
	var options_bg:FlxSprite;	// Highlight square of the Options Text
	
	
	// Item ID, in array with holes (null for hole) Length = grid.length
	public var ITEMS:Array<Null<ITEM_TYPE>>;
	
	public var isOpen(default, null):Bool;
	
	// :: CALLBACKS :: MUST BE SET!!
	public var onItemSelect:ITEM_TYPE->Void;
	public var onClose:Void->Void;
	public var onOpen:Void->Void;
	
	// Which group is focused. 0:options, 1:Items
	public var _grpfoc:Int = 0;	
	
	//====================================================;
	
	public function new()
	{
		super();
		
		this.scrollFactor.set(0, 0);

		// :: Background
		var bg = new FlxSprite(Reg.IM.STATIC.hud_inventory);
			bg.active = false;
		add(bg);
		
		D.text.fix({f:'fnt/text.ttf', s:16});
		
		// -- Menu Button
		options = D.text.get('menu', 158, 5,  {c:Pal_CPCBoy.COL[31]});
		options_bg = new FlxSprite(options.x + 1, options.y + 1);
		options_bg.makeGraphic(cast options.width - 2, cast options.height - 2, GRID_CURSOR_COLOR);
		add(options_bg);
		add(options);
		
		// --
		text_level = D.text.get("Generic level name", 38, 5, {c:Pal_CPCBoy.COL[29]});
		add(text_level);

		// --
		text = D.text.get("Dummy Text", 46, 79, {c:Pal_CPCBoy.COL[27]});
		text.fieldWidth = 100;
		text.alignment = "center";
		add(text);
				
		// --
		cursor = new FlxSprite();
		cursor.makeGraphic(GRID_BOX_SIZE+2, GRID_BOX_SIZE+2, GRID_CURSOR_COLOR);
		add(cursor);
		
		// --
		grid = new GridNav(GRID_WIDTH, GRID_HEIGHT);
		grid.set_box_size(GRID_BOX_SIZE, GRID_BOX_SIZE, GRID_PAD, GRID_PAD);
		grid.onCursorChange = handle_cursor_change;
		grid.onEscape = (d)->{
			if (d == FlxObject.UP){
				group_focus(0);
				D.snd.playV(SND.tick);
			}
		};
		
		// -- Add BUTTON INDICATORS
		//var t_equip = '[' + D.ctrl.getKeymapName(A) + ']';
		//var t_close = '[' + D.ctrl.getKeymapName(START) + ']';
		//var t1 = D.text.get(t_equip + ' equip', {c:Pal_CPCBoy.COL[31]});
		//var t2 = D.text.get(t_close + ' close', {c:Pal_CPCBoy.COL[31]});
		//D.align.inLine(7, 93, 177, [t1, t2], 'j');
		//add(t1);
		//add(t2);
		
		// -- Add Box Sprites
		for (c in 0...grid.length)
		{
			var i = Item.getItemSprite(1);	// (1) does not matter, it will be replaced later
				i.visible = false;			// default is not visible
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
		
		D.text.fix();
		
		// --
		ITEMS = [];
		_tween = null;
		isOpen = visible = active = false;
		
		// LAST:
		// - Fire to place the cursor. Must be called after setPosition()
		// This is the same code as 'handle_cursor_change(grid.index);' but without the sound call
			var p = grid.get_current_pos();
			cursor.setPosition(x + GRID_X + p.x - 1, y + GRID_Y + p.y - 1);
			_refresh_text();
	}//---------------------------------------------------;
	
	// Group 0: The Options button
	// Group 1: The inventory Items
	function group_focus(g:Int)
	{
		_grpfoc = g;
		if (_grpfoc == 0) {
			options.color = Pal_CPCBoy.COL[28];
			options_bg.visible = true;
			cursor.visible = false;
		}else{
			options.color = Pal_CPCBoy.COL[31];
			options_bg.visible = false;
			cursor.visible = true;
		}
	}//---------------------------------------------------;
	
	
	// --
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);

		if (_grpfoc == 0)
		{
			if (D.ctrl.justPressed(A)){
				Reg.openPauseMenu();
				D.snd.playV(SND.ok);
				return;
			}
			else if (D.ctrl.justPressed(DOWN)){
				group_focus(1);
				D.snd.playV(SND.tick);
			}
		}else
		{
			// group focus 1 :
			if (D.ctrl.justPressed(LEFT))  grid.cursor_move( -1,  0); else
			if (D.ctrl.justPressed(RIGHT)) grid.cursor_move(  1,  0); else
			if (D.ctrl.justPressed(DOWN))  grid.cursor_move(  0,  1); else
			if (D.ctrl.justPressed(UP))    grid.cursor_move(  0, -1);

			
			// NEW: NO Button to select an item. An item is autoselected
			//      when you close the inventory
		}
	
		// Same with both focus groups
		if (D.ctrl.justPressed(_START_A)) {
				
			if (ITEMS[grid.index] != null) onItemSelect(ITEMS[grid.index]);
			close();
		}
		
		// CHANGED: Back key (X) no longer does anything
		//			You have to close the inventory by (START) or (A)
		
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
	
	// @called directly from player when pressed the button
	// - This will callback `onOpen`, which is handled by StatePlay
	public function open()
	{
		if (isOpen || _tween != null) return;
		isOpen = true;
		visible = true;
		
		y = SCREEN_Y_OFF;
		_tween = FlxTween.tween(this, {y:SCREEN_Y}, TWEEN_TIME, { onComplete:(_)->{
			// DEV: I need to destroy and null. So that I can check for `null` later
			_tween.destroy();
			_tween = null;
			active = true;
		}});
		
		D.snd.play(SND.open);
		group_focus(1);
		onOpen();
	}//---------------------------------------------------;
	
	// --
	public function close(silent:Bool = false)
	{
		if (!isOpen || _tween != null) return;
		isOpen = false;
		active = false;
		
		if (silent)
		{
			y = SCREEN_Y_OFF;
			visible = false;
			onClose();
			
		}else{
			
			D.snd.play(SND.close);
			y = SCREEN_Y;
			_tween = FlxTween.tween(this, {y:SCREEN_Y_OFF}, TWEEN_TIME, { onComplete:(_)->{
				// DEV: I need to destroy and null, because it will not immediately be nulled
				_tween.destroy();
				_tween = null;
				visible = false;
				onClose();
			}});
		}
		
	}//---------------------------------------------------;
	
	/**
	   Adds an item with (ID, starting at 1) to the inventory
	   - Sets the item to the HUD
	   @param	it ItemType Enum
	   @return Does the item fit? Can it pick it up?
	**/
	public function addItem(it:ITEM_TYPE):Bool
	{
		var i = get_available_index();
		
		if (i ==-1) {
			return false;
		}
		
		ITEMS[i] = it;
		
		var item = box_items[i];
			item.setItemID(it.getIndex());
			item.visible = true;
		
		// The new item was added on the cursor, so change the text
		if (grid.index == i)
		{
			_refresh_text();
		}
		
		return true;
	}//---------------------------------------------------;
	// --
	public function removeItemWithID(it:ITEM_TYPE):Bool
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
		var AR2:Array<ITEM_TYPE> = [];
		for (i in ITEMS) {
			if (i != null) AR2.push(i);
		}
		ITEMS = AR2;
		for (c in 0...grid.length)
		{
			var item = box_items[c];
			if (ITEMS[c] != null){
				item.visible = true;
				item.setItemID(ITEMS[c].getIndex());
			}else{
				item.visible = false;
			}
		}
		_refresh_text();	// because the cursor could now point to another item
	}//---------------------------------------------------;
	
	
	// Quickly get current item, -1 for no item
	function get_current_item():ITEM_TYPE
	{
		if (ITEMS[grid.index] == null) return null;
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
		D.snd.playV(SND.tick);
	}//---------------------------------------------------;
	
	function _refresh_text()
	{
		// The item ID the cursor is pointing to
		var i = get_current_item();
		if (i != null){
			text.text = Item.ITEM_DATA.get(i).name;
		}else{
			text.text = "";
		}
	}//---------------------------------------------------;
	
	
	public function set_level_name(name:String = null)
	{
		if (name == null) text_level.text = ""; else text_level.text = name;
	}//---------------------------------------------------;
	
	
	
	public function SAVE(?str:String):String
	{
		if (str == null) {
			var data = "";
			for (i in 0...ITEMS.length)
			data += ITEMS[i] + ',';
			return data.substr(0, -1);	// trim the last
		}else
		{
			for (i in str.split(',')) {
				if (i == 'null' || i.length==0) continue;
				addItem(ITEM_TYPE.createByName(i));
			}
		}	
		return null;
	}//---------------------------------------------------;
	
	
}// --