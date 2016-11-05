package jp_2dgames.lib;

import flash.Lib;
import flixel.system.FlxSound;
import flixel.FlxG;

/**
 * サウンド管理
 **/
class Snd {

  // BGM無効フラグ
#if !neko
  static var _bBgmDisable = false;
#else
  #if debug
    static var _bBgmDisable = true;
  #else
    static var _bBgmDisable = false;
  #end
#end

  static var _bgmnow  = null; // 現在再生中のBGM
  static var _bgmprev = null; // 1つ前に再生したBGM
  static var _oneShotTable = new Map<String, SoundInfo>(); // SEワンショット再生用テーブル
  static var _bSeEnable = true; // SEを有効にするかどうか

  public static function getBgmNow():String {
    return _bgmnow;
  }
  public static function setBgmNow(v:String) {
    _bgmnow = v;
  }

  public static function getBgmPrev():String {
    return _bgmprev;
  }
  public static function setBgmPrev(v:String):Void {
    _bgmprev = v;
  }

  /**
   * キャッシュする
   **/
  public static function cache(name:String):Void {
    FlxG.sound.cache(name);
  }

  /**
   * SEの有効フラグを設定する
   **/
  public static function enableSe(b:Bool):Void {
    _bSeEnable = b;
  }

  /**
   * ゲームを起動しての経過時間を取得する
   **/
  public static function getPasttime():Float {
    return flash.Lib.getTimer() * 0.001;
  }

  /**
   * SEの再生
   **/
  public static function playSe(key:String, bOneShot:Bool = true, tWait:Float = 0.01):FlxSound {

    if(_bSeEnable == false) {
      // SE無効
      return null;
    }

    if(bOneShot) {

      var info:SoundInfo = null;

      if(_oneShotTable.exists(key)) {
        info = _oneShotTable[key];

        var diff = getPasttime() - info.time;
        if(diff < tWait) {
          // ちょっと待ってから再生する
          return info.data;
        }

        info.data.kill();
        info.time = 0;
      } else {
        info = new SoundInfo();
      }

      var data:FlxSound = FlxG.sound.play(key);
      info.data = data;
      info.time = getPasttime();
      _oneShotTable[key] = info;

      return info.data;
    } else {
      return FlxG.sound.play(key);
    }

  }

  /**
   * BGMを再生する
   * @param name BGM名
   * @param bLoop ループフラグ
   **/
  public static function playMusic(name:String, bLoop:Bool = true):Void {

    // BGM再生情報を保存
    _bgmprev = _bgmnow;
    _bgmnow = name;

    if(_bBgmDisable) {
      // BGM無効
      return;
    }

    var sound = FlxG.sound.cache(name);
    if(sound != null) {
      // キャッシュがあればキャッシュから再生
      FlxG.sound.playMusic(sound, 1, bLoop);
    } else {
      FlxG.sound.playMusic(name, 1, bLoop);
    }
  }

  /**
   * BGMを停止する
   **/
  public static function stopMusic(fadeTime:Float=0.0):Void {
    if(FlxG.sound.music != null) {
      if(fadeTime > 0.0) {
        FlxG.sound.music.fadeOut(fadeTime, 0);
      }
      else {
        FlxG.sound.music.stop();
      }
    }
  }

  /**
   * 1つ前に再生したBGMを再生する
   **/
  public static function playMusicPrev():Void {
    if(_bgmprev == null) {
      return;
    }
    playMusic(_bgmprev);
  }

  /**
   * サウンドファイル読み込み
   **/
  public static function load(name:String):FlxSound {
    return FlxG.sound.load(name);
  }
}

private class SoundInfo {
  public var data:FlxSound = null;
  public var time:Float = 0;

  public function new() {
  }
}
