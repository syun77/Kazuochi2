package jp_2dgames.game.actor;
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
    scale.set(0.5, 0.5);

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
