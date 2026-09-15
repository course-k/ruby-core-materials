# 模範解説 — rb1-06-strings-symbols

`why.md` の §1〜§3 を書き終えてから開く。読み終えたら §4「突き合わせで変わったこと」を書く。

この解説は **前の節で分かったことの上に次の節が乗る順序**で並べてある。
§3（凍結）は §2（書き換えられること）が分かって初めて意味を持ち、§4（Symbol）は
§2・§3 との対比で立つ。飛ばさずに読む。

## 1. この手本は何を見せているか

課題 2 で `#{ }` を、課題 2 の 1 行目で `# frozen_string_literal: true` を「何をする行かは
課題 6 で扱う」として素通りした。**その回収がこの手本**です。

文字列について 4 段で進みます。

| 段 | 定義 | 主題 |
|---|---|---|
| §2 | `interpolated` / `not_interpolated` / `adjacent` / `names` | 文字列の**作り方** |
| §2 | `shouted` / `trimmed` / `split_on_commas` / `dashed` ほか | 文字列の**操作**と、書き換わるかどうか |
| §3 | `frozen_literal` / `built_buffer` | **凍結**——書き換えを禁じる |
| §4 | `symbol_to_string` / `string_to_symbol` / `symbol_keyed` | **Symbol**——文字列に似た別物 |

## 2. 文字列の作り方と、書き換えられるということ

引用符の種類で補間の有無が決まります。

> Double-quoted strings allow interpolation of other values using `#{...}`.
> Interpolation may be disabled by escaping the "#" character or using single-quoted strings.
> — https://docs.ruby-lang.org/en/4.0/syntax/literals_rdoc.html

```ruby
"One plus one is two: #{1 + 1}"   # → "One plus one is two: 2"
'#{1 + 1}'                        # → "#{1 + 1}"（文字どおり）
```

JS はバッククォートのテンプレートリテラルで `${}` という**別の記法**に切り替えますが、
Ruby は同じ「文字列」の中で**引用符の種類**が補間の有無を決めます。

リテラルを並べるとつながります。

> Adjacent string literals are automatically concatenated by the interpreter.

```ruby
"con" "cat" "en" "at" "ion"   # → "concatenation"
```

配列にする短い記法もあります。

> You can write an array of strings as whitespace-separated words with `%w`
> (non-interpolable) or `%W` (interpolable).

```ruby
%w[ada grace linus]   # → ["ada", "grace", "linus"]
```

そして操作です。ここに**この課題の要点**があります。

```ruby
"abc".upcase    # → "ABC" を返す。元の "abc" は変わらない
s = +"abc"
s.upcase!       # → s そのものが "ABC" になる
```

> Potentially "dangerous" methods by convention end with exclamation marks
> (e.g. methods that modify `self` or the arguments, `exit!`, etc.)
> — https://www.ruby-lang.org/en/documentation/ruby-from-other-languages/

課題 2 で `?` の命名規約を見ました。**これが `!` の側の実例**です。`!` の付くメソッドは
受け手そのものを書き換え、付かないものは新しい文字列を返す。

**Ruby の文字列は書き換えられる**——これが次の節の前提になります。JS の文字列は不変
（immutable）なので、この前提自体が差です。

**ここまでで分かったこと**: 文字列は作れて、書き換えられる。
次は、その書き換えを**禁じる**仕組み。

## 3. 凍結 — `# frozen_string_literal: true`

§2 で「書き換えられる」と分かった。だから**書き換えを禁じる指定に意味がある**。

> Indicates that string literals should be allocated once at parse time and frozen.
> It must appear in the first comment section of a file.
> — https://docs.ruby-lang.org/en/4.0/syntax/comments_rdoc.html

ファイル先頭に置く**マジックコメント**で、そのファイルの文字列リテラルを解析時に 1 度だけ
作って凍らせます。コメントなのに効くのは、処理系がファイル冒頭のコメント区画だけを
特別に読むためです。

効果を実測で確かめられます。

```ruby
# frozen_string_literal: true
"hello".frozen?        #=> true
"one #{1+1}".frozen?   #=> false   ← 式展開のあるものは動的に作られるので凍らない
"abc" << "d"           #=> FrozenError: can't modify frozen String: "abc"
```

同じ内容のリテラルが**同じオブジェクト**を指すようにもなります。

```ruby
"a".object_id == "a".object_id
# frozen_string_literal 無し → false
# frozen_string_literal 有り → true
```

効果は 3 つ。①生成コストとメモリが減る ②書き換えようとすると `FrozenError` で早く気づく
③「後から書き換えない」という意図がファイル全体に宣言される。

この学習計画では全ファイルの先頭に置きます（教材の RuboCop 設定が
`Style/FrozenStringLiteralComment` を有効にしているので、無いと書式検査で落ちる）。

**では書き換えたい文字列が要るときは。** 手本の `built_buffer` がその形です。

```ruby
buffer = +""      # 単項の + は、凍ったリテラルの凍っていない複製を返す
buffer << "abc"
buffer.upcase!
```

`+"..."` のほか `"...".dup` と `String.new` も使えます。**凍結は既定で、解除は明示**という
向きになっている。

**ここまでで分かったこと**: 文字列は既定で凍り、必要なときだけ解く。
次は、最初から書き換えられない別のもの。

## 4. Symbol は文字列ではなく識別子

`:name` は文字列によく似ていますが、別のクラスの別のものです。

> A Symbol object represents a named identifier inside the Ruby interpreter.
> **The same Symbol object will be created for a given name or string for the duration of a
> program's execution**, regardless of the context or meaning of that name.
> A Symbol object differs from a String object in that a Symbol object represents an
> identifier, while a String object represents text or data.
> — https://docs.ruby-lang.org/en/4.0/Symbol.html

