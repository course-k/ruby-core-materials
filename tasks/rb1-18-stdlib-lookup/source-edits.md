# 原典との差分 — rb1-18-stdlib-lookup

教材がこの手本に加えた編集の記録。**学習者向けの文書ではない**——読み手は教材を検品する側と、
後で教材を直す側。学習のための解説は `commentary.md` にある。

根幹 §7「課題化の編集として認めるもの」が、認めた編集をすべてここに書くことを義務づけている。

## 教材がこの手本に加えた編集


底本は、公式リファレンスの JSON・Time・ERB の各項と、bundled gem の csv 3.3.5・logger 1.7.0 の
リポジトリ（タグ固定）。加えた編集は次のとおり。

1. **5 つのライブラリの例を 1 ファイルに連結した。** 各例の式（`JSON.parse` / `JSON.generate` /
   `symbolize_names` / `Time.new` と部分の取り出し / `strftime` / `ERB.new(...).result(binding)` /
   `CSV.parse` / `CSV.parse_line` / `CSV.generate` / `headers: true` / `Logger.new` と `formatter=`）は
   原文のままである。
2. **`# => ` のコメントを `assert` に置き換えた。**
3. **`CSV.generate` のブロックは底本どおり 1 行 1 文に開いてある。** 底本（csv の Simple Generating）は
   `csv << [...]` を 3 文に分けて書いている。
4. **Logger の出力先を `StringIO` にした。** 原典の例は標準出力やファイルへ書くが、
   テストで内容を確かめるために書き出し先だけを差し替えた。書式（`formatter=` に渡すラムダ）と
   severity の使い方は原文のまま。
