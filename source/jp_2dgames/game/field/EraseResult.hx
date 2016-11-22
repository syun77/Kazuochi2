package jp_2dgames.game.field;

import flixel.math.FlxMath;

/**
 * 消去パラメータ
 **/
class EraseResult {

  public var erase:Int;   // 消去数
  public var connect:Int; // 最大連結数
  public var kind:Int;    // 色数
  public var number:Int;  // 消した数値の合計

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
    number  = 0;
  }

  /**
   * すべてを初期化
   **/
  public function initAll():Void {
    init();

    chain   = 0;
    combo   = 0;
  }

  /**
   * 接続数を設定
   **/
  public function setConnect(v:Int):Void {
    if(v > connect) {
      // 最大数を越えていれば設定可能
      connect = v;
    }
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

  /**
   * APダメージを計算
   **/
  public function calculateApDamage():Int {
    return number * 5;
  }

  /**
   * APゲージの増加値を取得する
   **/
  public function calculateAp():Int {
    return 1 + combo + chain;
  }
}
