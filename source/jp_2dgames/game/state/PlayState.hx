package jp_2dgames.game.state;

import jp_2dgames.game.token.Block;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.addons.transition.FlxTransitionableState;
import jp_2dgames.game.particle.ParticleStartLevel;
import jp_2dgames.game.gui.GameUI;
import jp_2dgames.lib.Input;
import flash.system.System;
import jp_2dgames.game.gui.GameoverUI;
import jp_2dgames.game.gui.StageClearUI;
import jp_2dgames.game.particle.ParticleBmpFont;
import jp_2dgames.game.particle.Particle;
import flixel.FlxG;
import jp_2dgames.lib.Snd;
import jp_2dgames.game.global.Global;

/**
 * 状態
 **/
private enum State {
  Init;
  Main;
  DeadWait;
  Gameover;
  Stageclear;
}

/**
 * メインゲーム画面
 **/
class PlayState extends FlxTransitionableState {

  // ---------------------------------------
  // ■フィールド
  var _state:State = State.Init;

  var _seq:SeqMgr;

  /**
   * 生成
   **/
  override public function create():Void {

    // 初期化
    Global.initLevel();

    // マップ読み込み
    Field.loadLevel(Global.level);

    this.add(new FlxSprite(0, 0, "assets/images/bg.png"));

    // ブロック生成
    Block.createParent(this);

    // 各種オブジェクト生成
    Field.createObjects();

    // パーティクル生成
    Particle.createParent(this);
    ParticleBmpFont.createParent(this);

    // GUI生成
    this.add(new GameUI());

    // シーケンス管理生成
    _seq = new SeqMgr();

    for(j in 0...10) {
      for(i in 0...8) {
        var px = 80 * i;
        var py = 80 * j;
        Block.add(i+1, px, py);
      }
    }
  }

  /**
   * 破棄
   **/
  override public function destroy():Void {

    Block.destroyParent();
    Particle.destroyParent();
    ParticleBmpFont.destroyParent();
    Input.destroyVirtualPad();

    super.destroy();
  }

  /**
   * 更新
   **/
  override public function update(elapsed:Float):Void {
    super.update(elapsed);

    switch(_state) {
      case State.Init:
        // ゲーム開始
        _updateInit();
        _state = State.Main;

      case State.Main:
        _updateMain();

      case State.DeadWait:
        // 死亡演出終了待ち

      case State.Gameover:
        // ゲームオーバー

      case State.Stageclear:
        // 次のレベルに進む
        StageClearUI.nextLevel();
    }

    #if debug
    _updateDebug();
    #end
  }

  /**
   * 更新・初期化
   **/
  function _updateInit():Void {
    // 開始演出
    ParticleStartLevel.start(this);
  }

  /**
   * 更新・メイン
   **/
  function _updateMain():Void {

    switch(_seq.proc()) {
      case SeqMgr.RET_DEAD:
        // ゲームオーバー
        _startGameover();
        Snd.stopMusic();
        return;
      case SeqMgr.RET_STAGECLEAR:
        // ステージクリア
        _state = State.Stageclear;
        Snd.stopMusic(1);
    }
  }

  /**
   * ゲームオーバー開始
   **/
  function _startGameover():Void {
    _state = State.Gameover;
    this.add(new GameoverUI(true));
  }

  // -----------------------------------------------
  // ■アクセサ

  /**
   * デバッグ
   **/
  function _updateDebug():Void {

#if debug
#if desktop
    if(FlxG.keys.justPressed.ESCAPE) {
      // 強制終了
      System.exit(0);
    }
    if(FlxG.keys.justPressed.R) {
      // リスタート
      FlxG.resetState();
//      FlxG.switchState(new PlayInitState());
    }
#end
#end
  }
}
