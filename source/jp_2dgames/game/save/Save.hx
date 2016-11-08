package jp_2dgames.game.save;

import openfl.filesystem.File;
import jp_2dgames.game.global.Global;
import flixel.util.FlxSave;
import haxe.Json;

// グローバル
private class _Global {
  public var level:Int;       // レベル
  public function new() {
  }
  // セーブ
  public function save() {
    level = Global.level;
  }
  // ロード
  public function load(data:Dynamic) {
    Global.setLevel(data.level);
  }
}

/**
 * フィールドのブロック情報
 **/
private class _Field {
  public var data:Array<Int>;
  public function new() {
    data = new Array<Int>();
  }
  // セーブ
  public function save() {
    var layer = Field.getLayer();
    layer.forEach2(function(idx:Int, v:Int) {
      data.push(v);
    });
  }
  // ロード
  public function load(data:Dynamic) {
    var layer = Field.getLayer();
    var array:Array<Int> = cast data.data;
    var idx:Int = 0;
    for(v in array) {
      var x = layer.idxToX(idx);
      var y = layer.idxToY(idx);
      layer.set(x, y, v);
      idx++;
    }
  }
}


/**
 * セーブデータ
 **/
private class SaveData {
  public var global:_Global;
  public var field:_Field;

  public function new() {
    global = new _Global();
    field = new _Field();
  }

  // セーブ
  public function save() {
    global.save();
    field.save();
  }

  // ロード
  public function load(data:Dynamic) {
    global.load(data.global);
    field.load(data.field);
  }
}

/**
 * セーブ処理
 **/
class Save {
  public function new() {
  }

  /**
   * セーブする
   * @param bToText テキストへの保存を行うかどうか
   * @param bLog    ログ出力を行うかどうか
   **/
  public static function save(bToText:Bool, bLog:Bool):Void {

    var data = new SaveData();
    data.save();

    var str = Json.stringify(data);

    if(bToText) {
      // テキストへ保存する
#if neko
      sys.io.File.saveContent(AssetPaths.PATH_SAVE, str);
      if(bLog) {
        trace("save ----------------------");
        trace(data);
      }
#end
    }
    else {
      // セーブ領域へ書き込み
      var saveutil = new FlxSave();
      saveutil.bind("SAVEDATA");
      saveutil.data.playdata = str;
      saveutil.flush();
    }
  }

  /**
   * ロードする
   * @param bFromText テキストから読み込みを行うかどうか
   * @param bLog      ログ出力を行うかどうか
   **/
  public static function load(bFromText:Bool, bLog:Bool):Void {
    var str = "";
#if neko
    str = sys.io.File.getContent(AssetPaths.PATH_SAVE);
    if(bLog) {
      trace("load ----------------------");
      trace(str);
    }
#end

    var saveutil = new FlxSave();
    saveutil.bind("SAVEDATA");
    if(bFromText) {
      // テキストファイルからロードする
      var data = Json.parse(str);
      var s = new SaveData();
      s.load(data);
    }
    else {
      var data = Json.parse(saveutil.data.playdata);
      var s = new SaveData();
      s.load(data);
    }
  }

  /**
   * セーブデータを消去する
   **/
  public static function erase():Void {
    var saveutil = new FlxSave();
    saveutil.bind("SAVEDATA");
    saveutil.erase();
  }

  public static function isContinue():Bool {
    var saveutil = new FlxSave();
    saveutil.bind("SAVEDATA");
    if(saveutil.data == null) {
      return false;
    }
    if(saveutil.data.playdata == null) {
      return false;
    }

    return true;
  }
}
