 
package states;

import djA.DataT;
import djA.types.SimpleRect;

import djFlixel.D;
import djFlixel.core.Dcontrols;
import djFlixel.core.Dtext.DTextStyle;
import djFlixel.gfx.StarfieldSimple;
import djFlixel.gfx.pal.Pal_CPCBoy;
import djFlixel.other.FlxSequencer;
import djFlixel.ui.FlxMenu;
import djFlixel.ui.FlxSlides;
import djFlixel.ui.VList;

import flixel.util.FlxTimer;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;

import openfl.display.BitmapData;
import openfl.Assets;

class State_Debug extends FlxState
{	
	// -
	var tim:Float = 0;
	override public function create():Void 
	{
		super.create();
		bgColor = 0xFF112211;
	}//---------------------------------------------------;	
	
	override public function update(elapsed:Float):Void 
	{
		tim += elapsed;
		super.update(elapsed);
		trace(tim, elapsed);
	}//---------------------------------------------------;
	
}//-- end --//