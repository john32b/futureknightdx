/********************************************************************
 * Simple Minimap, for the spaceship section of the game
 * 
 * - open():Bool
 * 		Will auto get the current level and colorize the appropriate map section
 * 		Returns true/false, if there is a map for the current area
 * 		- This is because not all game levels support a map
 * 		- Handle this from caller
 * 	 
 * - close()
 * 		Closes the minimap and resumes gameplay
 * 
 *******************************************************************/


package gamesprites;

import djFlixel.core.Dcontrols.DButton;
import djFlixel.gfx.pal.Pal_CPCBoy;
import flash.display.BitmapData;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.system.FlxAssets;
import djFlixel.D;

class MiniMap extends FlxSprite 
{
	var bg:BitmapData;	// The unmodified bitmapdata
	
	// Map (level name) to (pixel coords) for where to highlight current room on the map
	var rooms = [
		"level_01" => "190,55",
		"level_02" => "166,55",
		"level_03" => "130,46",
		"level_04" => "130,30",
		"level_05" => "90,38",
		"level_06" => "70,64",
		"level_07" => "56,82",
		"level_08" => "158,80"
	];
	
	static var H_COLOR = Pal_CPCBoy.COL[23];	// Light Blue
	
	// What is the current hightlighted room. Null for none. Holds the level name "level_03"
	var currentCoords:String = null;
	
	var time:Float = 0; // Open/Close Time Buffer
	
	public function new() 
	{
		super();
		// --
		bg = FlxAssets.getBitmapData(Reg.IM.STATIC.minimap);
		
		makeGraphic(bg.width, bg.height, 0xFF000000, true); // Make sure it is unique
		scrollFactor.set(0, 0);
		
		// --
		resetImage(); // Draw a clean map image
		
		kill();	// Start off by being dead, no update no render.
		
	}//---------------------------------------------------;
	
	
	// -- Colorizes the MAP (x,y) coordinates
	//    "x,y" in string form, like they are on rooms map
	public function highlightCoords(coords:String)
	{
		if (currentCoords == coords) {
			trace("Room already colored");
			return;
		}
		var C = coords.split(',').map((s)->Std.parseInt(s));
		trace("Drawing again for Coords", coords);
		
		resetImage();
		pixels.floodFill(C[0], C[1], H_COLOR);
		dirty = true;
		currentCoords = coords;
	}//---------------------------------------------------;
	

	function resetImage()
	{
		pixels.lock();
		D.bmu.copyOn(bg, pixels);
		pixels.unlock();
	}//---------------------------------------------------;
	
	// Open and highlight current room
	public function open():Bool
	{
		if (alive) return true;	// This should not happen, but checking
		
		var coords:String = rooms.get(Reg.st.map.MAP_FILE);
		if (coords == null)
		{
			trace("Minimap not available for this room");
			return false;
		}
		
		highlightCoords(coords);	// Will colorize current room
		
		time = 0.2;	// Some arbitrary time to prevent the menu from closing. Will count down from this.
		revive();
		
		Reg.st.pause();
		D.snd.play("cursor_ok");	// A simple sound, this works OK
		
		return true;
	}//---------------------------------------------------;
	
	
	public function close()
	{
		D.snd.play("cursor_back");	// A simple sound, this works OK
		Reg.st.resume();
		kill();
	}//---------------------------------------------------;
	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
			
		// DEV: I need to add a time buffer, because else if I press the map key, the menu will open and
		//		it would register the same key at justPressed and immediately close
		
		if (time > 0){
			time-= FlxG.elapsed;
			return;
		}
	
		if (D.ctrl.justPressed(_ANY)) 
		{
			close();
		}
	}//---------------------------------------------------;
	
}// --