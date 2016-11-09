package jp_2dgames.game.gui;

import jp_2dgames.game.particle.Particle;
import jp_2dgames.lib.Input;
import flixel.FlxG;
import flixel.FlxState;
import flixel.util.FlxColor;
import jp_2dgames.game.token.Block;
import flixel.FlxSprite;

/**
 * 状態
 **/
private enum State {
  End;         // 非表示
  AppearBlock; // ブロック出現
  MoveCursor;  // カーソル移動
}

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

  // 終了したかどうか
  public static function isEnd():Bool {
    return _instance._isEnd();
  }

  // 次に出現するブロックを設定
  public static function start(nextBlock:Int):Void {
    _instance._start(nextBlock);
  }

  // 配置したブロックを取得
  public static function getBlock():Block {
    var block = _instance._block;
    _instance._block = null;
    return block;
  }

  // ==========================================
  // ■フィールド
  // 状態
  var _state:State = State.End;
  // 落下対象のブロック
  var _block:Block = null;
  // 経過時間
  var _elapsed:Float = 0;

  /**
   * コンストラクタ
   **/
  public function new() {
    super();

    var w = Block.WIDTH;
    var h = Block.HEIGHT * Field.GRID_Y;
    makeGraphic(w, h, FlxColor.WHITE);
    alpha = 0.2;
    visible = false;
    _state = State.End;
  }

  /**
   * 更新
   **/
  override public function update(elapsed:Float):Void {

    switch(_state) {
      case State.End:
        // カーソル非表示
        visible = false;
      case State.AppearBlock:
        // カーソル非表示
        visible = false;
        if(Input.touchJustPressed) {
          // カーソル移動へ
          _state = State.MoveCursor;
        }
      case State.MoveCursor:
        visible = true;
        if(Input.touchJustReleased) {
          // 離したのでおしまい
          _state = State.End;
        }
        else {
          // 移動中
          _updateMoveCursor();
        }
    }

    if(_state != State.End) {
      _elapsed += elapsed;
      if(_elapsed > 0.3) {
        var p = Particle.add(ParticleType.Rect, _block.xcenter, _block.ycenter, 0, 0);
        p.color = FlxColor.RED;
        _elapsed -= 0.3;
      }
    }

    super.update(elapsed);

  }

  /**
   * カーソル移動中
   **/
  function _updateMoveCursor():Void {
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
   * カーソル処理開始
   **/
  function _start(nextBlock:Int):Void {
    var px = Field.GRID_NEXT_X;
    var py = Field.GRID_NEXT_Y;
    _block = Block.add(nextBlock, px, py);

    // ブロック出現
    _state = State.AppearBlock;
    _elapsed = 0;
  }

  /**
   * カーソル処理が終了したかどうか
   **/
  function _isEnd():Bool {
    return _state == State.End;
  }

}
