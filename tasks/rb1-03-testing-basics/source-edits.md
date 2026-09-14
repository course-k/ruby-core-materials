# 原典との差分 — rb1-03-testing-basics

教材がこの手本に加えた編集の記録。**学習者向けの文書ではない**——読み手は教材を検品する側と、
後で教材を直す側。学習のための解説は `commentary.md` にある。

根幹 §7「課題化の編集として認めるもの」が、認めた編集をすべてここに書くことを義務づけている。

## 教材がこの手本に加えた編集


底本は 2 つある。minitest v6.0.0 の README の "Unit tests" 節（`Meme` と `TestMeme` の例）と、
同じ版の `lib/minitest/assertions.rb`（各 assert の定義と、その上のコメントに書かれた用例）。
教材はこの 2 つをつないで 1 ファイルにした。加えた編集は次のとおり。

1. **assert を足した。** README の例が持っているテストメソッドは
   `test_that_kitty_can_eat` / `test_that_it_will_not_blend` / `test_that_will_be_skipped` の 3 つ。
   残りの 3 メソッド（`test_assert_and_refute_are_about_truthiness` /
   `test_assert_nil_says_what_it_means` / `test_assert_raises_returns_the_exception`）は、
   `assertions.rb` に載っている用例を教材がテストメソッドの形にしたもの。
   とくに `assert_raises` の書き方は `assertions.rb` の `assert_raises` の直上にある用例
   （`error = assert_raises(CustomError) do … end` と `assert_equal 'This is really bad', error.message`）
   をそのまま使っている。
2. **セミコロンを展開した。** 例外クラスの定義は、公式ドキュメントでは
   `class MyException < StandardError; end` と 1 行で書かれている。教材の RuboCop 設定は
   セミコロンを禁じているので、`class CustomError < StandardError` と `end` の 2 行に展開した。
3. **`refute_match` に括弧を付けた。** README は `refute_match /^no/i, @meme.will_it_blend?` と
   書いているが、括弧なしで正規表現リテラルを渡すと Ruby が「ここの `/` は割り算のつもりか」と
   警告を出す。意味を変えずに警告を消すため `refute_match(/^no/i, …)` にした。
4. **クラス名を `CustomError` にした。** 公式ドキュメントの例は `MyException`。
   `assertions.rb` の用例側が `CustomError` なのでそちらに揃えた。
