# 模範解説 — rb1-09-blocks-procs

`why.md` を書き終えてから開く。

## 読み解き

### ブロックとは何か

`each { |x| ... }` の `{ |x| ... }` がブロック。**メソッド呼び出しに付ける、名前の無いコードの塊**で、
引数リストの一部ではない（だから括弧の外に書く）。1 つのメソッド呼び出しに 1 つだけ付けられる。

受け取り方は 2 通りある。

```ruby
def try              # 受け取らずに yield で呼ぶ
  if block_given?
    yield
  else
    "no block"
  end
end

def make_proc(&block) # Proc オブジェクトとして受け取る
  block
end
```

`yield` は「いま渡されているブロックを呼ぶ」。ブロックが渡されていないのに `yield` すると
`LocalJumpError` になるので、省略可能にするなら `block_given?` で確かめる。

`&block` の形で受け取ると**ブロックが Proc オブジェクトになる**ので、変数に入れたり、
別のメソッドへ渡したり、あとで呼んだりできる。原典は「ただ呼ぶだけなら `yield` のほうがよい」と
勧めている（`&` で受け取ると Proc を作るぶんだけ手間がかかる）。

### Proc の作り方は 5 通り

```ruby
Proc.new { |x| x**2 }   # コンストラクタ
proc { |x| x**2 }       # Proc.new の短縮形
make_proc { |x| x**2 }  # & で受け取ったもの
lambda { |x| x**2 }     # lambda 版
->(x) { x**2 }          # lambda 版のリテラル
```

呼び方は `call` / `.()` / `[]` の 3 通り。どれも同じ。

### Proc はクロージャ

```ruby
def gen_times(factor)
  Proc.new { |n| n * factor }
end
```

作られた時点の `factor` を覚えている。`gen_times(3)` が返した Proc は、
`gen_times` を抜けたあとでも `factor` が 3 だったことを知っている。

### lambda と非 lambda の違い

違いは 2 つだけである。

**(1) 引数の扱い**

| | 非 lambda（`proc` / ブロック） | lambda |
|---|---|---|
| 足りない | `nil` で埋める | `ArgumentError` |
| 多すぎる | 捨てる | `ArgumentError` |
| 配列 1 つを渡す | 複数引数に分解する | `ArgumentError` |

**(2) `return` の効き方**

- lambda の中の `return` … その lambda から戻るだけ。メソッドは続く。
- 非 lambda の中の `return` … **それを囲んでいるメソッドごと抜ける**。

```ruby
def returns_from_the_enclosing_method
  -> { return 3 }.call   # ここでは戻らない。lambda から出るだけ
  proc { return 4 }.call # ここでメソッドごと抜ける。戻り値は 4
  return 5               # 到達しない
end
```

`lambda?` で見分けられる。

**使い分け**: 原典の言い方が分かりやすい——lambda は「それ自体で完結した関数」として、
メソッドと同じように振る舞ってほしいときに使う。非 lambda は
「メソッドに処理を渡して回してもらう」イテレータ的な用途に向く
（`map { |a, b| ... }` が `[[1, 2]]` の要素を `a` と `b` に分解できるのは非 lambda だから）。

**迷ったら lambda**。引数の間違いがその場で分かり、`return` が驚きを生まないため。

### `&` の 2 つの顔

- **メソッドの定義側**の `&block` … ブロックを Proc として受け取る。
- **呼び出し側**の `&何か` … その何かをブロックに変換して渡す。

呼び出し側の `&` は、Proc ならそのままブロックにし、Proc でなければ `to_proc` を呼ぶ。
`Symbol#to_proc` があるので `&:to_s` が書ける。

```ruby
:to_s.to_proc.call(1)  # => "1"
[1, 2].map(&:to_s)     # => ["1", "2"]
```

`&` を通してもその Proc が lambda かどうかは変わらない。だから
`[[1, 2], [3, 4]].map(&l)` は `ArgumentError` になる（配列 1 つが分解されないため）。

### `return` / `break` / `next` の抜ける先

出力予測（`predict/01.rb`）で確かめる内容をまとめておく。

| 書いたもの | 抜ける先 | ブロックを呼んだメソッドの戻り値 |
|---|---|---|
| `next 値` | そのブロックの 1 回分 | ブロックの戻り値がその値になる |
| `break 値` | ブロックを渡したメソッド（`each` など） | その値 |
| `return 値` | **ブロックを囲んでいるメソッド全体** | メソッドの戻り値がその値 |

`next` は JS の `continue`、`break` は JS の `break` に近い。
`return` だけが「ブロックの外側のメソッドまで」飛ぶので、ここが驚きになる。

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
