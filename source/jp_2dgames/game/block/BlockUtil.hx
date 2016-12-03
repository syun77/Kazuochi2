package jp_2dgames.game.block;

/**
 * ブロックユーティリティ
 * ■データ構造
 * 1桁目: 数値
 * 2桁目: ドクロかどうか
 * 3桁目: HP
 * 4桁目: プレイヤーが新しく配置したブロックかどうか
 * 5桁目: スペシャルブロックの種類
 **/
class BlockUtil {

  // ===============================================
  // ■定数
  // HP関連
  public static inline var HP_NORMAL:Int   = 0; // 通常ブロック
  public static inline var HP_HARD:Int     = 1; // 固いブロック (中は見える)
  public static inline var HP_VERYHARD:Int = 2; // とても固いブロック (中が見えない)
  // データオフセット
  public static inline var OFS_SKULL:Int   = 10;
  public static inline var OFS_HP:Int      = 100;
  public static inline var OFS_NEWER:Int   = 1000;
  public static inline var OFS_SPECIAL:Int = 10000;


  public static function toData(number:Int, skullLv:Int, hp:Int, bNewer:Bool):Int {
    var skull:Int = skullLv * OFS_SKULL;
    var hpval:Int = hp * OFS_HP;
    var newer:Int = bNewer ? OFS_NEWER : 0;
    return number + skull + hpval + newer;
  }
  public static function toDataSpecial(type:BlockSpecial):Int {
    var special:Int = 0;
    switch(type) {
      case BlockSpecial.None:
        special = 0;
      case BlockSpecial.AllErase:
        special = OFS_SPECIAL * 1;
    }
    return special;
  }
  public static function toDataSkull(lv:Int):Int {
    return toData(0, lv, 0, false);
  }

  public static function isNone(data:Int):Bool {
    return data == 0;
  }

  public static function getNumber(data:Int):Int {
    return data%OFS_SKULL;
  }
  public static function isSkull(data:Int):Bool {
    var v = getSkullLv(data);
    return v > 0;
  }
  public static function getSkullLv(data:Int):Int {
    var v = data%OFS_HP - getNumber(data);
    return Math.floor(v / OFS_SKULL);
  }
  public static function skullCountDown(data:Int):Int {
    if(isSkull(data) == false) {
      return data;
    }
    var lv = getSkullLv(data);
    if(lv <= 2) {
      return data;
    }
    return data - 1 * OFS_SKULL;
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
    var v = data%OFS_SPECIAL;
    return v >= OFS_NEWER;
  }
  // New属性をつける
  public static function onNewer(data:Int):Int {
    if(isNewer(data) == false) {
      return data + OFS_NEWER;
    }
    return data;
  }
  // New属性を取る
  public static function offNewer(data:Int):Int {
    if(isNewer(data)) {
      return data - OFS_NEWER;
    }
    return data;
  }
  // スペシャルブロックかどうか
  public static function isSpecial(data:Int):Bool {
    return data >= OFS_SPECIAL;
  }
  // スペシャルブロックの種類を取得
  public static function getSpecial(data:Int):BlockSpecial {
    // TODO: 今のところ消しのみ
    return BlockSpecial.AllErase;
  }

  /**
   * 他と接続するかどうか
   **/
  public static function isConnect(data:Int):Bool {
    if(getHp(data) > 0) {
      return false;
    }
    if(isSkull(data)) {
      return false;
    }
    // 接続可能
    return true;
  }
}
