package jp_2dgames.game.field;

import flixel.math.FlxPoint;
import jp_2dgames.game.block.BlockUtil;
import flash.display.BlendMode;
import flixel.util.FlxColor;
import jp_2dgames.game.actor.Player;
import jp_2dgames.game.actor.Enemy;
import jp_2dgames.game.token.Shot;
import flixel.math.FlxMath;
import jp_2dgames.game.token.Block;
import flixel.tile.FlxTilemap;
import jp_2dgames.lib.Array2D;
import jp_2dgames.lib.TextUtil;
import jp_2dgames.lib.TmxLoader;

/**
 * フィールド
 **/
class Field {

  // フィールドサイズ
  public static inline var GRID_X:Int = 7;
  public static inline var GRID_Y:Int = 9;

  public static inline var GRID_X_CENTER:Int = 3; // Xの中心
  public static inline var GRID_Y_TOP:Int = 1; // Yの一番上

  // 次のブロックの位置
  public static inline var GRID_NEXT_X:Int = GRID_X_CENTER;
  public static inline var GRID_NEXT_Y:Int = 1;

  // オブジェクトレイヤー
  static inline var LAYER_NAME:String = "object";

  // 描画オフセット
  public static inline var OFFSET_X:Int = 20;
  public static inline var OFFSET_Y:Int = 128 - GRID_Y_TOP * TILE_HEIGHT;

  // タイルサイズ
  public static inline var TILE_WIDTH:Int  = Block.WIDTH;
  public static inline var TILE_HEIGHT:Int = Block.HEIGHT;
  public static inline var GRID_SIZE:Int   = Block.WIDTH;

  static var _tmx:TmxLoader = null;
  static var _map:FlxTilemap = null;
  static var _layer:Array2D = null;
  static var _tmpLayer:Array2D = null;

  /**
   * マップデータ読み込み
   **/
  public static function loadLevel(level:Int):Void {

    var name = TextUtil.fillZero(level, 3);
    _tmx = new TmxLoader();
    _tmx.load('assets/data/${name}.tmx');
    _layer = _tmx.getLayer(LAYER_NAME);
    _tmpLayer = new Array2D(_layer.width, _layer.height);
  }

  /**
   * マップデータ破棄
   **/
  public static function unload():Void {
    _tmx = null;
    _map = null;
  }

  /**
   * レイヤー情報の取得
   **/
  public static function getLayer():Array2D {
    return _layer;
  }

  /**
   * フィールドの幅
   **/
  public static function getWidth():Int {
    return _tmx.width * _tmx.tileWidth;
  }
  /**
   * フィールドの高さ
   **/
  public static function getHeight():Int {
    return _tmx.height * _tmx.tileHeight;
  }

  /**
   * レイヤー情報から各種オブジェクトを配置
   **/
  public static function createObjectsFromLayer():Void {
    var layer = _tmx.getLayer(LAYER_NAME);
    layer.forEach(function(i:Int, j:Int, v:Int) {
      switch(v) {
        case 1,2,3,4,5,6,7,8,9:
          Block.add(v, i, j);
      }
    });
  }

  /**
   * 消去チェック
   **/
  public static function checkErase(result:EraseResult, enemy:Enemy):EraseResult {

    result.init();

    // 消える場所のリスト
    var pList = new Array<FlxPoint>();

    _layer.forEach(function(i:Int, j:Int, v:Int) {
      if(v == 0) {
        // チェック不要
        return;
      }

      // テンポラリレイヤー初期化
      _tmpLayer.initialize(_layer.width, _layer.height);

      // 数値に変換
      v = BlockUtil.getNumber(v);

      // 消去できる数を計算する
      var cnt = _checkEraseRecursion(_layer, i, j, 0, 0, v, 0);
      if(cnt < v) {
        // 消去できない
        return;
      }

      // 消去できる
      // 消去数アップ
      result.erase += cnt;

      // 消去グループ数アップ
      result.kind++;

      // 最大連結数
      if(cnt > result.connect) {
        result.connect = cnt;
      }

      // 座標の合計
      var xgridTotal:Int = 0;
      var ygridTotal:Int = 0;

      _tmpLayer.forEach(function(xgrid:Int, ygrid:Int, val:Int) {
        if(val != 1) {
          // 消さない
          return;
        }

        var block = Block.search(xgrid, ygrid);
        if(block != null) {
          // ブロックを消す
          block.erase();
          // レイヤーからも消す
          _layer.set(xgrid, ygrid, 0);

          // 消去リストに入れる
          pList.push(FlxPoint.get(xgrid, ygrid));

          // 座標の合計を求める
          xgridTotal += xgrid;
          ygridTotal += ygrid;

        }
        else {
          trace('error:${xgrid},${ygrid}');
        }
      });

      // 攻撃演出生成
      var px = OFFSET_X + (xgridTotal / cnt + 0.5) * TILE_WIDTH;
      var py = OFFSET_Y + (ygridTotal / cnt + 0.5) * TILE_HEIGHT;
      var xtarget = enemy.xstart + enemy.origin.x;
      var ytarget = enemy.ystart + enemy.origin.y;
      Shot.add(px, py, xtarget, ytarget);

    });

    if(result.erase > 0) {
      // 連鎖数を増やす
      result.chain++;
    }
    else {
      // 連鎖終了
      result.chain = 0;
    }

    // ブロックへのダメージ処理
    for(p in pList) {

      var xgrid = Std.int(p.x);
      var ygrid = Std.int(p.y);
      p.put();

      // 上下左右のブロックにダメージを与える
      var xtbl = [-1, 0, 1, 0];
      var ytbl = [0, -1, 0, 1];
      for(i in 0...xtbl.length) {
        // 再帰検索
        var dx = xtbl[i];
        var dy = ytbl[i];
        var px = xgrid + dx;
        var py = ygrid + dy;
        var val2 = _layer.get(px, py);
        if(BlockUtil.getHp(val2) > 0) {
          // ダメージを与える
          _layer.set(px, py, BlockUtil.subHp(val2));
          var block2 = Block.search(px, py);
          if(block2 != null) {
            block2.damage();
          }
          else {
            trace(px, py, "none");
          }
        }
      }
    }

    // トータル消去数を返す
    return result;
  }

