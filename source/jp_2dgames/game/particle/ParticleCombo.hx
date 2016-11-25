package jp_2dgames.game.particle;

import jp_2dgames.lib.SprFont;
import flixel.util.FlxColor;
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

  static var OFFSET_X:Int = 188;
  static var OFFSET_Y:Int = 40;

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
      var px = -4;
      var py = -4;
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
        var sc = _sprCombo.scale.x;
        sc = Math.max(sc * 0.9, 1);
        _sprCombo.scale.set(sc, sc);

      case State.Hide:
        if(alpha > 0) {
          var sc = _sprCombo.scale.x;
          sc *= 0.9;
          _sprCombo.scale.set(sc, sc);
          alpha -= elapsed * 3;
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

    var str = '${combo}';
    var xofs = SprFont.FONT_WIDTH*3/2 - SprFont.FONT_WIDTH*str.length/2;
    SprFont.render(_sprCombo, '${combo}', xofs);

    alpha = 1;
    visible = true;
    for(obj in members) {
      obj.visible = true;
      obj.alpha = 1;
    }

    var sc = 3;
    _sprCombo.scale.set(sc, sc);

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
