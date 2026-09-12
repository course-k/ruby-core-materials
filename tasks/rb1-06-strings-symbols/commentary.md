# 模範解説 — rb1-06-strings-symbols

`why.md` を書き終えてから開く。

## 原典との差分（教材がこの手本に加えた編集）

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

## 読み解き

### 二重引用符と単一引用符

二重引用符の中でだけ `#{ }` の式展開とエスケープ列（`\n` など）が働く。
単一引用符の中では `\'` と `\\` 以外はそのままの文字になる。
`'#{1 + 1}'` は 6 文字の文字列であって、`2` ではない。

`"con" "cat" "en"` のように文字列リテラルを並べて書くと、**構文解析のときに**連結される。
`+` を使った実行時の連結とは違い、コストがかからない。

### `%w[...]`

空白区切りで文字列の配列を作る書き方。`["ada", "grace", "linus"]` と同じ。
引用符とカンマを打たずに済むので、単語の並びにはこちらを使うのが通例。

### `# frozen_string_literal: true`

ファイルの先頭に置く「マジックコメント」で、**そのファイルの中の**文字列リテラルを
解析時に 1 度だけ作って凍らせる。効果は 3 つある。

1. 同じ内容のリテラルが同じオブジェクトを指すようになる（メモリと生成コストが減る）。
2. リテラルを書き換えようとすると `FrozenError` になる。
3. 「この文字列は後から書き換えない」という意図がファイル全体に宣言される。

この学習計画では全ファイルの先頭にこれを置く（教材の RuboCop 設定が
`Style/FrozenStringLiteralComment` を有効にしているので、無いと書式検査で落ちる）。

書き換えたい文字列が要るときは、凍っていないものを作る。

- `+"..."` … 単項の `+`。凍ったリテラルの凍っていない複製を返す。
- `"...".dup` … 複製を返す。
- `String.new` … 新しい文字列を作る。

### String は書き換えられる

`buffer << "abc"` は `buffer` **そのもの**を伸ばす。`buffer.upcase!` は `buffer` そのものを
大文字にする。一方 `"ruby".upcase` は新しい文字列を返し、元は変わらない。

末尾の `!` は「危険」を意味する慣習で、多くの場合「受け手そのものを書き換える」ことを表す。
Ruby の標準ライブラリでは、`!` の付くメソッドにはたいてい `!` の付かない対応物がある。

### Symbol は「識別子」

`:george` は名前そのものを表すオブジェクトで、プログラムの実行中ずっと**同じオブジェクト**である。

```ruby
:george.object_id == :george.object_id        # => true
"george".dup.object_id == "george".dup.object_id  # => false
```

使い分けの基準は公式サイトの言い方が分かりやすい——
「大事なのはオブジェクトの**同一性**か（Hash のキーなど）、それとも**内容**か」。

- Hash のキー、メソッド名の参照、状態の名前（`:pending` / `:done`）→ Symbol
- 人が読むテキスト、外から来たデータ、組み立てる文字列 → String

`:name.to_s` と `"name".to_sym` で相互に変換できる。

### Hash の Symbol キー記法

`{ a: 1, b: 2 }` は `{ :a => 1, :b => 2 }` の短い書き方。
キーは Symbol なので、`h["a"]` では取り出せない（`nil` が返る）。
この記法はキーワード引数の書き方と同じ形をしている（課題 8 で扱う）。

### エンコーディング

文字列は「バイトの並び」と「それをどの文字集合として読むか（エンコーディング）」の組である。

- 文字列リテラルの既定のエンコーディングは**スクリプトのエンコーディング**で、既定は UTF-8。
- `force_encoding` は**解釈だけ**を変える。バイトは 1 つも変わらない。
- `encode` は**中身を変換する**。別のエンコーディングのバイト列を作る。
- `valid_encoding?` は、いまのエンコーディングとして正しいバイト並びかを返す。
- `ascii_only?` は、すべてのバイトが 7 ビット（US-ASCII の範囲）かを返す。

外から読んだデータで文字化けしたときに疑う順序は「バイトは正しいか（`valid_encoding?`）→
解釈が間違っているだけか（`force_encoding` で直る）→ 本当に変換が要るか（`encode`）」である。

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
