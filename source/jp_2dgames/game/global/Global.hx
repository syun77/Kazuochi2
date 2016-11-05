package jp_2dgames.game.global;

import flixel.math.FlxMath;

/**
 * グローバル変数
 **/
class Global {

  public static inline var MAX_LEVEL:Int = 4;
  public static inline var MAX_LIFE:Int = 100;
  public static inline var START_LEVEL:Int = 1;

  static var _level:Int = 1;
  static var _life:Int = MAX_LIFE;

  public static function initGame():Void {
    _level = START_LEVEL;
  }

  public static function initLevel():Void {
    _life = MAX_LIFE;
  }

  public static function addLevel():Bool {
    _level++;
    return _level > MAX_LEVEL;
  }

  public static function addLife(v:Int):Void {
    _life = FlxMath.maxAdd(_life, v, MAX_LIFE);
  }

  public static var level(get, never):Int;
  public static var life(get, never):Int;
  static function get_level() {
    return _level;
  }
  static function get_life() {
    return _life;
  }
}
