package jp_2dgames.game.token;

import jp_2dgames.game.particle.Particle;
import flixel.FlxG;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tweens.FlxTween;
import flash.display.BlendMode;

/**
 * ショット
 **/
class Shot extends Token {

  public static var parent:FlxTypedGroup<Shot> = null;
  public static function createParent(state:FlxState):Void {
    parent = new FlxTypedGroup<Shot>();
    state.add(parent);
  }
  public static function destroyParent():Void {
    parent = null;
  }
  public static function add(X:Float, Y:Float, TargetX:Float, TargetY:Float):Shot {
    var shot:Shot = parent.recycle(Shot);
    shot.init(X, Y, TargetX, TargetY);
    return shot;
  }

  /**
   * 生存数をカウント
   **/
  public static function count():Int {
    return parent.countLiving();
  }

  // ====================================
  // ■フィールド
  var _elapsed:Float;

  /**
   * コンストラクタ
   **/
  public function new() {
    super();
    loadGraphic(AssetPaths.IMAGE_PARTICLE, true);
    blend = BlendMode.ADD;
    animation.add("play", [0]);
    animation.play("play");

    var sc = 0.8;
    scale.set(sc, sc);
  }

  /**
   * 初期化
   **/
  public function init(X:Float, Y:Float, xtarget:Float, ytarget:Float):Void {
    x = X - origin.x;
    y = Y - origin.y;

    _elapsed = 0;

    // 制御点
    var xctrl = -200;
    var yctrl = -200;
    var xctrl2 = 200;
    var yctrl2 = 200;

    if(X > FlxG.width/2) {
      xctrl = 200;
      yctrl2 = 0;
    }

    if(FlxG.random.bool()) {
      xctrl = FlxG.random.int(0, 200);
    }
    else {
      yctrl = FlxG.random.int(0, 200);
    }
    if(FlxG.random.bool()) {
      xctrl2 = 120 + FlxG.random.int(0, 100);
    }
    else {
      yctrl2 = 300 + FlxG.random.int(0, 200);
    }

    xtarget -= origin.x;
    ytarget -= origin.y;

    // 移動完了後のコールバック関数
    var func = function(_) {
      kill();
    }

    if(FlxG.random.bool()) {
      FlxTween.quadMotion(this, x, y, xctrl, yctrl, xtarget, ytarget, 0.5, true, {onComplete:func});
    }
    else {

      FlxTween.cubicMotion(this, x, y, xctrl, yctrl, xctrl2, yctrl2, xtarget, ytarget, 0.5, {onComplete:func});
    }
  }

  /**
   * 更新
   **/
  override public function update(elapsed:Float):Void {
    super.update(elapsed);

    _elapsed += elapsed;

    if(_elapsed > 0.05) {
      _elapsed -= 0.05;
      var deg = FlxG.random.float(0, 360);
      var speed = FlxG.random.float(50, 100);
      var p = Particle.add(ParticleType.Ball, xcenter, ycenter, deg, speed);
      p.scale.set(0.4, 0.4);
    }
  }
}
