package jp_2dgames.game;

/**
 * 状態
 **/
import jp_2dgames.game.gui.CursorUI;
import jp_2dgames.lib.Input;
import jp_2dgames.game.token.Block;
import flixel.FlxG;
private enum State {

  None;              // 無効

  Init;              // 初期化
  // 下から出現
  AppearBottomCheck; // チェック
  AppearBottomExec;  // 実行

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
  var _nextBlock:Int = 0; // 次に出現するブロックの番号

  /**
   * コンストラクタ
   **/
  public function new() {
    _state = State.Init;
    _statePrev = _state;

    // デバッグ用
    FlxG.watch.add(this, "_state");
    FlxG.watch.add(this, "_statePrev");
  }

  /**
   * 状態遷移
   **/
  function _change(next:State):Void {
    trace('${_state} -> ${next}');
    _statePrev = _state;
    _state = next;
  }

  function _procInit():State {
    // ブロック出現
    return State.AppearBlock;
  }

  function _procAppearBottomCheck():State {
    // せり上げチェック
    return State.AppearBottomExec;
  }

  function _procAppearBottomExec():State {
    // 消滅チェック
    if(false) {
      // 下から出現
      return State.EraseCheck;
    }

    // 出現終わり
    return State.AppearBlock;
  }

  function _procAppearBlock():State {
    // TOOD: 次に出現するブロックを抽選
    _nextBlock = FlxG.random.int(2, 5);
    CursorUI.setNextBlock(_nextBlock);
    return State.InputKey;
  }

  function _procInputKey():State {

    if(Input.touchJustPressed) {
      CursorUI.show();
    }
    if(Input.touchJustReleased) {
      // ブロックを配置
      var block = CursorUI.getBlock();
      CursorUI.hide();
      var layer = Field.getLayer();
      layer.set(block.xgrid, block.ygrid, _nextBlock);
      // 落下開始
      Field.fall();
      return State.FallBlock;
    }

    return State.None;
  }

  function _procFallBlock():State {
    // TODO: 落下処理
    if(Block.isIdleAll() == false) {
      // ブロック落下中
      return State.None;
    }
    return State.EraseCheck;
  }

  function _procEraseCheck():State {
    // 消去処理
    var cntErase = Field.checkErase();
    if(cntErase > 0) {
      // 消去できた
      // 連鎖続行
      _bKeepOnChain = true;
      return State.EraseExec;
    }
    else {
      // ダメージチェックへ
      // 連鎖終了
      _bKeepOnChain = false;
      return State.DamageCheck;
    }
  }

  function _procEraseExec():State {

    if(Block.isIdleAll() == false) {
      // 消滅中
      return State.None;
    }

    // 勝利敗北判定
    return State.WinLoseCheck;
  }

  function _procDamageCheck():State {
    // TODO: ダメージ処理
    return State.DamageExec;
  }

  function _procDamageExec():State {
    // TODO: ダメージ処理
    return State.WinLoseCheck;
  }

  function _procWinLoseCheck():State {
    if(false) {
      // TODO: プレイヤー死亡
      return State.Lose;
    }
    if(false) {
      // TODO: 敵死亡
      return State.Win;
    }
    if(_bKeepOnChain) {
      // TODO: 連鎖あり
      // 落下処理
      Field.fall();
      return State.FallBlock;
    }

    // プレイヤーのターン終了
    // 敵の行動
    return State.EnemyAIExec;
  }

  function _procEnemyAIExec():State {
    // TODO: AI実行
    if(false) {
      // 上から降らす
      return State.FallBlock;
    }
    else if(true) {
      // 下からせり上げ
      return State.AppearBottomCheck;
    }
    else {
      // ブロック出現要求なし
      return State.AppearBlock;
    }
  }

  function _procWin():State {
    return State.None;
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
      // 下から出現
      State.AppearBottomCheck => _procAppearBottomCheck, // チェック
      State.AppearBottomExec  => _procAppearBottomExec,  // 実行

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
