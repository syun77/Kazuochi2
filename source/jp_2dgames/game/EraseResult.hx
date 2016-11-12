package jp_2dgames.game;

/**
 * 消去パラメータ
 **/
import flixel.math.FlxMath;
class EraseResult {

  public var erase:Int;   // 消去数
  public var connect:Int; // 最大連結数
  public var kind:Int;    // 色数

  // init()で初期化しない項目
  public var chain:Int;   // 連鎖数
  public var combo:Int;   // コンボ数

  /**
   * コンストラクタ
   **/
  public function new() {
    initAll();
  }

  /**
   * 初期化
   **/
  public function init():Void {
    erase   = 0;
    connect = 0;
    kind    = 0;
  }

  /**
   * すべてを初期化
   **/
  public function initAll():Void {
    erase   = 0;
    connect = 0;
    kind    = 0;

    chain   = 0;
    combo   = 0;
  }

  /**
   * ダメージ量の計算
   **/
  public function calculateDamage():Int {

    // ダメージ = 消去数 x 10 x (最大連結数 + 色数ボーナス + 連鎖ボーナス + コンボボーナス)
    var a:Int = erase;
    var b:Int = 10; // 基本点
    var c:Int = connect;
    var d:Int = kind;
    var e:Int = chain;
    var f:Int = combo;

    // 連結ボーナス
    c = FlxMath.maxAdd(c, -2, 9999);

    // 色数ボーナス
    if(d <= 1) {
      d = 0;
    }
    else {
      d = Std.int(Math.pow(2, d-2));
    }

    // 連鎖ボーナス
    if(e <= 1) {
      e = 0;
    }
    else {
      e = 8 * (e - 1);
    }

    // コンボボーナス
    if(f <= 1) {
      f = 0;
    }
    else {
      f = 3 * (f - 1);
    }


    var ret = a * b * (c + d + e + f);

//    trace('${ret} = ${a} * ${b} * (${c} + ${d} + ${e} + ${f})');

    if(ret < 10) {
      // 最低保障ダメージ
      ret = 10;
    }

    return Std.int(ret);
  }
}
