package jp_2dgames.game.gui;
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
      spr.init(1, Field.GRID_X_CENTER, 0);
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
      block.setNumber(v);
    });
  }
}