実測で並べると差が見えます。

```ruby
:a.object_id == :a.object_id     #=> true    ← 常に同じオブジェクト
"a".object_id == "a".object_id   #=> false   ← （frozen_string_literal 無しの場合）
```

§3 で見た「凍結すると同じオブジェクトになる」は、**Symbol が最初から持っている性質**です。
Symbol は生まれつき凍っていて、名前が同じなら同じ 1 つ。

使い分けの基準はこうです。

| 用途 | 使うもの |
|---|---|
| Hash のキー、メソッド名の参照、状態の名前（`:pending` / `:done`） | Symbol |
| 人が読むテキスト、外から来たデータ、組み立てる文字列 | String |

**同一性が大事なら Symbol、内容が大事なら String。**

手本の `symbol_keyed` が Hash のキーに Symbol を使っているのはこのためです。

```ruby
{ a: 1, b: 2 }   # { :a => 1, :b => 2 } の短い書き方
```

キーは Symbol なので `h["a"]` では取り出せません（`nil` が返る）。この記法はキーワード引数の
書き方と同じ形をしています（課題 8 で扱う）。

`:name.to_s` と `"name".to_sym` で相互に変換できます。

**ここまでで分かったこと**: この手本の全部。作って操作する（§2）→ 凍結で書き換えを禁じる（§3）
→ 最初から凍っている識別子 Symbol（§4）。

## 5. バイト列とエンコーディング

文字列は「バイトの並び」と「それをどの文字集合として読むか」の**組**です。
`why.md` の問いが聞いている `force_encoding` と `encode` の差は、この組のどちらを変えるかの差。

> encode: Returns a copy of `self` with all characters transcoded from one encoding to another.
> force_encoding: Changes the encoding to a given encoding; returns `self`.
> — https://docs.ruby-lang.org/en/4.0/String.html

実測がいちばん分かりやすい。

```ruby
"あ".bytes                                  #=> [227, 129, 130]
"あ".encode("EUC-JP").bytes                 #=> [164, 162]        ← バイト列が変わった
"あ".dup.force_encoding("ASCII-8BIT").bytes #=> [227, 129, 130]   ← バイト列はそのまま
```

**`encode` は中身を作り直し、`force_encoding` はラベルを貼り替えるだけ。**
文字列リテラルの既定のエンコーディングはスクリプトのエンコーディングで、既定は UTF-8。

外から読んだデータが文字化けしたときに疑う順序は「バイトは正しいか（`valid_encoding?`）→
ラベルが違うだけか（`force_encoding` で直る）→ 本当に変換が要るか（`encode`）」。

## JS ではこうだが Ruby では

### 文字列は書き換えられる

JS の文字列は**不変**である。`str[0] = "X"` は黙って失敗する（strict mode と ES モジュールでは
TypeError になる）。MDN: String「attempting to delete or assign a value to these properties will
not succeed. The properties involved are neither writable nor configurable」。
`toUpperCase()` などはすべて新しい文字列を返す。

Ruby の String は既定では**可変**で、`<<` や `upcase!` は受け手そのものを変える。
これは JS 経験者が最も踏みやすい差である。他人から受け取った文字列を
`gsub!` すると、渡した側の文字列まで変わる。

`# frozen_string_literal: true` は、この差を「JS 側に寄せる」ための宣言だと読める。
リテラルを凍らせておけば、うっかり書き換えたときに `FrozenError` で気づける。

### テンプレートリテラルと式展開

JS はバッククォート + `${}`（MDN: Template literals）。Ruby は二重引用符 + `#{}`。
JS の通常の `'...'` / `"..."` は補間しない。Ruby では**引用符の種類が補間の有無を決める**。

### `Symbol` の意味がまるで違う

JS にも `Symbol` はある（ES2015、MDN: Symbol）が、意味は逆である。

| | JS の `Symbol` | Ruby の Symbol |
|---|---|---|
| 生成 | `Symbol("a")` は**呼ぶたびに別物**（MDN:「Every `Symbol()` call is guaranteed to return a unique Symbol」） | `:a` は名前が同じなら**常に同じオブジェクト** |
| 目的 | 他のコードと衝突しないプロパティキーを作る（弱い隠蔽） | 名前そのものを表す。Hash のキー、メソッド名 |
| 同じ名前で共有する方法 | `Symbol.for("a")`（グローバルレジストリ経由）だけ | 既定でそうなっている |

JS で「オブジェクトのキー」を担うのは普通の文字列である。
Ruby でその役を担うのが Symbol だと読み替えるとよい。
なお JS の `Symbol.for("a") === Symbol.for("a")` は真で、これは Ruby の `:a` の振る舞いに近い。

### エンコーディング

JS の文字列は UTF-16 コード単位の並びと決まっていて、エンコーディングという概念が
文字列オブジェクトに付いていない。バイト列を扱うときは `TextDecoder` / `Uint8Array` を使う。
Ruby は**文字列 1 つ 1 つがエンコーディングを持つ**ので、`force_encoding` のような
「解釈だけを変える」操作が存在する。ここは対応する概念が JS に無い。

## 底本の URL

Ruby 側（一次情報）:

- https://docs.ruby-lang.org/en/4.0/syntax/literals_rdoc.html
- https://docs.ruby-lang.org/en/4.0/syntax/comments_rdoc.html
- https://docs.ruby-lang.org/en/4.0/String.html
- https://docs.ruby-lang.org/en/4.0/Symbol.html
- https://docs.ruby-lang.org/en/4.0/language/encodings_rdoc.html
- https://www.ruby-lang.org/en/documentation/ruby-from-other-languages/

JS 側（MDN）:

- https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/String
- https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Template_literals
- https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Symbol
