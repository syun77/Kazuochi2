package jp_2dgames.game.gui;

import flixel.FlxSprite;
import flixel.group.FlxGroup;

/**
 * 背景
 **/
class BgUI extends FlxGroup {

  var _spr:FlxSprite;

  /**
   * コンストラクタ
   **/
  public function new() {
    super();

    _spr = _createSprite();
    this.add(_spr);
    _spr.animation.play("0");
  }

  /**
   * 背景スプライトの生成
   **/
  function _createSprite():FlxSprite {
    var spr = new FlxSprite();
    spr.loadGraphic(AssetPaths.IMAGE_BG, true, 320, 480);
    for(i in 0...6) {
      spr.animation.add('${i}', [i]);
    }

    return spr;
  }
}
