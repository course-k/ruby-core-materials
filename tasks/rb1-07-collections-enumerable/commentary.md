# 模範解説 — rb1-07-collections-enumerable

`why.md` を書き終えてから開く。

## 読み解き

### リテラル

- 配列 `[1, 1 + 1, 1 + 2]` … 要素には任意の式を書ける。入れ子にできる。
- ハッシュ `{ "a" => 1 }` / `{ a: 1 }` … **キーも値も任意のオブジェクト**でよい。
  配列をキーにもできる。
- `{ x:, y: }` … 値を省くと、同じ名前のローカル変数（かメソッド）の値が入る。
- 範囲 `(1..2)` は終端を含み、`(1...2)` は含まない。`(1..)` や `(..1)` のように端を省ける。

### `each` と `map` の戻り値

`each` は**レシーバ自身**を返す。`map` は**ブロックの戻り値を集めた新しい配列**を返す。
だから `each` は連鎖できず（連鎖しても元のコレクションに戻るだけ）、`map` は連鎖できる。

「副作用を起こしたいときは `each`、値を作りたいときは `map`」が使い分けの基準になる。

### 目的別の早見表

| したいこと | メソッド | 返るもの |
|---|---|---|
| 1 つずつ処理する（副作用） | `each` | レシーバ |
| 1 つずつ変換する | `map` | 新しい配列 |
| 条件に合うものを残す | `select` | 新しい配列 |
| 条件に合うものを捨てる | `reject` | 新しい配列 |
| 1 つの値に畳み込む | `reduce` / `inject` | 畳み込んだ値 |
| 入れ物を持ち回りながら組み立てる | `each_with_object` | 渡した入れ物 |
| キーごとにまとめる | `group_by` | キー → 配列 の Hash |
| 出現回数を数える | `tally` | 要素 → 個数 の Hash |
| 並べ替える | `sort_by` | 新しい配列 |
| 重複を除く | `uniq` | 新しい配列 |

`reduce` と `each_with_object` はどちらも「集める」用途だが、ブロックの戻り値の扱いが逆である。

- `reduce` … **ブロックが返した値**が次の回の `result` になる。だから最後の行を間違えると壊れる。
- `each_with_object` … 渡した入れ物がそのまま返る。ブロックの戻り値は無視される。

Hash を組み立てるときは `each_with_object({})` のほうが事故が少ない
（Enumerable の `inject` の項も、Hash を作る例でわざわざ「最後の行が `counts` であることに注意」と
書いている）。

### Hash を回すときのブロック引数

`{ foo: 0 }.map { |key, value| ... }` のように 2 つ受けると、キーと値に分かれる。
`each_with_object` のように「要素とそれ以外」を受けるメソッドでは、
`{ |(k, v), h| ... }` と**括弧で括って**分解する。括弧を忘れると `k` にペアの配列全体が入る。

### `sort_by` と `uniq` のブロック

どちらも「要素そのもの」ではなく「ブロックが返した値」で判断する。

- `sort_by { |s| -s.size }` … 大きい順。
- `uniq { |i| i.even? ? i : 0 }` … ブロックの値が同じものを重複とみなす。

「何を同じとみなすか」を自分で決められるこの形は、課題 14（等価性と値オブジェクト）と
この先の重複排除でそのまま使う。

### ブロックの 2 つの書き方

`{ |x| ... }` と `do |x| ... end` は同じもので、慣習として
1 行なら `{ }`、複数行なら `do ... end` を使う。
（厳密には結合の強さが違うが、この課題の範囲では同じと考えてよい。ブロックそのものは課題 9 で扱う。）

## JS ではこうだが Ruby では

### `forEach` は `undefined`、`each` はレシーバ

JS の `Array.prototype.forEach` は常に `undefined` を返し、連鎖できない
（MDN:「Unlike `map()`, `forEach()` always returns `undefined` and is not chainable」）。
Ruby の `each` はレシーバを返す。どちらも「連鎖しない」点は同じだが、
Ruby では `arr.each { ... }.size` と書いても動いてしまう（`arr.size` になる）ので、
意図しない連鎖に気づきにくい。

### メソッド名の対応

| JS | Ruby |
|---|---|
| `map` | `map`（別名 `collect`） |
| `filter` | `select`（別名 `find_all`） |
| （`filter` の否定を自分で書く） | `reject` |
| `reduce` | `reduce`（別名 `inject`） |
| `find` | `find`（別名 `detect`） |
| `some` / `every` | `any?` / `all?` |
| `includes` | `include?` |
| `flat` / `flatMap` | `flatten` / `flat_map` |
| （無い。自分で書く） | `group_by` / `tally` / `each_with_object` / `sort_by` / `uniq` |

**`reject` / `group_by` / `tally` / `sort_by` / `uniq` に相当するものが JS の標準には無い**
（`Object.groupBy` は比較的新しい）。JS ではライブラリを入れるか手で書く場面が、
Ruby では 1 メソッドで済む。Enumerable の一覧を 1 度眺めておくと、
「自分で `reduce` を書く前に探す」癖がつく。

### `reduce` の引数の順序

JS は `arr.reduce((acc, cur) => ..., initial)` で**初期値が最後**。
Ruby は `arr.reduce(initial) { |acc, cur| ... }` で**初期値が先**。
どちらも初期値を省けるが、省いたときに先頭要素が初期値になる点は同じである
（MDN: reduce、Enumerable#inject の "First Shortcut: Default Initial value"）。

### `Object` と `Hash`

JS のオブジェクトのキーは文字列か `Symbol` に限られる（数値キーも文字列になる）。
`Map` を使えば任意の値をキーにできるが、別の型になる。
Ruby の Hash は最初から**任意のオブジェクト**をキーにできる。配列をキーにするのは普通の書き方である。

ただし「何を同じキーとみなすか」は `hash` と `eql?` で決まるので、
自作クラスをキーにするときは定義が要る（課題 14）。

### 破壊的メソッドがある

JS の `map` / `filter` は必ず新しい配列を返す。Ruby には `map!` / `select!` / `uniq!` のように
**受け手そのものを書き換える**版がある（課題 6 の `!` の慣習）。
連鎖の途中でうっかり `!` 付きを呼ぶと、元のコレクションが変わる。

## 底本の URL

Ruby 側（一次情報）:

- https://docs.ruby-lang.org/en/4.0/syntax/literals_rdoc.html
- https://docs.ruby-lang.org/en/4.0/Array.html
- https://docs.ruby-lang.org/en/4.0/Hash.html
- https://docs.ruby-lang.org/en/4.0/Enumerable.html

JS 側（MDN）:

- https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/forEach
- https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/map
- https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/reduce
- https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Map
