package jp_2dgames.game.actor;
import flixel.FlxG;
import jp_2dgames.lib.Input;
class Enemy extends Actor  {

  // ==========================================
  // ■フィールド
  var _totalElapsed:Float = 0.0;

  /**
   * コンストラクタ
   **/
  public function new(X:Float, Y:Float) {
    super(X, Y);
    setStartPosition(X, Y);

    loadGraphic(AssetPaths.IMAGE_ENEMY, true);
    _registerAnimations();
    animation.play("5");
  }

  /**
   * 更新
   **/
  override public function update(elapsed:Float):Void {
    super.update(elapsed);

    _totalElapsed += elapsed;

    angle = 5 * Math.sin(_totalElapsed);

    if(Input.press.A) {
      var anim = FlxG.random.int(1, 5);
      animation.play('${anim}');
    }
  }

  /**
   * アニメーションの登録
   **/
  function _registerAnimations():Void {
    for(i in 0...5) {
      animation.add('${i+1}', [i]);
    }
  }
}
