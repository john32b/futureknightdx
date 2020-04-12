/**
 Game related logic and vars
 ========================
 
 - Quick access pointers to some game components
 
*/



package;

import gamesprites.Player;


class Game 
{
	public static function init()
	{
		trace("Game init()..");
	}//---------------------------------------------------;
	
	// Pointer
	public static var map:MapFK;
	
	// Pointer
	public static var player:Player;
	
	// Pointer
	public static var roomspr:RoomSprites;
	
	
	
}// --