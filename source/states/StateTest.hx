package states;
import djFlixel.gfx.BoxFader;
import djFlixel.gfx.FilterFader;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;


class StateTest extends FlxState
{
	
	var upd:Void->Void;

	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		if (upd != null) upd();
	}//---------------------------------------------------;

	override public function create() 
	{
		super.create();
		sub_testPixelFader();
		
		FlxG.watch.add(this, "length");
	}//---------------------------------------------------
	
	function sub_testPixelFader()
	{
		add(new FlxSprite("im/game_art.png"));
		
		var st = new FilterFader(false,()->{
			trace("Filter complete");
		});

	}//---------------------------------------------------;
	
}// --