package jp_2dgames.game.actor;

/**
 * アニメーション状態
 **/
import jp_2dgames.lib.Input;
private enum AnimState {
  Idle; // 待機
  Damage;  // ダメージ
  Attack;  // 攻撃
}

/**
 * プレイヤー
 **/
class Player extends Actor {

  // ==========================================
  // ■フィールド
  var _anim:AnimState;

  var _totalElapsed:Float = 0.0;

  /**
   * コンストラクタ
   **/
  public function new(X:Float, Y:Float) {
    super(X, Y);
    setStartPosition(X, Y);
    scale.set(0.5, 0.5);

    loadGraphic(AssetPaths.IMAGE_PLAYER, true);
    _registerAnimations();

    _anim = AnimState.Idle;
  }

  /**
   * 更新
   **/
  override public function update(elapsed:Float):Void {
    super.update(elapsed);

    _totalElapsed += elapsed;
    y = ystart + 4 * Math.sin(_totalElapsed*4);

    if(Input.on.A) {
      setParam(_hpmax + 100);
    }

    animation.play('${_anim}');
  }

  /**
   * アニメーションの登録
   **/
  function _registerAnimations():Void {
    animation.add('${AnimState.Idle}', [1]);
    animation.add('${AnimState.Damage}', [2]);
    animation.add('${AnimState.Attack}', [0]);
  }
}
