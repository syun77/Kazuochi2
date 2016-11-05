package jp_2dgames.game.token;

import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;

/**
 * ブロック
 **/
class Block extends Token {

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

  /**
   * コンストラクタ
   **/
  public function new() {
    super();
    loadGraphic(AssetPaths.IMAGE_BLOCK, true, 80, 80);
    for(i in 0...12) {
      animation.add('${i+1}', [i]);
    }
  }

  /**
   * 初期化
   **/
  public function init(Type:Int, X:Float, Y:Float):Void {
    animation.play('${Type}');
    x = X;
    y = Y;
  }
}
