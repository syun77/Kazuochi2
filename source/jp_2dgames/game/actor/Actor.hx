package jp_2dgames.game.actor;
import jp_2dgames.game.particle.Particle;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import jp_2dgames.lib.DirUtil;
import flixel.util.FlxColor;
import jp_2dgames.game.particle.ParticleBmpFont;
import flixel.math.FlxMath;
import jp_2dgames.game.token.Token;

/**
 * キャラクター基底クラス
 **/
class Actor extends Token {

  // ========================================
  // ■定数
  static inline var TIMER_DAMAGE_SMALL:Int  = 30;
  static inline var TIMER_DAMAGE_MIDDLE:Int = 60;
  static inline var TIMER_DAMAGE_LARGE:Int  = 90;

  // ========================================
  // ■プロパティ
  public var hp(get, never):Int;
  public var hpmax(get, never):Int;
  public var hpratio(get, never):Float;
  public var ap(get, never):Int;
  public var apmax(get, never):Int;
  public var apratio(get, never):Float;
  public var canAttack(get, never):Bool;

  // ========================================
  // ■フィールド
  var _hp:Int;    // 現在のHP
  var _hpmax:Int; // 最大HP
  var _ap:Int;    // 現在の行動ポイント
  var _apmax:Int; // 最大行動ポイント
  var _tDamage:Float; // ダメージタイマー
  var _tween:FlxTween;
  var _bPlayer:Bool; // プレイヤーかどうか

  /**
   * コンストラクタ
   **/
  public function new(X:Float=0.0, Y:Float=0.0) {
    super(X, Y);
    setStartPosition(X, Y);
    _bPlayer = false;
  }

  /**
   * パラメータを設定する
   **/
  public function setParam(hpmax:Int):Void {
    _hpmax = hpmax;
    _hp    = hpmax;
    _ap    = 0;
    _apmax = 100;
    _tDamage = 0;
    _tween = null;

    visible = true;
  }

  /**
   * 死亡しているかどうか
   **/
  public function isDead():Bool {
    return _hp <= 0;
  }

  /**
   * 消滅演出
   **/
  public function vanish():Void {
    // サブクラスで実装する
  }

  /**
   * ターン開始
   **/
  public function beginTurn():Void {
    // サブクラスで実装
  }

  /**
   * ターン終了
   **/
  public function endTurn():Void {
    // サブクラスで実装
  }

  /**
   * ダメージを与える
   **/
  public function damage(v:Int):Void {

    _hp = FlxMath.maxAdd(_hp, -v, _hpmax);

    ParticleBmpFont.startNumber(xcenter, ycenter+8, v, FlxColor.WHITE, Dir.Up);
    _tDamage = _getDamageTimer(v);
    FlxTween.color(this, 0.5, FlxColor.RED, FlxColor.WHITE);

    if(_tween != null) {
      // 再生していたら止める
      _tween.cancel();
    }
    _tween = FlxTween.tween(this, {_tDamage:0}, 1, {ease:FlxEase.expoOut, onComplete:function(_) {
      x = xstart;
      y = ystart;
      _tween = null;
    }});

    // ダメージ演出
    var deg = FlxG.random.float(0, 360);
    for(i in 0...6) {
      deg += 360/5 + FlxG.random.float(0, 30);
      var speed = FlxG.random.float(200, 400);
      var p = Particle.add(ParticleType.Ball, xcenter, ycenter, deg, speed);
      var sc = FlxG.random.float(0.6, 1.2);
      p.scale.set(sc, sc);
      p.acceleration.y = 200;
      if(_bPlayer) {
        // プレイヤー
        p.color = FlxColor.RED;
      }
    }
  }

  /**
   * ダメージタイマーの取得
   **/
  function _getDamageTimer(v:Int):Int {
    if(v < 300) {
      return TIMER_DAMAGE_SMALL;
    }
    if(v < 1000) {
      return TIMER_DAMAGE_MIDDLE;
    }
    return TIMER_DAMAGE_LARGE;
  }

  /**
   * 攻撃開始
   **/
  public function beginAttack():Void {
    // サブクラスで実装する
  }

  /**
   * 更新
   **/
  override public function update(elapsed:Float):Void {
    super.update(elapsed);

    // 揺れの更新
    _updateShake();
  }

  /**
   * 更新・揺れ
   **/
  function _updateShake():Void {
    if(_tDamage > 0) {
      var v = _tDamage/3;
      x = xstart + v * (Math.floor(_tDamage)%2 == 0 ? -1 : 1);
      y = ystart + FlxG.random.float(-v, v)/2;
    }
  }

  /**
   * HPを回復する
   **/
  public function recover(v:Int):Void {
    _hp = FlxMath.maxAdd(_hp, v, _hpmax);
  }

  /**
   * APを加算する
   **/
  public function addAp(v:Int):Void {
    _ap = FlxMath.maxAdd(_ap, v, _apmax);
  }

  /**
   * APをリセットする
   **/
  public function resetAp():Void {
    _ap = 0;
  }

  // ========================================
  // ■プロパティ
  function get_hp() { return _hp; }
  function get_hpmax() { return _hpmax; }
  function get_hpratio() { return _hp / _hpmax; }
  function get_ap() { return _ap; }
  function get_apmax() { return _apmax; }
  function get_apratio() { return _ap / _apmax; }
  function get_canAttack() { return _ap == _apmax; }
}
