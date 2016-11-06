package jp_2dgames.game.token;

import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;

/**
 * ブロック
 **/
class Block extends Token {

  public static inline var WIDTH:Int = 40;
  public static inline var HEIGHT:Int = 40;

  public static inline var SPECIAL:Int = 10; // スペシャルブロック
  public static inline var HARD:Int    = 11; // 固いブロック
  public static inline var SKULL:Int   = 12; // ドクロ

  public static var parent:FlxTypedGroup<Block>;
  public static function createParent(state:FlxState):Void {
    parent = new FlxTypedGroup<Block>();
    state.add(parent);
  }
  public static function destroyParent():Void {
    parent = null;
  }
  public static function add(Type:Int, xgrid:Int, ygrid:Int):Block {
    var block:Block = parent.recycle(Block);
    block.init(Type, xgrid, ygrid);
    return block;
  }
  public static function search(xgrid:Int, ygrid:Int):Block {
    return forEachIf(function(block:Block) {
      if(block.xgrid == xgrid && block.ygrid == ygrid) {
        return true;
      }
      return false;
    });
  }
  public static function forEachIf(func:Block->Bool):Block {
    for(block in parent.members) {
      if(block.exists) {
        if(func(block)) {
          // 条件に一致した
          return block;
        }
      }
    }
    // 一致しなかった
    return null;
  }

  // ==========================================================
  // ■プロパティ
  public var xgrid(get, never):Int;
  public var ygrid(get, never):Int;

  // ==========================================================
  // ■フィールド
  var _xgrid:Int;  // グリッド座標(X)
  var _ygrid:Int;  // グリッド座標(Y)
  var _number:Int; // 数値
  var _hp:Int;     // ブロックの堅さ

  /**
   * コンストラクタ
   **/
  public function new() {
    super();
    loadGraphic(AssetPaths.IMAGE_BLOCK, true, WIDTH, HEIGHT);
    for(i in 0...12) {
      animation.add('${i+1}', [i]);
    }
  }

  /**
   * 初期化
   **/
  public function init(Number:Int, xgrid:Int, ygrid:Int, Hp:Int=0):Void {
    animation.play('${Number}');
    _xgrid = xgrid;
    _ygrid = ygrid;
    x = Field.toWorldX(_xgrid);
    y = Field.toWorldY(_ygrid);
    _hp = Hp;
  }

  // ======================================================================
  // ■アクセサ
  function get_xgrid() { return _xgrid; }
  function get_ygrid() { return _ygrid; }
}
