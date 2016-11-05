package jp_2dgames.game.state;
import flixel.addons.transition.FlxTransitionableState;
import flixel.ui.FlxButton;
import flixel.text.FlxText;
import flixel.FlxG;

/**
 * エンディング画面
 **/
class EndingState extends FlxTransitionableState {

  static inline var FONT_SIZE:Int = 8 * 1;

  override public function create():Void {
    super.create();

    var txt = new FlxText(0, 64, FlxG.width, "Congratulation!", FONT_SIZE * 3);
    txt.setBorderStyle(FlxTextBorderStyle.OUTLINE, 2);
    txt.alignment = "center";
    this.add(txt);
    var msg = new FlxText(0, 128, FlxG.width, "completed all of the levels.", FONT_SIZE);
    msg.alignment = "center";
    this.add(msg);

    // タイトルに戻るボタン
    var btn = new FlxButton(0, FlxG.height*0.8, "Back to TITLE", function() {
      FlxG.switchState(new TitleState());
    });
    btn.x = FlxG.width/2 - btn.width/2;
    this.add(btn);
  }

  override public function destroy():Void
  {
    super.destroy();
  }

  override public function update(elapsed:Float):Void
  {
    super.update(elapsed);
  }
}
