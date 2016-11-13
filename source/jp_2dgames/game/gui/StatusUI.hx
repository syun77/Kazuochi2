package jp_2dgames.game.gui;

import flixel.group.FlxSpriteGroup;
import jp_2dgames.game.actor.Actor;
import flixel.util.FlxColor;
import jp_2dgames.lib.SprFont;
import flixel.FlxSprite;
import jp_2dgames.lib.StatusBar;

/**
 * ステータスUI
 **/
class StatusUI extends FlxSpriteGroup {

  // HP数値の最大桁数
  static inline var MAX_DIGIT:Int = 8;

  // アクティブゲージ
  var _activeBar:StatusBar;
  // HP
  var _txtHp:FlxSprite;
  var _txtHpX:Float;
  // 対象のアクター
  var _actor:Actor;

  // 前回のHP
  var _hp:Int;

  /**
   * コンストラクタ
   **/
  public function new(X:Float, Y:Float, actor:Actor) {
    super();
    x = X;
    y = Y;

    // アクターを保持
    _actor = actor;

    // アクティブゲージ作成
    _activeBar = new StatusBar(0, 0, 64, 8, true);
    _txtHpX = 33;
    _txtHp = new FlxSprite(_txtHpX, 12);

    // HP数値作成
    var FONT_SIZE:Int = SprFont.FONT_WIDTH;
    _txtHp.makeGraphic(FONT_SIZE * MAX_DIGIT, FONT_SIZE, FlxColor.TRANSPARENT, true);

    this.add(_activeBar);
    this.add(_txtHp);

    _hp = 0;
  }

  /**
   * 更新
   **/
  override public function update(elapsed:Float):Void {
    super.update(elapsed);

    // アクティブゲージ更新
    _activeBar.setPercent(100 * _actor.apratio);

    // HP更新
    {
      var hp = _actor.hp;
      if(hp != _hp) {
        // 前回と値が違ったら描画
        var w = SprFont.render(_txtHp, '${hp}');
        _txtHp.x = x + _txtHpX - (w/2);
        _hp = hp;
      }
    }
  }
}
