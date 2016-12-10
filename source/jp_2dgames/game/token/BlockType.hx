package jp_2dgames.game.token;

import jp_2dgames.game.block.BlockSpecial;

/**
 * ブロック種別
 **/
enum BlockType {
  Normal(number:Int); // 通常ブロック
  Number(number:Int, hp:Int); // 通常ブロックHP指定バージョン
  Newer(number:Int); // 新しく配置したブロック
  Skull(lv:Int, ext:Int); // ドクロブロック
  Special(type:BlockSpecial); // スペシャルブロック
}
