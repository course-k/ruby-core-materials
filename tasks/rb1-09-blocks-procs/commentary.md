# 模範解説 — rb1-09-blocks-procs

`why.md` の §1〜§3 を書き終えてから開く。読み終えたら §4「突き合わせで変わったこと」を書く。

この解説は **前の節で分かったことの上に次の節が乗る順序**で並べてある。
§3（オブジェクトにする）は §2（ブロックは値ではない）が分かって初めて意味を持ち、
§5（`return` の飛び先）は §4（2 種類がある）の帰結として立つ。飛ばさずに読む。

## 1. この手本は何を見せているか

課題 7 でブロックを**渡す側**、課題 8 で**受け取る側**をやりました。
**この手本はブロックそのものの正体**を扱います。

手本はたった 4 つの定義しかありませんが、それぞれが別の問いに答えています。

| 定義 | 答える問い |
|---|---|
| `try` | ブロックが渡されなかったらどうするか |
| `make_proc` | ブロックをオブジェクトにできるか |
| `gen_times` | Proc は何を覚えているか |
| `returns_from_the_enclosing_method` | **`return` はどこへ戻るか** |

最後の 1 つがこの課題の山場です。

## 2. ブロックは値ではない

`each { |x| ... }` の `{ |x| ... }` がブロック。**メソッド呼び出しに付ける、名前の無いコードの塊**
です。ここが大事——**引数リストの一部ではありません。** だから括弧の外に書くし、
1 つのメソッド呼び出しに 1 つだけしか付けられない。

JS の関数は値なので、配列に入れたり変数に代入したりできます。**Ruby のブロックはできません。**
構文であって値ではない。

受け取る側から見ると、いちばん素直な形が `yield` です。

```ruby
def try
  if block_given?
    yield
  else
    "no block"
  end
end
```

`yield` は「いま渡されているブロックを呼ぶ」。渡されていないのに `yield` すると
`LocalJumpError: no block given (yield)`（実測）になるので、省略可能にするなら
`block_given?` で確かめます。

> block_given?: Returns `true` if a block was passed to the calling method.
> — https://docs.ruby-lang.org/en/4.0/Kernel.html

実測: `try` はブロック無しで `"no block"`、`try { 42 }` で `42`。

**ここまでで分かったこと**: ブロックは値ではなく、`yield` でその場で呼ぶもの。
次は、それでも値にしたいときの話。

## 3. ブロックをオブジェクトにする — Proc

手本の `make_proc` は 1 行しかありません。

```ruby
def make_proc(&block)
  block
end
```

**受け取ったブロックをそのまま返しているだけ。** §2 で「ブロックは値ではない」と言ったのに、
これは返り値になっています。`&` がその変換をしている。

> A Proc object is an encapsulation of a block of code, which can be stored in a local
> variable, passed to a method or another Proc, and can be called.
> — https://docs.ruby-lang.org/en/4.0/Proc.html

**`&` を通るとブロックが Proc オブジェクトになる。** 変数に入れられるし、別のメソッドへ渡せるし、
あとで呼べる。原典は「ただ呼ぶだけなら `yield` のほうがよい」と勧めています（`&` は Proc を
作るぶんだけ手間がかかる）。

作り方は 5 通りありますが、どれも同じ Proc です。

```ruby
Proc.new { |x| x**2 }   # コンストラクタ
proc { |x| x**2 }       # Proc.new の短縮形
make_proc { |x| x**2 }  # & で受け取ったもの
lambda { |x| x**2 }     # lambda 版
->(x) { x**2 }          # lambda 版のリテラル
```

呼び方は `call` / `.()` / `[]` の 3 通り。どれも同じ。

そして Proc は**作られたときの文脈を覚えています**。

> Proc objects are closures, meaning they remember and can use the entire context in which
> they were created.

```ruby
def gen_times(factor)
  Proc.new { |n| n * factor }   # remembers the value of factor at the moment of creation
end
```

実測: `gen_times(3).call(12)` は `36`。`gen_times` を抜けたあとでも、`factor` が 3 だったことを
知っている。これが**クロージャ**です。

