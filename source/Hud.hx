/**
  FUTURE KNIGHT BOTTOM HUD
  =======================
  
  - Display health, lives, weapon, items, score
  - ! Important to create this after <Reg.st.map> is available
      Because it is automatically positioned below the main game map camera
  
  - Creates own camera, all members draw to that camera only
  
================================= **/

package;

import djFlixel.D;
import djFlixel.gfx.pal.Pal_CPCBoy;
import gamesprites.Item;

import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.group.FlxGroup;
import flixel.text.FlxText;

import gamesprites.Item.ITEM_TYPE;


// Item HUD information
typedef ItemHudInfo = {
	name:String,
	desc:String,
	icon:Int	// There are 10 unique item icons for the HUD (1-10) values
}

class Hud extends FlxGroup
{
	static inline var TEXT_TIME_GENERAL = 5;	// seconds
	static inline var TEXT_TIME_ITEM 	= 6;	// seconds
	static inline var HUD_SCREEN_X 		= 25; 	// (320-270)/2 (screenwidth-graphicwidth) / 2 
	static inline var TEXT_BLINK_TIME 	= 0.4;
	static inline var LIVES_BLINK_TIME 	= 1;

	
	// -----
	var _health:Int = 0;	// Current displayed health (not actual player health)
	var _score:Int = 0;		// Current score
	var _item:Int = 0; 		// Current item ID
	var _lives:Int = 0;		// Current Lives icons
	
	var text_info:FlxText;
	var text_score:FlxText;
	var fx_static:FlxSprite;
	
	var digits_health:Array<FlxSprite>;	// 3 sprites to print the health text
	
	var el_lives:Array<FlxSprite>;
	var el_bullet:FlxSprite;
	var el_item:FlxSprite;
	
	var _timer_text:Float = -1;	// When this reaches 0 kill the text. -1 to do nothing
	
	// The ITEM GID if an item is equipped
	public var equipped_item(default, null):ITEM_TYPE = null;
	
