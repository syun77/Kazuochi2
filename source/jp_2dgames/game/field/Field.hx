package jp_2dgames.game.field;

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
  public static inline var GRID_Y:Int = 8;

  // Xの中心
  public static inline var GRID_X_CENTER:Int = 3;

  // 次のブロックの位置
  public static inline var GRID_NEXT_X:Int = 3;
  public static inline var GRID_NEXT_Y:Int = 0;

  // オブジェクトレイヤー
  static inline var LAYER_NAME:String = "object";

  // 描画オフセット
  public static inline var OFFSET_X:Int = 20;
  public static inline var OFFSET_Y:Int = 128;

  // タイルサイズ
  static inline var TILE_WIDTH:Int  = Block.WIDTH;
  static inline var TILE_HEIGHT:Int = Block.HEIGHT;
  static inline var GRID_SIZE:Int   = Block.WIDTH;

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

    _layer.forEach(function(i:Int, j:Int, v:Int) {
      if(v == 0) {
        // チェック不要
        return;
      }

      // テンポラリレイヤー初期化
      _tmpLayer.initialize(_layer.width, _layer.height);

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

