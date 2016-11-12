package jp_2dgames.game;

/**
 * 消去パラメータ
 **/
class EraseResult {

  public var erase:Int;   // 消去数
  public var connect:Int; // 最大連結数
  public var kind:Int;    // 色数

  // init()で初期化しない項目
  public var chain:Int;   // 連鎖数
  public var combo:Int;   // コンボ数

  /**
   * コンストラクタ
   **/
  public function new() {
    initAll();
  }

  /**
   * 初期化
   **/
  public function init():Void {
    erase   = 0;
    connect = 0;
    kind    = 0;
  }

  /**
   * すべてを初期化
   **/
  public function initAll():Void {
    erase   = 0;
    connect = 0;
    kind    = 0;
    chain   = 0;
    combo   = 0;
  }
}