	//====================================================;
	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		if (_timer_text > 0) {
			if ((_timer_text -= elapsed) < 0) {
				text_info.text = "";
			}
		}
	}//---------------------------------------------------;
		
	public function new() 
	{
		super();
		
		var bg = new FlxSprite(Reg.IM.STATIC.hud_bottom);
		
		// -- Camera. Puts it right below the Game Map
		var C = Reg.st.map.camera;
		camera = new FlxCamera(
			Std.int(HUD_SCREEN_X),			// IN SCREEN PIXELS
			Std.int((C.height) + C.y), 		// IN SCREEN PIXELS
			bg.frameWidth  + 1,									// IN GAME PIXELS
			bg.frameHeight + 1									// IN GAME PIXELS
		);
		
		FlxG.cameras.add(camera, false);	// false means not a default camera. Only this group will draw on this camera
		
		// > after creating the camera begin adding spritess
		add(bg);
			
		// -- Texts
		text_info = D.text.get("", 16, 6, {f:"fnt/text.ttf", s:16, c:Pal_CPCBoy.COL[27]});
			add(text_info);
			
		text_score = D.text.get("", 30, 30, {f:"fnt/score.ttf", s:6, c:Pal_CPCBoy.COL[22]});
			add(text_score);
			
		// -- Bullets, Item
		el_bullet = Reg.IM.getSprite(107, 29, "huditem", 1);
			add(el_bullet);
			
		el_item = Reg.IM.getSprite(145, 29, "huditem", 7);
			add(el_item);
			
			
		// -- Health digital text
		digits_health = [
			Reg.IM.getSprite(204			, 35, "digital", 0),
			Reg.IM.getSprite(204 + 12		, 35, "digital", 1),
			Reg.IM.getSprite(204 + 12 + 12	, 35, "digital", 2)
		];
		
		for (i in digits_health) {
			add(i);
		}
			
		//-- Lives
		el_lives = [];
		for (l in 0...3) {
			var spr = Reg.IM.getSprite(25 + l * 16, 41, "huditem", 3);
			spr.visible = false;
			el_lives[l] = spr;
			add(spr);
		}
		
		//-- Put this at the top of the list
		fx_static = new FlxSprite(103, 25);
		Reg.IM.loadGraphic(fx_static, "static");
		fx_static.animation.add("main", [0, 1, 2, 3, 4, 0, 1, 5, 6, 7, 5, 4, 3, 2], 12	, false);
		fx_static.visible = false;
		add(fx_static);
		fx_static.active = true;
	}//---------------------------------------------------;
	
	override public function add(O:FlxBasic):FlxBasic 
	{
		if (Std.isOfType(O, FlxSprite)){
			var a = cast(O, FlxSprite);
			a.active = false;	// don't waste cycles
		}
		return super.add(O);
	}//---------------------------------------------------;
	
	/**
	   Reflect play state
	**/
	public function reset()
	{
		_health = 100;	// so that it colorizes the health correctly
		set_health(Reg.st.player.health);
		set_lives(Reg.st.player.lives);
		set_bullet(Reg.st.player.bullet_type);
		
		set_text("");
		set_score(0);
		set_item_icon(0);
		
		fx_static.visible = false;
		fx_static.animation.reset();
		
		equipped_item = null;
	}//---------------------------------------------------;
	
	
	public function bullet_pickup(bullet:Int)
	{
		set_bullet(bullet);
		static_run();
	}//---------------------------------------------------;
	
	// Pick up item with real itemID (EntityID, starting from 1
	// Call with NULL to remove the item graphic
	public function item_pickup(itemID:ITEM_TYPE = null)
	{
		equipped_item = itemID;
		
		if (itemID != null)
		{
			var ITD = Item.ITEM_DATA.get(itemID);
			set_text(ITD.desc, true, TEXT_TIME_ITEM);
			set_item_icon(ITD.icon);
			static_run();
		}else{
			set_item_icon(0);
			set_text("");
			static_run();
		}
		
	}//---------------------------------------------------;
	
	
	// Values (0-999)
	public function set_health(val:Float)
	{
		if (val < _health)
		{
			if (val < 100 && _health >= 100) {
				for (t in digits_health) 
					t.color = Pal_CPCBoy.COL[6]; // red color
			}
			// ^ this is to only set color once
		}else
		{
			// health going up
			if (val >= 100)
			{
				for (t in digits_health) t.color = Pal_CPCBoy.COL[27];
			}
		}
		
		_health = Std.int(val);
		
		digits_health[0].animation.frameIndex = Math.floor(_health / 100);
		digits_health[1].animation.frameIndex = Math.floor((_health % 100) / 10);
		digits_health[2].animation.frameIndex = (_health % 100) % 10;
		
	}//---------------------------------------------------;
	
	// Values (0-3)
	public function set_lives(i:Int, blink:Bool = false)
	{
		// Safequard ?
		if (i < 0) i = 0; else if (i > 3) i = 3;

		for (l in 0...3) {
			if (l < i)
				el_lives[l].visible = true;
			else
			{
				if (!blink) {
					el_lives[l].visible = false;
				} else {
					// Flicker the lives that are off, Works OK
					if (l >= i && l < _lives)
					FlxFlicker.flicker(el_lives[l], LIVES_BLINK_TIME, Reg.P.flicker_rate, false);	
				}
			}
		}
		_lives = i;
	}//---------------------------------------------------;
	
	/**
	 * Set text auto blink and auto time
	 */
	public function set_text2(t:String)
	{
		set_text(t, true, TEXT_TIME_GENERAL);
	}//---------------------------------------------------;
	
	// --
	public function set_text(t:String, ?blinkOn:Bool = false, ?timeToLive:Float = -1)
	{
		_timer_text = timeToLive;
		text_info.text = t;
		if (blinkOn) FlxFlicker.flicker(text_info, TEXT_BLINK_TIME, Reg.P.flicker_rate);
	}//---------------------------------------------------;
	
	// Values 1-3
	public function set_bullet(i:Int)
	{
		el_bullet.animation.frameIndex = i;
	}//---------------------------------------------------;
	
	// Actual Frame icon in "hud_items.png" Starting from 1
	// Look it up with aseprite 
	public function set_item_icon(i:Int = 0)
	{
		el_item.visible = (i > 0);
		el_item.animation.frameIndex = i - 1;
	}//---------------------------------------------------;
	
	// The text will be padded to 6 digits
	public function set_score(i:Int)
	{
		_score = i;
		if (_score > 9999999) _score = 9999999;
		text_score.text = StringTools.lpad(Std.string(_score), "0", 6);
	}//---------------------------------------------------;

	
	function static_run(?callback:Void->Void)
	{
		fx_static.visible = true;
		fx_static.animation.play("main", true);
		fx_static.animation.finishCallback = (s)->{
			fx_static.visible = false;
			if (callback != null) callback();
		}
	}//---------------------------------------------------;
	
	
	public function score_add(c:Int)
	{
		set_score(_score + c);
	}//---------------------------------------------------;
	
	
	public function SAVE(?str:String):String
	{
		if (str == null) {
			var data = '$_score,$equipped_item';
			return data;
		}else{
			var o = str.split(',');
			set_score(Std.parseInt(o[0]));
			if (o[1] != 'null') {
				item_pickup(ITEM_TYPE.createByName(o[1]));
				set_text("");
				fx_static.visible = false;
			}
		}	
		return null;
	}//---------------------------------------------------;
		
}// --



