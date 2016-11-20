package jp_2dgames.game.gui;

import jp_2dgames.game.block.BlockUtil;
import flash.display.BlendMode;
import flixel.group.FlxGroup;
import jp_2dgames.game.field.Field;
import flixel.math.FlxMath;
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
class CursorUI extends FlxGroup {

  // ===================================================
  // ■定数
  static inline var BG_ALPHA:Float = 0.3;
  static inline var CURSOR_ALPHA:Float = 0.2;

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

  // 現在操作中のブロックを取得する
  public static function getNowBlockData():Int {
    return _instance._data;
  }

  // ==========================================
  // ■フィールド
  // 状態
  var _state:State = State.End;
  // 落下対象のブロック
  var _block:Block = null;
  // 元のブロックの情報
  var _data:Int = 0;
  // 経過時間
  var _elapsed:Float = 0.0;
  // カーソル背景
  var _bg:FlxSprite;
  // ブロックを光らせる
  var _cursor:FlxSprite;
  // アニメーションタイマー
  var _tAnim:Float = 0.0;

  /**
   * コンストラクタ
   **/
  public function new() {
    super();

    // 背景
    var w = Block.WIDTH;
    var h = Block.HEIGHT * (Field.GRID_Y - Field.GRID_Y_TOP);
    _bg = new FlxSprite().makeGraphic(w, h, FlxColor.WHITE);
    _bg.alpha = BG_ALPHA;
    _bg.visible = false;
    this.add(_bg);

    // ブロックカーソル
    _cursor = new FlxSprite().makeGraphic(Block.WIDTH, Block.HEIGHT, FlxColor.WHITE);
    _cursor.visible = false;
    _cursor.alpha = CURSOR_ALPHA;
    _cursor.blend = BlendMode.ADD;
    this.add(_cursor);

    _state = State.End;
  }

  /**
   * グリッド内かどうか
   **/
  function _isInGrid():Bool {
    var ygrid = Field.toGridY(Input.y);
    if(ygrid > Field.GRID_Y_BOTTOM) {
      // グリッド外
      return false;
    }
    if(ygrid < Field.GRID_Y_TOP) {
      // グリッド外
      return false;
    }
    return true;
  }

  /**
   * 更新
   **/
  override public function update(elapsed:Float):Void {

    _tAnim += elapsed;

    switch(_state) {
      case State.End:
        // カーソル非表示
        _bg.visible = false;
        _cursor.visible = false;

      case State.AppearBlock:
        // カーソル非表示
        _bg.visible = false;
        _cursor.visible = true;

        if(_isInGrid()) {
#if flash
          // カーソル移動へ
          _state = State.MoveCursor;
#else
          if(Input.touchJustPressed) {
            // カーソル移動へ
            _state = State.MoveCursor;
          }
        }
#end

      case State.MoveCursor:
        _bg.visible = true;
        _cursor.visible = true;

        if(_isInGrid() == false) {
          // グリッド外に出たので未選択状態へ
          _state = State.AppearBlock;
          return;
        }

      #if flash
        _block.visible = true;
        if(FlxG.mouse.justPressed) {
          // 離したのでおしまい
          _state = State.End;
        }
      #else
        if(Input.touchJustReleased) {
          // 離したのでおしまい
          _state = State.End;
        }
      #end
    }

    if(_state != State.End) {

      // カーソル移動
      _updateMoveCursor();

      // カーソル点滅
      var d = Math.sin(_tAnim * 4);
      _bg.alpha = BG_ALPHA + 0.05 * d;
      _cursor.alpha = CURSOR_ALPHA + 0.1 * d;

      // エフェクト出現
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
    var ygrid = Field.GRID_Y_TOP;

    // フィールド外に出ないようにする
    xgrid = FlxMath.maxInt(xgrid, 0);
    xgrid = FlxMath.minInt(xgrid, Field.GRID_X-1);

    _bg.x = Field.toWorldX(xgrid);
    _bg.y = Field.toWorldY(ygrid);

  #if mobile
    if(Input.touchPressed == false) {
      // タッチしていなかったら移動処理はしない
      return;
    }
  #end

    _cursor.x = _bg.x;
    _cursor.y = _bg.y;

    // ブロックも一緒に移動
    _block.moveNoWait(xgrid, ygrid);
  }

  /**
   * カーソル処理開始
   **/
  function _start(nextBlock:Int):Void {

    // 保存
    _data = nextBlock;

    var px = Field.GRID_NEXT_X;
    var py = Field.GRID_NEXT_Y;

    // TODO: 数値のみ
    var number = BlockUtil.getNumber(nextBlock);
    _block = Block.addNewer(number, px, py);
    _cursor.x = Field.toWorldX(px);
    _cursor.y = Field.toWorldY(py);

#if flash
    _block.visible = false;
#end

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
