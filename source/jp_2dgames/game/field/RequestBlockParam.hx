package jp_2dgames.game.field;

import jp_2dgames.game.global.NextBlockMgr;
import flixel.math.FlxMath;
import flixel.FlxG;
import jp_2dgames.game.token.Block;

/**
 * 要求するブロックの種類
 **/
enum RequestBlock {
  None;   // なし
  Upper;  // 上から
  Bottom; // 下から
}

/**
 * ブロック出現要求パラメータ
 **/
class RequestBlockParam {

  // ===================================================================
  // ■プロパティ
  public var type(get, never):RequestBlock;

  // ===================================================================
  // ■フィールド
  var _type:RequestBlock; // 種別
  var _count:Int;         // 出現数
  var _hp:Int;            // ブロックの堅さ (Block.HP_*)
  var _bSkull:Bool;       // ドクロブロックかどうか
  var _nLine:Int;         // 上昇するライン数 (RequestBlock.Bottom のみ有効)

  /**
   * コンストラクタ
   **/
  public function new() {
    init();
  }

  /**
   * 初期化
   **/
  public function init():Void {
    _type   = RequestBlock.None;
    _count  = 0;
    _hp     = 0;
    _bSkull = false;
    _nLine  = 0;
  }

  /**
   * リクエストが有効かどうか
   **/
  public function isEnd():Bool {
    if(_type == RequestBlock.None) {
      // 要求なし
      return true;
    }

    if(_count <= 0) {
      // 落下するブロックなし
      return true;
    }

    // 何かしらの要求がある
    return false;
  }

  /**
   * 実行する
   **/
  public function execute():Void {
    switch(_type) {
      case RequestBlock.None:
        // 何もしない

      case RequestBlock.Upper:
        _executeUpper();
        if(isEnd()) {
          // 終わったら初期化しておく
          init();
        }

      case RequestBlock.Bottom:
        _executeBottom();
        if(isEnd()) {
          // 終わったら初期化しておく
          init();
        }
    }
  }

  /**
   * 上から降らす
   **/
  function _executeUpper():Void {

    // どこから降らすかを決める
    var arr = [for(i in 0...Field.GRID_X) i];
    FlxG.random.shuffle(arr);

    var field = Field.getLayer();
    var count = FlxMath.minInt(_count, Field.GRID_X); // 最大 Field.GRID_X まで

    for(i in 0...count) {
      var number = NextBlockMgr.put();
      var xgrid  = arr[i];
      var ygrid  = 0;
      field.set(xgrid, ygrid, number);
      var b = Block.add(number, xgrid, ygrid);
      // TODO: 固ぷよ
      // TODO: ドクロブロック
      // TODO: 出現演出
    }

    // 出現したぶんだけ減らす
    _count -= count;
  }

  /**
   * 下から降らす
   **/
  function _executeBottom():Void {

  }

  // =========================================================
  // ■各種要求
  /**
   * 上から出現
   */
  public function setUpper(count:Int):Void {
    _type  = RequestBlock.Upper;
    _count = count;
  }

  /**
   * 上から出現 (固ぷよ)
   */
  public function setUpperVerd(count:Int):Void {
    _type  = RequestBlock.Upper;
    _count = count;
    _hp    = Block.HP_HARD;
  }

  /**
   * 上から出現 (固ぷよ)
   */
  public function setUpperVeryHard(count:Int):Void {
    _type  = RequestBlock.Upper;
    _count = count;
    _hp    = Block.HP_VERYHARD;
  }

  /**
   * 上から出現 (ドクロ)
   */
  public function setUpperSkull(count:Int):Void {
    _type   = RequestBlock.Upper;
    _count  = count;
    _bSkull = true;
  }

  /**
   * 下から出現
   * @param nLine 出現ライン数
   */
  public function setBottom(nLine:Int):Void {
    _type  = RequestBlock.Bottom;
    _nLine = nLine;
    _hp    = Block.HP_NORMAL;
  }

  /**
   * 下から出現 (固ぷよ)
   */
  public function setBottomHard(nLine:Int):Void {
    _type  = RequestBlock.Bottom;
    _nLine = nLine;
    _hp    = Block.HP_HARD;
  }

  // ===================================================================
  // ■アクセサ
  function get_type() { return _type; }
}
