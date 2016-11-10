package jp_2dgames.game.actor;
import flixel.math.FlxMath;
import jp_2dgames.game.token.Token;

/**
 * キャラクター基底クラス
 **/
class Actor extends Token {

  // ========================================
  // ■プロパティ
  public var hp(get, never):Int;
  public var hpmax(get, never):Int;
  public var hpratio(get, never):Float;
  public var ap(get, never):Int;
  public var apmax(get, never):Int;
  public var apratio(get, never):Float;

  // ========================================
  // ■フィールド
  var _hp:Int;    // 現在のHP
  var _hpmax:Int; // 最大HP
  var _ap:Int;    // 現在の行動ポイント
  var _apmax:Int; // 最大行動ポイント

  /**
   * コンストラクタ
   **/
  public function new(X:Float=0.0, Y:Float=0.0) {
    super(X, Y);
  }

  /**
   * パラメータを設定する
   **/
  public function setParam(hpmax:Int):Void {
    _hpmax = hpmax;
    _hp    = hpmax;
    _ap    = 0;
    _apmax = 100;
  }

  /**
   * 死亡しているかどうか
   **/
  public function isDead():Bool {
    return _hp <= 0;
  }

  /**
   * ダメージを与える
   **/
  public function damage(v:Int):Void {
    _hp = FlxMath.maxAdd(_hp, -v, _hpmax);
  }

  /**
   * HPを回復する
   **/
  public function recover(v:Int):Void {
    _hp = FlxMath.maxAdd(_hp, v, _hpmax);
  }

  // ========================================
  // ■プロパティ
  function get_hp() { return _hp; }
  function get_hpmax() { return _hpmax; }
  function get_hpratio() { return _hp / _hpmax; }
  function get_ap() { return _ap; }
  function get_apmax() { return _apmax; }
  function get_apratio() { return _ap / _apmax; }
}
