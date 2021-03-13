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
	
	// This is the KEYMAP that will be built when all keys are captures.
	public var KEYMAP(default, null):Array<FlxKey>;
	
	// e.g. ['up', 'right', 'down', 'left', 'ok / jump']
	var NAMES:Array<String>;
	
	var keyname:String; // Current key name
	
	/**
	   @param	kn The names of the keys to get, In sequence | e.g. ['up', 'right', 'down', 'left', 'ok / jump']
	**/
	public function new(kn:Array<String>)
	{
		super();
		KEYMAP = [];
		NAMES = kn;
	}//---------------------------------------------------;
	
	public function start()
	{
		FlxG.keys.reset();
		FlxG.state.add(this);
		waitNextKey();
	}//---------------------------------------------------;
	
	// - Put (c) at a valid action KEY
	// - it skips nulls and ''
	// - if end of string, send complete event
	function waitNextKey()
	{
		if (NAMES.length == 0)
		{
			FlxG.state.remove(this);
			onEvent('complete', '');
			return;
		}
		
		keyname = NAMES.shift();
		if (keyname == null || keyname.length == 0)
		{
			KEYMAP.push( -1);
			trace("HOLE KEY >>");
			waitNextKey();
			
		}else{
			onEvent('wait', keyname);
		}
		
	}//---------------------------------------------------;
	
	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		var k = FlxG.keys.firstJustPressed();
		if ( k > 0) {
			FlxG.keys.reset();
			var key:FlxKey = cast k;
			// -- Check if is not already defined
			if (KEYMAP.indexOf(key) >= 0)  {
				onEvent('error', keyname);
				return;
			}
			KEYMAP.push(key);
			onEvent('ok', keyname);
			waitNextKey(); // > wait next or complete
		}
	}//---------------------------------------------------;
	
}// --