package jp_2dgames.game.state;

import jp_2dgames.game.field.Field;
import jp_2dgames.game.global.NextBlockMgr;
import jp_2dgames.game.gui.NextBlockUI;
import jp_2dgames.game.token.Shot;
import jp_2dgames.game.actor.Enemy;
import jp_2dgames.game.actor.Player;
import jp_2dgames.game.save.Save;
import jp_2dgames.game.gui.CursorUI;
import jp_2dgames.game.gui.BgUI;
import jp_2dgames.game.token.Block;
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
  // ■定数
  static inline var PLAYER_POS_X:Int = 0;
  static inline var PLAYER_POS_Y:Int = 0;
  static inline var ENEMY_POS_X:Int = 192;
  static inline var ENEMY_POS_Y:Int = PLAYER_POS_Y+9;

  // ---------------------------------------
  // ■フィールド
  var _state:State = State.Init;

  var _bg:BgUI;
  var _seq:SeqMgr;

  /**
   * 生成
   **/
  override public function create():Void {

    // 初期化
    Global.initLevel();

    // 背景の生成
    _bg = new BgUI();
    this.add(_bg);

    // マップ読み込み
    Field.loadLevel(Global.level);

    // ブロック生成
    Block.createParent(this);

    // NEXTブロックUI生成
    this.add(new NextBlockUI(0, 0));

    // 各種オブジェクト生成
    Field.createObjectsFromLayer();

    // プレイヤーの生成
    var player = new Player(PLAYER_POS_X, PLAYER_POS_Y);
    player.setParam(100);
    this.add(player);

    // 敵の生成
    var enemy = new Enemy(ENEMY_POS_X, ENEMY_POS_Y);
    enemy.setParam(1000);
    this.add(enemy);

    // ショット生成
    Shot.createParent(this);

    // パーティクル生成
    Particle.createParent(this);
    ParticleBmpFont.createParent(this);

    // GUI生成
    CursorUI.createInstance(this);
    this.add(new GameUI(player, enemy));

    // NEXTブロック管理生成
    NextBlockMgr.createInstance();
    NextBlockMgr.init();

    // シーケンス管理生成
    _seq = new SeqMgr(player, enemy);
  }

  /**
   * 破棄
   **/
  override public function destroy():Void {

    Block.destroyParent();
    Shot.destroyParent();
    Particle.destroyParent();
    ParticleBmpFont.destroyParent();
    Input.destroyVirtualPad();
    CursorUI.destroyInstance();
    NextBlockMgr.destroyInstance();

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
    if(FlxG.keys.justPressed.S) {
      Save.save(true, true);
    }
    if(FlxG.keys.justPressed.A) {
      Save.load(true, true);
      Block.killAll();
      Field.createObjectsFromLayer();
    }
#end
#end
  }
}
