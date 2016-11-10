package jp_2dgames.game.gui;

import jp_2dgames.game.actor.Player;
import flixel.math.FlxPoint;
import flixel.FlxG;
import jp_2dgames.game.global.Global;
import flixel.text.FlxText;
import flixel.group.FlxSpriteGroup;

/**
 * ゲームUI
 **/
class GameUI extends FlxSpriteGroup {

  static inline var FONT_SIZE:Int = 8;
  static inline var BAR_WIDTH:Int = 128;
  static inline var BAR_HEIGHT:Int = 8;

  // ---------------------------------------------------
  // ■フィールド
  var _txtLevel:FlxText;
  var _txtScore:FlxText;

  var _tAnim:Int = 0;

  var _playerUI:StatusUI;

  /**
   * コンストラクタ
   **/
  public function new(player:Player) {
    super(4, 2);

    var px:Float = 0;
    var py:Float = 0;

    // スコア
    _txtScore = new FlxText(px, py, 0, "", FONT_SIZE);
//    this.add(_txtScore);

    // レベル
    _txtLevel = new FlxText(px, py+FONT_SIZE+4, 0, "", FONT_SIZE);
//    this.add(_txtLevel);
    _txtLevel.y -= FONT_SIZE-4;

    // プレイヤーUI作成
    _playerUI = new StatusUI(player.left+32, player.bottom-32, player);
    this.add(_playerUI);

#if debug
    // デバッグボタン
    var btnDebug = new MyButton(0, FlxG.height-48, "Debug", function() {
      FlxG.debugger.visible = !FlxG.debugger.visible;
    });
    this.add(btnDebug);
    // リトライ
    var btnRetry = new MyButton(120, FlxG.height-48, "Retry", function() {
      FlxG.resetState();
    });
    this.add(btnRetry);
#end

    scrollFactor.set();
  }

  /**
   * 更新
   **/
  public override function update(elapsed:Float):Void {
    super.update(elapsed);

    _tAnim++;

//    _txtScore.text = 'SCORE: ${Global.score}';
    _txtLevel.text = 'LEVEL: ${Global.level}';
  }
}
