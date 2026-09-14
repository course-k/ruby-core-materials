# 原典との差分 — rb1-08-methods-arguments

教材がこの手本に加えた編集の記録。**学習者向けの文書ではない**——読み手は教材を検品する側と、
後で教材を直す側。学習のための解説は `commentary.md` にある。

根幹 §7「課題化の編集として認めるもの」が、認めた編集をすべてここに書くことを義務づけている。

## 教材がこの手本に加えた編集


底本は、公式リファレンスの Methods（Method Names / Return Values / Arguments の各節）と
Calling Methods（Default Positional Arguments / Keyword Arguments の各節）、
および String の `empty?` / `upcase!` の項。加えた編集は次のとおり。

1. **同名メソッドを別名にした。** 原典は `add_values` という 1 つの名前で
   「既定値つき」「既定値が左の引数を参照する」「可変長」「キーワード」を順に説明している。
   1 つのファイルに同じ名前を並べると後の定義が前を上書きするので、教材は
   `sum_with_default` / `sum_referring_to_earlier` / `fill_in_the_middle` /
   `gather_arguments` / `gather_middle` / `add_keywords` / `require_keywords` /
   `gather_keywords` / `call_the_block` / `yields_once` に分けた。
   シグネチャ（引数の並び）は原典のままである。
2. **`p` で表示していた例を戻り値に直した。** 原典の `gather_arguments` は
   `p arguments` で表示して「prints [1, 2, 3]」と書いている。教材は表示の代わりに
   その値を返して `assert_equal` で確かめた。
3. **`return` を 2 つ続ける例はそのまま写した。** `two_plus_two` の
   `1 + 1 # this expression is never evaluated` は原典のコメントごと残してある。
4. **`?` と `!` の規約は説明文しか無いので、String の実例で確かめた。**
   Methods の Method Names 節は「`?` で終わるメソッドは慣習として真偽を返す」
   「`!` で終わるメソッドは危険であり、多くは受け手そのものを書き換える」と述べているだけなので、
   `"".empty?` と `upcase!` を教材が持ってきた。
