package jp_2dgames.game.gui;

import flixel.util.FlxColor;
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

  static inline var FONT_SIZE:Int = 12;
  static inline var BAR_WIDTH:Int = 128;
  static inline var BAR_HEIGHT:Int = 8;

  // ---------------------------------------------------
  // ■フィールド
  var _txtLevel:FlxText;
  var _txtStage:FlxText;
  var _txtScore:FlxText;
  var _txtWait:FlxText;

  var _tAnim:Int = 0;

  var _enemy:Enemy;
  var _playerUI:StatusUI;
  var _enemyUI:StatusUI;
  var _btnSpecial:MyButton; // スペシャルボタン
  var _canPressSpecialButton:Void->Bool; // スペシャルボタンを押すことができるかどうか

  /**
   * コンストラクタ
   **/
  public function new(player:Player, enemy:Enemy) {
    super(4, 2);

    _enemy = enemy;

    var px:Float = 0;
    var py:Float = 0;

    // スコア
    _txtScore = new FlxText(px, py, 0, "", FONT_SIZE);
//    this.add(_txtScore);

    // レベル
    _txtLevel = new FlxText(px, py+FONT_SIZE+4, 0, "", FONT_SIZE);
    this.add(_txtLevel);
    _txtLevel.y -= FONT_SIZE-4;

    // ステージ
    _txtStage = new FlxText(px, py+(FONT_SIZE+4)*2, 0, "", FONT_SIZE);
    this.add(_txtStage);
    _txtStage.y -= FONT_SIZE-4;

    // プレイヤーUI作成
    _playerUI = new StatusUI(player.left+32, player.bottom-48, player);
    this.add(_playerUI);

    // 敵UI作成
    _enemyUI = new StatusUI(enemy.left+84, enemy.bottom-92, enemy);
    this.add(_enemyUI);

    // 敵が攻撃するまでのターン数
    _txtWait = new FlxText(enemy.xcenter-8, enemy.ycenter-40, 0, "");
    this.add(_txtWait);

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

    // フォントを設定
    forEachOfType(FlxText, function(txt:FlxText) {
      txt.setFormat(null, FONT_SIZE, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    });

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
    _txtStage.text = 'STAGE: ${Global.stage+1}/${Global.maxStage}';

    // 敵の攻撃までのターン数を計算
    {
      var wait = _enemy.calculateWaitTurnCount();
      if(wait < 0) {
        _txtWait.text = "";
      }
      else {
        _txtWait.text = 'WAIT: ${wait}';
      }
      _txtWait.color = FlxColor.WHITE;
      if(wait <= 1) {
        _txtWait.color = FlxColor.RED;
      }
    }

    // スペシャルボタンを有効にするかどうか
    _btnSpecial.enabled = _canPressSpecialButton();
  }

  /**
   * スペシャルボタンを押すことができるかどうか判定する関数を登録
   **/
  public function setCanPressSpecialFunc(func:Void->Bool):Void {
    _canPressSpecialButton = func;
  }
}
