# 原典との差分 — rb1-09-blocks-procs

教材がこの手本に加えた編集の記録。**学習者向けの文書ではない**——読み手は教材を検品する側と、
後で教材を直す側。学習のための解説は `commentary.md` にある。

根幹 §7「課題化の編集として認めるもの」が、認めた編集をすべてここに書くことを義務づけている。

## 教材がこの手本に加えた編集


底本は、公式リファレンスの Proc（クラスの説明・Creation・Lambda and non-lambda semantics・
Conversion of other objects to procs の各節）、Methods の Block Argument 節、
Kernel#block_given? の項。加えた編集は次のとおり。

1. **`# => ` のコメントを `assert_equal` / `assert_raises` に置き換えた。** 原典は
   `l.call(1) # ArgumentError: wrong number of arguments (given 1, expected 2)` の形で
   例外を書いている。
2. **メソッド名を 1 つ変えた。** 原典の「`return` の違い」の例はメソッド名が `test_return` で、
   これを `Minitest::Test` のクラスの外に置いても紛らわしいので
   `returns_from_the_enclosing_method` に改名した（`test_` で始まる名前は minitest が
   テストとして拾うため）。本体のコードとコメントは原典のままである。
3. **`$a = []; def m1(&b) …` の 1 行に詰めた例は採らなかった。** 原典の
   Lambda and non-lambda semantics 節にある `break` / `next` の対照表はセミコロンで
   1 行に詰めて書かれている。教材の書式ではセミコロンが使えず、改行に開くと原文の
   「横に並べて見比べる」意図が崩れるので、この節からは `p` / `l` の引数の対照と
   `test_return` の例だけを採った。`break` / `next` の違いは出力予測（`predict/01.rb`）で扱う。
4. **`lambda?` の呼び出しは教材が足した。** 原典は「`lambda?` で見分けられる」と述べているだけ。
