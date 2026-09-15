# 模範解説 — rb1-18-stdlib-lookup

`why.md` の §1〜§3 を書き終えてから開く。読み終えたら §4「突き合わせで変わったこと」を書く。

この解説は **前の節で分かったことの上に次の節が乗る順序**で並べてある。
§2（gem の別）が分かっていないと、そもそも §3 以降の `require` が通りません。飛ばさずに読む。

## 1. この課題は何を練習しているか

**この課題だけ狙いが違います。** ここまでの課題は「Ruby の言語そのもの」でしたが、
これは**公式ドキュメントを引いて知らないライブラリを使う**練習です。

だから 4 つのライブラリが並んでいますが、**全部を覚えるための課題ではありません。**
覚えるのは「引き方」のほうです。

| 段 | 主題 |
|---|---|
| §2 | そもそも `require` が通る条件（**default gem と bundled gem**） |
| §3 | データを読み書きする — JSON と CSV |
| §4 | テキストを組み立てる — ERB と Time |
| §5 | 動きを記録する — Logger |

## 2. まず `require` が通る条件 — 2 種類の同梱 gem

手本の冒頭 4 行がいきなり躓きどころです。

```ruby
require "json"
require "csv"
require "erb"
require "logger"
```

**`json` は `Gemfile` に書かなくても通りますが、`csv` と `logger` は書かないと通りません。**

> **Default gems** are shipped with Ruby releases and also available as rubygems.
> Default gems are not uninstallable from the Ruby installation.
> **Bundled gems** ... They can be uninstalled from the Ruby installation.
> **They need to be declared in a Gemfile when used with bundler.**
> — https://docs.ruby-lang.org/en/4.0/standard_library_md.html

実測で分類できます。

```ruby
Gem::Specification.find_by_name("json").default_gem?      #=> true    default gem
Gem::Specification.find_by_name("csv").default_gem?       #=> false   bundled gem
Gem::Specification.find_by_name("logger").default_gem?    #=> false   bundled gem
Gem::Specification.find_by_name("minitest").default_gem?  #=> false   bundled gem
```

**`minitest` が課題 1 の `Gemfile` に最初から入っていたのは、これが理由**です。
「Ruby に入っている」と「Bundler から見える」は別の話。

**ここまでで分かったこと**: `require` が通る条件。ここから 4 つのライブラリを見ます。

## 3. データを読み書きする — JSON と CSV

**JSON。** 引っかかるのはキーの型です。

> Option `symbolize_names` (boolean) specifies whether returned Hash keys should be Symbols;
> defaults to `false` (use Strings).
> — https://docs.ruby-lang.org/en/4.0/JSON.html

実測: `JSON.parse('{"a":1}')` は `{"a" => 1}`、`symbolize_names: true` では `{a: 1}`。

**既定が文字列なのには理由があります。** JSON のキーは任意の文字列でありえます。一方
Symbol は一度作ると実行中ずっと残る（課題 6 §4）。**外から来た未知のキーを無条件に Symbol に
するのは危うい**——だから既定は安全側です。自分が形を知っている JSON にだけ
`symbolize_names: true` を使う。

逆向きは `JSON.generate`。

> To generate a Ruby String containing JSON data, use method `JSON.generate(source, opts)`,
> where `source` is a Ruby object.

空白を入れない 1 行の JSON を返します（人が読む形は `JSON.pretty_generate`）。

**CSV。** こちらは**オプション 1 つで戻り値の型が変わります**。

> Parsing methods commonly return either of:
> - An Array of Arrays of Strings: The outer Array is the entire "table". Each inner Array is
>   a row. Each String is a field.
> - **A CSV::Table object.** For details, see CSV with Headers.
> — csv v3.3.5 の lib/csv.rb

実測:

```ruby
CSV.parse("a,b\n1,2\n")                #=> [["a","b"],["1","2"]]    Array の Array
CSV.parse("a,b\n1,2\n", headers: true) #=> CSV::Table
  .first                                 #=> CSV::Row
  .first["a"]                            #=> "1"                      列名で引ける
```

