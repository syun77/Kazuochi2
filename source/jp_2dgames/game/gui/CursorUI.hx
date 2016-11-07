package jp_2dgames.game.gui;

import jp_2dgames.lib.Input;
import flixel.FlxG;
import flixel.FlxState;
import flixel.util.FlxColor;
import jp_2dgames.game.token.Block;
import flixel.FlxSprite;

/**
 * カーソルUI
 **/
class CursorUI extends FlxSprite {

  static var _instance:CursorUI = null;
  public static function createInstance(state:FlxState):Void {
    _instance = new CursorUI();
    state.add(_instance);
  }
  public static function destroyInstance():Void {
    _instance = null;
  }
  public static function show():Void {
    _instance.revive();
    // 座標を更新しておく
    _instance.update(FlxG.elapsed);
  }
  public static function hide():Void {
    _instance.kill();
  }

  // ==========================================
  // フィールド


  /**
   * コンストラクタ
   **/
  public function new() {
    super();

    var w = Block.WIDTH;
    var h = Block.HEIGHT * Field.GRID_Y;
    makeGraphic(w, h, FlxColor.WHITE);
    alpha = 0.5;
    kill();
  }

  /**
   * 更新
   **/
  override public function update(elapsed:Float):Void {
    super.update(elapsed);

    var xtouch = Input.x;
    x = Field.toWorldX(Math.floor(xtouch/Block.WIDTH));
    y = 0;
  }
}
