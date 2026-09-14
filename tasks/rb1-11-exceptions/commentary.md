# 模範解説 — rb1-11-exceptions

`why.md` を書き終えてから開く。

## 読み解き

### ハンドラの形

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

順序は `begin` → `rescue`（複数可）→ `else` → `ensure` → `end` で固定。

`ensure` は必ず走るが、**`ensure` の中の最後の式はハンドラ全体の戻り値にならない**。
原典が「does not implicitly return the last evaluated statement」と注意しているのがこれである。
戻り値は `rescue` か `else`（か `begin`）の最後の式になる。

### `begin` を書かなくてよい場所

メソッドの本体・クラスやモジュールの本体・ブロックは、そのまま `begin` の代わりになる。

```ruby
def capture_the_exception
  1 / 0
rescue => x
  [x.class, x.message]
end
```

```ruby
[0, 1, 2].map do |i|
  10 / i
rescue ZeroDivisionError
  nil
end
```

`begin` を書くのは「メソッドの一部だけを囲みたいとき」と「`retry` を使いたいとき」に絞れる。

### 何が捕まるか

`rescue` にクラスを書かないと **`StandardError` とその子孫**が捕まる。
`Exception` 全体ではない。`SystemExit`（`exit` が投げる）や `NoMemoryError`・`SignalException` は
`StandardError` の子孫ではないので、素の `rescue` では捕まらない。
これは意図的な設計で、「プログラムを終わらせるべき異常」まで飲み込まないようになっている。

**`rescue Exception` と書いてはいけない**のはこのためである。

複数の `rescue` 節は上から順に照合され、**最初に当たった 1 つだけ**が走る。
だから子孫クラスの節を先に、親クラスの節を後に書く。

### 例外オブジェクトを受け取る

`rescue => x` と書くと `x` に例外オブジェクトが入る。
`x.message`（メッセージ）、`x.class`（種類）、`x.backtrace`（呼び出しの経路）が読める。

`$!` は「いま処理中の例外」を指すグローバル変数で、`rescue` 節の中でだけ値を持つ。
変数を書くほうが読みやすいので、`$!` は「ログ出力の 1 行で使う」程度に留めるのが通例。

### 再送出と `retry`

- 引数なしの `raise` … **いま捕まえている例外をそのまま投げ直す**。
  ログを取ってから上へ流したいときに使う。引数を書くと別の例外（既定は `RuntimeError`）になってしまう。
- `retry` … `begin` 節を**最初から**やり直す。`rescue` 節の中でしか書けない。
  失敗の回数を数えて上限を決めないと無限ループになる。

### 自作の例外

```ruby
class MyException < StandardError
end
```

`StandardError`（か `RuntimeError`）を継承する。`Exception` を直接継承しない
（素の `rescue` で捕まらなくなるため）。

自作例外をいくつか作るときは、**この仕組みの例外すべての親**を 1 つ作って、
そこから派生させるのが定石である。使う側が「この仕組みの失敗すべて」を 1 つの `rescue` で
受けられるようになる。確認課題の `Inventory::Error` がその形である。

### `raise` の書き方

```ruby
raise "Boom!"                  # RuntimeError を、このメッセージで
raise MyException              # MyException を、既定のメッセージで
raise MyException, "custom"    # MyException を、このメッセージで
raise                          # rescue 節の中でだけ: いまの例外を投げ直す
```

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
