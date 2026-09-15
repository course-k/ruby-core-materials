# 模範解説 — rb1-07-collections-enumerable

`why.md` の §1〜§3 を書き終えてから開く。読み終えたら §4「突き合わせで変わったこと」を書く。

この解説は **前の節で分かったことの上に次の節が乗る順序**で並べてある。
§3（変換）は §2（入れ物）の上に、§4（畳み込み）は §3 の「戻り値で決まる」の上に、
§5（まとめる）は §4 の応用として立つ。飛ばさずに読む。

## 1. この手本は何を見せているか

課題 2 で `@names.each do |name| ... end` を「ブロックは課題 9 で扱う」として素通りした。
**その each が属する世界がこの手本**です。ただしブロックの仕組みではなく、
**使う側**——コレクションに何ができるか——に集中します。

3 段で進みます。

| 段 | 主題 | 定義 |
|---|---|---|
| §2 | 入れ物を作る | `literal_with_expressions` / `nested_literal` / 範囲 / `omitted_values` / `any_key_hash` |
| §3 | 1 つずつ変換する・選ぶ | `each_collects` / `squares` / `multiples_of_three` / `not_doubled_evens` |
| §4-5 | 畳み込む・まとめる | `product_with_inject` / `each_with_object` / `group_by` / `tally` / `sort_by` |

**メソッドの数は多いが、覚えることは 2 つだけ**です——「何が返るか」と「ブロックの戻り値が
使われるか無視されるか」。この 2 つで全部が整理できます。

## 2. 入れ物を作る

**配列**の要素には任意の式を書けて、入れ子にできます。

```ruby
[1, 1 + 1, 1 + 2]        # → [1, 2, 3]
[1, [1 + 1, [1 + 2]]]    # → [1, [2, [3]]]
```

**範囲**は 2 種類。

> Ranges may be created with the `..` (inclusive) and `...` (exclusive) operators.
> — https://docs.ruby-lang.org/en/4.0/syntax/literals_rdoc.html

実測: `(1..2).to_a` は `[1, 2]`、`(1...2).to_a` は `[1]`。点の数が 1 つ増えると終端が外れる。
`(1..)` や `(..1)` のように端を省くこともできます。

**Hash** は、ここが JS と大きく違うところです。

> A Hash object maps each of its unique keys to a specific value.
> **An array index is always an integer. A hash key can be (almost) any object.**
> — https://docs.ruby-lang.org/en/4.0/Hash.html

手本の `any_key_hash` がそれを実演します。

```ruby
{ [1, 2] => "pair", :sym => "symbol", "str" => "string" }
```

**配列がキーになっています。** JS のオブジェクトのキーは文字列と Symbol だけで、
それ以外は文字列化される。任意のオブジェクトをキーにするには `Map` が要ります。
Ruby の Hash は最初からそれができる。

*「何を同じキーとみなすか」の判定（`eql?` と `hash`）は課題 14 で扱います。*

`omitted_values` は値の省略記法です。

```ruby
x = 100
y = 200
{ x:, y: }    # → {x: 100, y: 200}
```

値を省くと、同じ名前のローカル変数（かメソッド）の値が入る。

**ここまでで分かったこと**: 入れ物の作り方。次は、その中身を 1 つずつ扱う。

## 3. 1 つずつ扱う — 戻り値で使い分ける

手本の `each_collects` は、1 つのメソッドで `each` の性格を見せています。

```ruby
def each_collects(values)
  seen = []
  result = values.each { |value| seen << value }
  [seen, result]
end
```

集めるために `seen` という変数を**外に用意**しています。なぜか。

> Implement method `each` which must yield successive elements of the collection.
> — https://docs.ruby-lang.org/en/4.0/Enumerable.html

`each` は要素を渡すだけで、**ブロックの戻り値を使いません**。戻ってくるのはレシーバ自身
（実測: `a.each { }` は `a` と `equal?`）。だから集めたければ外の入れ物が要る。

`map` は逆です。

> map / collect: Returns objects returned by the block.

**ブロックの戻り値を集めた新しい配列**を返す。実測: `[1,2,3].map { |x| x*x }` は `[1,4,9]`。
だから `squares` は外に変数を用意していません。

**使い分けの基準はこれだけです。副作用を起こしたいなら `each`、値を作りたいなら `map`。**

`select` / `reject` も戻り値で決まりますが、見るのは**真偽**です。

> select / filter: Returns elements selected by the block.
> reject: Returns elements not rejected by the block.

ここに罠を仕込んだのが `not_doubled_evens` です。

```ruby
def not_doubled_evens(range)
  range.reject { |i| i * 2 if i.even? }
end
```

名前は「2 倍しない偶数」ですが、実測の結果は `[1, 3, 5]`——**2 倍された値はどこにもありません**。
奇数のときブロックは `nil`（後置 `if` が偽）を返し、`nil` は偽なので捨てられない。偶数のときは
`i * 2` という真の値を返すので捨てられる。**「2 倍した値」ではなく「真偽」で判定されている。**

課題 4 の「偽は `nil` と `false` だけ」が、ここで効いてきます。

