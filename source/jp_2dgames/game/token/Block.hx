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
  public static function add(Type:Int, X:Float, Y:Float):Block {
    var block:Block = parent.recycle(Block);
    block.init(Type, X, Y);
    return block;
  }

  // ==========================================================
  // ■フィールド
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
  public function init(Number:Int, X:Float, Y:Float, Hp:Int=0):Void {
    animation.play('${Number}');
    x = X;
    y = Y;
    _hp = Hp;
  }
}
