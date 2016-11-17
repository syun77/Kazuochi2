package jp_2dgames.game.token;


/**
 * ブロック種別
 **/
enum BlockType {
  Normal(number:Int); // 通常ブロック
  Number(number:Int, hp:Int); // 通常ブロックHP指定バージョン
  Newer(number:Int); // 新しく配置したブロック
  Skull; // ドクロブロック
}