**ここまでで分かったこと**: ブロックの戻り値が「集められる」か「真偽として見られる」か
「無視される」かでメソッドが分かれること。次は、それを 1 つの値に畳む。

## 4. 畳み込む — `inject` と `each_with_object`

手本は同じ「積を求める」を 2 つの書き方で見せています。

```ruby
values.inject(1) { |result, next_value| result * next_value }   # 初期値あり
values.reduce { |result, next_value| result * next_value }      # 初期値なし
```

`inject` と `reduce` は同じメソッドの別名です。

> Returns the object formed by combining all elements.
> (1..4).inject {|sum, n| sum + n } # => 10
> — https://docs.ruby-lang.org/en/4.0/Enumerable.html

原文の例が答えを示しています。`1+2+3+4` で 10 であって、`0+1+2+3+4` ではない。
**初期値を省くと、最初の要素が初期値になり、2 番目から畳み込みが始まる。**

実測で差が出るのは**空のとき**です。

```ruby
[].reduce { |a,b| a+b }   #=> nil
```

初期値を書けば空でもその値が返る。**初期値を書くかどうかは、空のときに何を返してほしいかで
決まります。**

`each_with_object` は同じ「集める」でも性格が逆です。

> Calls the block with each successive element and a given object.

```ruby
(1..3).each_with_object([]) { |i, acc| acc.push(i**2) }   # → [1, 4, 9]
```

| | ブロックの戻り値 | 返るもの |
|---|---|---|
| `inject` / `reduce` | **次の回の累積値になる** | 最後の戻り値 |
| `each_with_object` | **無視される** | 渡した入れ物 |

`inject` は最後の行を間違えると壊れます。`each_with_object` は壊れません。
**Hash を組み立てるときは `each_with_object({})` のほうが事故が少ない。**

引数の順が逆なのも注意点です。`inject` は `|累積, 要素|`、`each_with_object` は `|要素, 累積|`。

Hash を回すときは、ブロック引数が**ペア**で来ます。

```ruby
hash.map { |_key, value| value * 2 }            # 2 つ受けるとキーと値に分かれる
hash.each_with_object({}) { |(k, v), h| ... }   # 要素とそれ以外を受けるので括弧で分解
```

`each_with_object` で括弧を忘れると `k` にペアの配列全体が入ります。

**ここまでで分かったこと**: 畳み込みの 2 つの形。次は、それを使った定番の形。

## 5. まとめる・並べる

`group_by` と `tally` はどちらも Hash を返しますが、残すものが違います。

> group_by: Returns a Hash that partitions the elements into groups.
> tally: Returns a new Hash containing the counts of occurrences of each element.

実測:

```ruby
(1..6).group_by { |i| i % 3 }   #=> {1=>[1,4], 2=>[2,5], 0=>[3,6]}   ← 要素が残る
%w[a b a c a].tally             #=> {"a"=>3, "b"=>1, "c"=>1}          ← 数だけ残る
```

**数えるだけなら `tally`、後で要素を使うなら `group_by`。**

`sort_by` と `uniq` は、どちらも「要素そのもの」ではなく**ブロックが返した値**で判断します。

```ruby
values.sort_by { |s| s.size }     # 長さの昇順
values.sort_by { |s| -s.size }    # 符号を反転させて降順
```

「何を基準に並べるか」「何を同じとみなすか」を自分で決められるこの形は、課題 14（等価性と
値オブジェクト）と、この先の重複排除でそのまま使います。

## 6. 目的別の早見表

| したいこと | メソッド | 返るもの | ブロックの戻り値 |
|---|---|---|---|
| 1 つずつ処理する（副作用） | `each` | レシーバ | 無視 |
| 1 つずつ変換する | `map` | 新しい配列 | 集める |
| 条件に合うものを残す | `select` | 新しい配列 | 真偽で判定 |
| 条件に合うものを捨てる | `reject` | 新しい配列 | 真偽で判定 |
| 1 つの値に畳み込む | `reduce` / `inject` | 畳み込んだ値 | 次の累積値 |
| 入れ物を持ち回る | `each_with_object` | 渡した入れ物 | 無視 |
| キーごとにまとめる | `group_by` | キー → 配列 の Hash | グループのキー |
| 出現回数を数える | `tally` | 要素 → 個数 の Hash | （ブロックを取らない） |
| 並べ替える | `sort_by` | 新しい配列 | 並べる基準 |
| 重複を除く | `uniq` | 新しい配列 | 同一とみなす基準 |

**この表の右 2 列が読めれば、知らないメソッドも推測できます。**

最後に 1 つ。**Enumerable が要求するのは `each` ただ 1 つ**です。自分のクラスに `each` を
書いて Enumerable を include すれば、この表のメソッドが全部使えるようになる。
*課題 13（modules-mixins）でそれを実際にやります。*

ブロックの 2 つの書き方（`{ |x| ... }` と `do |x| ... end`）は同じもので、慣習として
1 行なら `{ }`、複数行なら `do ... end`。*ブロックそのものは課題 9 で扱います。*

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
