package jp_2dgames.game;

import jp_2dgames.game.particle.ParticleCombo;
import jp_2dgames.game.particle.ParticleChain;
import jp_2dgames.game.gui.GameUI;
import jp_2dgames.game.block.BlockUtil;
import jp_2dgames.game.field.RequestBlockParam;
import jp_2dgames.game.field.EraseResult;
import jp_2dgames.game.field.Field;
import jp_2dgames.game.global.NextBlockMgr;
import jp_2dgames.game.token.Shot;
import jp_2dgames.game.actor.Enemy;
import jp_2dgames.game.actor.Player;
import flixel.math.FlxMath;
import jp_2dgames.game.gui.CursorUI;
import jp_2dgames.lib.Input;
import jp_2dgames.game.token.Block;
import flixel.FlxG;
import jp_2dgames.game.dat.MyDB;

/**
 * 状態
 **/
private enum State {

  None;              // 無効

  Init;              // 初期化

  AppearBlock;       // ブロック出現
  InputKey;          // 落下場所選択
  FallBlock;         // ブロック落下
  // ブロック消滅 (敵へのダメージ)
  EraseCheck;        // チェック
  EraseExec;         // 実行
  // ダメージ (プレイヤーへのダメージ)
  DamageCheck;       // チェック
  DamageExec;        // 実行

  WinLoseCheck;      // 勝利・敗北判定
  EnemyAIExec;       // 敵のAI実行

  Win;               // 勝利演出
  Lose;              // 敗北演出
  GameOver;          // ゲームオーバー

  StageClear;        // ステージクリア

  End;               // おしまい

}

/**
 * シーケンス管理
 **/
class SeqMgr {

  public static var RET_NONE:Int    = 0;
  public static var RET_DEAD:Int    = 3; // プレイヤー死亡
  public static var RET_STAGECLEAR:Int  = 5; // ステージクリア

  // 状態
  var _state:State;
  var _statePrev:State;

  var _bKeepOnChain:Bool = false; // 連鎖が続行するかどうか

  var _eraseResult:EraseResult;        // 消去結果
  var _requestBlock:RequestBlockParam; // ブロック落下情報
  var _nDamageBlock:Int;               // ダメージブロックの数

  // キャラクター
  var _player:Player;
  var _enemy:Enemy;

  /**
   * コンストラクタ
   **/
  public function new(player:Player, enemy:Enemy, ui:GameUI) {
    _state = State.Init;
    _statePrev = _state;

    _eraseResult = new EraseResult();
    _requestBlock = new RequestBlockParam();
    _nDamageBlock = 0;

    _player = player;
    _enemy  = enemy;

    ui.setCanPressSpecialFunc(_canPressSpecialButton);

    // デバッグ用
    FlxG.watch.add(this, "_state");
    FlxG.watch.add(this, "_statePrev");

    _player.addAp(95);
  }

  /**
   * セーブ・ロード可能な状態かどうか
   **/
  public function canSaveAndLoad():Bool {
    return _state == State.InputKey;
  }

  /**
   * スペシャルボタンを押すことができるかどうか
   **/
  function _canPressSpecialButton():Bool {
    if(_state != State.InputKey) {
      return false;
    }
    if(_player.apratio < 1) {
      return false;
    }

    return true;

  }

  /**
   * 状態遷移
   **/
  function _change(next:State):Void {
    trace('${_state} -> ${next}');
    _statePrev = _state;
    _state = next;
  }

  /**
   * ターン開始
   **/
  function _beginTurn():Void {
    _player.beginTurn();
    _enemy.beginTurn();
  }

  /**
   * ターン終了
   **/
  function _endTurn():Void {
    _player.endTurn();
    _enemy.endTurn();
  }

  function _procInit():State {

    // 敵出現
    _enemy.appear(EnemiesKind.Bat);

    // ブロック出現
    return State.AppearBlock;
  }

  function _procAppearBlock():State {

    // ターン終了
    _endTurn();

    // ターン開始
    _beginTurn();

    // 次に出現するブロックを抽選
    var next = NextBlockMgr.next();
    CursorUI.start(next);
    return State.InputKey;
  }

  function _procInputKey():State {

    if(CursorUI.isEnd()) {
      // カーソル処理終了
      // ブロックを配置
      var block = CursorUI.getBlock();
      var layer = Field.getLayer();
      var data  = CursorUI.getNowBlockData();
      // NEW属性をつける
      data = BlockUtil.onNewer(data);
      layer.set(block.xgrid, block.ygrid, data);
      // 落下開始
      Field.fall();
      return State.FallBlock;
    }

    return State.None;
  }

  function _procFallBlock():State {
    // 落下処理
    if(Block.isIdleAll() == false) {
      // ブロック落下中
      return State.None;
    }
    return State.EraseCheck;
  }