**ここまでで分かったこと**: ブロックは `&` でオブジェクトになり、文脈を持ち運べる。
次に——その Proc には 2 種類ある。

## 4. Proc には 2 種類ある — lambda かどうか

見た目は似ていますが、`lambda` / `->` で作ったものと、`proc` / `Proc.new` / ブロックから
作ったものは**振る舞いが違います**。

> You can tell a lambda from a regular proc by using the `lambda?` instance method.

実測: `lambda { }.lambda?` は `true`、`proc { }.lambda?` は `false`。

違いは 2 つだけ。**1 つ目は引数の扱い**です。

> In lambdas, arguments are treated in the same way as in methods: **strict**, with
> ArgumentError for mismatching argument number, and no additional argument processing.
> Regular procs accept arguments **more generously**: missing arguments are filled with `nil`,
> single Array arguments are deconstructed if the proc has multiple arguments, and there is
> no error raised on extra arguments.

実測で並べると差がはっきりします。

| 渡し方 | `proc { \|a,b\| [a,b] }` | `lambda { \|a,b\| }` |
|---|---|---|
| `call(1)` | `[1, nil]` | `ArgumentError (given 1, expected 2)` |
| `call(1,2,3)` | `[1, 2]` | `ArgumentError` |
| `call([1,2])` | `[1, 2]`（分解される） | `ArgumentError` |

課題 7 で `hash.map { |k, v| ... }` がペアを分解できたのは、**ブロックが非 lambda だから**です。

**ここまでで分かったこと**: 2 種類あり、引数の厳しさが違う。
2 つ目の違いが、この課題の山場です。

## 5. `return` はどこへ戻るか

> **In non-lambda procs, `return` means exit from embracing method**
> (and will throw LocalJumpError if invoked outside the method).
> **In lambdas, `return` and `break` means exit from this lambda.**

手本の 3 行が、これを 1 つのメソッドで見せています。

```ruby
def returns_from_the_enclosing_method
  -> { return 3 }.call   # just returns from lambda into method body
  proc { return 4 }.call # returns from method
  return 5
end
```

**実測の戻り値は `4`。**

1 行目の `-> { return 3 }` は lambda なので、`return 3` はその lambda から出るだけ。
戻り値 `3` は誰も受け取らないので捨てられ、メソッドは 2 行目へ進みます。

2 行目の `proc { return 4 }` は非 lambda なので、`return 4` は**メソッドごと抜けます**。
だから 3 行目の `return 5` には**到達しません**。

「同じ `return` なのに飛び先が違う」——ここが Ruby で最も驚く場所の 1 つです。

ブロックの中から抜ける語は 3 つあり、それぞれ飛び先が違います。

| 書いたもの | 抜ける先 | メソッドの戻り値 |
|---|---|---|
| `next 値` | そのブロックの 1 回分 | ブロックの戻り値がその値になる |
| `break 値` | ブロックを渡したメソッド（`each` など） | その値 |
| `return 値` | **ブロックを囲んでいるメソッド全体** | メソッドの戻り値がその値 |

`next` は JS の `continue`、`break` は JS の `break` に近い。**`return` だけが外側のメソッドまで
飛ぶ**ので、ここが驚きになる。

**使い分け**: lambda は「それ自体で完結した関数」として、メソッドと同じように振る舞って
ほしいときに。非 lambda は「メソッドに処理を渡して回してもらう」イテレータ的な用途に。

**迷ったら lambda。** 引数の間違いがその場で分かり、`return` が驚きを生まないため。

**ここまでで分かったこと**: 2 種類の違いの全部。最後に、記号の読み方。

## 6. `&` の 2 つの顔

同じ `&` が、書く位置で別の働きをします。

| 位置 | 働き |
|---|---|
| **定義側** `def m(&block)` | ブロックを Proc として受け取る（§3） |
| **呼び出し側** `m(&何か)` | その何かをブロックに変換して渡す |

呼び出し側の `&` は、Proc ならそのままブロックにし、**Proc でなければ `to_proc` を呼びます**。
`Symbol` が `to_proc` を持っているので `&:to_s` が書ける。

