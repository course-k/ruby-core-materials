# 模範解説 — rb1-08-methods-arguments

`why.md` の §1〜§3 を書き終えてから開く。読み終えたら §4「突き合わせで変わったこと」を書く。

この解説は **前の節で分かったことの上に次の節が乗る順序**で並べてある。
§2〜§5 は「何で対応づけるか」が段階的に変わる——**並び順 → 残り → 名前 → コードそのもの**。
飛ばさずに読む。

## 1. この手本は何を見せているか

課題 2 で `def hi(name = "World")` を書き、既定値を知った。**この手本は、引数の渡し方を
全部並べたカタログ**です。

対応づけの手段で 4 つに分かれます。

| 段 | 何で対応づくか | 定義 |
|---|---|---|
| §2 | **並び順** | `add_one` / `sum_with_default` / `sum_referring_to_earlier` / `fill_in_the_middle` |
| §3 | **残り全部** | `gather_arguments` / `gather_middle` |
| §4 | **名前** | `add_keywords` / `require_keywords` / `gather_keywords` |
| §5 | **コードそのもの** | `call_the_block` / `yields_once` |

そして戻り値（`one_plus_one` / `two_plus_two`）が §6。

## 2. 並び順で対応づける — 位置引数

```ruby
def add_one(value)
  value + 1
end
```

いちばん単純な形。括弧は省けます（`def add_one value`）が、1 行の短縮形
（`def add_one(value) = value + 1`）では必須。数が合わないと `ArgumentError`。

**既定値**を付けると、渡さなくてよくなります。

> Default argument values can refer to arguments that have already been evaluated as local
> variables, and argument values are always evaluated left to right.
> — https://docs.ruby-lang.org/en/4.0/syntax/methods_rdoc.html

**呼び出しのたびに、左から右へ**評価される。だから手本のこれが動きます。

```ruby
def sum_referring_to_earlier(a = 1, b = a)   # b の既定値が a を見ている
  a + b
end
```

実測: 引数なしで `2`、`(5)` で `10`。逆順の `(a = b, b = 1)` は `NameError` になります。

**既定値は真ん中にも置けます。ただし条件がある。**

> The default value does not need to appear first, but arguments with defaults must be
> grouped together.

`(a = 1, b = 2, c)` は書けますが、`(a = 1, b, c = 1)` は `SyntaxError`。既定値つきの引数は
**まとめて並べる**必要があります。

手本の `fill_in_the_middle(a, b = 2, c = 3, d)` がその形です。埋まり方は「まず必須の `a` と
`d` を端から埋め、残りを左から既定値つきの引数に配る」。

```ruby
fill_in_the_middle(1, 4)      #=> [1, 2, 3, 4]   ← b, c は既定値
fill_in_the_middle(1, 9, 4)   #=> [1, 9, 3, 4]   ← 余った 9 は左の b へ
```

**ここまでで分かったこと**: 並び順で対応づく仕組みと、既定値の埋まり方。
次は、並び順で決まらない「残り」の受け方。

## 3. 残りをまとめて受ける — `*`

> Prefixing an argument with `*` causes any remaining arguments to be converted to an Array.
> — methods_rdoc

```ruby
def gather_arguments(*arguments)
  arguments
end
```

渡されたものが全部 1 つの配列になります。`*` は 1 つだけ書けて、**前にも後ろにも必須の引数を
置けます**。

```ruby
def gather_middle(first_arg, *middle_arguments, last_arg)
```

実測: `(1,2,3,4)` を渡すと `[1, [2,3], 4]`。§2 と同じで、**端の必須を先に取り、残りが真ん中に
集まる**。

JS のレストパラメータ `...args` は最後にしか置けません。Ruby の `*` は真ん中に置ける。

**ここまでで分かったこと**: 位置での受け方は出尽くした。次は、位置をやめて名前で渡す。

## 4. 名前で対応づける — キーワード引数

```ruby
def add_keywords(first: 1, second: 2)     # 既定値つき
def require_keywords(first:, second:)     # 既定値を書かなければ必須
def gather_keywords(first: nil, **rest)   # 残りのキーワードを Hash で受ける
```

**並び順と無関係**になります。呼ぶ側は順不同で渡せる。

必須にする方法が独特です。

> To require a specific keyword argument, do not include a default value for the keyword
> argument.
> — methods_rdoc

**既定値を書かない**と必須になる。実測で `require_keywords(first: 1)` は
`ArgumentError: missing keyword: :second`。

`**` は §3 の `*` のキーワード版です。

> Arbitrary keyword arguments will be accepted with `**`.

実測: `gather_keywords(first: 1, a: 2, b: 3)` は `[1, {a: 2, b: 3}]`。受け付けないキーワードを
渡すと通常は `ArgumentError` ですが、`**` があると `rest` に入ります。

位置引数と混ぜるときは**位置引数が先**。

JS にキーワード引数はありません。オブジェクトを 1 つ渡して分割代入するのが代替ですが、
「必須かどうか」を言語が見てくれない点が違います。

**ここまでで分かったこと**: 値の渡し方は全部。次は、値ではなく**コード**を渡す。

## 5. コードを渡す — ブロック

手本は 2 つの受け方を並べています。

```ruby
def call_the_block(value, &my_block)   # Proc オブジェクトとして受け取る
  my_block.call(value)
end

def yields_once(value)                 # 受け取らずに yield で呼ぶ
  yield value
end
```

