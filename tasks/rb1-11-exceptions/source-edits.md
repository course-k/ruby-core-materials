# 原典との差分 — rb1-11-exceptions

教材がこの手本に加えた編集の記録。**学習者向けの文書ではない**——読み手は教材を検品する側と、
後で教材を直す側。学習のための解説は `commentary.md` にある。

根幹 §7「課題化の編集として認めるもの」が、認めた編集をすべてここに書くことを義務づけている。

## 教材がこの手本に加えた編集


底本は、公式リファレンスの Exceptions ガイド（Rescued Exceptions / Multiple Rescue Clauses /
Capturing the Rescued Exception / Global Variables / Else Clause / Ensure Clause /
Begin-Less Exception Handlers / Re-Raising an Exception / Retrying / Custom Exceptions の各節）と、
Exception Handling の構文の項、Exception の項。加えた編集は次のとおり。

1. **標準出力に出る例は `assert_output` で受け、値になる例はメソッドの戻り値にした。**
   原典の `foo(boom: true)` の例は `puts` で経過を表示するので出力のまま確かめた。
   `1 / 0` を捕まえる例は原典が `puts $!.class` と表示しているところを、
   値を返して `assert_equal` で確かめる形にした。
2. **`retry` の例から `puts` の 3 行だけを落とした。** 原典は 3 回の試行の経過を `puts` で
   表示するが、教材は経過の表示だけを外し、`if (retries += 1) < 3 ... else ... raise end` と
   諦めたときの再送出はそのまま残した。再送出されることは `assert_raises(RuntimeError)` で
   確かめている。
3. **`raise` の再送出の例は原典のコメントごと写した。**
   `# Do needful things (like logging).` と
   `# Raised exception will be ZeroDivisionError, not RuntimeError.` は原文である。
4. **自作例外の定義のセミコロンを展開した。** 原典は
   `class MyException < StandardError; end` の 1 行。教材の書式ではセミコロンが使えないので
   2 行に開いた。
5. **例外階層を確かめる 3 行は教材が書いた。** 原典は「Built-In Exception Class Hierarchy を見よ」と
   参照するだけなので、`<` 演算子で親子関係を確かめる形にした。