> to_proc: Returns a `Proc` object which calls the method with name of `self` on the first
> parameter and passes the remaining parameters to the method.
> proc = :to_s.to_proc ; proc.call(1000) # => "1000" ; (1..3).collect(&:to_s) # => ["1", "2", "3"]
> — https://docs.ruby-lang.org/en/4.0/Symbol.html

実測: `[1,2,3].map(&:to_s)` は `["1","2","3"]`、`:to_s.to_proc.call(9)` は `"9"`。
展開すると `[1,2,3].map { |x| x.to_s }` と同じです。

**`&` を通しても lambda かどうかは変わりません。** だから lambda を `&l` で渡すと、
`[[1, 2], [3, 4]].map(&l)` は `ArgumentError` になる（§4 のとおり配列が分解されないため）。

**ここまでで分かったこと**: この手本の全部。ブロックは値でない（§2）→ `&` でオブジェクトに
なる（§3）→ 2 種類ある（§4）→ `return` の飛び先が違う（§5）→ `&` の 2 つの顔（§6）。

## JS ではこうだが Ruby では

### 役割は同じ、飛び先が違う

ブロックとコールバック関数は「関数に処理を渡して、あとで呼んでもらう」という同じ役割を持つ。
書き方の対応も素直である。

```js
[1, 2, 3].map((n) => n * 2);
```

```ruby
[1, 2, 3].map { |n| n * 2 }
```

決定的な差は `return` である。JS のコールバックの中の `return` は**そのコールバックから戻るだけ**で、
外側の関数は続く。

```js
function find(list) {
  list.forEach((n) => {
    if (n === 2) return n; // forEach から抜けるだけ。find は続く
  });
  return "never mind";
}
find([1, 2, 3]); // => "never mind"
```

Ruby のブロックの中の `return` は**外側のメソッドごと抜ける**。

```ruby
def find(list)
  list.each do |n|
    return n if n == 2 # find そのものから抜ける
  end
  "never mind"
end
find([1, 2, 3]) # => 2
```

JS の感覚で書くと「抜けないはず」のところで抜ける。逆に Ruby の感覚で JS を書くと
「抜けたはず」のところで抜けない。**どちらの向きにも事故になる**ので、
この 1 点はここで覚えきる。

Ruby でも lambda を使えば JS のコールバックと同じ振る舞いになる（`return` が lambda から出るだけ）。

### 関数は値、ブロックは値ではない

JS の関数は第一級の値で、変数に入れ、配列に詰め、引数に渡せる。
Ruby の**ブロックは値ではない**。値として扱いたいときに Proc / lambda にする。
`&` は「値（Proc）」と「ブロック」を行き来させる記号だと読むとよい。

だから Ruby には「1 回の呼び出しにブロックは 1 つだけ」という制限がある。
2 つ渡したいときは Proc を引数として渡す（`on_success:` / `on_failure:` のように
キーワード引数で受けるのが通例）。

### 「引数が足りないと `undefined`」に相当するのが非 lambda

JS の関数は引数が足りなければ `undefined` が入り、多すぎれば無視される。
これは Ruby の**非 lambda** の振る舞いと同じである。
Ruby のメソッドと lambda は厳しい（`ArgumentError`）。
つまり JS の関数の感覚に近いのは非 lambda のほうだが、
**JS の `return` の感覚に近いのは lambda のほう**である。ここがねじれている。

### アロー関数と `->`

見た目が似ているが、`->` は lambda リテラルであって、`this` の扱いのような意味は持たない。
Ruby の `self` はブロックの中でも外と同じものを指すので、
JS の「アロー関数なら `this` が束縛される」に相当する悩みは Ruby には無い。

## 底本の URL

Ruby 側（一次情報）:

- https://docs.ruby-lang.org/en/4.0/Proc.html
- https://docs.ruby-lang.org/en/4.0/syntax/methods_rdoc.html
- https://docs.ruby-lang.org/en/4.0/Kernel.html#method-i-block_given-3F
- https://docs.ruby-lang.org/en/4.0/Symbol.html#method-i-to_proc
- https://docs.ruby-lang.org/en/4.0/syntax/control_expressions_rdoc.html

JS 側（MDN）:

- https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Functions/Arrow_functions
- https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/forEach
- https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/return
