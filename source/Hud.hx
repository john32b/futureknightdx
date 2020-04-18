/**
  FUTURE KNIGHT BOTTOM HUD
  =======================
  
  - Display health, lives, weapon, items, score
  - ! Important to create this after <Reg.st.map> is available
      Because it is automatically positioned below the main game map camera
 
================================= **/

package;

import djFlixel.D;
import djFlixel.gfx.pal.Pal_CPCBoy;

import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.group.FlxGroup;
import flixel.text.FlxText;

class Hud extends FlxGroup
{

	static inline var HUD_SCREEN_X:Int = 25; // (320-270)/2
	static inline var FONT_HEALTH = "fnt/lc_light.otf";
	
	// -----
	var _health:Int = 0;	// Current displayed health (not actual player health)
	var _score:Int = 0;		// Current score
	var _item:Int = 0; 		// Current item ID
	var _lives:Int = 0;		// Current Lives icons
	
	var text_info:FlxText;
	var text_health:FlxText;
	var text_score:FlxText;
	var fx_static:FlxSprite;
	
	var el_lives:Array<FlxSprite>;
	var el_bullet:FlxSprite;
	var el_item:FlxSprite;
	
	//====================================================;
			override public function update(elapsed:Float):Void 
		{
			super.update(elapsed);
			if (FlxG.keys.justPressed.ONE) static_run();
			if (FlxG.keys.justPressed.TWO) set_lives(1,true);
			if (FlxG.keys.justPressed.THREE) set_lives(2,true);
			if (FlxG.keys.justPressed.FOUR) set_lives(3,true);
			if (FlxG.keys.justPressed.ZERO) set_lives(0,true);
		}
		
	public function new() 
	{
		super();
		
		// --
		var bg = new FlxSprite(Reg.IM.STATIC.hud_bottom);

		// -- Camera. Puts it right below the Game Map
		var C = Reg.st.map.camera;
		camera = new FlxCamera(
			Std.int(HUD_SCREEN_X * FlxG.initialZoom),			// IN SCREEN PIXELS
			Std.int((C.height * FlxG.initialZoom) + C.y), 		// IN SCREEN PIXELS
			bg.frameWidth  + 1,									// IN GAME PIXELS
			bg.frameHeight + 1									// IN GAME PIXELS
		);
		FlxG.cameras.add(camera);
		
		// > after creating the camera
		add(bg);
			
		// --
		text_info = D.text.get("", 16, 4, {c:Pal_CPCBoy.COL[27]});
		text_health = D.text.get("", 202, 30, {f:FONT_HEALTH, s:26, c:Pal_CPCBoy.COL[6]} );
		text_health.antialiasing = false;
		text_health.textField.antiAliasType = "advanced";
		text_health.textField.sharpness = 400;
		text_score = D.text.get("", 30, 30, {c:Pal_CPCBoy.COL[30]});
		add(text_info);
		add(text_health);
		add(text_score);
		
		
		//-- Lives
		el_lives = [];
		for (l in 0...3) {
			var spr = new FlxSprite(25 + l * 16, 39);
			Reg.IM.loadGraphic(spr, "huditem");
			spr.animation.frameIndex = 3;
			el_lives[l] = spr;
			add(spr);
			spr.visible = false;
		}
		
		//-- Put this at the top of the list
		fx_static = new FlxSprite(103, 23);
		Reg.IM.loadGraphic(fx_static, "static");
		fx_static.animation.add("main", [0, 1, 2, 3, 4, 0, 1, 5, 6, 7, 5, 4, 3, 2], 10, false);
		fx_static.visible = false;
		add(fx_static);
	}//---------------------------------------------------;
	
	
	/**
	   Reflect play state
	**/
	public function reset()
	{
		set_health(Reg.st.player.health);
		set_lives(Reg.st.player.lives);
		text_info.text = "";
		set_score(0);
		fx_static.visible = false;
	}//---------------------------------------------------;
	
	
	public function item_pickup(itemID:Int)
	{
		var ITD = Reg.ITEM_DATA.get(cast itemID);
		static_run();
		set_info_text(ITD.desc);
		/// ICON change to itd.icon
	}//---------------------------------------------------;
	
	function static_run()
	{
		fx_static.visible = true;
		fx_static.animation.play("main");
		fx_static.animation.finishCallback = (s)->{
			fx_static.visible = false;
		}
	}//---------------------------------------------------;
	
	
	
	
	/*
	  	"hud" : {
		"ammo" : { "x" : 120, "y" : 30 },
		"bullet" : { "x" : 98, "y" : 24 },
	},*/
	
	override public function add(O:FlxBasic):FlxBasic 
	{
		O.cameras = [camera];
		if (Std.is(O, FlxSprite)){
			var a = cast(O, FlxSprite);
			a.moves = false;
			a.solid = false;
		}
		return super.add(O);
	}//---------------------------------------------------;
	
	
	/** Set and Draw Health, if no parameter
	    Values 0-999 
	 */
	public function set_health(val:Float)
	{
		_health = Std.int(val);
		text_health.text = StringTools.lpad(Std.string(_health), "0", 3);
	}//---------------------------------------------------;
	
	/** Values 0-3 */
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
					FlxFlicker.flicker(el_lives[l], 1, 0.1, false);
				}
			}
		}
		_lives = i;
	}//---------------------------------------------------;
	
	
	public function set_info_text(t:String)
	{
		text_info.text = t;
		FlxFlicker.flicker(text_info, 1, 0.25);
	}//---------------------------------------------------;
	
	/** Values 1-3 */
	public function set_weapon(i:Int)
	{
	}//---------------------------------------------------;
	
	public function set_item(i:Int)
	{
	}//---------------------------------------------------;
	
	/**/
	public function set_score(i:Int)
	{
		_score = i;
		text_score.text = StringTools.lpad(Std.string(_score), "0", 6);
	}//---------------------------------------------------;
	
}// --