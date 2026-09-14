# 原典との差分 — rb1-05-control-flow-io

教材がこの手本に加えた編集の記録。**学習者向けの文書ではない**——読み手は教材を検品する側と、
後で教材を直す側。学習のための解説は `commentary.md` にある。

根幹 §7「課題化の編集として認めるもの」が、認めた編集をすべてここに書くことを義務づけている。

## 教材がこの手本に加えた編集


底本は、公式リファレンスの Control Expressions・Precedence・Calling Methods（Safe Navigation Operator 節）と、
Kernel の `puts` / `warn` / `exit` の項、Object の `ARGV` の項、IO の項、
それに Exceptions ガイドの Begin-Less Exception Handlers 節。加えた編集は次のとおり。

1. **`puts` で表示していた例を「値を返す形」に直した。** Control Expressions の
   `if` / `unless` / `case` の例は `puts` で結果を表示している。教材は
   「`if` 式の値」「`case` 式の値」を確かめたかったので、同じ分岐の各枝が文字列を返す形にして、
   その値を変数に代入した。原典自身が「The result value of an if expression is the last value
   executed in the expression」と書いている性質を使っている。分岐の構造は変えていない。
2. **`warn` の例は Kernel#warn の項の `warn("warning 1", "warning 2")` をそのまま使った。**
   出力が標準エラーへ行くことを確かめるため `assert_output` の第 2 引数で受けた。
3. **`exit` の例は Kernel#exit の項の「`SystemExit` は捕まえられる」という記述に基づく。**
   原典の例は `begin / rescue SystemExit / end` の形。教材はメソッド本体がそのまま
   例外ハンドラになる書き方（Exceptions ガイドの Begin-Less Exception Handlers 節）で書き、
   `SystemExit#status` が引数の値になることを確かめた。
4. **`ARGV` と `$stdin` はテストの中で差し替えている。** 本来この 2 つは端末から呼ばれたときに
   外から与えられるものなので、テストの中では `ARGV.replace(...)` と
   `$stdin = StringIO.new(...)` で値を作り、`ensure` で元に戻している。
   端末から本物の `ARGV` と標準入力を使う手順は README の手順 6 にある。
5. **`&.` の例は Calling Methods の Safe Navigation Operator 節の 2 つの例をつないだ。**
   原典が `# NoMethodError` とコメントで書いている箇所を `assert_raises(NoMethodError)` にした。
   `REGEX` という定数名も原典のまま。
6. **主語なし `case` の例は、Control Expressions の 2 つの例を合成したものである。**
   原典の主語なし `case` の節は `when a == 1, a == 2` と `when a == 3` の 2 枝、
   `else` 節の文言 `"I don't know what a is"` は同じ節の別の例から取っている。
   分岐の構造と各枝の式はいずれも原文のまま。
7. **`and` と `&&` を並べた 2 行（`a = true && false` / `b = true and false`）は教材が書いた。**
   底本の Precedence の項は演算子の優先順位を表として示すだけでコード例を持たない。
   表の「`&&` は代入より強く、`and` は代入より弱い」という記述を、
   2 行のコードと 1 つの `assert_equal` に起こしたもの。

8. **後置 `until` の例は変数名を `a` から `b` に改名した。** 底本（Control Expressions の Modifier until）は
   `a += 1 until a > 10`。同じテストメソッド内で先に `a` を使っているため衝突を避けて `b` にした。
