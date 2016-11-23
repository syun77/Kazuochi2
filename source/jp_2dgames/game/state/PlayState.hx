package jp_2dgames.game.state;

import jp_2dgames.game.particle.ParticleChain;
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
  static inline var PLAYER_POS_Y:Int = 16;
  static inline var ENEMY_POS_X:Int = 132;
  static inline var ENEMY_POS_Y:Int = -51;

  // ---------------------------------------
  // ■プロパティ
  public static var player(get, never):Player;
  public static var enemy(get, never):Enemy;

  // ---------------------------------------
  // ■フィールド
  var _state:State = State.Init;

  var _bg:BgUI;
  var _seq:SeqMgr;
  var _player:Player;
  var _enemy:Enemy;

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
    _player = new Player(PLAYER_POS_X, PLAYER_POS_Y);
    _player.setParam(100);
    this.add(_player);

    // 敵の生成
    _enemy = new Enemy(ENEMY_POS_X, ENEMY_POS_Y);
    this.add(_enemy);

    // ショット生成
    Shot.createParent(this);

    // パーティクル生成
    Particle.createParent(this);
    ParticleBmpFont.createParent(this);
    ParticleChain.createInstance(this);

    // GUI生成
    CursorUI.createInstance(this);
    var ui = new GameUI(player, enemy);
    this.add(ui);

    // NEXTブロック管理生成
    NextBlockMgr.createInstance();
    NextBlockMgr.init();

    // シーケンス管理生成
    _seq = new SeqMgr(player, enemy, ui);
  }

  /**
   * 破棄
   **/
  override public function destroy():Void {

    Block.destroyParent();
    Shot.destroyParent();
    Particle.destroyParent();
    ParticleBmpFont.destroyParent();
    ParticleChain.destroyInstance();
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
  static function get_player() { return cast(FlxG.state, PlayState)._player; }
  static function get_enemy() { return cast(FlxG.state, PlayState)._enemy; }

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

    if(_seq.canSaveAndLoad()) {
      if(FlxG.keys.justPressed.S) {
        Save.save(true, true);
      }
      if(FlxG.keys.justPressed.A) {
        Block.killAll();
        Save.load(true, true);
        Field.createObjectsFromLayer();
      }
    }
#end
#end
  }
}
