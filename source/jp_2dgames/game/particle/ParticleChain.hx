package jp_2dgames.game.particle;

import flixel.tweens.FlxTween;
import flash.display.BlendMode;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.FlxState;
import flixel.group.FlxSpriteGroup;

private enum State {
  Appear; // 表示中
  Hide;   // 消えている
}

/**
 * 連鎖演出
 **/
class ParticleChain extends FlxSpriteGroup {

  static var OFFSET_Y:Int = 64;

  static var _instance:ParticleChain = null;
  public static function createInstance(state:FlxState):Void {
    _instance = new ParticleChain();
    state.add(_instance);
  }
  public static function destroyInstance():Void {
    _instance = null;
  }

  /**
   * チェイン演出開始
   **/
  public static function start(chain:Int):Void {
    _instance._start(chain);
  }

  /**
   * チェイン演出終わり
   **/
  public static function end():Void {
    _instance._end();
  }

  // =====================================================
  // ■フィールド
  var _state:State; // 状態
  var _bg:FlxSprite; // 背景
  var _txtChain:FlxText; // チェイン数
  var _tween:FlxTween = null;

  /**
   * コンストラクタ
   **/
  public function new() {
    super(0, OFFSET_Y);

    _state = State.Hide;

    // 背景
    _bg = new FlxSprite(0, 8);
    _bg.makeGraphic(FlxG.width, 8, FlxColor.RED);
    _bg.blend = BlendMode.ADD;
    this.add(_bg);

    // チェイン数
    _txtChain = new FlxText(0, 0, FlxG.width);
    _txtChain.setFormat(null, 16, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    this.add(_txtChain);

    visible = false;
    alpha = 0;
  }

  /**
   * 更新
   **/
  override public function update(elapsed:Float):Void {
    super.update(elapsed);

    switch(_state) {
      case State.Appear:
      case State.Hide:
        if(alpha > 0) {
          alpha -= elapsed;
          if(alpha <= 0) {
            visible = false;
          }
        }
    }
  }

  /**
   * 演出開始
   **/
  function _start(chain:Int):Void {

    if(_tween != null) {
      _tween.cancel();
    }
    _bg.scale.y = 1;
    _tween = FlxTween.tween(_bg.scale, {y:0.3}, 0.5);

    _txtChain.text = '${chain} Chain';

    alpha = 1;
    visible = true;
    _state = State.Appear;
    for(obj in members) {
      obj.visible = true;
      obj.alpha = 1;
    }
  }

  /**
   * 演出終わり
   **/
  function _end():Void {
    _state = State.Hide;
  }
}
