package;

import jp_2dgames.game.state.BootState;
import flixel.FlxGame;
import openfl.Lib;
import openfl.display.Sprite;

class Main extends Sprite {
  public function new() {
    super();
    addChild(new FlxGame(320, 568, BootState));
  }
}
