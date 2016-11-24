package jp_2dgames.game.particle;

import flixel.util.FlxColor;
import jp_2dgames.lib.SprFont;
import flixel.text.FlxText;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxSpriteGroup;

/**
 * 状態
 **/
private enum State {
  Appear; // 表示中
  Hide;   // 消えている
}

/**
 * コンボ演出
 **/
class ParticleCombo extends FlxSpriteGroup {

  static var OFFSET_X:Int = 180;
  static var OFFSET_Y:Int = 80;

  static var _instance:ParticleCombo = null;
  public static function createInstance(state:FlxState):Void {
    _instance = new ParticleCombo();
    state.add(_instance);
  }
  public static function destroyInstance():Void {
    _instance = null;
  }

  /**
   * コンボ演出開始
   **/
  public static function start(combo:Int):Void {
    _instance._start(combo);
  }

  /**
   * コンボ演出終了
   **/
  public static function end():Void {
    _instance._end();
  }

  // ===============================================
  // ■フィールド
  var _state:State; // 状態
  var _sprCombo:FlxSprite; // コンボ数
  var _txtCombo:FlxText; // コンボ

  /**
   * コンストラクタ
   **/
  public function new() {
    super(OFFSET_X, OFFSET_Y);


    // コンボ数
    {
      var size = SprFont.FONT_WIDTH;
      var px = 8 * 2.5;
      var py = 0;
      _sprCombo = new FlxSprite(px, py).makeGraphic(size * 3, size, FlxColor.TRANSPARENT);
      this.add(_sprCombo);
    }

    // コンボテキスト
    _txtCombo = new FlxText(0, 12, 0, "COMBO");
    _txtCombo.setFormat(null, 8, FlxColor.WHITE, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    this.add(_txtCombo);

    _state = State.Hide;
    visible = false;
    alpha   = 0;
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
          alpha -= alpha * 3;
          if(alpha <= 0) {
            visible = false;
          }
        }
    }
  }

  /**
   * 演出開始
   **/
  function _start(combo:Int):Void {

    SprFont.render(_sprCombo, '${combo}');

    alpha = 1;
    visible = true;
    for(obj in members) {
      obj.visible = true;
      obj.alpha = 1;
    }

    // 出現状態にする
    _state = State.Appear;
  }

  /**
   * 演出終わり
   **/
  function _end():Void {
    _state = State.Hide;
  }
}
