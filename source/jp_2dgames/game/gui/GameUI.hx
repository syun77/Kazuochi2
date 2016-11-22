package jp_2dgames.game.gui;

import jp_2dgames.game.block.BlockSpecial;
import jp_2dgames.game.global.NextBlockMgr;
import flixel.ui.FlxButton;
import jp_2dgames.game.state.SubMenuState;
import jp_2dgames.game.actor.Enemy;
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
  var _enemyUI:StatusUI;
  var _btnSpecial:MyButton; // スペシャルボタン
  var _canPressSpecialButton:Void->Bool; // スペシャルボタンを押すことができるかどうか

  /**
   * コンストラクタ
   **/
  public function new(player:Player, enemy:Enemy) {
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
    _playerUI = new StatusUI(player.left+32, player.bottom-48, player);
    this.add(_playerUI);

    // 敵UI作成
    _enemyUI = new StatusUI(enemy.left+84, enemy.bottom-92, enemy);
    this.add(_enemyUI);

    // メニューボタン
    var btnMenu = new FlxButton(FlxG.width-86, 0, "MENU", function() {
      FlxG.state.openSubState(new SubMenuState());
    });
    this.add(btnMenu);

    // スペシャルボタン
    _btnSpecial = new MyButton(0, FlxG.height-48, "Special", function() {
      // 全消しブロック出現
      NextBlockMgr.addTailSpecial(BlockSpecial.AllErase);
      // AP消費
      player.subAp(player.apmax);
    });
    this.add(_btnSpecial);

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

    _btnSpecial.enabled = _canPressSpecialButton();
  }

  /**
   * スペシャルボタンを押すことができるかどうか判定する関数を登録
   **/
  public function setCanPressSpecialFunc(func:Void->Bool):Void {
    _canPressSpecialButton = func;
  }
}
