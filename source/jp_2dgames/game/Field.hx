package jp_2dgames.game;

import jp_2dgames.game.token.Block;
import jp_2dgames.lib.DirUtil.Dir;
import flixel.math.FlxPoint;
import flash.geom.Point;
import flixel.util.FlxColor;
import flash.geom.Rectangle;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.tile.FlxTilemap;
import jp_2dgames.lib.Array2D;
import jp_2dgames.lib.TextUtil;
import jp_2dgames.lib.TmxLoader;

/**
 * フィールド
 **/
class Field {

  // オブジェクトレイヤー
  static inline var LAYER_NAME:String = "object";

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
  public static function checkErase():Void {

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
      _tmpLayer.forEach(function(xgrid:Int, ygrid:Int, val:Int) {
        if(val != 1) {
          // 消さない
          return;
        }

        var block = Block.search(xgrid, ygrid);
        if(block != null) {
          block.kill();
          // レイヤーからも消す
          _layer.set(xgrid, ygrid, 0);
        }
        else {
          trace('error:${xgrid},${ygrid}');
        }
      });
    });
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
   * グリッド座標をワールド座標に変換(X)
   **/
  public static function toWorldX(i:Float):Float {
    return i * TILE_WIDTH;
  }

  /**
   * グリッド座標をワールド座標に変換(Y)
   **/
  public static function toWorldY(j:Float):Float {
    return j * TILE_HEIGHT;
  }

  /**
   * ワールド座標をグリッド座標に変換(X)
   **/
  public static function toGridX(i:Float):Int {
    return Math.floor(i / TILE_WIDTH);
  }

  /**
   * ワールド座標をグリッド座標に変換(Y)
   **/
  public static function toGridY(j:Float):Int {
    return Math.floor(j / TILE_HEIGHT);
  }

  /**
   * 座標をグリッドに合わせる
   **/
  public static function snapGrid(a:Float):Float {
    return Std.int(a / GRID_SIZE) * GRID_SIZE;
  }
}

