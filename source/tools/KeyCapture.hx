/**
 
 Helper object, capture keyboard keys for a series of ACTIONS
 
 - Automatically added to the state
 - Works with events
 - Autochecks to see if a key is already defined and will request again
  
 - Example:
  --------
  		var k = new KeyCapture(['up', 'right', 'down', 'left', 'jump', '', 'shoot', 'use item']);
		k.onEvent = (a, b)->{
			if (a == "complete") {
				trace("Keys", k.KEYMAP);
			}
		};
		k.start();
 
 ===================================================================================== */

package tools;
import flixel.FlxBasic;
import flixel.FlxG;
import flixel.input.keyboard.FlxKey;

class KeyCapture extends FlxBasic
{
	
	// wait, actionName
	// ok , actionName
	// error, actionName
	// complete -> read KEYMAP manually
	public var onEvent:String->String->Void;
	
	var c = 0; // current key being processed
	
	// This is the KEYMAP that will be built when all keys are captures
	public var KEYMAP(default, null):Array<FlxKey>;
	var NAMES:Array<String>;
	
	public function new(kn:Array<String>)
	{
		super();
		KEYMAP = [];
		NAMES = kn;
	}//---------------------------------------------------;
	
	
	public function start()
	{
		c = 0;
		FlxG.keys.reset();
		FlxG.state.add(this);
		waitNextKey();
	}//---------------------------------------------------;
	
	// - Put (c) at a valid action KEY
	// - it skips nulls and ''
	// - if end of string, send complete event
	function waitNextKey()
	{
		while (NAMES[c] == null || NAMES[c].length == 0)
		{
			c++;
			if (c >= NAMES.length) {
				FlxG.state.remove(this);
				onEvent('complete', '');
				return;
			}
		}
		
		onEvent('wait', NAMES[c]);
	}//---------------------------------------------------;
	
	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		var k = FlxG.keys.firstJustPressed();
		if ( k > 0) {
			
			FlxG.keys.reset();
			var key:FlxKey = cast k;
			
			// -- Check if key valid
			
			if (KEYMAP.indexOf(key) >= 0)
			{
				onEvent('error', NAMES[KEYMAP.indexOf(key)]);
				return;
			}
			
			KEYMAP[c] = key;
			onEvent('ok', NAMES[c]);
			
			c++;
			waitNextKey(); // > wait next or complete
		}
	}//---------------------------------------------------;
	
}// --