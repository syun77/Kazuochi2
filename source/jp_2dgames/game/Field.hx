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

  /**
   * マップデータ読み込み
   **/
  public static function loadLevel(level:Int):Void {

    var name = TextUtil.fillZero(level, 3);
    _tmx = new TmxLoader();
    _tmx.load('assets/data/${name}.tmx');
    _layer = _tmx.getLayer(LAYER_NAME);
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
      var x = toWorldX(i);
      var y = toWorldY(j);
      switch(v) {
        case 1,2,3,4,5,6,7,8,9:
          Block.add(v, x, y);
      }
    });
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

