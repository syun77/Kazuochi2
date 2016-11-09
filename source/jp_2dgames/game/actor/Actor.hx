package jp_2dgames.game.actor;
import flixel.math.FlxMath;
import jp_2dgames.game.token.Token;

/**
 * キャラクター基底クラス
 **/
class Actor extends Token {

  // ========================================
  // ■プロパティ
  var hp(get, never):Int;
  var hpmax(get, never):Int;

  // ========================================
  // ■フィールド
  var _hp;    // 現在のHP
  var _hpmax; // 最大HP

  /**
   * コンストラクタ
   **/
  public function new() {
    super();
  }

  /**
   * パラメータを設定する
   **/
  public function setParam(hpmax:Int):Void {
    _hpmax = hpmax;
    _hp    = hpmax;
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
}
