package jp_2dgames.game.state;
import jp_2dgames.game.gui.MyButton;
import flixel.addons.transition.FlxTransitionableState;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.text.FlxText;

/**
 * タイトル画面
 **/
class TitleState extends FlxTransitionableState {

  /**
   * 生成
   **/
  override public function create():Void {
    super.create();

    var bg = new FlxSprite(0, 0, AssetPaths.IMAGE_TITLE);
    this.add(bg);

    var btn = new MyButton(FlxG.width/2, FlxG.height*0.7, "CLICK HERE", function() {
      FlxG.switchState(new PlayInitState());
    });
    btn.x -= btn.width/2;
    this.add(btn);

    var txtCopy = new FlxText(0, FlxG.height-32, FlxG.width, "(C) 2016 2dgames.jp", 8);
    txtCopy.alignment = "center";
    this.add(txtCopy);
  }
}
