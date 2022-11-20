import flixel.FlxG;
import flixel.util.FlxSave;
//import flixel.input.keyboard.FlxKey;
//import flixel.graphics.FlxGraphic; 
//import Controls; 

class ClientPrefs { 
    //fps thing 
    public static var showFPS:Bool = true;
    //The fps that the game is playing 
    public static var framerate:Int = 120;


   public static function saveSettings(){ 
    FlxG.save.data.showFPS = showFPS;
    FlxG.save.data.framerate = framerate;
   } 

   public static function loadprefs(){ 
    if(FlxG.save.data.framerate != null) {
        framerate = FlxG.save.data.framerate;
        if(framerate > FlxG.drawFramerate) {
            FlxG.updateFramerate = framerate;
            FlxG.drawFramerate = framerate;
        } else {
            FlxG.drawFramerate = framerate;
            FlxG.updateFramerate = framerate;
        }
    }
   }

}