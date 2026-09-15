# 模範解説 — rb1-11-exceptions

`why.md` の §1〜§3 を書き終えてから開く。読み終えたら §4「突き合わせで変わったこと」を書く。

この解説は **前の節で分かったことの上に次の節が乗る順序**で並べてある。
§3（何が捕まるか）は §2（ハンドラの形）の上に、§5（自作例外）は §3 の階層が分かって初めて
「なぜ StandardError を継承するのか」が立つ。飛ばさずに読む。

## 1. この手本は何を見せているか

課題 3 で `assert_raises` の的として `CustomError < StandardError` が出てきました。
課題 5 で `exit` が例外で実装されていることに触れました。**その回収がこの手本**です。

5 つのメソッドが、それぞれ別の局面を見せています。

| 定義 | 見せる局面 |
|---|---|
| `foo` | ハンドラの**全部の節**（rescue / else / ensure）が揃った形 |
| `capture_the_exception` | 捕まえた例外から何が読めるか |
| `first_matching_clause` | 節を複数書いたときどれが走るか |
| `retried` | **やり直す**——`retry` と、その止め方 |
| `re_raised` | 捕まえてから**上へ流す** |

`MyException < StandardError` が、その全部の前提になる 2 行です。

## 2. ハンドラの形 — 4 つの節

```ruby
begin
  # 例外が起きるかもしれないコード
rescue SomeError => e
  # SomeError（とその子孫）が起きたとき
else
  # 何も起きなかったとき
ensure
  # 起きても起きなくても、捕まえても捕まえなくても必ず
end
```

順序は `begin` → `rescue`（複数可）→ `else` → `ensure` → `end` で固定です。

手本の `foo` が 1 つのメソッドで全部を見せています。実測で流れが見えます。

```
foo              → Begin. / No exception raised. / Always do this.
foo(boom: true)  → Begin. / Rescued an exception! / Always do this.
```

**`else` は例外が起きなかったときだけ。**

> Contains code that is to be executed if no exception is raised in the begin clause.
> — https://docs.ruby-lang.org/en/4.0/language/exceptions_md.html

**`ensure` は必ず。**

> Contains code that is to be executed **regardless of** whether an exception is raised,
> **and regardless of** whether a raised exception is handled.

「捕まえなくても走る」が効きます。`rescue` 節を持たないメソッドで `raise` しても `ensure` は
走り、その後で例外が外へ抜ける（実測で確認）。**後片付けが確実に行われる**のはこの性質のためで、
課題 5 で「`exit` しても `ensure` は実行される」と言ったのも同じ話です。

**注意点が 1 つ。`ensure` の中の最後の式はハンドラ全体の戻り値になりません。** 原典が
「does not implicitly return the last evaluated statement」と書いているのがこれ。戻り値は
`rescue` か `else`（か `begin`）の最後の式です。

そして**`begin` は多くの場合書かなくてよい**。メソッドの本体・クラスやモジュールの本体・
ブロックが、そのまま `begin` の代わりになります。

```ruby
def capture_the_exception
  1 / 0
rescue => x
  [x.class, x.message]
end
```

手本のメソッドに `begin` が出てこないのはこのためです（`retried` だけが例外——理由は §4）。

**ここまでで分かったこと**: 4 つの節と、その走る条件。次は「何が捕まるのか」。

## 3. 捕まるのは `StandardError` の子孫だけ

> A `rescue` statement may include one or more classes that are to be rescued;
> **if none is given, `StandardError` is assumed.**
> — exceptions_md

クラスを書かない `rescue` は `Exception` 全体ではなく、**`StandardError` とその子孫**を捕まえます。

実測で階層が見えます。

```ruby
ZeroDivisionError.ancestors
#=> [ZeroDivisionError, StandardError, Exception, Object, Kernel]
```

`Exception` は `StandardError` の**親**です。だから `raise Exception, "x"` は
`rescue => e` では捕まりません（実測で確認）。

