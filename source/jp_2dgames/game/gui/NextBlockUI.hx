package jp_2dgames.game.gui;
import jp_2dgames.game.block.BlockSpecial;
import jp_2dgames.game.block.BlockUtil;
import jp_2dgames.game.token.BlockType;
import jp_2dgames.game.field.Field;
import jp_2dgames.game.token.Block;
import jp_2dgames.game.global.NextBlockMgr;
import flixel.group.FlxSpriteGroup;

/**
 * 次のブロック
 **/
class NextBlockUI extends FlxSpriteGroup {

  // ===========================================
  // ■フィールド

  /**
   * コンストラクタ
   **/
  public function new(X:Float, Y:Float) {
    super(X, Y);

    // 描画をずらす値
    var dy:Float = Y + Block.HEIGHT + 4;

    for(i in 0...NextBlockMgr.MAX) {
      var spr = new Block();
      spr.init(Field.GRID_X_CENTER, Field.GRID_Y_TOP, BlockType.Normal(1));
      var sc = 0.8 - 0.2 * i;
      spr.scale.set(sc, sc);

      // 表意位置を設定
      spr.y -= dy;
      this.add(spr);

      // 表示したブロックのぶんだけ上にずらす
      dy += 0.4 + Block.HEIGHT * sc;
      dy -= 0.2 * Block.HEIGHT * (1 - sc);
    }
  }

  /**
   * 更新
   **/
  override public function update(elapsed:Float):Void {
    super.update(elapsed);

    NextBlockMgr.forEachWithIndex(function(idx:Int, v:Int) {
      var block:Block = cast members[idx];
      if(BlockUtil.isSpecial(v)) {
        // スペシャルブロック
        var type = BlockUtil.getSpecial(v);
        block.setSpecial(type);
        block.setNumber(0);
      }
      else {
        // 通常ブロック
        block.setSpecial(BlockSpecial.None);
        block.setNumber(v);
      }
    });
  }
}
