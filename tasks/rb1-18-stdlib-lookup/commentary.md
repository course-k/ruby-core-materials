# 模範解説 — rb1-18-stdlib-lookup

`why.md` を自分の言葉で書き終えてから読む。

## 読み解き

- `require "json"` は通るのに `require "csv"` は `Gemfile` に書かないと通らない。
  Ruby に同梱される gem には 2 種類あり、`json` のような **default gem** は
  `Gemfile` を使うプログラムからもそのまま `require` できるが、`csv` と `logger` のような
  **bundled gem** は「同梱はされているが、Bundler から見れば普通の gem」なので
  `Gemfile` に書かないと読み込めない。`minitest` も bundled gem で、課題 1 の `Gemfile` に
  最初から入っていたのはこの理由。
- `JSON.parse(json)` — JSON の配列は Ruby の Array に、`null` は `nil` に、`2.0e2` は `200.0` になる。
  戻り値の Hash のキーは**既定で文字列**。`JSON.parse(source, { symbolize_names: true })` を渡すと
  Symbol キーになる。公式ドキュメントは `symbolize_names` を
  「specifies whether returned Hash keys should be Symbols; defaults to false」と書く。
- `JSON.generate(ruby)` — 逆向き。空白を入れない 1 行の JSON を返す。
  人が読む形にしたいときは `JSON.pretty_generate`（手順 8 で自分で引く対象）。
- `Time.new(2000, 12, 31, 23, 59, 59)` — 年・月・日・時・分・秒を順に渡して作る。
  `year` / `month` / `mday` / `hour` / `min` / `sec` で部分を取り出せる。
  `strftime("%a %b %e %T %Y")` は公式ドキュメントが `ctime`（= `asctime`）の書式として
  挙げているもの。`to_s` のほうは `"2000-12-31 23:59:59 +0900"` の形である。
- `ERB.new(template).result(binding)` — `<%= %>` の中の式を評価して差し込む。
  `binding` は「いまこの場所で見えているローカル変数とその値」をオブジェクトにしたもので、
  これを渡さないとテンプレート側から `magic_word` が見えない。
  公式ドキュメントの 2 つ目の例（`Date::DAYNAMES` を使うもの）が `binding` 無しで動くのは、
  参照しているのがローカル変数ではなく定数だから。`<%# %>` はコメントタグで、結果から丸ごと消える。
- `CSV.parse(string)` — 文字列全体を「配列の配列」にする。値はすべて String
  （`"0"` であって `0` ではない）。`CSV.parse_line` は先頭 1 行だけ。
  `CSV.generate { |csv| csv << [...] }` はブロックに渡された CSV オブジェクトへ行を push して
  文字列を組み立てる。`<<` が自分自身を返すので `csv << a << b` と続けられる。
- `CSV.parse(..., headers: true)` — 戻り値の型が Array から `CSV::Table` に変わる。
  各行は `CSV::Row` になり、`to_h` で列名をキーにした Hash が取れる。
  「オプション 1 つで戻り値の型が変わる」のは Ruby の標準ライブラリでは珍しくない形で、
  公式ドキュメントの戻り値の記述を読む癖がここで要る。
- `Logger.new(device, level: Logger::WARN)` — 第 1 引数は書き出し先で、ファイル名でも
  `$stdout` でも、手本のように `StringIO`（メモリ上の書き出し先）でもよい。
  `level:` より低い severity の記録は**書かれずに捨てられる**。だから `logger.info(...)` の行は
  出力に現れない。`logger.info?` が偽になるのも同じ理由。
- `logger.formatter = proc { |severity, _time, progname, msg| ... }` — 1 行の書式を自分で決める。
  proc が受け取る 4 つは公式ドキュメントの並びどおり（severity / time / progname / msg）。
  既定の書式は時刻とプロセス ID を含むので、テストで文字列を突き合わせるなら差し替えるのが定石。
  `logger.add(Logger::ERROR, "...", "mung")` の第 3 引数が progname にあたる。

## JS ではこうだが Ruby では

### JSON — 「言語の一部」か「ライブラリ」か

JS の `JSON` は言語に組み込まれたグローバルオブジェクトで、`JSON.parse` / `JSON.stringify` が
そのまま使える（MDN）。Ruby は `require "json"` が要る。名前も
`JSON.generate` ↔ `JSON.stringify`、`JSON.parse` ↔ `JSON.parse` と半分ずれている。
挙動の差で効くのは**キーの型**で、JS ではオブジェクトのキーは常に文字列なので迷う余地が無いが、
Ruby には String と Symbol の 2 つがあるため `symbolize_names` という選択が生まれる。
なお MDN は「JSON は JavaScript のオブジェクトリテラルとは別物」と注意しており
（文字列は二重引用符のみ、`undefined` もコメントも無い）、この点は Ruby から見ても同じ。

### Time と Date — 月の数え方が違う

MDN は `Date` を「milliseconds since the midnight at the beginning of January 1, 1970, UTC」を
包んだものと説明し、`getMonth()` は「Returns the month (0 – 11)」と書く。**JS の月は 0 始まり**で、
1 月が `0`。Ruby の `Time#month` は 1 始まりで、`Time.new(2000, 12, ...)` の 12 はそのまま 12 月。
JS 経験者が最初に踏む差はここ。
書式化も違い、JS には `strftime` が無く、`toISOString()` か `Intl.DateTimeFormat` を使う。
Ruby の `strftime` は書式指定子（`%Y` `%m` `%d` `%F` `%T` …）を並べて自分で形を決める。

### CSV と Logger に相当するものは標準に無い

JS / Node.js の標準には CSV パーサも構造化ロガーも無く、npm の `csv-parse` や `pino` を入れる。
Ruby はどちらも同梱されている（ただし bundled gem なので `Gemfile` に書く）。
「標準に何が入っているか」の線引きが言語ごとに違うこと自体が、この課題で見ておくところ。

### テンプレート

JS のテンプレートリテラル（`` `The magic word is ${magicWord}.` ``）は**コードの中に書く**もので、
実行時に外から文字列を受け取って埋め込むことはできない。ERB は逆で、テンプレートは実行時の文字列
（ファイルから読んでもよい）で、`binding` を渡してその場の変数を見せる。
JS で同じことをするなら、テンプレートエンジンを入れるか `new Function` を使うことになる。

## 底本の URL

- https://docs.ruby-lang.org/en/4.0/JSON.html
- https://docs.ruby-lang.org/en/4.0/Time.html
- https://docs.ruby-lang.org/en/4.0/ERB.html
- https://github.com/ruby/csv/tree/v3.3.5 （README.md と lib/csv.rb 冒頭の解説）
- https://github.com/ruby/logger/tree/v1.7.0 （README.md と lib/logger.rb 冒頭の解説）
- https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/JSON
- https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Date