**これは意図的な設計です。** `SystemExit`（`exit` が投げる）・`NoMemoryError`・
`SignalException` は `StandardError` の子孫ではないので、素の `rescue` では捕まらない。
**「プログラムを終わらせるべき異常」まで飲み込まないようになっている。**

だから **`rescue Exception` と書いてはいけません。** Ctrl-C も `exit` も飲み込んでしまいます。

捕まえた例外からは 3 つが読めます。

```ruby
x.message     # メッセージ
x.class       # 種類
x.backtrace   # 呼び出しの経路
```

実測: `1/0` を捕まえると `[ZeroDivisionError, "divided by 0"]`。

`$!` は「いま処理中の例外」を指すグローバル変数です。

> `$!`: contains the rescued exception.

手本の `first_matching_clause` が変数に受けず `$!` を使っています。ただし変数のほうが
読みやすいので、`$!` は「ログ出力の 1 行で使う」程度に留めるのが通例。

**節を複数書いたときは上から順に照合され、最初に当たった 1 つだけが走ります。**

> A `rescue` clause: Starts with a `rescue` statement. … **Ends with the first following**
> `rescue`, `else`, `ensure`, or `end` statement.

手本の `first_matching_clause` は `Errno::ENOTDIR` と `Errno::ENOENT` を並べていて、
存在しないパスなので後者が当たります。**子孫クラスの節を先に、親クラスの節を後に**書く。

**ここまでで分かったこと**: 捕まる範囲と、選ばれ方。次は、捕まえた後にどうするか。

## 4. 捕まえた後の 2 つの道 — やり直す / 上へ流す

`rescue` 節に書けることは、大きく 2 つあります。

**(1) やり直す — `retry`**

```ruby
def retried
  retries = 0
  begin
    raise "Boom"
  rescue
    if (retries += 1) < 3
      retry
    else
      raise
    end
  end
end
```

> Note that the `retry` **re-executes the entire begin clause**, not just the part after the
> point of failure.
> — exceptions_md

**`begin` 節の最初からやり直します。** 失敗した箇所からではありません。

だから `retries = 0` が **`begin` の外**に置いてあります。中に置くと、やり直すたびに 0 に
戻って永久に終わらない。**手本がこのメソッドだけ明示的に `begin` を書いているのは、
「どこからやり直すか」を目に見える形にするためです。**

上限に達したら `raise` で諦める。実測: 3 回目で `RuntimeError: Boom` が外へ出ます。

**(2) 上へ流す — 引数なしの `raise`**

```ruby
def re_raised
  1 / 0
rescue ZeroDivisionError
  # Do needful things (like logging).
  raise # Raised exception will be ZeroDivisionError, not RuntimeError.
end
```

> Calls method `raise` with no argument, which raises the rescued exception.

**いま捕まえている例外をそのまま投げ直します。** 手本のコメントが注意しているとおり、
引数を書くと**別の例外**（既定は `RuntimeError`）になってしまう。ログを取ってから上へ流す、
という定石がこの形です。

`raise` の書き方をまとめます。

```ruby
raise "Boom!"                  # RuntimeError を、このメッセージで
raise MyException              # MyException を、既定のメッセージで
raise MyException, "custom"    # MyException を、このメッセージで
raise                          # rescue 節の中でだけ: いまの例外を投げ直す
```

**ここまでで分かったこと**: 捕まえた後の選択肢。最後に、自分で例外を作る側。

## 5. 自作の例外 — なぜ `StandardError` を継承するのか

```ruby
class MyException < StandardError
end
```

> To provide additional or alternate information, you may create custom exception classes.
> Each should be a subclass of one of the built-in exception classes
> (commonly StandardError or RuntimeError).
> — exceptions_md

中身が空でも構いません。**クラスの名前そのものが情報**だからです。

**なぜ `Exception` を直接継承しないのか。** §3 が答えです——素の `rescue` で捕まらなくなり、
「プログラムを止めるべき異常」と同じ層に置かれてしまう。使う側が
`rescue MyException` と明示しない限り誰も拾えない例外になります。

