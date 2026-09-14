# 原典との差分 — rb1-06-strings-symbols

教材がこの手本に加えた編集の記録。**学習者向けの文書ではない**——読み手は教材を検品する側と、
後で教材を直す側。学習のための解説は `commentary.md` にある。

根幹 §7「課題化の編集として認めるもの」が、認めた編集をすべてここに書くことを義務づけている。

## 教材がこの手本に加えた編集


底本は、公式リファレンスの Literals・Comments（frozen_string_literal Directive 節）・String・Symbol・
Encodings と、公式サイトの「Ruby From Other Languages」の
Symbols are not lightweight Strings 節。加えた編集は次のとおり。

1. **`# => ` のコメントを `assert_equal` に置き換えた。** 原典は
   `'#{1 + 1}' #=> "\#{1 + 1}"` のように結果をコメントで書いている。
2. **`.dup` を足した箇所がある。** 原典の Symbol の説明は
   `"george".object_id == "george".object_id # => false` を示すが、この手本は
   `# frozen_string_literal: true` を先頭に持つので、同じ内容の文字列リテラルは
   **1 つのオブジェクトに共有される**（Comments の frozen_string_literal Directive 節が
   「string literals should be allocated once at parse time and frozen」と書いているとおり）。
   共有されていては原典の言いたいことが再現できないので、`.dup` で複製を作って比べている。
   同じ理由で、`force_encoding` を呼ぶ文字列にも `.dup` を付けた（凍った文字列は変更できない）。
3. **`+""` は教材が書いた。** 凍っていない空文字列を作る書き方（String の単項 `+`）。
   原典の Encodings 節は `String.new(encoding: ...)` を使っているが、
   ここで見せたいのは「凍っていない文字列は `<<` で伸ばせる」ことなので短い書き方を選んだ。
4. **`assert_raises(FrozenError)` は教材が足した。** 原典は「凍る」とだけ書いていて、
   書き換えたときに何が起きるかは書いていない。
