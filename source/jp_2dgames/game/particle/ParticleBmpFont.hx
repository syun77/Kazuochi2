package jp_2dgames.game.particle;

import flixel.effects.FlxFlicker;
import jp_2dgames.lib.DirUtil;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxG;
import jp_2dgames.lib.SprFont;
import flixel.FlxState;
import flixel.util.FlxColor;
import flixel.FlxSprite;

/**
 * 状態
 **/
private enum State {
  Main;    // メイン
  Flicker; // 点滅で消える
}

/**
 * BMPフォントエフェクト
 **/
class ParticleBmpFont extends FlxSprite {

  // フォントサイズ
  private static inline var FONT_SIZE:Int = SprFont.FONT_WIDTH;

  // 表示時間
  static inline var TIMER_EXIST:Int = 60;

  // ■速度関連
  // 開始速度
  static inline var SPEED_INIT:Float = 200.0;
  // 重力加速度
  static inline var GRAVITY:Float = 800.0;
  // 床との反発係数
  static inline var FRICTION:Float = 0.5;

  // パーティクル管理
  public static var parent:FlxTypedGroup<ParticleBmpFont> = null;
  /**
   * 生成
   **/
  public static function createParent(state:FlxState):Void {
    parent = new FlxTypedGroup<ParticleBmpFont>(16);
    for(i in 0...parent.maxSize) {
      parent.add(new ParticleBmpFont());
    }
    state.add(parent);
  }
  /**
   * 破棄
   **/
  public static function destroyParent():Void {
    parent = null;
  }

  public static function start(X:Float, Y:Float, str:String, color:Int=FlxColor.WHITE, ?movedir:Dir):ParticleBmpFont {
    var p:ParticleBmpFont = parent.recycle();
    p.init(X, Y, str);
    p.color = color;
    return p;
  }
  public static function startNumber(X:Float, Y:Float, val:Int, color:Int=FlxColor.WHITE, ?movedir:Dir):ParticleBmpFont {
    return start(X, Y, '${val}', color);
  }

  /**
   * 外部から更新
   **/
  public static function forceUpdate(elapsed:Float):Void {
    parent.update(elapsed);
  }

  // ----------------------------------------------------------
  // ■フィールド
  // 開始座標
  var _ystart:Float;
  var _state:State;
  var _timer:Int;

  /**
   * コンストラクタ
   **/
  public function new() {
    super();

    makeGraphic(FONT_SIZE * 8, FONT_SIZE, FlxColor.TRANSPARENT, true);

    // 非表示にしておく
    kill();
  }

  /**
   * 初期化
   **/
  public function init(X:Float, Y:Float, str:String) {

    x = X;
    y = Y;
    _ystart = Y;
    acceleration.y = GRAVITY;

    var w = SprFont.render(this, str);

    // 移動開始
    velocity.y = -SPEED_INIT;

    // フォントを中央揃えする
    x = X - (w / 2);

    visible = true;
    alpha = 1;

    // スクロール無効
    scrollFactor.set();

    // メイン状態へ
    _state = State.Main;
    _timer = TIMER_EXIST;
  }

  /**
   * 更新
   **/
  override public function update(elapsed:Float):Void {
    super.update(elapsed);

    if(y > _ystart) {
      // 地面に当たったら跳ね返る
      y = _ystart;
      velocity.y *= -FRICTION;
    }

    switch(_state) {
      case State.Main:
        _timer--;
        if(_timer == 0) {
          // 点滅で消える
          _state = State.Flicker;
          FlxFlicker.flicker(this, 0.3, 0.02, true, true, function(_) {
            // 点滅終了後に消える
            kill();
          });
        }

      case State.Flicker:
    }

  }
}
