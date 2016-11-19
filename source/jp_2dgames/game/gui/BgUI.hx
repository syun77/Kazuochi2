package jp_2dgames.game.gui;

import jp_2dgames.game.state.PlayState;
import jp_2dgames.game.field.Field;
import jp_2dgames.game.token.Shot;
import flixel.tweens.FlxTween;
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
  static inline var MAX_BLACK:Float = 0.4;
  static inline var MAX_RED:Float = 0.4;
  static inline var BG_COLOR:Int = 0xFFD0D0D0;
  static inline var BG_DARK:Int = MyColor.CHARCOAL;
  static inline var BG_RED:Int = MyColor.RED;

  // ==================================
  // ■フィールド
  var _bg:FlxSprite;
  var _grid:FlxSprite;

  // 暗くするタイマー
  var _tBlack:Float = 0.0;

  // 赤くするタイマー
  var _tRed:Float = 0.0;

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

    // 危険ライン
    {
      var px = Field.toWorldX(0);
      var py = Field.toWorldY(Field.GRID_Y_TOP + 1);
      var w  = Block.WIDTH * Field.GRID_X+4;
      var h  = 8;
      px -= 2;
      py -= h/2;
      var line = new FlxSprite(px, py);
      line.makeGraphic(w, h, FlxColor.RED);
      FlxTween.tween(line, {alpha:0.5}, 1, {type:FlxTween.PINGPONG});
      this.add(line);
    }
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
    var spr = new FlxSprite(Field.OFFSET_X, Field.OFFSET_Y, _createGridImage());
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
      var py1 = Field.GRID_Y_TOP * Block.HEIGHT;
      var py2 = (Field.GRID_Y - Field.GRID_Y_TOP) * Block.HEIGHT;
      rect.x = px;
      rect.width = THICK;
      rect.y = py1;
      rect.height = py2;
      bitmap.fillRect(rect, FlxColor.WHITE);
    }
    for(j in Field.GRID_Y_TOP...Field.GRID_Y+1) {
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

  /**
   * 更新
   **/
  override public function update(elapsed:Float):Void {
    super.update(elapsed);

    if(Shot.count() > 0) {
      // 暗くする
      _tBlack = Math.min(_tBlack + elapsed, MAX_BLACK);
    }
    else {
      // 明るくする
      _tBlack = Math.max(_tBlack - elapsed, 0);
    }

    if(PlayState.player.isDanger()) {
      // 危険状態
      _tRed = Math.min(_tRed + elapsed, MAX_RED);
    }
    else {
      _tRed = Math.max(_tRed - elapsed, 0);
    }

    _bg.color = FlxColor.interpolate(BG_COLOR, BG_DARK, _tBlack/MAX_BLACK);
    _bg.color = FlxColor.interpolate(_bg.color, BG_RED, _tRed/MAX_RED);
  }
}
