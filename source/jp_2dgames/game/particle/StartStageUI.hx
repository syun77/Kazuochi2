package jp_2dgames.game.particle;

import flixel.group.FlxSpriteGroup;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.FlxState;
import jp_2dgames.game.global.Global;

/**
 * レベル開始演出
 **/
class StartStageUI extends FlxSpriteGroup {

  static inline var FONTSIZE:Int = 32;

  static var _instance:StartStageUI = null;
  public static function createInstance(state:FlxState):Void {
    _instance = new StartStageUI();
    state.add(_instance);
  }
  public static function destroyInstance():Void {
    _instance = null;
  }

  public static function start():Void {
    _instance._start();
  }

  // ============================================
  // ■フィールド
  var _txt:FlxText;
  var _tween:FlxTween = null;

  /**
   * コンストラクタ
   **/
  public function new():Void {
    super();
    // テキスト
    _txt = new FlxText(0, FlxG.height*0.4, FlxG.width);
    _txt.setFormat(null, FONTSIZE, FlxColor.WHITE, "center", FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    if(Global.level == Global.MAX_LEVEL) {
      _txt.text = "FINAL STAGE";
    }

    this.add(_txt);

    scrollFactor.set();
  }

  /**
   * 開始
   **/
  function _start():Void {
    // ステージ開始演出
    if(Global.stage >= Global.maxStage - 1) {
      _txt.text = 'FINAL STAGE';
    }
    else {
      _txt.text = 'STAGE ${Global.stage+1}/${Global.maxStage}';
    }

    if(_tween != null) {
      _tween.cancel();
    }

    var px = 0;
    _txt.x = -FlxG.width*0.75;
    FlxTween.tween(_txt, {x:px}, 1, {ease:FlxEase.expoOut, onComplete:function(_) {
      var px2 = FlxG.width * 0.8;
      FlxTween.tween(_txt, {x:px2}, 1, {ease:FlxEase.expoIn, onComplete:function(_) {
        // おしまい
        _tween = null;
      }});
    }});
  }
}
