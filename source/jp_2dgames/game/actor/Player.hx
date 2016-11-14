package jp_2dgames.game.actor;

/**
 * アニメーション状態
 **/
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
  // ■定数
  static inline var TIMER_ATTACK:Int = 40;
  static inline var TIMER_DAMAGE:Int = 40;

  // ==========================================
  // ■フィールド
  var _anim:AnimState;
  var _tAnim:Int = 0; // アニメーションタイマー

  var _totalElapsed:Float = 0.0;

  /**
   * コンストラクタ
   **/
  public function new(X:Float, Y:Float) {
    super(X, Y);
    scale.set(0.5, 0.5);

    loadGraphic(AssetPaths.IMAGE_PLAYER, true);
    _registerAnimations();

    _anim = AnimState.Idle;
  }

  /**
   * 攻撃アニメーション再生要求
   **/
  public function requestAttack():Void {
    _anim = AnimState.Attack;
    _tAnim = 0;
  }

  /**
   * 更新
   **/
  override public function update(elapsed:Float):Void {
    super.update(elapsed);

    _totalElapsed += elapsed;

    switch(_anim) {
      case AnimState.Idle:
        // 通常
        y = ystart + 4 * Math.sin(_totalElapsed*4);
      case AnimState.Attack:
        // 攻撃
        x = xstart + 16;
        y = ystart;
        _tAnim++;
        if(_tAnim >= TIMER_ATTACK) {
          _anim = AnimState.Idle;
          x = xstart;
        }
      case AnimState.Damage:
        // ダメージ
        y = ystart;
        _tAnim++;
        if(_tAnim >= TIMER_DAMAGE){
          _anim = AnimState.Idle;
        }
    }

    animation.play('${_anim}');
  }

  /**
   * ダメージ
   **/
  override public function damage(v:Int):Void {
    super.damage(v);
    // ダメージ演出開始
    _anim = AnimState.Damage;
    _tAnim = 0;
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
