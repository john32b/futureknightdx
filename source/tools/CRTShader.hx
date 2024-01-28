/**
   Simple CRT Shader
   -----------------
  
   example:
   		var myshader = new CRTShader();
		FlxG.game.setFilters([new ShaderFilter(SHADER)]);
		
		myshader.STRENGTH = [0.75, 0.3];
		myshader.CHROMAB = 0.75;
		myshader.SCANLINES = false;
**/
		


package tools;

import flixel.FlxG;
import flixel.system.FlxAssets.FlxShader;
import openfl.Lib;


class CRTShader extends FlxShader
{
	
@:glFragmentSource(' 

#pragma header
#define PI 3.14159265358

uniform vec2 GAME_SIZE;	// Game size in pixels. If a game is 320x240, zoomed 2x, then 640x480 is ok. Used in scanlines
uniform vec2 WIN_SIZE;	// The actual window wize. Used in scanlines

uniform vec2 BLUR;  // Blur Multiplier
uniform float CHROM;// Chromatic Aberration Strength
uniform bool SCAN;	// Scanlines on/off


// https://github.com/Jam3/glsl-fast-gaussian-blur/blob/master/9.glsl
vec4 blur9(vec2 uv, vec2 resolution) 
{
	vec4 color = vec4(0.0);
	vec2 off1 = vec2(1.3846153846) * BLUR;
	vec2 off2 = vec2(3.2307692308) * BLUR;
	color += flixel_texture2D(bitmap, uv) * 0.2270270270;
	color += flixel_texture2D(bitmap, uv + (off1 / resolution)) * 0.3162162162;
	color += flixel_texture2D(bitmap, uv - (off1 / resolution)) * 0.3162162162;
	color += flixel_texture2D(bitmap, uv + (off2 / resolution)) * 0.0702702703;
	color += flixel_texture2D(bitmap, uv - (off2 / resolution)) * 0.0702702703;
	return color;
}

void main() 
{
	vec2 UV = openfl_TextureCoordv;

	// Chromatic Abberation
	// : float onePixelFraction = 1.0 / GAME_SIZE.x; ( 1/640 == 0.0015.. )
	// : I am going to use 0.002 for one pixel
	vec4 col1;
	col1.r = flixel_texture2D(bitmap, UV + vec2(  0.002,  0.002) * CHROM).r;
    col1.g = flixel_texture2D(bitmap, UV + vec2(  0.000,  0.001) * CHROM).g;
    col1.b = flixel_texture2D(bitmap, UV + vec2( -0.002, -0.002) * CHROM).b;
	
	// Blur
	vec4 col2 = blur9(UV, openfl_TextureSize);
	
	// Mix Chroma + Blur
	vec4 colF = mix(col1, col2, 0.5);
	
	// Scanlines
	if (SCAN) {
		float yratio = (gl_FragCoord.y / WIN_SIZE.y);
		colF = colF * mix(0.85, 1.05, sin(PI * GAME_SIZE.y * yratio));
	}
	
	gl_FragColor = colF;
}

')

	// Blur strength
	public var STRENGTH(default, set):Array<Float>;
	
	// Enable/Disable scanlines
	public var SCANLINES(default, set):Bool;
	
	// Chromatic abberation Strength
	public var CHROMAB(default, set):Float;
	
	public function setWinSize(x:Int, y:Int)
	{
		#if flash return; #end
		data.WIN_SIZE.value = [cast(x, Float), cast(y, Float)];
	}//---------------------------------------------------;
	
	function set_STRENGTH(val:Array<Float>):Array<Float>
	{
		STRENGTH = val;
		data.BLUR.value = [val[0], val[1]];
		return STRENGTH;
	}//---------------------------------------------------;
	
	function set_SCANLINES(val:Bool):Bool
	{
		SCANLINES = val;
		data.SCAN.value = [val];
		return SCANLINES;
	}//---------------------------------------------------;
	
	function set_CHROMAB(val:Float):Float
	{
		CHROMAB = val;
		data.CHROM.value = [val];
		return CHROMAB;
	}//---------------------------------------------------;
	
	
    public function new(GAME_WIDTH:Float = 0, GAME_HEIGHT:Float = 0)
    {
        super();
		#if flash return; #end
		if (GAME_WIDTH == 0) GAME_WIDTH = cast FlxG.width * 2;
		if (GAME_HEIGHT == 0) GAME_HEIGHT = cast FlxG.height * 2;
		
		data.GAME_SIZE.value = [GAME_WIDTH, GAME_HEIGHT];
		
		setWinSize(Lib.current.stage.stageWidth, Lib.current.stage.stageHeight);
		
		STRENGTH = [1.0, 1.0];
		SCANLINES = true;
		CHROMAB = 1;
		
		// -- Make sure to call setWinSize() everytime the window is resized
    }//---------------------------------------------------;	
	
}