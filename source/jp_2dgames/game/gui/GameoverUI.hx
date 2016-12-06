package jp_2dgames.game.gui;
import jp_2dgames.game.state.TitleState;
import flixel.util.FlxAxes;
import jp_2dgames.game.gui.MyButton;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.group.FlxSpriteGroup;

/**
 * ゲームオーバーUI
 **/
class GameoverUI extends FlxSpriteGroup {

  static inline var FONT_SIZE:Int = 16 * 2;

  public function new() {
    super();

    var txt = new FlxText(0, FlxG.height*0.3, FlxG.width, "GAME OVER");
    txt.setFormat(null, FONT_SIZE, FlxColor.WHITE, "center", FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    this.add(txt);
    // 中央に配置
    txt.screenCenter(FlxAxes.Y);

    // タイトル画面にボタン
    var btn = new MyButton(FlxG.width/2, FlxG.height*0.7, "Title", function() {
      FlxG.switchState(new TitleState());
    });
    btn.x -= btn.width/2;
    this.add(btn);

    scrollFactor.set();
  }
}
