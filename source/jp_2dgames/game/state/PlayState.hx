package jp_2dgames.game.state;

import jp_2dgames.lib.MyShake;
import jp_2dgames.game.dat.LevelDB;
import jp_2dgames.game.particle.ParticleCombo;
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
import jp_2dgames.game.particle.StartStageUI;
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
  LevelCompleted;
}

/**
 * メインゲーム画面
 **/
class PlayState extends FlxTransitionableState {

  // ---------------------------------------
  // ■定数
  static inline var PLAYER_POS_X:Int = -8;
  static inline var PLAYER_POS_Y:Int = 16;
  static inline var ENEMY_POS_X:Int = 140;
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
  var _gameUI:GameUI;

  /**
   * 生成
   **/
  override public function create():Void {

    // 初期化
    Global.startLevel(1);

    // 背景の生成
    _bg = new BgUI();
    this.add(_bg);

    // ブロック生成
    Block.createParent(this);

    // NEXTブロックUI生成
    this.add(new NextBlockUI(0, 0));

    // マップ読み込み
    {
      var file = LevelDB.getTmx(Global.level);
      Field.loadLevelFromFile(file);
      // 各種オブジェクト生成
      Field.createObjectsFromLayer();
    }

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
    ParticleCombo.createInstance(this);
    StartStageUI.createInstance(this);

    // GUI生成
    CursorUI.createInstance(this);
    _gameUI = new GameUI(player, enemy);
    this.add(_gameUI);

    // NEXTブロック管理生成
    NextBlockMgr.createInstance();
    // 出現するブロックを設定
    {
      var start = LevelDB.getStartBlock(Global.level);
      var end   = LevelDB.getEndBlock(Global.level);
      NextBlockMgr.setRange(start, end);
    }
    NextBlockMgr.init();


    // シーケンス管理生成
    _seq = new SeqMgr(player, enemy, _gameUI);
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
    ParticleCombo.destroyInstance();
    Input.destroyVirtualPad();
    StartStageUI.destroyInstance();
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

      case State.LevelCompleted:
        // レベルクリア
        // TODO: タイトル画面に戻る
        FlxG.switchState(new EndingState());
    }

    #if debug
    _updateDebug();
    #end
  }

  /**
   * 更新・初期化
   **/
  function _updateInit():Void {
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

      case SeqMgr.RET_LEVEL_COMPLETED:
        // レベルクリア
        _state = State.LevelCompleted;
        Snd.stopMusic(1);
    }
  }

  /**
   * ゲームオーバー開始
   **/
  function _startGameover():Void {
    _state = State.Gameover;
    // メニューボタンを消す
    _gameUI.hideMenuButton();
    // プレイヤーを消す
    _player.vanish();
    // 画面を揺らす
    MyShake.high();
    this.add(new GameoverUI());
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
//      FlxG.switchState(StartStageUI PlayInitState());
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
