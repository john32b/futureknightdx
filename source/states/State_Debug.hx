 
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
	override public function create():Void 
	{
		super.create();
		bgColor = 0xFF112211;
		
		var tx1 = D.text.get('AMSTRAD FONT', 32, 32, {f:'im/amstrad.ttf', s:8});
		add(tx1);
	}//---------------------------------------------------;	
	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
	}//---------------------------------------------------;
	
}//-- end --//