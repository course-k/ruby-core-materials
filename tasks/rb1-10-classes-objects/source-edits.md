# 原典との差分 — rb1-10-classes-objects

教材がこの手本に加えた編集の記録。**学習者向けの文書ではない**——読み手は教材を検品する側と、
後で教材を直す側。学習のための解説は `commentary.md` にある。

根幹 §7「課題化の編集として認めるもの」が、認めた編集をすべてここに書くことを義務づけている。

## 教材がこの手本に加えた編集


底本は、公式リファレンスの Modules and Classes（Classes / Defining a class / Inheritance /
Visibility の各節）、Object#inspect、Module#attr_accessor、
および公式入門「Ruby in Twenty Minutes」の第 2・3 部。加えた編集は次のとおり。

1. **クラス名の重複を避けるために改名した。** 原典は継承の例・可視性の例・再オープンの例で
   どれも `A` / `B` / `C` / `D` という名前を使い回している。1 つのファイルに並べると
   後の定義が前を壊すので、可視性の例を `Owner`、再オープンの例を `Reopened`、
   `attr_accessor` の例を `Attrs` に改名した。継承の例（`A` / `B` と定数 `Z`）は原典のままである。
   メソッド名（`z` / `without` / `with_self` / `with_other` / `m`）と本体は変えていない。
2. **`# => ` のコメントを `assert` に置き換えた。** `Foo.new.inspect #=> "#<Foo:0x0300c868>"` は
   アドレスが実行ごとに変わるので、`assert_match` に正規表現を渡す形にした。
3. **`protected` の例は手本から外した。** 原典の Visibility 節には `protected` の例
   （`A` / `B` / `C` の 3 クラス）もあるが、手本の行数の上限に収まらないので落とした。
   内容は下の「読み解き」に引用してある。
4. **`with_renamed` の例を落とした。** 原典の `private` の例は
   `copy = self; copy.m`（`self` を別の変数に入れてから呼ぶと `NoMethodError`）という
   4 つ目のメソッドを持つが、`with_other` と同じことを示すので 1 つにした。
5. **再オープンの例は「Ruby in Twenty Minutes」第 3 部どおり、`attr_accessor` を足すだけにした。**
   クラスメソッドは底本を Modules and Classes の Singleton Classes 節へ移し、
   その節の `class C / class << self` と `def my_method / 1 + 1` をつないで原文の形で載せている。
   `to_s` は上書きせず、Object の既定の `to_s`（クラス名とオブジェクト id の符号を出す）を
   `inspect` と同じテストで確かめる形にした。
