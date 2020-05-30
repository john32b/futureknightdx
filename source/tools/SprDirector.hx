/** 

  = Quickly add /images/sprites/text to the scene In one Go
  and set attribute like position, alpha, tween.
  
  = Works best for UI elements, the benefit is that you
  can declare many sprites without having to declare them as variables
 
  = EXAMPLE =
  
  var sp = new SprDirector();
  add(sp);
  sp.on("id1", new FlxSprite(~)).p(20,20).a(0.3).tween({alpha:1,x:30},1);
    
================================================================== **/
  
 
package tools;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxTween.TweenOptions;


@:dce
class SprDirector extends FlxGroup
{
	var map:Map<String,FlxSprite>;
	
	var _last:FlxSprite;
	
	public function new() 
	{
		super();
		map = [];
		_last = null;
	}//---------------------------------------------------;
	
	/**
	   Apply direction on this sprite
	   @param as Asset Name or ID if you put your own sprite. Or existing ID
	   @param s Your sprite, make sure to set `as` as an ID so you can look it up later with that id
	   @return For chaining
	**/
	public function on(as:String, ?s:FlxSprite):SprDirector
	{
		if (map.exists(as))
		{
			_last = map.get(as);
			return this;
		}
		
		if (s == null)
		{
			_last = new FlxSprite(0, 0, as);
		}else
		{
			_last = s;
		}
		
		map.set(as, _last);
		add(_last);
		return this;
	}//---------------------------------------------------;
	
	/**
	   Set multiple fields at once
	   x,y : Position 
	   rx,ry : Relative x/y
	   a: Alpha Float
	   v: Visible in INT 0-1
	**/
	public function s(o:Dynamic)
	{
		if (o.x != null) _last.x = o.x;
		if (o.y != null) _last.y = o.y;
		if (o.rx != null) _last.x += o.rx;
		if (o.ry != null) _last.y += o.ry;
		if (o.a != null) _last.alpha = o.a;
		if (o.v != null) _last.visible = (o.v == 1);
	}//---------------------------------------------------;
	
	
	/** Position */
	public function p(x:Int, y:Int):SprDirector
	{
		_last.x = x;
		_last.y = y;
		return this;
	}
	
	/** Relative position */
	public function rp(x:Int, y:Int):SprDirector
	{
		_last.x += x;
		_last.y += y;
		return this;
	}
	
	/** Alpha */
	public function a(f:Float):SprDirector
	{
		_last.alpha = f;
		return this;
	}
	
	/** Visible use (1 or 0) it is shorter than true/false */
	public function v(b:Float):SprDirector
	{
		_last.visible = (b==1);
		return this;
	}
	
	/** Tween */
	public function tween(Values:Dynamic, Duration:Float = 1, ?Options:TweenOptions):SprDirector
	{
		FlxTween.tween(_last, Values, Duration, Options);
		return this;
	}
	
	override public function destroy():Void 
	{
		for (k => v in map) v.destroy();
		map = null;
		super.destroy();
	}//---------------------------------------------------;
	
}// --