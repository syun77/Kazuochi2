package jp_2dgames.game.actor;

import jp_2dgames.lib.Snd;
import jp_2dgames.game.dat.EnemyDB;
import jp_2dgames.game.field.RequestBlockParam;
import flixel.tweens.FlxEase;
import jp_2dgames.game.particle.Particle;
import flixel.FlxG;
import flixel.tweens.FlxTween;
import jp_2dgames.game.dat.MyDB;

/**
 * 状態
 **/
private enum State {
  Appear;  // 出現中
  Standby; // 待機中
  Attack;  // 攻撃中
}

/**
 * 敵
 **/
class Enemy extends Actor  {

  // ==========================================
  // ■プロパティ
  public var kind(get, never):EnemiesKind;

  // ■フィールド
  var _totalElapsed:Float = 0.0;
  var _kind:EnemiesKind; // 敵の種類
  var _tStun:Int = 0; // スタンするターン数
  var _state:State = State.Appear; // 状態

  /**
   * コンストラクタ
   **/
  public function new(X:Float, Y:Float) {
    super(X, Y);
    setStartPosition(X, Y);

    // ひとまずコウモリにしておく
    _kind = EnemiesKind.Bat;
    _load();

    // HPをひとまず1
    setParam(1);

    // 消しておく
    visible = false;

    FlxG.watch.add(this, "_tStun");
    FlxG.watch.add(this, "ap");
  }

  /**
   * 画像を読み込む
   **/
  function _load():Void {
    loadGraphic(EnemyDB.getImage(_kind));

    // Y座標をずらす
    offset.y = EnemyDB.getOffsetY(_kind);
  }

  /**
   * 敵出現
   **/
  public function appear(kind:EnemiesKind, bReset:Bool=true):Void {

    _state = State.Appear;
    _kind = kind;
    _load();

    if(bReset) {
      // HPを設定
      var hp = EnemyDB.getHp(_kind);
      setParam(hp);
    }

    // 変数初期化
    _totalElapsed = 0;
    _tStun = 1; // 出現直後はAPゲージを増やさない
    _tFrame = 0;

    scale.set(0.5, 0.5);
    x = FlxG.width * 1.5;
    visible = true;
    FlxTween.tween(this, {x:xstart}, 1, {ease:FlxEase.expoOut, onComplete:function(_) {
      _state = State.Standby;
    }});
  }

  /**
   * 攻撃開始
   **/
  override public function beginAttack():Void {

    _state = State.Attack;

    var xtarget = xstart - 128;
    FlxTween.tween(this, {x:xtarget}, 0.25, {ease:FlxEase.quadOut, onComplete:function(_) {
      FlxTween.tween(this, {x:xstart}, 0.25, {ease:FlxEase.quadOut, onComplete:function(_) {
        _state = State.Standby;
      }});
    }});
  }

  /**
   * 更新
   **/
  override public function update(elapsed:Float):Void {
    super.update(elapsed);

    _totalElapsed += elapsed;

    if(isDead() == false) {
      angle = 5 * Math.sin(_totalElapsed);
    }
  }

  /**
   * ダメージ処理
   **/
  override public function damage(v:Int):Void {
    super.damage(v);

    // 1ターンスタンさせる
    _tStun = 1;
  }

  /**
   * APダメージ処理
   **/
  public function damageAp(v:Int):Void {
    subAp(v);
  }

  /**
   * 消滅
   **/
  override public function vanish():Void {

    FlxTween.tween(scale, {x:0.05, y:1}, 0.5, {ease:FlxEase.elasticIn, onComplete:function(_) {
      var deg = FlxG.random.float(0, 360);
      for(i in 0...12) {
        deg += 360/7 + FlxG.random.float(0, 20);
        var speed = FlxG.random.float(200, 400);
        var p = Particle.add(ParticleType.Ball, xcenter, ycenter, deg, speed);
        var sc = FlxG.random.float(0.3, 0.6);
        p.scale.set(sc, sc);
        p.acceleration.y = 200;
      }

      // ダメージアニメ停止
      if(_tween != null) {
        _tween.cancel();
        _tween = null;
        _tDamage = 0;
        x = xstart;
        y = ystart;
      }
      scale.y = 0.25;
      FlxTween.tween(scale, {x:2, y:0}, 0.3, {ease:FlxEase.expoOut, onComplete:function(_) {
        // 見た目だけ消す
        visible = false;
      }});
    }});
  }

  /**
   * ターンを開始
   **/
  override public function beginTurn():Void {

    if(_tStun > 0) {
      // スタン中は行動不可
      _tStun--;
      return;
    }

    var ap = EnemyDB.getAp(_kind);
    addAp(ap);
  }

  /**
   * 攻撃までの残りターン数を取得する
   **/
  public function calculateWaitTurnCount():Int {

    if(isDead()) {
      return -1;
    }

    switch(_state) {
      case State.Appear:
        return -1;
      case State.Standby:
        var d = apmax - ap;
        return Math.ceil(d / EnemyDB.getAp(_kind)) + 1;
      case State.Attack:
        return 0;
    }
  }

  /**
   * ターン終了
   **/
  override public function endTurn():Void {
  }

  /**
   * AIの実行
   **/
  public function execAI(req:RequestBlockParam):Void {
    req.set(
      EnemyDB.getDirection(_kind),
      EnemyDB.getBlockHp(_kind),
      EnemyDB.getBlockSkull(_kind),
      EnemyDB.getBlockCount(_kind)
    );

    resetAp();
    if(_tStun == 0) {
      // 攻撃後は休憩
      _tStun = 1;
    }
  }

  /**
   * APがちょうど満タンになった
   **/
  override function _cbJustApFull():Void {
    Snd.playSe("apmax");
  }

  // =================================================
  // ■アクセサ
  function get_kind() { return _kind; }
  override function get_apratio() {
    if(isDead()) {
      // 死亡しているときは常に0
      return 0.0;
    }
    return _ap / _apmax;
  }
}
