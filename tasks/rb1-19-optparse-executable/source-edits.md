# 原典との差分 — rb1-19-optparse-executable

教材がこの手本に加えた編集の記録。**学習者向けの文書ではない**——読み手は教材を検品する側と、
後で教材を直す側。学習のための解説は `commentary.md` にある。

根幹 §7「課題化の編集として認めるもの」が、認めた編集をすべてここに書くことを義務づけている。

## 教材がこの手本に加えた編集


底本は、公式リファレンスの OptionParser のチュートリアルと OptionParser の項、
および公式入門「Ruby in Twenty Minutes」第 4 部。加えた編集は次のとおり。

1. **チュートリアルの複数の節の例を 1 ファイルに連結した。** `parser.on("-x", "--xxx", ...)` /
   `"-yYYY"` / `"-z [ZZZ]"` の 3 つの書き分けと `into:`、`banner=`、`help`、
   `OptionParser::InvalidOption` は、いずれもチュートリアルと OptionParser の項の例である。
2. **`"-n NAME", "--name NAME"` は短い名前と長い名前の両方にダミーの語を付けてある。**
   チュートリアルは「引数が要ることはダミーの語で示す」と説明しており、
   短い側だけに付けた例も長い側だけに付けた例も載っている。教材は両側に付けた形を採った。
3. **起動処理は `if __FILE__ == $0 ... end` で囲ってある。** 「Ruby in Twenty Minutes」第 4 部が
   「This allows a file to be used as a library, and not to execute code in that context」として
   示す形。`require` されたときにオプションの解析まで走らないようにするためである。
4. **実行権限とファイルの起動を確かめる部分は教材が書いた。** `Dir.mktmpdir` / `FileUtils.chmod` /
   `File.executable?` / `IO.popen` は底本に無く、shebang と実行権限が実際に効くことを
   テストとして確かめるために足したもの。出典は原本の冒頭コメントに並べてある。