> The block argument is indicated by `&` and must come last.
> — methods_rdoc

**`&` で受けると変数になり、他所へ渡したり加工したりできる。** `yield` は受け取らずにその場で
呼ぶだけ。原典は「ブロックを呼ぶだけで、他所へ渡したり加工したりしないなら、明示的な
ブロック引数を書かず `yield` を使うほうがよい」と勧めています。

ブロックが渡されなかったら何が起きるか。実測: `yields_once(1)` をブロック無しで呼ぶと
`LocalJumpError: no block given (yield)`。

課題 7 で `map` や `each_with_object` にブロックを渡す側をやりました。**ここはその受け取る側**
です。*ブロックそのもの（Proc と lambda の違い、`&:upcase` の展開）は課題 9 で正面から扱います。*

**ここまでで分かったこと**: 引数の 4 通り。最後に、返す側。

## 6. 戻り値と、名前の末尾の記号

> By default, a method returns the last expression that was evaluated in the body of the method.
> It can also be used to make a method return before the last expression is evaluated.
> — methods_rdoc

手本が `return` の効き方を 2 つ並べています。

```ruby
def one_plus_one
  return 1 + 1
end

def two_plus_two
  return 2 + 2
  1 + 1 # this expression is never evaluated
end
```

コメントが言うとおり、`return` の後ろは**評価されません**。`return` を書くのは
「途中で抜けたいとき」と「読み手に戻り値を明示したいとき」。

最後に命名規約。課題 2（`respond_to?` / `nil?`）と課題 6（`upcase!`）で実例を見てきたものの
まとめです。

> By convention, methods that answer questions end in question marks
> (e.g. `Array#empty?`, which returns `true` if the receiver is empty).
> Potentially "dangerous" methods by convention end with exclamation marks
> (e.g. methods that modify `self` or the arguments, `exit!`, etc.)
> — https://www.ruby-lang.org/en/documentation/ruby-from-other-languages/

**どちらもただの慣習**で、言語が強制する意味はありません（メソッド名に使える文字というだけ）。
`?` が付いていても `true` / `false` とは限らず、真とみなせる何かを返すこともある。

**ここまでで分かったこと**: この手本の全部。並び順（§2）→ 残り（§3）→ 名前（§4）→
コード（§5）→ 返す側と命名（§6）。

## JS ではこうだが Ruby では

### 既定値の評価のしかたは同じ

これは**差ではない**。JS も Ruby も、既定値は呼び出しのたびに評価され、新しいオブジェクトが作られる
（MDN: Default parameters「Evaluated at call time」——「a new object is created each time the
function is called」）。左の引数を右の既定値から参照できる点も同じ
（MDN: 同ページ「Earlier parameters are available to later default parameters」）。
JS 経験者はここを素直に持ち込んでよい。

### 引数の数が合わないとき

これが最大の差である。

| | JS | Ruby |
|---|---|---|
| 足りない | 残りは `undefined` | `ArgumentError` |
| 多すぎる | 黙って無視（`function` 宣言なら `arguments` に入る。アロー関数に `arguments` は無い） | `ArgumentError` |

JS は「呼べてしまって、あとで `undefined` に起因するバグになる」。
Ruby は**呼んだ瞬間に落ちる**。落ちる場所が呼び出し側なので、原因が近い。

### キーワード引数とオプションオブジェクト

JS でよく使う「最後の引数にオプションのオブジェクトを渡す」書き方

```js
function line(label, { separator = ", ", prefix = "" } = {}) {}
line("total", { separator: " / " });
```

は、Ruby ではキーワード引数そのものになる。

```ruby
def line(label, separator: ", ", prefix: nil)
end
line("total", separator: " / ")
```

**渡す側に `{ }` が要らない**のが見た目の差。中身の差はもっと大きく、
Ruby は「受け付けないキーワード」を `ArgumentError` で弾く。
JS の分割代入は知らないキーを黙って捨てる。タイプミスが即座に露見するのは Ruby 側である。

### 呼び出しの括弧

Ruby は曖昧でなければ括弧を省ける（`hi "chris"`）。JS は必須。
省けることの代償として、`method_one arg1, method_two arg2, arg3` のような式は
`SyntaxError` になる。**引数を取るメソッドを引数の中で呼ぶときは括弧を書く**のが安全。

### `return` の省略

JS のアロー関数には式本体の暗黙の return（`x => x + 1`）があるが、`function` 宣言と
ブロック本体のアロー関数では `return` が必須。
Ruby は**すべてのメソッドで**最後の式が戻り値になる。`return` を書かないのが普通の書き方である。

### 可変長引数

JS の `...rest` と Ruby の `*rest` はほぼ同じ働きをする。
JS の `...rest` は最後にしか置けないが、Ruby の `*` は
`def gather_middle(first, *middle, last)` のように中ほどに置ける。

## 底本の URL

Ruby 側（一次情報）:

- https://docs.ruby-lang.org/en/4.0/syntax/methods_rdoc.html
- https://docs.ruby-lang.org/en/4.0/syntax/calling_methods_rdoc.html
- https://docs.ruby-lang.org/en/4.0/String.html

JS 側（MDN）:

- https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Functions/Default_parameters
- https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Functions/rest_parameters
- https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/Destructuring
