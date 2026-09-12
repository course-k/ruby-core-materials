# 模範解説 — rb1-08-methods-arguments

`why.md` を書き終えてから開く。

## 原典との差分（教材がこの手本に加えた編集）

底本は、公式リファレンスの Methods（Method Names / Return Values / Arguments の各節）と
Calling Methods（Default Positional Arguments / Keyword Arguments の各節）、
および String の `empty?` / `upcase!` の項。加えた編集は次のとおり。

1. **同名メソッドを別名にした。** 原典は `add_values` という 1 つの名前で
   「既定値つき」「既定値が左の引数を参照する」「可変長」「キーワード」を順に説明している。
   1 つのファイルに同じ名前を並べると後の定義が前を上書きするので、教材は
   `sum_with_default` / `sum_referring_to_earlier` / `fill_in_the_middle` /
   `gather_arguments` / `gather_middle` / `add_keywords` / `require_keywords` /
   `gather_keywords` / `call_the_block` / `yields_once` に分けた。
   シグネチャ（引数の並び）は原典のままである。
2. **`p` で表示していた例を戻り値に直した。** 原典の `gather_arguments` は
   `p arguments` で表示して「prints [1, 2, 3]」と書いている。教材は表示の代わりに
   その値を返して `assert_equal` で確かめた。
3. **`return` を 2 つ続ける例はそのまま写した。** `two_plus_two` の
   `1 + 1 # this expression is never evaluated` は原典のコメントごと残してある。
4. **`?` と `!` の規約は説明文しか無いので、String の実例で確かめた。**
   Methods の Method Names 節は「`?` で終わるメソッドは慣習として真偽を返す」
   「`!` で終わるメソッドは危険であり、多くは受け手そのものを書き換える」と述べているだけなので、
   `"".empty?` と `upcase!` を教材が持ってきた。

## 読み解き

### 位置引数

```ruby
def add_one(value)
  value + 1
end
```

括弧は省ける（`def add_one value`）が、1 行で書く短縮形（`def add_one(value) = value + 1`）では必須。
数が合わないと `ArgumentError` になる。

### 既定値

```ruby
def sum_with_default(a, b = 1)
```

既定値を持つ引数はまとめて並べる必要がある。`(a = 1, b = 2, c)` は書けるが、
`(a = 1, b, c = 1)` は `SyntaxError`。

既定値は**呼び出しのたびに、左から右へ**評価される。だから
`def sum_referring_to_earlier(a = 1, b = a)` は動く（`b` の既定値が `a` を見る）。
逆に `(a = b, b = 1)` は `NameError` になる。

既定値が中ほどにある `fill_in_the_middle(a, b = 2, c = 3, d)` の埋まり方は、
Calling Methods の説明どおり「まず必須の `a` と `d` を端から埋め、
残りを左から既定値つきの引数に配る」である。

- `(1, 4)` → `a = 1`、`d = 4`、`b` と `c` は既定値 → `[1, 2, 3, 4]`
- `(1, 5, 6)` → `a = 1`、`d = 6`、余った `5` を左の `b` へ → `[1, 5, 3, 6]`

### `*` — 残りを配列にまとめる

```ruby
def gather_arguments(*arguments)
def gather_middle(first_arg, *middle_arguments, last_arg)
```

`*` は 1 つだけ書ける。前や後ろに必須の引数を置いてもよい。

### キーワード引数

```ruby
def add_keywords(first: 1, second: 2)   # 既定値つき
def require_keywords(first:, second:)   # 既定値を書かなければ必須
def gather_keywords(first: nil, **rest) # 残りのキーワードを Hash で受ける
```

- **順不同**で渡せる。
- メソッドが受け付けないキーワードを渡すと `ArgumentError`（`**` を持つときは `rest` に入る）。
- 位置引数とキーワード引数を混ぜるときは、位置引数が先。

### ブロック引数

```ruby
def call_the_block(value, &my_block)   # Proc オブジェクトとして受け取る
  my_block.call(value)
end

def yields_once(value)                 # 受け取らずに yield で呼ぶ
  yield value
end
```

原典は「ブロックを呼ぶだけで、他所へ渡したり加工したりしないなら、
明示的なブロック引数を書かず `yield` を使うほうがよい」と勧めている。
ブロックそのものは次の課題（課題 9）で正面から扱う。

### 戻り値

`return` を書かなければ**最後に評価した式**が戻る。`return` は「途中で抜けたいとき」と
「読み手に戻り値を明示したいとき」に書く。

### `?` と `!`

どちらも**ただの慣習**で、言語が強制する意味は無い（メソッド名として使える文字というだけ）。

- `?` … 真偽を返すメソッド。ただし `true` / `false` とは限らず、真とみなせる何かを返すこともある。
- `!` … 「危険」の印。標準ライブラリでは「受け手そのものを書き換える」ことを表す。
  多くは `!` の付かない版が対になっていて、そちらは新しいオブジェクトを返す。

`upcase!` は**変更が無かったときに `nil` を返す**。`"RUBY".dup.upcase!` が `nil` になるのがそれ。
`s = s.upcase!` と書くと `nil` が入ることがある、というのが典型的な落とし穴である。

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
