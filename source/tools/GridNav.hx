/**
 * 
 General Purpose GRID NAVIGATON
 ==============================
 - Api/Library Agnostic
 - Handles box placement and cursor navigation
 - Must be implemented by something else
 

 USAGE:
 ------
	var grid = new GridNav(3,2);	
		grid.setBoxSize(24,24,2,2);
		
		grid.onCursorChange = (ind)->{ .... }
		
		for (c in 0...grid.length) { // Place some items on a grid
			var item = new Item();
			var pos = grid.get_box_pos(c); // < will return pixel cordinates
				item.x = pos.x;
				item.y = pos.y;
		}
		
		grid.length 	==	length number of boxes
		grid.index == current selected index
		
**/


package tools;
import djA.types.SimpleCoords;


class GridNav 
{
	// Grid Box size and paddings
	var box = {
		w:0,
		h:0,
		padx:0,
		pady:0
	}
	
	// Currently selected INDEX. You can set an index with set_index()
	public var index(default, null):Int;
	
	// Currently selected BOX in (x,y) coords, starting at (0,0)
	var cursor_pos:SimpleCoords;
	
	// Total boxes in the grid
	public var length(default, null):Int;
	
	// Width/Height in box count
	public var size(default, null):SimpleCoords;
	
	// Called whenever the cursor changes index (newIndex)->{}
	// WARNING. When the grid is created, it does not fire this.
	public var onCursorChange:Int->Void;
	
	public var FLAG_LOOP:Bool = false;
	
	public function new(X_COUNT:Int, Y_COUNT:Int) 
	{
		cursor_pos = new SimpleCoords(0, 0);
		size = new SimpleCoords(X_COUNT, Y_COUNT);
		length = (X_COUNT * Y_COUNT);
		index = 0;
	}//---------------------------------------------------;
	
	public function set_box_size(w:Int, h:Int, px:Int = 0, py:Int = 0)
	{
		box = {
			w:w, h:h, padx:px, pady:py
		};
	}//---------------------------------------------------;
	
	
	/**
	   Get a target index box position
	**/
	public function get_box_pos(i:Int):{x:Int, y:Int}
	{
		return {
			x: (i % size.x) * (box.h + box.pady),
			y: (Math.floor(i / size.x)) * (box.w + box.padx),
		};
	}//---------------------------------------------------;
	
	
	/**
	   Get the currently selected cursor PIXEL COORDINATES
	**/
	public function get_current_pos():{x:Int,y:Int}
	{
		return {
			x: cursor_pos.x * (box.w + box.padx),
			y: cursor_pos.y * (box.h + box.pady)
		};
	}//---------------------------------------------------;
	
	
	public function cursor_move(x:Int, y:Int):Bool
	{
		return set_cursor_pos(cursor_pos.x + x, cursor_pos.y + y);
	}//---------------------------------------------------;
	
	
	// Sets both <cursor_pos> and <index>
	public function set_cursor_pos(x:Int, y:Int):Bool
	{
		if (cursor_pos.x == x && cursor_pos.y == y) return false;
		if (x<0 || x>size.x-1) return false;
		if (y<0 || y>size.y-1) return false;
		cursor_pos.set(x, y);
		index = y * size.x + x;
		if (onCursorChange != null) onCursorChange(index);
		return true;
	}//---------------------------------------------------;
	
	// Sets both <cursor_pos> and <index>
	public function set_index(i:Int):Bool
	{
		if (index == i) return false;
		if (i<0 || i>length-1) return false;
		index = i;
		cursor_pos.x = i % size.x;
		cursor_pos.y = Math.floor(i / size.x);
		if (onCursorChange != null) onCursorChange(index);
		return true;
	}//---------------------------------------------------;
	
}// --
