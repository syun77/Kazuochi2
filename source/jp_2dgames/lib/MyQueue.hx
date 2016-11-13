package jp_2dgames.lib;

/**
 * キュー
 **/
class MyQueue<T> {

  // ==============================
  // ■プロパティ
  // 要素数
  public var length(get, never):Int;

  // ==============================
  // ■フィールド
  var _list:List<T>;

  /**
   * コンストラクタ
   **/
  public function new() {
    _list = new List<T>();
  }

  /**
   * 要素の消去
   **/
  public function clear():Void {
    _list.clear();
  }

  /**
   * 要素が何もないかどうか
   **/
  public function isEmpty():Bool {
    return _list.isEmpty();
  }

  /**
   * 要素の追加
   **/
  public function enqueue(v:T):Void {
    _list.add(v);
  }

  /**
   * 先頭の要素を取り出す
   **/
  public function dequeue():T {
    return _list.pop();
  }

  /**
   * イテレーターを返す
   **/
  public function iterator():Iterator<T> {
    return _list.iterator();
  }

  /**
   * 要素の削除
   * @return 削除に成功したらtrue
   **/
  public function remove(v:T):Bool {
    return _list.remove(v);
  }

  /**
   * デバッグ出力
   **/
  public function dump():Void {
    var str = 'MyQueue dump [length=${length}]';
    for(v in iterator()) {
      str += '${v}, ';
    }
    trace(str);
  }

  // ==============================
  // ■アクセサ
  function get_length() { return _list.length; }
}
