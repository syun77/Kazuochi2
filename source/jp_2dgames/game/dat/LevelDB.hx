package jp_2dgames.game.dat;

import jp_2dgames.game.dat.MyDB;

/**
 * レベルDB
 **/
class LevelDB {
  public static function get(id:Int):Levels {
    for(level in MyDB.levels.all) {
      if(id == level.level) {
        return level;
      }
    }

    // 指定のIDが見つからなかった
    throw 'Not found level id = ${id}';
  }

  public static function getStartBlock(level:Int):Int {
    return get(level).blocks[0].number;
  }

  public static function getEndBlock(level:Int):Int {
    return get(level).blocks[1].number;
  }

  public static function getTmx(level:Int):String {
    var tmx = get(level).tmx;
    return StringTools.replace(tmx, "../../../../", "");
  }

  public static function getEnemyKind(level:Int, idx:Int):EnemiesKind {
    return get(level).enemies[idx].enemy.id;
  }

  public static function getEnemyLength(level:Int):Int {
    return get(level).enemies.length;
  }

}
