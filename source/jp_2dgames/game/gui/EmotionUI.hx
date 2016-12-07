package jp_2dgames.game.gui;

import flixel.FlxSprite;

/**
 * 感情
 **/
enum Emotion {
  None;     // なし
  Suprised; // 驚き
  Groovy;   // ノリノリ♪
  Happy;    // 喜び
  Angry;    // 怒り
  Bad;      // 悔しい
}

/**
 * 感情アイコン
 **/
class EmotionUI extends FlxSprite {

  /**
   * コンストラクタ
   **/
  public function new(X:Float, Y:Float) {
    super(X, Y);

    loadGraphic(AssetPaths.IMAGE_EMOTION, true, 32, 32);
    _registerAnimations();
  }

  /**
   * アニメーションを変更
   **/
  public function change(emotion:Emotion):Void {
    if(emotion == Emotion.None) {
      kill();
      return;
    }

    if(exists == false) {
      revive();
    }
    animation.play('${emotion}');
  }

  /**
   * アニメーションの登録
   **/
  function _registerAnimations():Void {
    var speed = 3;
    animation.add('${Emotion.Suprised}', [0,  1,  2],  speed);
    animation.add('${Emotion.Groovy}',   [3,  4,  5],  speed);
    animation.add('${Emotion.Happy}',    [6,  7,  8],  speed);
    animation.add('${Emotion.Angry}',    [9,  10, 11], speed);
    animation.add('${Emotion.Bad}',      [12, 13, 14], speed);
  }
}
