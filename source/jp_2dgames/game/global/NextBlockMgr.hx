package jp_2dgames.game.global;
import jp_2dgames.game.block.BlockUtil;
import jp_2dgames.game.block.BlockSpecial;
import flixel.FlxG;
import jp_2dgames.lib.MyQueue;

/**
 * NEXTブロック管理
 **/
class NextBlockMgr {

  // NEXT表示の最大数
  public static inline var MAX:Int = 3;

  static var _instance:NextBlockMgr;
  public static function createInstance():Void {
    _instance = new NextBlockMgr();
  }
  public static function destroyInstance():Void {
    _instance = null;
  }

  /**
   * 初期化
   **/
  public static function init():Void {
    _instance._init();
  }

  /**
   * NEXTブロックを設定する
   **/
  public static function setNextBlocks(arr:Array<Int>):Void {
    _instance._setNextBlocks(arr);
  }

  /**
   * 次のブロックを取り出し
   **/
  public static function next():Int {
    return _instance._next();
  }

  /**
   * 末尾にスペシャルブロックを設定する
   **/
  public static function addTailSpecial(type:BlockSpecial):Void {
    _instance._addTailSpecial(type);
  }

  /**
   * ブロック出現範囲を設定
   **/
  public static function setRange(start:Int, end:Int):Void {
    _instance._setRange(start, end);
  }

  /**
   * ブロック出現範囲の開始を取得する
   **/
  public static function getRangeStart():Int {
    return _instance._start;
  }

  /**
   * ブロック出現範囲の終端を取得する
   **/
  public static function getRangeEnd():Int {
    return _instance._end;
  }

  /**
   * ブロックを抽選
   **/
  public static function put():Int {
    return _instance._put();
  }

  /**
   * キューの要素を全走査
   **/
  public static function forEachWithIndex(func:Int->Int->Void):Void {
    var idx:Int = 0;
    for(i in _instance._blocks.iterator()) {
      func(idx, i);
      idx++;
    }
  }

  // ==========================
  // ■フィールド
  var _blocks:MyQueue<Int>;
  var _start:Int; // 出現ブロック範囲の開始番号
  var _end:Int;   // 出現ブロック範囲の終了番号

  /**
   * コンストラクタ
   **/
  public function new() {
    _blocks = new MyQueue();

    _start = 2;
    _end   = 5;
  }

  /**
   * 初期化
   **/
  function _init():Void {

    // キューをクリア
    _blocks.clear();

    for(i in 0...MAX) {
      _enque();
    }
  }

  /**
   * NEXTブロックを設定する
   **/
  function _setNextBlocks(arr:Array<Int>):Void {

    // キューをクリア
    _blocks.clear();

    for(i in 0...MAX) {
      var v = arr[i];
      _blocks.enqueue(v);
    }
  }

  /**
   * ブロック出現範囲を設定
   **/
  function _setRange(start:Int, end:Int):Void {
    _start = start;
    _end   = end;
  }

  /**
   * ブロックを抽選
   **/
  function _put():Int {
    return FlxG.random.int(_start, _end);
  }

  /**
   * 要素を追加する
   **/
  function _enque():Void {
    var v = _put();
    _blocks.enqueue(v);
  }

  /**
   * キューから次のブロックを取り出し
   **/
  function _next():Int {
    _enque();
    return _blocks.dequeue();
  }

  /**
   * 末尾をスペシャルブロックに置き換える
   **/
  function _addTailSpecial(type:BlockSpecial):Void {
    // 末尾を削除
    var v = _blocks.last;
    _blocks.remove(v);
    // 末尾にスペシャルブロックを追加
    var next = BlockUtil.toDataSpecial(type);
    _blocks.enqueue(next);
  }

  /**
   * デバッグ出力
   **/
  function _dump():Void {
    _blocks.dump();
  }


}
