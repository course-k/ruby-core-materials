# 原典との差分 — rb1-04-values-truth

教材がこの手本に加えた編集の記録。**学習者向けの文書ではない**——読み手は教材を検品する側と、
後で教材を直す側。学習のための解説は `commentary.md` にある。

根幹 §7「課題化の編集として認めるもの」が、認めた編集をすべてここに書くことを義務づけている。

## 教材がこの手本に加えた編集


底本は 3 つ。公式リファレンスの Literals（Boolean and Nil Literals 節）と
Control Expressions、それに公式サイトの「Ruby From Other Languages」の
Everything has a value / The universal truth 節。加えた編集は次のとおり。

1. **minitest の骨格と assert を足した。** 原典は「この式はこの値になる」を散文と
   `# => true` のコメントで書いている。それを `assert_equal` に置き換えた。
2. **`puts` する例を `assert_output` で包んだ。** 原典の The universal truth 節は
   `if 0 … puts "0 is true" … end` を書いて「これは “0 is true” と表示する」と述べている。
   表示の内容を機械で確かめるため、`assert_output("0 is true\n") do … end` で囲んだ。
   囲みの中身は原文のままである。
3. **`values.reject { |value| value }` の 1 行は教材が書いた。** 「`nil` と `false` だけが偽」という
   Literals 節の文を、1 つの式で確かめられる形にしたもの。原典に同じコードは無い。
4. **`case` の例は Control Expressions から 2 つ取った。** `case "12345" / when /^1/` の例と、
   `when 1, 2 then …` の 1 行形式の例。後者は原典が `puts` で書いているものを、
   「`case` 式の値」を確かめるために代入の形にした（Control Expressions が
   「The result value of a case expression is the last value executed in the expression」と
   書いているとおりの性質を使っている）。
