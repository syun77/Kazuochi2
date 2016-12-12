package jp_2dgames.game.token;

import jp_2dgames.lib.MyColor;
import flixel.text.FlxText;
import flixel.FlxSprite;
import jp_2dgames.game.block.BlockSpecial;
import flixel.math.FlxPoint;
import jp_2dgames.lib.DirUtil;
import flash.display.BlendMode;
import flixel.FlxG;
import flixel.util.FlxColor;
import jp_2dgames.game.particle.Particle;
import jp_2dgames.game.block.BlockUtil;
import jp_2dgames.game.field.Field;
import flixel.effects.FlxFlicker;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;

/**
 * 状態
 **/
private enum State {
  Idle;      // 待機中
  Fall;      // 落下中
  Flicker;   // 点滅中
  Slide;     // スライド移動中
  CountDown; // カウントダウン中
}

/**
 * ブロック
 **/
class Block extends Token {

  // ===============================================
  // ■定数
  public static inline var WIDTH:Int = 40;
  public static inline var HEIGHT:Int = 40;

  public static inline var SPECIAL:Int = 10; // スペシャルブロック
  public static inline var HARD:Int    = 11; // 固いブロック
  public static inline var SKULL:Int   = 12; // ドクロ

  static inline var ANIM_HARD_OFS:Int = 10;
  static inline var ANIM_VERYHARD:String = "veryhard";
  static inline var ANIM_SKULL:String = "skull1";
  static inline var ANIM_SKULL2:String = "skull2";
  static inline var ANIM_SPECIAL:String = "special";


  public static var parent:FlxTypedGroup<Block>;
  public static function createParent(state:FlxState):Void {
    parent = new FlxTypedGroup<Block>(Field.GRID_X * Field.GRID_Y);
    for(i in 0...parent.maxSize) {
      var b = new Block();
      b.kill();
      parent.add(b);
    }
    state.add(parent);
    // テキスト登録
    for(b in parent.members) {
      state.add(b.txtCountDown);
    }
  }
  public static function destroyParent():Void {
    parent = null;
  }
  public static function add(xgrid:Int, ygrid:Int, type:BlockType):Block {
    var block:Block = parent.recycle();
    block.init(xgrid, ygrid, type);
    return block;
  }
  public static function addNewer(number:Int, xgrid:Int, ygrid:Int):Block {
    var block:Block = parent.recycle(Block);
    block.init(xgrid, ygrid, BlockType.Newer(number));
    return block;
  }
  public static function addSkull(xgrid:Int, ygrid:Int, lv:Int, ext:Int):Block {
    var block:Block = parent.recycle(Block);
    block.init(xgrid, ygrid, BlockType.Skull(lv, ext));
    return block;
  }
  public static function addSpecial(xgrid:Int, ygrid:Int, type:BlockSpecial):Block {
    var block:Block = parent.recycle(Block);
    block.init(xgrid, ygrid, BlockType.Special(type));
    return block;
  }
  public static function search(xgrid:Int, ygrid:Int):Block {
    return forEachIf(function(block:Block) {
      if(block.xgrid == xgrid && block.ygrid == ygrid) {
        return true;
      }
      return false;
    });
  }
  /**
   * すべて停止しているかどうか
   **/
  public static function isIdleAll():Bool {
    return forEachIf(function(block:Block) {
      return block.isIdle() == false;
    }) == null;
  }
  /**
   * すべて消す
   **/
  public static function killAll():Void {
    forEach(function(b:Block) {
      b.kill();
    });
  }
  /**
   * すべてスライド移動する
   **/
  public static function slideAll(dir:Dir):Void {
    var pt = FlxPoint.get(0, 0);
    DirUtil.move(dir, pt);
    var dx = Std.int(pt.x);
    var dy = Std.int(pt.y);
    forEach(function(b:Block) {
      b.moveSlide(b.xgrid, b.ygrid, b.xgrid+dx, b.ygrid+dy);
    });
  }
  public static function forEach(func:Block->Void):Void {
    parent.forEachExists(func);
  }
  public static function forEachIf(func:Block->Bool):Block {
    for(block in parent.members) {
      if(block.exists) {
        if(func(block)) {
          // 条件に一致した
          return block;
        }
      }
    }
    // 一致しなかった
    return null;
  }