**利点は列名で引けること、面倒は後段の書き方が変わること。** 値はどちらも String
（`"1"` であって `1` ではない）。

`CSV.generate { |csv| csv << [...] }` はブロックに渡された CSV オブジェクトへ行を push して
文字列を組み立てます。`<<` が自分自身を返すので `csv << a << b` と続けられる。

**「オプション 1 つで戻り値の型が変わる」のは Ruby の標準ライブラリでは珍しくない形です。
公式ドキュメントの戻り値の記述を読む癖が、ここで要ります。**

**ここまでで分かったこと**: 読み書きの 2 つ。次は組み立てる側。

## 4. テキストを組み立てる — ERB と Time

**ERB の山場は `binding` です。**

```ruby
def filled_template(magic_word)
  template = "The magic word is <%= magic_word %>."
  ERB.new(template).result(binding)
end
```

> The binding object provides the bindings for expressions in expression tags.
> （引数を省くと）the one returned by method `new_toplevel`. This binding has the bindings
> defined by Ruby itself, which are those for Ruby's constants and variables.
> — https://docs.ruby-lang.org/en/4.0/ERB.html

**`binding` は「いまこの場所で見えているローカル変数とその値」をオブジェクトにしたもの**です。
渡さないとテンプレート側から `magic_word` が見えません。実測:

```
result(binding)  → "The magic word is abracadabra."
result           → NameError — undefined local variable or method 'magic_word' for main
```

（公式ドキュメントの別の例が `binding` 無しで動くのは、参照しているのがローカル変数ではなく
**定数**だからです。）

コメントタグは書き方が厳密です。

> You can embed a comment in a template using a _comment tag_; its syntax is `<%# text %>`.
> **Note that the beginning of the tag must be `'<%#'`, not `'<% #'`.**

実測: `"Some stuff;<%# Note %> more stuff."` の結果は `"Some stuff; more stuff."`——丸ごと消えます。

**Time。**

> strftime: Returns a string representation of `self`, formatted according to the given
> string `format`.
> — https://docs.ruby-lang.org/en/4.0/Time.html

実測: `Time.new(2024,12,31,23,59,59).strftime("%a %b %e %T %Y")` は
`"Tue Dec 31 23:59:59 2024"`。`to_s` のほうは `"2024-12-31 23:59:59 +0900"` の形です。

**ここまでで分かったこと**: 組み立てる 2 つ。最後に、動きを記録する側。

## 5. 動きを記録する — Logger

```ruby
logger = Logger.new(device, level: Logger::WARN)
```

第 1 引数は書き出し先で、ファイル名でも `$stdout` でも、手本のように `StringIO`
（メモリ上の書き出し先）でもよい。

> The log level setting determines whether an entry is actually written to the log,
> based on the entry's severity.
> info?: Returns `true` if the log level allows entries with severity Logger::INFO to be
> written, `false` otherwise.
> — logger v1.7.0 の lib/logger.rb

**閾値より軽い記録は書かれずに捨てられます。** 実測: `level: Logger::WARN` のとき
`logger.info("ignored")` は出力に現れず、`logger.warn("kept")` だけが残る。
`logger.info?` は `false`、`logger.warn?` は `true`。

**`info?` の使いどころ**は、ログに渡す文字列を作るのが重いときです。捨てられると分かっている
なら、作る前に `info?` で聞けば無駄な計算をせずに済む。

```ruby
logger.formatter = proc { |severity, _time, progname, msg| ... }
```

proc が受け取る 4 つは公式ドキュメントの並びどおり（severity / time / progname / msg）。
既定の書式は時刻とプロセス ID を含むので、**テストで文字列を突き合わせるなら差し替えるのが定石**
です。手本がそうしているのはそのため。

**ここまでで分かったこと**: この課題の全部。`require` が通る条件（§2）→ 読み書き（§3）→
組み立て（§4）→ 記録（§5）。

**この課題で身につけるのは 4 つのライブラリの知識ではなく、「戻り値の型」「既定値」
「オプションで何が変わるか」を公式ドキュメントで確かめる習慣**です。手順 8 で自分で引く対象
（`JSON.pretty_generate` など）が置かれているのはそのためです。

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
