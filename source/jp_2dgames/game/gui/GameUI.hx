package jp_2dgames.game.gui;

import flixel.ui.FlxButton;
import flixel.util.FlxAxes;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.ui.FlxBar;
import jp_2dgames.lib.StatusBar;
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
//  var _barHp:FlxBar;
  var _barHp:StatusBar;
  var _txtHp:FlxText;
  var _orbs:Array<FlxSprite>;

  var _tAnim:Int = 0;

  /**
   * コンストラクタ
   **/
  public function new() {
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

    // HP
    px += FlxG.width * 0.3;
    py += 4;
    _barHp = new StatusBar(px, py, BAR_WIDTH, BAR_HEIGHT, true);
//    _barHp = new FlxBar(px, py, null, 256, 16, null, "", 0, 100, true);
    _barHp.screenCenter(FlxAxes.X);
    this.add(_barHp);

    // HPテキスト
    _txtHp = new FlxText(_barHp.x + _barHp.width, py-2, 0, "", FONT_SIZE);
    this.add(_txtHp);

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
    _barHp.setPercent(Global.life);
//    _barHp.percent = Global.life;
    var hp = Std.int(Global.life);
    var hpmax = Std.int(Global.MAX_LIFE);
    _txtHp.text = '${hp}/${hpmax}';
    _txtHp.color = FlxColor.WHITE;
    if(hp < 40 && _tAnim%32 < 16) {
      // 危険
      _txtHp.color = FlxColor.RED;
    }
  }
}