  // ==========================================================
  // ■プロパティ
  public var xgrid(get, never):Int;
  public var ygrid(get, never):Int;
  public var isNewer(get, never):Bool;
  public var isSkull(get, never):Bool;
  public var skullLv(get, never):Int;
  public var number(get, never):Int;
  public var txtCountDown(get, never):FlxText;
  public var countDownVal(get, never):Int;

  // ==========================================================
  // ■フィールド
  var _xgrid:Int;   // グリッド座標(X)
  var _ygrid:Int;   // グリッド座標(Y)
  var _number:Int;  // 数値
  var _hp:Int;      // ブロックの堅さ
  var _state:State; // 状態
  var _bNewer:Bool; // プレイヤーが新しく配置したブロックかどうか
  var _skullLv:Int; // ドクロLv
  var _special:BlockSpecial; // スペシャルブロックの種類
  var _elapsed:Float;
  var _txtCountDown:FlxText; // ドクロ用のカウントダウン数値
  var _countDownVal:Int;     // カウントダウンの値
  var _tAnim:Int = 0;

  /**
   * コンストラクタ
   **/
  public function new() {
    super();

    // 画像読み込み
    loadGraphic(AssetPaths.IMAGE_BLOCK, true, WIDTH, HEIGHT);

    // アニメーションの登録
    _registerAnimations();

    // カウントダウン数値
    _txtCountDown = new FlxText();
    _txtCountDown.setFormat(null, 20, MyColor.WHITE, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    _txtCountDown.kill();
  }

  /**
   * 初期化
   **/
  public function init(xgrid:Int, ygrid:Int, type:BlockType):Void {

    // 変数初期化
    _state  = State.Idle;
    _hp     = BlockUtil.HP_NORMAL;
    color   = FlxColor.WHITE;
    _tAnim  = 0;
    _countDownVal = 0;

    // 座標設定
    _xgrid = xgrid;
    _ygrid = ygrid;
    x = Field.toWorldX(_xgrid);
    y = Field.toWorldY(_ygrid);

    _bNewer = false;
    _skullLv = 0;
    _special = BlockSpecial.None;

    // パラメータデフォルト値
    var number = 0;
    switch(type) {
      case BlockType.Normal(num):
        // 通常ブロック
        number = num;

      case BlockType.Number(num, hp):
        // 通常ブロックHP指定バージョン
        number = num;
        _hp = hp;

      case BlockType.Newer(num):
        // 新しく配置したブロック
        number = num;
        _bNewer = true;

      case BlockType.Skull(lv, ext):
        // ドクロブロック
        _skullLv = lv;
        if(_skullLv == BlockUtil.SKULL_LV2) {
          // Lv2はカウントダウン
          _countDownVal = ext;
          _txtCountDown.revive();
          _updateTextNumber();
        }

      case BlockType.Special(type):
        // スペシャルブロック
        _special = type;
    }
    setNumber(number);

    _elapsed = 0;
  }

  /**
   * スペシャルブロックを設定
   **/
  public function setSpecial(type:BlockSpecial):Void {
    _special = type;
  }

  /**
   * ドクロレベルを設定する
   **/
  public function setSkullLv(lv:Int, ext:Int):Void {
    if(isSkull == false) {
      return;
    }

    if(_skullLv == BlockUtil.SKULL_LV2) {
      // ドクロLv2
      if(ext < _countDownVal) {
        // 現在のカウントダウン値より小さければ演出をする
        var sc = 2;
        _txtCountDown.scale.set(sc, sc);
        _countDownVal = ext;
        if(_countDownVal == 0) {
          // 発車前演出
          var p = Particle.add(ParticleType.CircleReverse, xcenter, ycenter);
          var sc = 3;
          p.scale.set(sc, sc);
          p.color = FlxColor.RED;
        }
        _state = State.CountDown;
        FlxTween.tween(_txtCountDown.scale, {x:1, y:1}, 0.5, {ease:FlxEase.expoOut, onComplete:function(_) {
          _state = State.Idle;
        }});
      }
    }

    _skullLv = lv;
  }

  /**
   * 番号を設定
   **/
  public function setNumber(Number:Int):Void {

    if(_special != BlockSpecial.None) {
      // スペシャルブロック
      animation.play(ANIM_SPECIAL);
      return;
    }

    if(_skullLv > 0) {
      // ドクロブロック
      if(_skullLv == 1) {
        animation.play('skull1');
      }
      else {
        animation.play('skull2');
      }
      return;
    }

    _number = Number;

    if(_hp == BlockUtil.HP_VERYHARD) {
      // とても固い
      animation.play(ANIM_VERYHARD);
      return;
    }

    var num = Number;
    if(_hp == BlockUtil.HP_HARD) {
      // 固い
      num += ANIM_HARD_OFS;
    }

    if(num == 0) {
      trace(xgrid, ygrid, _number, _skullLv, _hp);
      throw "error";
    }

    animation.play('${num}');
  }

  /**
   * HPを1つ減らす
   **/
  public function damage():Void {
    _hp -= 1;
    if(_hp < 0) {
      _hp = 0;
    }
    else {
      // 破片を散らす
      var deg = FlxG.random.float(360);
      for(i in 0...8) {
        var speed = FlxG.random.int(60, 90);
        var p = Particle.add(ParticleType.Stone, xcenter, ycenter, deg, speed);
        p.acceleration.y = 100;
        p.blend = BlendMode.ALPHA;
        deg += 70 + FlxG.random.float(45);
      }
    }
    setNumber(_number);
  }

  /**
   * スペシャルブロックかどうか
   **/
  function _isSpecial():Bool {
    return _special != BlockSpecial.None;
  }

  /**
   * ドクロのカウントダウン番号を設定する
   **/
  function setSkullNumber(v:Int):Void {
    if(_skullLv == BlockUtil.SKULL_LV2) {
      _countDownVal = v;
    }
  }

  /**
   * 更新
   **/
  override public function update(elapsed:Float):Void {

    color = FlxColor.WHITE;
    _tAnim++;

    switch(_state) {
      case State.Idle:
        if(_isSpecial()) {
          // スペシャルブロックであれば点滅
          color = FlxG.random.color(FlxColor.GRAY, FlxColor.WHITE);
        }
      case State.Fall:
        _updateFall(elapsed);
      case State.Flicker:
      case State.Slide:
      case State.CountDown:
    }

    // テキスト更新
    _updateTextNumber();
  }

  /**
   * 更新・落下
   **/
  function _updateFall(elapsed:Float):Void {

    if(isNewer == false) {
      // 新しく配置したブロックだけ
      return;
    }

    _elapsed += elapsed;

    if(_elapsed > 0.05) {
      _elapsed -= 0.05;
      var p = Particle.add(ParticleType.Rect, xcenter, ycenter);
      p.color = FlxColor.RED;
    }
  }


  /**
   * 移動する
   **/
  public function move(xgrid:Int, ygrid:Int, cntDelay:Int):Void {

    if(_xgrid == xgrid && _ygrid == ygrid) {
      // 同じ位置なので落下不要
      return;
    }

    var dy = ygrid - _ygrid;

    _xgrid = xgrid;
    _ygrid = ygrid;

    // 落下中
    _state = State.Fall;
    _elapsed = 0;
    var xnext = Field.toWorldX(_xgrid);
    var ynext = Field.toWorldY(_ygrid);

    var speed = 0.1 + dy * 0.05;
    var delay = 0.025 * cntDelay;

    FlxTween.tween(this, {x:xnext, y:ynext}, speed, {ease:FlxEase.quadIn, startDelay:delay, onComplete:function(_) {
      // 移動完了
      _state = State.Idle;
      // 着地演出
      for(i in 0...4) {
        var px = FlxG.random.float(left, right);
        var angle = FlxG.random.float(-60, 60) + 90;
        var speed = FlxG.random.float(50, 100);
        var p = Particle.add(ParticleType.Ball, px, bottom, angle, speed);
        p.drag.x = 50;
        p.acceleration.y = 50;
        var sc = 0.5;
        p.scale.set(sc, sc);
      }
      _bNewer = false;
    }});
  }

  /**
   * 移動する（ウェイトなし）
   **/
  public function moveNoWait(xgrid:Int, ygrid:Int):Void {
    _xgrid = xgrid;
    _ygrid = ygrid;

    x = Field.toWorldX(_xgrid);
    y = Field.toWorldY(_ygrid);
  }

  /**
   * スライド移動
   **/
  public function moveSlide(fromX:Int, fromY:Int, toX:Int, toY:Int, bFade:Bool=false):Void {

    _state = State.Slide;

    // まずは移動元に移動
    moveNoWait(fromX, fromY);

    var xnext = Field.toWorldX(toX);
    var ynext = Field.toWorldY(toY);

    var speed = 0.3;

    if(bFade) {
      // フェードあり
      alpha = 0;
    }
    FlxTween.tween(this, {x:xnext, y:ynext, alpha:1}, speed, {onComplete:function(_) {
      // 移動完了
      _state = State.Idle;
      moveNoWait(toX, toY);
    }});
  }

  /**
   * 待機中かどうか
   **/
  public function isIdle():Bool {
    return _state == State.Idle;
  }

  override public function kill():Void {
    super.kill();
    // テキストも一緒に消す
    _txtCountDown.kill();
  }

  /**
   * 消滅する
   **/
  public function erase():Void {
    _state = State.Flicker;
    var duration = 0.5;
    FlxFlicker.flicker(this, duration, 0.04, true, true, function(_) {
      kill();
    });
  }

  /**
   * ドクロカウンタの更新
   **/
  function _updateTextNumber():Void {
    _txtCountDown.text = '${countDownVal}';
    _txtCountDown.x = x+20;
    _txtCountDown.y = y+12;
    _txtCountDown.color = FlxColor.YELLOW;
    if(countDownVal <= 1) {
      _txtCountDown.color = FlxColor.RED;
    }
    if(_tAnim%32 < 16) {
      _txtCountDown.color = FlxColor.WHITE;
    }
  }

  /**
   * アニメーションの登録
   **/
  function _registerAnimations():Void {
    // 数字
    for(i in 0...9) {
      animation.add('${i+1}',  [i]);
      // 固いブロック
      animation.add('${i+1+ANIM_HARD_OFS}', [12 + i]);
    }
    // とても固いブロック
    animation.add(ANIM_VERYHARD, [10]);
    // ドクロ
    animation.add(ANIM_SKULL, [11]);
    // ドクロLv2
    animation.add(ANIM_SKULL2, [23]);
    // スペシャル
    animation.add(ANIM_SPECIAL, [9]);
  }

  // ======================================================================
  // ■アクセサ
  function get_xgrid()       { return _xgrid; }
  function get_ygrid()       { return _ygrid; }
  function get_isNewer()     { return _bNewer; }
  function get_isSkull()     { return _skullLv > 0; }
  function get_skullLv()     { return _skullLv;}
  function get_number()      { return _number; }
  function get_txtCountDown(){ return _txtCountDown; }
  function get_countDownVal(){ return _countDownVal; }
}
