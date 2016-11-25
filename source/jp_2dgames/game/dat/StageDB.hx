package jp_2dgames.game.dat;

import jp_2dgames.game.dat.MyDB;

/**
 * ステージDB
 **/
class StageDB {
  public static function get(id:Int):Stages {
    for(stage in MyDB.stages.all) {
      if(id == stage.stage) {
        return stage;
      }
    }

    // 指定のIDが見つからなかった
    throw 'Not found stage id = ${id}';
  }

  public static function getEnemyKind(stage:Int, idx:Int):EnemiesKind {
    return get(stage).enemies[idx].enemy.id;
  }

  public static function getEnemyLength(stage:Int):Int {
    return get(stage).enemies.length;
  }
}
