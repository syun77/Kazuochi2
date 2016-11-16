package jp_2dgames.game.block;

/**
 * ブロックユーティリティ
 * ■データ構造
 * 1桁目: 数値
 * 2桁目: ドクロかどうか
 * 3桁目: HP
 * 4桁目: プレイヤーが新しく配置したブロックかどうか
 **/
class BlockUtil {

  // ===============================================
  // ■定数
  // HP関連
  public static inline var HP_NORMAL:Int   = 0; // 通常ブロック
  public static inline var HP_HARD:Int     = 1; // 固いブロック (中は見える)
  public static inline var HP_VERYHARD:Int = 2; // とても固いブロック (中が見えない)
  // データオフセット
  public static inline var OFS_SKULL:Int = 10;
  public static inline var OFS_HP:Int    = 100;
  public static inline var OFS_NEWER:Int = 1000;


  public static function toData(number:Int, bSkull:Bool, hp:Int, bNewer:Bool):Int {
    var skull:Int = bSkull ? OFS_SKULL : 0;
    var hpval:Int = hp * OFS_HP;
    var newer:Int = bNewer ? OFS_NEWER : 0;
    return number + skull + hpval + newer;
  }

  public static function getNumber(data:Int):Int {
    return data%OFS_SKULL;
  }
  public static function isSkull(data:Int):Bool {
    var v = data%OFS_HP;
    return v >= OFS_SKULL;
  }
  public static function getHp(data:Int):Int {
    var v = data%OFS_NEWER;
    return Math.floor(v/OFS_HP);
  }
  public static function subHp(data:Int):Int {
    var hp = getHp(data);
    if(hp > 0) {
      data -= OFS_HP;
    }
    return data;
  }
  public static function isNewer(data:Int):Bool {
    return data >= OFS_NEWER;
  }
  public static function offNewer(data:Int):Int {
    if(isNewer(data)) {
      return data - OFS_NEWER;
    }
    return data;
  }
}
