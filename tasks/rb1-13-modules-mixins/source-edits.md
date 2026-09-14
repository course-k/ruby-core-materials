# 原典との差分 — rb1-13-modules-mixins

教材がこの手本に加えた編集の記録。**学習者向けの文書ではない**——読み手は教材を検品する側と、
後で教材を直す側。学習のための解説は `commentary.md` にある。

根幹 §7「課題化の編集として認めるもの」が、認めた編集をすべてここに書くことを義務づけている。

## 教材がこの手本に加えた編集


底本は、公式リファレンスの Modules and Classes（module / 名前空間 / ネスト / include の各節）、
Comparable の項、Enumerable の項、Object#extend の項。加えた編集は次のとおり。

1. **4 つの節の例を 1 ファイルに連結した。** `Outer::Inner`・`module A` と `include A`・
   `StringSorter`（Comparable）・`Foo`（Enumerable）・`Mod` と `Klass`（extend）は、
   それぞれ別のページの例である。識別子・メソッド本体は原文のまま。
2. **`attr :str` は原文のまま残した。** Comparable の項の例がこの書き方をしている。
   いまは `attr_reader :str` と書くのが普通だが、原文の型を変えないためそのままにしてある
   （この差は「手本の各行がしていること」にも書いてある）。
3. **`# => ` のコメントと `puts` を `assert` に置き換えた。** 原典が
   `s1 < s2 # => true`、`[s3, s2, s5, s4, s1].sort # => [...]` と結果をコメントで示している箇所を、
   `assert_operator` / `assert_equal` に直した。分岐も式も変えていない。
4. **Enumerable の例は `each_entry` で受けた。** 原典の `Foo#each` は `yield 1` / `yield 1, 2` /
   `yield` の 3 通りを投げる例で、それを受けるのが `each_entry` であることも原文の説明にある。
