package jp_2dgames.game.token;

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
  Idle;    // 待機中
  Fall;    // 落下中
  Flicker; // 点滅中
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
  static inline var ANIM_SKULL:String = "skull";


  public static var parent:FlxTypedGroup<Block>;
  public static function createParent(state:FlxState):Void {
    parent = new FlxTypedGroup<Block>();
    state.add(parent);
  }
  public static function destroyParent():Void {
    parent = null;
  }
  public static function add(number:Int, xgrid:Int, ygrid:Int, hp:Int=BlockUtil.HP_NORMAL):Block {
    var block:Block = parent.recycle(Block);
    block.init(number, xgrid, ygrid, hp);
    return block;
  }
  public static function addNewer(number:Int, xgrid:Int, ygrid:Int):Block {
    var block:Block = parent.recycle(Block);
    block.init(number, xgrid, ygrid, BlockUtil.HP_NORMAL, true);
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

  // ==========================================================
  // ■フィールド
  var _xgrid:Int;   // グリッド座標(X)
  var _ygrid:Int;   // グリッド座標(Y)
  var _number:Int;  // 数値
  var _hp:Int;      // ブロックの堅さ
  var _state:State; // 状態
  var _bNewer:Bool; // プレイヤーが新しく配置したブロックかどうか
  var _elapsed:Float;

  /**
   * コンストラクタ
   **/
  public function new() {
    super();

    // 画像読み込み
    loadGraphic(AssetPaths.IMAGE_BLOCK, true, WIDTH, HEIGHT);
    for(i in 0...9) {
      animation.add('${i+1}',  [i]);
      animation.add('${i+1+ANIM_HARD_OFS}', [12 + i]);
    }
    animation.add(ANIM_VERYHARD, [11]);
    animation.add(ANIM_SKULL, [12]);
  }

  /**
   * 初期化
   **/
  public function init(number:Int, xgrid:Int, ygrid:Int, hp:Int=BlockUtil.HP_NORMAL, bNewer:Bool=false):Void {
    _state = State.Idle;
    _hp = hp;
    setNumber(number);

    _xgrid = xgrid;
    _ygrid = ygrid;
    x = Field.toWorldX(_xgrid);
    y = Field.toWorldY(_ygrid);
    _bNewer = bNewer;
    _elapsed = 0;
  }

  /**
   * 番号を設定
   **/
  public function setNumber(Number:Int):Void {

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
        p.acceleration.y = 200;
        p.blend = BlendMode.ALPHA;
        deg += 70 + FlxG.random.float(45);
      }
    }
    setNumber(_number);
  }

  /**
   * 更新
   **/
  override public function update(elapsed:Float):Void {
    switch(_state) {
      case State.Idle:
      case State.Fall:
        _updateFall(elapsed);
      case State.Flicker:
    }
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
      var p = Particle.add(ParticleType.Rect, xcenter, ycenter, 0, 0);
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
   * 待機中かどうか
   **/
  public function isIdle():Bool {
    return _state == State.Idle;
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

  // ======================================================================
  // ■アクセサ
  function get_xgrid()   { return _xgrid; }
  function get_ygrid()   { return _ygrid; }
  function get_isNewer() { return _bNewer; }
}
