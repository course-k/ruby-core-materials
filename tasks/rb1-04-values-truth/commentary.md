# 模範解説 — rb1-04-values-truth

`why.md` の §1〜§3 を書き終えてから開く。読み終えたら §4「突き合わせで変わったこと」を書く。

この解説は **前の節で分かったことの上に次の節が乗る順序**で並べてある。
§4（`case`）は §2（すべてが式）と §3（真偽の規則）の両方を使う。飛ばさずに読む。

## 1. この手本は何を見せているか

課題 2 で「メソッドの戻り値は最後に評価した式の値」と出てきた。その「式」が Ruby では
どこまで広いのか、そして「真」とは何か——**この 2 つだけ**を、6 つの小さなメソッドで見せる手本。

| 定義 | 何を見せるか |
|---|---|
| `bigger?` | 分岐が値を返すこと |
| `zero_is_true` | `0` が真であること |
| `FALSEY` / `falsey_values` | 偽なのは何と何か |
| `print_hello_world` | `puts` の戻り値 |
| `starts_with_one` | `case` が正規表現で照合できること |
| `label_for` | `when` の複数値と `then` |

前半 3 つが「真偽」、後半 3 つが「式と `case`」です。

## 2. すべての式が値を持つ

`bigger?` を見ます。

```ruby
def bigger?(x, y)
  if x < y
    true
  else
    false
  end
end
```

`return` がありません。書かなくてよい理由は 2 段あります。

> The result value of an `if` expression is the last value executed in the expression.
> — https://docs.ruby-lang.org/en/4.0/syntax/control_expressions_rdoc.html

**`if` そのものが値を返す。** `if` 全体が 1 つの式で、その値がメソッドの最後の式の値、
つまり戻り値になる。実測でも代入できます。

```ruby
r = if 0 then "0 is true" else "0 is false" end
#=> "0 is true"
```

JS の `if` は文で値を持たないので、値が要るときは三項演算子か関数に切り出す必要がありました。
Ruby はその必要がありません。**「すべての式が値を持つ」**は、以降ずっと効いてくる性質です。

`print_hello_world` は逆から同じことを見せています。`puts` は画面に出しますが、
**戻り値は `nil`**（実測）。だからこのメソッドの戻り値も `nil` です。「値を返さない」のではなく
「`nil` という値を返す」。

**ここまでで分かったこと**: `if` を含めて何もかもが値を持つ。次は、その値が分岐で
どう扱われるか——「真」の定義。

## 3. 真と偽の境目

`zero_is_true` が答えを名前で言っています。

```ruby
def zero_is_true
  if 0
    "0 is true"
  else
    "0 is false"
  end
end
```

> In Ruby, everything except `nil` and `false` is considered true.
> In C, Python and many other languages, 0 and possibly other values, such as empty lists,
> are considered false.
> — https://www.ruby-lang.org/en/documentation/ruby-from-other-languages/

**偽なのは `nil` と `false` の 2 つだけ。** `FALSEY` と `falsey_values` がそれを実演します。

```ruby
FALSEY = [nil, false, 0, "", [], {}, "0"].freeze

def falsey_values
  FALSEY.reject { |value| value }
end
```

`reject` は「ブロックが真を返した要素を捨てる」ので、残るのは偽の要素だけ。
実測の結果は `[nil, false]` で、**7 つ並べても 2 つしか残りません**。

JS から来ると、ここが一番踏みます。JS の falsy は `false`・`0`・`-0`・`0n`・`""`・`null`・
`undefined`・`NaN` の 8 つ。`if (list.length)` や `if (str)` と書いていた形は、Ruby では
**常に真**になります。空かどうかは `empty?` で聞く。

`nil` は特別な値に見えますが、これもオブジェクトです。

> The class of the singleton object `nil`.
> Returns `true`. For all other objects, method `nil?` returns `false`.
> — https://docs.ruby-lang.org/en/4.0/NilClass.html

`NilClass` の唯一のオブジェクトで、`nil.nil?` が真を返す。**`nil` にもメソッドが呼べる**という
のが JS の `null`（プロパティを触ると TypeError）との大きな差です。

**ここまでで分かったこと**: 何が真で何が偽か。次は、この真偽の仕組みの上に `case` が乗る。

## 4. `case` は `===` で照合する

`starts_with_one` を見ます。

```ruby
def starts_with_one(text)
  case text
  when /^1/
    "the string starts with one"
  else
    "I don't know what the string starts with"
  end
end
```

`when` に**正規表現**が書いてあります。`text == /^1/` では絶対に真になりません。では何で
比べているのか。

> The patterns are matched using the `===` method which is aliased to `==` on Object.
> — control_expressions_rdoc

**`===` です。** そして `===` は Object では `==` と同じですが、クラスごとに上書きされています。
実測:

```ruby
/^1/ === "123"   #=> true    ← Regexp が「マッチするか」に上書きしている
/^1/ == "123"    #=> false   ← こちらはただの等価比較
```

`==` と同じだと思って書くと、ここで食い違います。`when` に書けるのは値だけではなく、
**「`===` が真を返すもの」なら何でも**——正規表現、クラス（`when String`）、範囲（`when 1..5`）。
1 つの構文でこれだけ扱えるのは `===` を経由しているからです。

`label_for` は `when` の書き方を 2 つ見せています。

```ruby
def label_for(a)
  case a
  when 1, 2 then "a is one or two"
  when 3 then "a is three"
  else "I don't know what a is"
  end
end
```

> You may place multiple conditions on the same `when`. / Ruby will try each condition in turn.
> You may use `then` after the `when` condition. This is most frequently used to place the
> body of the `when` on a single line.
> — control_expressions_rdoc

カンマ区切りで複数、`then` で 1 行。そして `case` 全体も**式なので値を返します**（§2）。
`label_for` に `return` が無いのはそのためです。

*`case ... in`（パターンマッチ）は別物で、課題 15 で扱います。`when` が `===` を聞くのに対し、
`in` は構造を分解します。*

**ここまでで分かったこと**: この手本の全部。式が値を持つ（§2）→ 真偽の規則（§3）→
その上に `case` と `===` が乗る（§4）。

## JS ではこうだが Ruby では

### 偽になる値の数

JS で偽になる値は `false` / `0` / `-0` / `0n` / `""` / `null` / `undefined` / `NaN` の 8 つ
（MDN: Falsy。加えて `document.all` だけが唯一の偽になるオブジェクトである、とも書かれている）。
Ruby は `nil` と `false` の 2 つだけ。

差として効くのはこの 3 つである。

| 値 | JS | Ruby |
|---|---|---|
| `0` | 偽 | **真** |
| `""` | 偽 | **真** |
| `NaN` / `Float::NAN` | 偽 | **真** |

`[]` と `{}` は JS でも Ruby でも真なので、ここは差ではない。

実務で効くのは `if (x)` の書き方である。JS で
`const limit = options.limit || 10` と書くと `limit` が `0` のときに `10` になってしまう
（だから JS には `??` がある）。Ruby で `overrides[key] || DEFAULTS[key]` と書くと、
`0` や `""` は真なので素通りするが、**`false` は偽なので既定値に落ちる**。
この課題の確認課題はその形の欠陥である。

### `null` と `undefined` の 2 本立てが無い

JS は「値が無い」を `null`（明示的に無い）と `undefined`（まだ無い）の 2 つで表す
（MDN の `null` の項と `undefined` の項。Falsy の一覧はこの区別を書いていない）。
Ruby は `nil` の 1 つだけ。存在しない Hash のキーを引いても `nil`、
初期化していないインスタンス変数も `nil` である。

### `===` の意味が逆向き

JS の `===` は**厳密等価**（型変換なしの等しさ）で、`switch` の照合にも使われる
（MDN: switch「using the strict equality comparison」）。
Ruby の `===` は等値ではなく `case` の照合演算子で、クラスごとに意味が違う。
**同じ記号で意味が違う**ので、JS の癖で `a === b` と書くと意図しない判定になる。
Ruby で等値を見たいときは `==`。

### `if` が値を返す

JS の `if` は文であり値を返さないので、同じことをするには三項演算子か即時関数を使う。
Ruby は `if` 自体が値を返すので、`z = if … else … end` と書ける。
Ruby にも三項演算子（`a ? b : c`）はあり、Control Expressions は
「単純な条件のときだけ使うこと」と勧めている。

## 底本の URL

Ruby 側（一次情報）:

- https://docs.ruby-lang.org/en/4.0/syntax/literals_rdoc.html
- https://docs.ruby-lang.org/en/4.0/syntax/control_expressions_rdoc.html
- https://www.ruby-lang.org/en/documentation/ruby-from-other-languages/
- https://www.ruby-lang.org/en/documentation/quickstart/
- https://docs.ruby-lang.org/en/4.0/NilClass.html
- https://docs.ruby-lang.org/en/4.0/TrueClass.html
- https://docs.ruby-lang.org/en/4.0/Object.html#method-i-nil-3F
- https://docs.ruby-lang.org/en/4.0/Object.html#method-i-3D-3D-3D
- https://docs.ruby-lang.org/en/4.0/Module.html#method-i-3D-3D-3D
- https://docs.ruby-lang.org/en/4.0/Kernel.html#method-i-puts

JS 側（MDN）:

- https://developer.mozilla.org/en-US/docs/Glossary/Falsy
- https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/switch
- https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/Equality
