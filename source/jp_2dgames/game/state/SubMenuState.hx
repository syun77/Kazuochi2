package jp_2dgames.game.state;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxAxes;
import jp_2dgames.game.gui.MyButton;
import flixel.FlxSubState;

/**
 * 中断メニュー
 **/
class SubMenuState extends FlxSubState {

  var _tween:FlxTween;
  /**
   * 生成
   **/
  override public function create():Void {
    super.create();

    var bg = new FlxSprite();
    bg.makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
    bg.alpha = 0;
    FlxTween.tween(bg, {alpha:0.5}, 0.5, {ease:FlxEase.quartOut});
    this.add(bg);

    _tween = FlxTween.tween(FlxG.camera, {zoom:1.2}, 0.3, {ease:FlxEase.backOut});

    var btnList = new Array<MyButton>();
#if debug
    // デバッグボタン
    var btnDebug = new MyButton(0, 0, "Debug", function() {
      FlxG.debugger.visible = !FlxG.debugger.visible;
    });
    btnList.push(btnDebug);
    // リトライ
    var btnRetry = new MyButton(0, 0, "Retry", function() {
      FlxG.resetState();
    });
    btnList.push(btnRetry);
#end

    var BTN_OFS_Y:Int = 96; // 描画開始座標
    var BTN_DY:Int = 48; // ボタンの間隔

    var idx:Int = 0;
    for(btn in btnList) {
      btn.screenCenter(FlxAxes.X);
      var px = btn.x;
      btn.y = BTN_OFS_Y + (BTN_DY * idx);
      btn.x = FlxG.width;
      FlxTween.tween(btn, {x:px}, 0.5, {ease:FlxEase.backOut, startDelay:idx*0.1});
      idx++;
      this.add(btn);
    }


    // 閉じるボタン
    var btnClose = new MyButton(0, FlxG.height-96, "Close", function() {
      close();
    });
    btnClose.screenCenter(FlxAxes.X);
    this.add(btnClose);
  }

  /**
   * 破棄
   **/
  override public function destroy():Void {
    super.destroy();

    _tween.cancel();
    FlxG.camera.zoom = 1;
  }

  /**
   * 更新
   **/
  override public function update(elapsed:Float):Void {
    super.update(elapsed);
  }
}
