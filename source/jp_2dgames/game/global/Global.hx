package jp_2dgames.game.global;

import jp_2dgames.game.dat.LevelDB;

/**
 * グローバル変数
 **/
class Global {

  public static inline var MAX_LEVEL:Int = 4;
  public static inline var MAX_LIFE:Int = 100;
  public static inline var START_STAGE:Int = 0;

  static var _level:Int = 1; // レベル
  static var _stage:Int = 0; // 現在のステージ
  static var _score:Int = 0; // スコア

  public static function initGame():Void {
    // tODO: 未実装
  }

  public static function startLevel(lv:Int):Void {
    _level = lv;
    _stage = START_STAGE;
    _score = 0;
  }

  public static function setLevel(lv:Int, stage:Int, score:Int):Void {
    _level = lv;
    _stage = stage;
    _score = score;
  }

  public static function nextStage():Bool {
    _stage++;
    return _stage < maxStage;
  }

  public static var level(get, never):Int;
  public static var stage(get, never):Int;
  public static var maxStage(get, never):Int;
  public static var score(get, never):Int;
  static function get_level() { return _level; }
  static function get_stage() { return _stage; }
  static function get_maxStage() { return LevelDB.getEnemyLength(level); }
  static function get_score() { return _score; }
}
