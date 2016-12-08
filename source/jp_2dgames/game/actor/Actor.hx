package jp_2dgames.game.actor;
import jp_2dgames.game.gui.EmotionUI;
import jp_2dgames.lib.Snd;
import jp_2dgames.game.dat.EnemyDB;
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

  static inline var EMOTION_OFS_X:Int = 16;
  static inline var EMOTION_OFS_Y:Int = -64;

  // ========================================
  // ■プロパティ
  public var hp(get, never):Int;
  public var hpmax(get, never):Int;
  public var hpratio(get, never):Float;
  public var ap(get, never):Float;
  public var apmax(get, never):Float;
  public var apratio(get, never):Float;
  public var canAttack(get, never):Bool;
  public var emotionUI(get, never):EmotionUI;

  // ========================================
  // ■フィールド
  var _hp:Int;         // 現在のHP
  var _hpmax:Int;      // 最大HP
  var _ap:Float;       // 現在の行動ポイント
  var _apmax:Float;    // 最大行動ポイント
  var _tDamage:Float;  // ダメージタイマー
  var _tFrame:Int = 0; // 経過フレーム数
  var _tween:FlxTween;
  var _bPlayer:Bool; // プレイヤーかどうか
  var _emotionUI:EmotionUI; // 感情アイコン

  /**
   * コンストラクタ
   **/
  public function new(X:Float=0.0, Y:Float=0.0) {
    super(X, Y);
    setStartPosition(X, Y);
    _bPlayer = false;

    _emotionUI = new EmotionUI(xcenter, ycenter);
    _emotionUI.kill();
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
    _tFrame = 0;
    _tween = null;

    visible = true;
  }

  public function setParamEx(hp:Int, hpmax:Int, ap:Float, apmax:Float):Void {
    setParam(hpmax);
    _hp    = hp;
    _ap    = ap;
    _apmax = apmax;
  }

  /**
   * 危険状態かどうか
   **/
  public function isDanger():Bool {
    return hpratio <= 0.3;
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
    kill();
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
    if(isDead() == false) {
      Snd.playSe("damage");
    }

    ParticleBmpFont.startNumber(xcenter, ycenter, v, FlxColor.WHITE, Dir.Up);
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

    _tFrame++;

    // 揺れの更新
    _updateShake();

    if(ap == apmax) {
      // APゲージ満タンアニメ
      _updateApMax();
    }

    // 感情アイコン
    if(_bPlayer) {
      _emotionUI.x = xcenter + EMOTION_OFS_X;
      _emotionUI.y = ycenter + EMOTION_OFS_Y;
    }
    else {
      // 適用のオフセット
      _emotionUI.x = xcenter - EMOTION_OFS_X*2.5;
      _emotionUI.flipX = true;
      _emotionUI.y = ycenter + EMOTION_OFS_Y*0.7+offset.y;
    }
  }

  /**
   * 更新・APゲージ満タン
   **/
  function _updateApMax():Void {

    if(isDead()) {
      // 死亡中は演出なし
      return;
    }

    if(_tFrame%48 == 0) {
      for(i in 0...2) {
        var p = Particle.add(ParticleType.Circle, xcenter, ycenter+offset.y);
        var sc = 0.2 + 0.1*i;
        p.scale.set(sc, sc);
        p.age = 1.5;
        p.color = FlxColor.RED;
      }
    }
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
  public function addAp(v:Float):Void {

    var bJustFull = true;
    if(apratio == 1) {
      bJustFull = false;
    }

    _ap = Math.min(_ap + v, _apmax);

    if(apratio < 1) {
      bJustFull = false;
    }

    if(bJustFull) {
      // APがちょうど満タンになった
      _cbJustApFull();
    }
  }
  /**
   * APを減少させる
   **/
  public function subAp(v:Float):Void {
    _ap = Math.max(_ap - v, 0);
  }

  /**
   * APをリセットする
   **/
  public function resetAp():Void {
    _ap = 0;
  }

  // ========================================
  // ■コールバック関数

  /**
   * APがちょうど満タンになったら
   **/
  function _cbJustApFull():Void {
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
  function get_emotionUI() { return _emotionUI; }
}
