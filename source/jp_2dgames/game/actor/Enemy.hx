package jp_2dgames.game.actor;

import jp_2dgames.game.dat.EnemyDB;
import jp_2dgames.game.field.RequestBlockParam;
import flixel.tweens.FlxEase;
import jp_2dgames.game.particle.Particle;
import flixel.FlxG;
import flixel.tweens.FlxTween;
import jp_2dgames.game.dat.MyDB;

/**
 * 敵
 **/
class Enemy extends Actor  {

  // ==========================================
  // ■フィールド
  var _totalElapsed:Float = 0.0;
  var _kind:EnemiesKind;

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
  }

  /**
   * 画像を読み込む
   **/
  function _load():Void {
    loadGraphic(EnemyDB.getImage(_kind));
  }

  /**
   * 敵出現
   **/
  public function appear(kind:EnemiesKind):Void {

    _kind = kind;
    _load();

    // HPを設定
    var hp = EnemyDB.getHp(_kind);
    setParam(hp);

    // 変数初期化
    _totalElapsed = 0;

    scale.set(0.5, 0.5);
    x = FlxG.width * 1.5;
    visible = true;
    FlxTween.tween(this, {x:xstart}, 1, {ease:FlxEase.expoOut});
  }

  /**
   * 攻撃開始
   **/
  override public function beginAttack():Void {
    var xtarget = xstart - 128;
    FlxTween.tween(this, {x:xtarget}, 0.25, {ease:FlxEase.quadOut, onComplete:function(_) {
      FlxTween.tween(this, {x:xstart}, 0.25, {ease:FlxEase.quadOut});
    }});
  }

  /**
   * 更新
   **/
  override public function update(elapsed:Float):Void {
    super.update(elapsed);

    _totalElapsed += elapsed;

    angle = 5 * Math.sin(_totalElapsed);
  }

  /**
   * ダメージ処理
   **/
  override public function damage(v:Int):Void {
    super.damage(v);
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
    // TODO:
    addAp(30);
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
      EnemyDB.isBlockSkull(_kind),
      EnemyDB.getBlockCount(_kind)
    );

    resetAp();
  }


}
