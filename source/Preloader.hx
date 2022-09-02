package ;

import flixel.system.FlxBasePreloader;
import openfl.Lib;
import openfl.display.Bitmap;
import openfl.display.Sprite;
import openfl.display.BitmapData;
 
@:keep @:bitmap("assets/images/monitor_overlay1.png") 
class BorderImage extends BitmapData { }
 
class Preloader extends FlxBasePreloader
{
	var border:Bitmap;
	
	// - Will auto place the bar at the middle of the screen
	var bar:Bitmap;
	var barMaxWidth = 500;
	var barHeight = 6;
	var barColor = 0x3b3b3b;
	
    public function new(min:Float=0, ?allowed:Array<String>)  
    {
        super(min, allowed);
    }
	
    override function create():Void 
	{
		Lib.current.stage.color = 0x060606;
		
		// StageSize should be whatever project.xml says for the window? 640,480
		_width = Std.int(Lib.current.stage.stageWidth);
		_height = Std.int(Lib.current.stage.stageHeight);
		
		bar = new Bitmap(new BitmapData(1, barHeight, false, barColor));
		
		bar.x = (_width - barMaxWidth) / 2;
		bar.y = (_height / 2) - barHeight / 2;
		addChild(bar);
		
		border = createBitmap(BorderImage, function(bit:Bitmap) {
			border.width = _width;
			border.height = _height;
		});
		
		addChild(border);
		// --
        super.create();
    }   
	
	override function update(Percent:Float):Void 
	{
		bar.scaleX = Percent * (barMaxWidth);
	}
	
	override function destroy():Void
	{
		removeChild(border);
		removeChild(bar);
		border = bar = null; // FlxPreloader does this, but shouldn't GC deal with these?
		super.destroy();
	}
}