  function _procEraseCheck():State {
    // 消去処理
    var result = Field.checkErase(_eraseResult, _enemy);
    if(result.erase > 0) {
      // 消去できた
      if(result.chain == 1) {
        // 最初の連鎖でコンボ数を増やす
        result.addCombo();
        ParticleCombo.start(result.combo);
      }
      // 攻撃アニメーション開始
      _player.beginAttack();
      // 連鎖演出開始
      ParticleChain.start(result.chain);
      // 連鎖続行
      _bKeepOnChain = true;
      // APゲージ増加
      _player.addAp(result.calculateAp());
      return State.EraseExec;
    }
    else {
      // ダメージチェックへ
      // 連鎖終了
      ParticleChain.end();
      if(result.chain == 0) {
        // 連鎖なしでコンボ終了
        result.resetCombo();
        ParticleCombo.end();
      }
      // 連鎖数をリセット
      result.chain = 0;
      _bKeepOnChain = false;
      return State.DamageCheck;
    }
  }

  function _procEraseExec():State {

    if(Block.isIdleAll() == false) {
      // 消滅中
      return State.None;
    }

    if(Shot.count() > 0) {
      // 演出中
      return State.None;
    }

    {
      // ダメージ計算
      var v = _eraseResult.calculateDamage();
      // 敵にダメージを与える
      _enemy.damage(v);
      // APダメージ計算
      var ap = _eraseResult.calculateApDamage();
      _enemy.damageAp(v);
    }

    // 勝利敗北判定
    return State.WinLoseCheck;
  }

  function _procDamageCheck():State {

    // ダメージブロック数を取得
    _nDamageBlock = Field.checkEraseTop(_player);

    if(_nDamageBlock > 0) {
      // 存在する場合はダメージ処理
      return State.DamageExec;
    }
    else {
      // 存在しない場合は勝敗チェック
      return State.WinLoseCheck;
    }
  }

  function _procDamageExec():State {

    if(Shot.count() > 0) {
      // 演出完了待ち
      return State.None;
    }

    var nEraseBlock:Int = _nDamageBlock; // 消滅したブロック数
    var v:Int = 0;  // 最終的なダメージ値
    var d:Int = 30; // 基準
    for(i in 0...nEraseBlock) {
      v += d;
      d = Math.floor(d / 2);
      d = FlxMath.maxInt(d, 5); // 5ダメージが下限
    }

    // TODO: プレイヤーにダメージを与える
    _player.damage(v);
    _player.addAp(1);

    return State.WinLoseCheck;
  }

  function _procWinLoseCheck():State {

    if(Block.isIdleAll() == false) {
      // ブロック消去中
      return State.None;
    }

    if(false) {
      // TODO: プレイヤー死亡
      return State.Lose;
    }
    if(_enemy.isDead()) {
      // 敵死亡
      _enemy.vanish();
      _player.addAp(2);
      return State.Win;
    }
    if(_bKeepOnChain) {
      // 連鎖あり
      // 落下処理
      Field.fall();
      return State.FallBlock;
    }

    // プレイヤーのターン終了
    // 敵の行動
    return State.EnemyAIExec;
  }

  function _procEnemyAIExec():State {
    if(_enemy.canAttack) {
      // AI実行
      _enemy.execAI(_requestBlock);
      // 攻撃アニメーション再生
      _enemy.beginAttack();
    }

    switch(_requestBlock.type) {
      case RequestBlock.Upper:
        // 上から降らす
        _requestBlock.execute();
        Field.fall();
        return State.FallBlock;

      case RequestBlock.Bottom:
        // 下からせり上げ
        _requestBlock.execute();
        return State.FallBlock;

      case RequestBlock.None:
        // 要求なし
        return State.AppearBlock;
    }
  }

  function _procWin():State {
    if(_enemy.visible) {
      // 敵消滅待ち
      return State.None;
    }

    // TODO: 次の敵出現
    _enemy.appear(EnemiesKind.Snake);

    // 落下開始
    Field.fall();
    return State.FallBlock;
  }

  function _procLose():State {
    return State.None;
  }

  function _procGameOver():State {
    return State.None;
  }

  function _procStageClear():State {
    return State.None;
  }

  function _procEnd():State {
    return State.None;
  }

  /**
   * 更新
   **/
  public function proc():Int {

    var ret = RET_NONE;
    var tbl = [
      State.Init              => _procInit,       // 初期化

      State.AppearBlock       => _procAppearBlock,       // ブロック出現
      State.InputKey          => _procInputKey,          // 落下場所選択
      State.FallBlock         => _procFallBlock,         // ブロック落下
      // ブロック消滅
      State.EraseCheck        => _procEraseCheck,        // チェック
      State.EraseExec         => _procEraseExec,         // 実行
      // ダメージ
      State.DamageCheck       => _procDamageCheck,       // チェック
      State.DamageExec        => _procDamageExec,        // 実行

      State.WinLoseCheck      => _procWinLoseCheck,      // 勝利・敗北判定
      State.EnemyAIExec       => _procEnemyAIExec,       // 敵のAI実行

      State.Win               => _procWin,               // 勝利演出
      State.Lose              => _procLose,              // 敗北演出
      State.GameOver          => _procGameOver,          // ゲームオーバー

      State.StageClear        => _procStageClear,        // ステージクリア

      State.End               => _procEnd,               // おしまい

    ];

    var next = tbl[_state]();
    if(next != State.None) {
      // 状態遷移
      _change(next);
    }

    return RET_NONE;
  }
}
