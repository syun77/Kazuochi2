package jp_2dgames.game.token;

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
   * コンストラクタ
   **/
  public function new() {
    super();
    loadGraphic(AssetPaths.IMAGE_PARTICLE, true, 256, 256);
    blend = BlendMode.ADD;
    animation.add("play", [0]);
    animation.play("play");

    var sc = 0.4;
    scale.set(sc, sc);
  }

  /**
   * 初期化
   **/
  public function init(X:Float, Y:Float, xtarget:Float, ytarget:Float):Void {
    x = X - origin.x;
    y = Y - origin.y;

    // 制御点
    var xctrl = -200;
    var yctrl = -200;

    if(X > FlxG.width/2) {
      xctrl = 200;
    }

    if(FlxG.random.bool()) {
      xctrl = FlxG.random.int(0, 200);
    }
    else {
      yctrl = FlxG.random.int(0, 200);
    }

    xtarget -= origin.x;
    ytarget -= origin.y;
    trace(offset.x, offset.y);

    // 移動完了後のコールバック関数
    var func = function(_) {
      kill();
    }

    FlxTween.quadMotion(this, x, y, xctrl, yctrl, xtarget, ytarget, 0.5, true, {onComplete:func});
  }
}