  static function _checkEraseRecursion(layer:Array2D, x:Int, y:Int, dx:Int, dy:Int, val:Int, cnt:Int):Int {
    var px = x + dx;
    var py = y + dy;
    if(_tmpLayer.get(px, py) == 1) {
      // チェック済み
      return cnt;
    }

    var val2 = layer.get(px, py);
    if(val2 == layer.outOfRange) {
      // 領域外
      return cnt;
    }

    if(BlockUtil.getHp(val2) > 0) {
      // 消去対象とならない
      return cnt;
    }
    val2 = BlockUtil.getNumber(val2);
    if(val2 != val) {
      // 消去対象とならない
      return cnt;
    }

    // 番号が一致した
    _tmpLayer.set(px, py, 1);
    cnt++;

    var xtbl = [-1, 0, 1, 0];
    var ytbl = [0, -1, 0, 1];
    for(i in 0...xtbl.length) {
      // 再帰検索
      var dx = xtbl[i];
      var dy = ytbl[i];
      cnt = _checkEraseRecursion(_layer, px, py, dx, dy, val, cnt);
    }
    return cnt;
  }

  /**
   * 領域外のブロックをチェック
   **/
  public static function checkEraseOutside(player:Player):Int {

    var ret:Int = 0;

    _layer.forEach(function(i:Int, j:Int, v:Int) {
      if(v == 0) {
        // チェック不要
        return;
      }

      var bNewer = BlockUtil.isNewer(v);
      if(j > Field.GRID_Y_TOP) {
        // チェック不要
        // フラグを下げる
        v = BlockUtil.offNewer(v);
        _layer.set(i, j, v);
        return;
      }

      if(bNewer) {
        // そのターンにプレイヤーが置いたブロック
        // 下にあるブロックも消す
        var py = j+1;
        var bottom = Block.search(i, py);
        bottom.erase();
        // レイヤーからも消す
        _layer.set(i, py, 0);
      }
      else {
        // ダメージを受ける
        v = BlockUtil.getNumber(v);
        ret++;
        // ダメージ演出生成
        var px = OFFSET_X + (i + 0.5) * TILE_WIDTH;
        var py = OFFSET_Y + (i + 0.5) * TILE_HEIGHT;
        var xtarget = player.xcenter;
        var ytarget = player.ycenter;
        var shot = Shot.add(px, py, xtarget, ytarget);
        shot.color = FlxColor.RED;
      }

      // 対象のブロックを消す
      var block = Block.search(i, j);
      block.erase();
      // レイヤーからも消す
      _layer.set(i, j, 0);
    });

    return ret;
  }

  /**
   * ブロックの落下
   **/
  public static function fall():Void {
    for(i in 0..._layer.width) {
      var cntZero:Int = 0;
      var cntDelay:Int = 0;
      // 下から調べる
      var array = [for(a in 0..._layer.height) _layer.height-1-a];
      for(j in array) {
        var v = _layer.get(i, j);
        if(v > 0) {
          // ブロックが存在するのでずらす
          var xnext = i;
          var ynext = j + cntZero;
          var block = Block.search(i, j);
          _layer.set(i, j, 0); // 現在の位置から消す
          _layer.set(xnext, ynext, v); // 移動
          block.move(xnext, ynext, cntDelay);
          cntDelay++;
        }
        else {
          // 何もない
          cntZero++;
          cntDelay = 0;
        }
      }
    }
  }

  /**
   * グリッド座標をワールド座標に変換(X)
   **/
  public static function toWorldX(i:Float):Float {
    i = Math.max(i, 0);
    i = Math.min(i, GRID_X-1);
    return i * TILE_WIDTH + OFFSET_X;
  }

  /**
   * グリッド座標をワールド座標に変換(Y)
   **/
  public static function toWorldY(j:Float):Float {
    return j * TILE_HEIGHT + OFFSET_Y;
  }

  /**
   * ワールド座標をグリッド座標に変換(X)
   **/
  public static function toGridX(i:Float):Int {
    return Math.floor((i-OFFSET_X) / TILE_WIDTH);
  }

  /**
   * ワールド座標をグリッド座標に変換(Y)
   **/
  public static function toGridY(j:Float):Int {
    return Math.floor((j-OFFSET_Y) / TILE_HEIGHT);
  }

  /**
   * 座標をグリッドに合わせる(X)
   **/
  public static function snapGridX(x:Float):Float {
    return Std.int((x-OFFSET_X) / GRID_SIZE) * GRID_SIZE + OFFSET_X;
  }

  /**
   * 座標をグリッドに合わせる(Y)
   **/
  public static function snapGridY(y:Float):Float {
    return Std.int((y-OFFSET_Y) / GRID_SIZE) * GRID_SIZE + OFFSET_Y;
  }
}

