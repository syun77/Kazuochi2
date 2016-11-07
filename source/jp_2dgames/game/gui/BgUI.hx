package jp_2dgames.game.gui;

import jp_2dgames.lib.MyColor;
import flixel.util.FlxColor;
import jp_2dgames.game.token.Block;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flash.display.BitmapData;
import flash.geom.Rectangle;

/**
 * 背景
 **/
class BgUI extends FlxGroup {

  static inline var THICK:Int = 2; // 線の太さ

  // ==================================
  // ■フィールド
  var _bg:FlxSprite;
  var _grid:FlxSprite;

  /**
   * コンストラクタ
   **/
  public function new() {
    super();

    // 背景作成
    _bg = _createSprite();
    this.add(_bg);
    _bg.animation.play("0");

    // グリッド作成
    _grid = _createGrid();
    _grid.color = MyColor.SILVER;
    this.add(_grid);
  }

  /**
   * 背景スプライトの生成
   **/
  function _createSprite():FlxSprite {
    var spr = new FlxSprite();
    spr.loadGraphic(AssetPaths.IMAGE_BG, true, 320, 480);
    for(i in 0...6) {
      spr.animation.add('${i}', [i]);
    }

    return spr;
  }

  /**
   * グリッド画像の作成
   **/
  function _createGrid():FlxSprite {
    var spr = new FlxSprite(0, 0, _createGridImage());
    return spr;
  }

  /**
   * グリッド画像データの作成
   **/
  function _createGridImage():BitmapData {

    // 透過画像を作成
    var bitmap = new BitmapData(FlxG.width, FlxG.height, true, FlxColor.TRANSPARENT);

    var rect = new Rectangle();
    for(i in 0...Field.GRID_X+1) {
      var px = i * Block.WIDTH;
      var py1 = 0;
      var py2 = Field.GRID_Y * Block.HEIGHT;
      rect.x = px;
      rect.width = THICK;
      rect.y = py1;
      rect.height = py2;
      bitmap.fillRect(rect, FlxColor.WHITE);
    }
    for(j in 0...Field.GRID_Y+1) {
      var py = j * Block.HEIGHT;
      var px1 = 0;
      var px2 = Field.GRID_X * Block.WIDTH;
      rect.y = py;
      rect.height = THICK;
      rect.x = px1;
      rect.width = px2;
      bitmap.fillRect(rect, FlxColor.WHITE);
    }

    return bitmap;
  }
}
