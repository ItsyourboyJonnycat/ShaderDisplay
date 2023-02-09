package;

import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import openfl.Assets;
import openfl.Lib;
import openfl.display.FPS;
import openfl.display.Sprite;
import openfl.events.Event;
#if android //only android will use those
import sys.FileSystem;
import lime.app.Application;
import lime.system.System;
import android.*;
#end
import openfl.display.StageScaleMode;
import ClientPrefs; 
import openfl.Lib; 
class Main extends Sprite
{
	var gameWidth:Int = 1280; // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var gameHeight:Int = 720; // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var initialState:Class<FlxState> = TestState; // The FlxState the game starts with.
	var zoom:Float = -1; // If -1, zoom is automatically calculated to fit the window dimensions.
	var framerate:Int = 240; // How many frames per second the game should run at.
	var skipSplash:Bool = true; // Whether to skip the flixel splash screen that appears in release mode.
	var startFullscreen:Bool = false; // Whether to start the game in fullscreen on desktop targets
	public static var fpsVar:FPS;

	#if android//the things android uses  
    private static var androidDir:String = null;
    private static var storagePath:String = AndroidTools.getExternalStorageDirectory();  
    #end

	// You can pretty much ignore everything from here on - your code should go in your states.
   
	public static function main():Void
	{
		Lib.current.addChild(new Main()); //DO NOT DELETE THIS CODE!!!!
	}

	public function new()
	{
		super();

		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;

		if (zoom == -1)
		{
			var ratioX:Float = stageWidth / gameWidth;
			var ratioY:Float = stageHeight / gameHeight;
			zoom = Math.min(ratioX, ratioY);
			gameWidth = Math.ceil(stageWidth / zoom);
			gameHeight = Math.ceil(stageHeight / zoom);
		}

		addChild(new FlxGame(gameWidth, gameHeight, initialState, #if (flixel < "5.0.0")zoom,#end  framerate, framerate, skipSplash, startFullscreen));

#if !mobile
 fpsVar = new FPS(10, 3, 0xFFFFFF);
 addChild(fpsVar);
 Lib.current.stage.align = "tl";
 Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;
 if(fpsVar != null) {
 	fpsVar.visible = ClientPrefs.showFPS;
 }
 #end
	}

        static public function getDataPath():String
        {
        	#if android
                if (androidDir != null && androidDir.length > 0) 
                {
                        return androidDir;
                } 
                else 
                { 
                        androidDir = storagePath + "/" + Application.current.meta.get("packageName") + "/files/";
                }
                return androidDir;
                #else
                return "";
	        #end
        }
}
