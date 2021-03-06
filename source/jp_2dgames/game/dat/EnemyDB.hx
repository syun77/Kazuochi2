package jp_2dgames.game.dat;

import jp_2dgames.game.block.BlockUtil;
import jp_2dgames.game.field.RequestBlockParam.RequestBlock;
import jp_2dgames.game.dat.MyDB;

/**
 * 敵DB
 **/
class EnemyDB {

  public static function get(id:EnemiesKind):Enemies {
    return MyDB.enemies.get(id);
  }

  public static function getName(id:EnemiesKind):String {
    return get(id).name;
  }

  public static function getImage(id:EnemiesKind):String {
    var image = get(id).image;
    return StringTools.replace(image, "../../../../", "");
  }

  public static function getOffsetY(id:EnemiesKind):Int {
    return get(id).yoffset;
  }

  public static function getHp(id:EnemiesKind):Int {
    return get(id).hp;
  }

  public static function getAp(id:EnemiesKind):Float {
    return get(id).ap * 100;
  }

  public static function getDirection(id:EnemiesKind):RequestBlock {
    var direction = get(id).direction;
    switch(direction) {
      case Enemies_direction.Upper: return RequestBlock.Upper;
      case Enemies_direction.Bottom: return RequestBlock.Bottom;
    }
  }

  public static function getBlockSkull(id:EnemiesKind):Int {
    switch(get(id).block) {
      case Enemies_block.Skull:
        return BlockUtil.SKULL_LV1;
      case Enemies_block.Skull2:
        return BlockUtil.SKULL_LV2;
      default:
        return 0;
    }
  }

  public static function getBlockHp(id:EnemiesKind):Int {
    var block = get(id).block;
    return switch(block) {
      case Enemies_block.Normal:   BlockUtil.HP_NORMAL;
      case Enemies_block.Hard:     BlockUtil.HP_HARD;
      case Enemies_block.VeryHard: BlockUtil.HP_VERYHARD;
      case Enemies_block.Skull:    BlockUtil.HP_NORMAL;
      case Enemies_block.Skull2:   BlockUtil.HP_NORMAL;
    }
  }
  public static function getBlockCount(id:EnemiesKind):Int {
    return get(id).count;
  }
  public static function getExtVal(id:EnemiesKind):Int {
    return get(id).extval;
  }
}
