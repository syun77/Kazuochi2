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

  // 次に出現するブロックを設定
  public static function setNextBlock(nextBlock:Int):Void {
    _instance._setNextBlock(nextBlock);
  }

  // 表示
  public static function show():Void {
    _instance._show();
    // 座標を更新しておく
    _instance.update(FlxG.elapsed);
  }

  // 非表示
  public static function hide():Void {
    _instance._hide();
  }

  // ==========================================
  // ■フィールド
  // 落下対象のブロック
  var _block:Block = null;

  /**
   * コンストラクタ
   **/
  public function new() {
    super();

    var w = Block.WIDTH;
    var h = Block.HEIGHT * Field.GRID_Y;
    makeGraphic(w, h, FlxColor.WHITE);
    alpha = 0.5;
    visible = false;
  }

  /**
   * 更新
   **/
  override public function update(elapsed:Float):Void {

    if(visible == false) {
      // 非表示の場合は操作できない
      return;
    }

    super.update(elapsed);

    // カーソル移動
    var xtouch = Input.x-Block.WIDTH/2;
    var xgrid = Math.floor(xtouch/Block.WIDTH);
    var ygrid = 0;
    x = Field.toWorldX(xgrid);
    y = Field.toWorldY(ygrid);

    // ブロックも一緒に移動
    _block.moveNoWait(xgrid, ygrid);
  }

  /**
   * 次のブロックを表示
   **/
  function _setNextBlock(nextBlock:Int):Void {
    var px = Field.GRID_NEXT_X;
    var py = Field.GRID_NEXT_Y;
    _block = Block.add(nextBlock, px, py);
  }

  /**
   * 表示
   **/
  function _show():Void {
    visible = true;
  }

  /**
   * 非表示
   **/
  function _hide():Void {
    visible = false;
  }
}