自作例外をいくつか作るときは、**その仕組みの例外すべての親**を 1 つ作って、そこから
派生させるのが定石です。

```ruby
class Inventory
  class Error < StandardError; end
  class NotFound < Error; end
  class OutOfStock < Error; end
end
```

使う側が `rescue Inventory::Error` と書けば「この仕組みの失敗すべて」を 1 つで受けられ、
`rescue Inventory::NotFound` と書けば個別に扱える。**§3 で見た「上から順に、最初に当たった
1 つ」が、この階層の上で効いてきます。** 確認課題の `Inventory::Error` がその形です。

**ここまでで分かったこと**: この手本の全部。ハンドラの形（§2）→ 捕まる範囲（§3）→
捕まえた後（§4）→ 自分で作る側（§5）。

## JS ではこうだが Ruby では

### 構文の対応

| JS | Ruby |
|---|---|
| `try { }` | `begin` |
| `catch (e) { }` | `rescue => e` |
| `finally { }` | `ensure` |
| （無い） | `else`（例外が起きなかったときだけ） |
| `throw new Error("x")` | `raise RuntimeError, "x"` / `raise "x"` |
| `class MyError extends Error {}` | `class MyError < StandardError; end` |

`finally` と `ensure` はほぼ同じで、どちらも「構文を抜ける前に必ず走る」
（MDN: try...catch「The code in the `finally` block will always be executed before control flow
exits the entire construct」）。

**`else` 節は JS に無い。** 「`try` の中に置くと `catch` に拾われてしまうが、
成功したときだけ走らせたいコード」を置く場所である。

### 種類による分岐のしかた

これが最大の差である。JS の `catch` は**無条件**で、投げられたものを何でも受け取る
（MDN: try...catch「Unconditional catch block」）。種類で分けたければ
`catch` の中で `if (e instanceof TypeError)` と自分で書き、
当てはまらなければ `throw e` で投げ直す——という手順を毎回書くことになる。

```js
try {
  risky();
} catch (e) {
  if (!(e instanceof TypeError)) throw e;
  handleTypeError(e);
}
```

Ruby は `rescue` 節が**クラスで選ぶ**ので、この定型が要らない。

```ruby
begin
  risky
rescue TypeError => e
  handle_type_error(e)
end
```

当てはまらない例外は、そもそもその `rescue` 節に入らず上へ抜けていく。
**「知らない例外は自動的に上へ流れる」**のが Ruby の既定の振る舞いである。

この差は文化の差にもなっている。JS では例外を型で分ける習慣が薄く、
エラーコードや戻り値で分けることが多い。Ruby では
**失敗の種類ごとにクラスを作る**のが自然な設計になる。

### 投げられるものが限られる

JS は文字列でも数値でも何でも `throw` できる（だから MDN の例にも
`if (!(e instanceof Error)) e = new Error(e)` という防御が出てくる）。
Ruby が `raise` できるのは `Exception` の子孫だけで、文字列を渡したときは
`RuntimeError` のメッセージとして扱われる。**受け取る側が `message` の有無を心配しなくてよい。**

### `finally` / `ensure` の戻り値

JS の `finally` の中の `return` は、`try` / `catch` の戻り値を**上書きする**。
Ruby の `ensure` の中の最後の式は戻り値にならない（明示的に `return` を書けば別）。
Ruby のほうが事故が起きにくい。

## 底本の URL

Ruby 側（一次情報）:

- https://docs.ruby-lang.org/en/4.0/language/exceptions_md.html
- https://docs.ruby-lang.org/en/4.0/syntax/exceptions_rdoc.html
- https://docs.ruby-lang.org/en/4.0/Exception.html
- https://docs.ruby-lang.org/en/4.0/Errno.html
- https://docs.ruby-lang.org/en/4.0/Kernel.html#method-i-raise

JS 側（MDN）:

- https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/try...catch
- https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/throw
- https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Error
