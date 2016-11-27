package jp_2dgames.game.field;

import jp_2dgames.game.block.BlockSpecial;
import flixel.tweens.FlxTween;
import jp_2dgames.lib.DirUtil;
import jp_2dgames.game.token.BlockType;
import jp_2dgames.game.block.BlockUtil;
import flash.display.BlendMode;
import flixel.util.FlxColor;
import jp_2dgames.game.particle.Particle;
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
      if(_bSkull) {
        number = 0;
      }
      var xgrid  = arr[i];
      var ygrid  = 0;
      {
        // レイヤーに設定
        var data = BlockUtil.toData(number, _bSkull, _hp, false);
        field.set(xgrid, ygrid, data);
      }

      if(_bSkull) {
        // ドクロブロック
        Block.addSkull(xgrid, ygrid);
      }
      else {
        Block.add(xgrid, ygrid, BlockType.Number(number, _hp));
      }
      // 出現演出
      var px = Field.toWorldX(xgrid) + Field.TILE_WIDTH/2;
      var py = Field.toWorldY(ygrid) + Field.TILE_HEIGHT/2;
      var p = Particle.add(ParticleType.Circle, px, py);
      var sc = 0.8;
      p.scale.set(sc, sc);
      p.color = FlxColor.RED;
    }

    // 出現したぶんだけ減らす
    _count -= count;
  }

  /**
   * 下からせり上げる
   **/
  function _executeBottom():Void {
    var field = Field.getLayer();
    field.shift(Dir.Up);
    Block.slideAll(Dir.Up);

    for(i in 0...field.width) {
      var j = Field.GRID_Y_BOTTOM;
      var number = NextBlockMgr.put();
      var data = BlockUtil.toData(number, _bSkull, _hp, false);
      field.set(i, j, data);
      var block = Block.add(i, j+1, BlockType.Number(number, _hp));
      block.moveSlide(i, j+1, i, j, true);
    }
    // せり上げ回数を減らす
    _count--;
  }

  // =========================================================
  // ■各種要求

  public function set(type:RequestBlock, hp:Int, bSkull:Bool, count:Int):Void {
    _type   = type;
    _hp     = hp;
    _bSkull = bSkull;
    _count  = count;
  }
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
  public function setUpperHard(count:Int):Void {
    _type  = RequestBlock.Upper;
    _count = count;
    _hp    = BlockUtil.HP_HARD;
  }

  /**
   * 上から出現 (固ぷよ)
   */
  public function setUpperVeryHard(count:Int):Void {
    _type  = RequestBlock.Upper;
    _count = count;
    _hp    = BlockUtil.HP_VERYHARD;
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
    _hp    = BlockUtil.HP_NORMAL;
  }

  /**
   * 下から出現 (固ぷよ)
   */
  public function setBottomHard(nLine:Int):Void {
    _type  = RequestBlock.Bottom;
    _nLine = nLine;
    _hp    = BlockUtil.HP_HARD;
  }

  // ===================================================================
  // ■アクセサ
  function get_type() { return _type; }
}
