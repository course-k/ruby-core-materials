# 模範解説 — rb1-03-testing-basics

`why.md` を書き終えてから開く。

## 読み解き

### ファイルの形

```ruby
require "minitest/autorun"
```

これ 1 行で、minitest 本体の読み込みと「このファイルの実行が終わったらテストを全部走らせる」
という予約が同時に行われる。`autorun` の名前どおりで、明示的に「走らせる」と書く行は要らない。

テストは `Minitest::Test` を継承したクラスに書き、**メソッド名が `test_` で始まるものだけ**が
テストとして拾われる。名前の付け方に魔法は無く、ただの命名規約である。
minitest の README が「minitest はテストケースの発見に魔法を使っていない」と書いているのがこれ。

### `setup`

`setup` はテストメソッドが走る**たびに**、その直前に呼ばれる。
各テストは `@meme` を作り直した状態から始まるので、あるテストが `@meme` を壊しても
次のテストに影響しない。

### `assert` と `refute`

`assert test` は `test` が**真**であれば通る。`refute test` はその逆。
Ruby で偽になるのは `nil` と `false` だけなので（課題 4 で扱う）、
`assert 0` も `assert ""` も通ってしまう。この 2 つは「真偽値を返すメソッドの結果」を
そのまま渡すときに使う。

### `assert_equal exp, act`

**第 1 引数が期待値、第 2 引数が実際の値**。この順序は失敗時の表示に効く
（`Expected` の側が第 1 引数）。逆に書いても通るときは通るが、落ちたときのメッセージが読みにくくなる。

`assertions.rb` の定義には、`exp` が `nil` のときだけ
「`nil` を期待するなら `assert_nil` を使え」と別の失敗にする分岐が入っている。
だから `assert_equal nil, x` ではなく `assert_nil x` と書く。

### `assert_nil obj`

`obj.nil?` が真であることを確かめる。失敗時は「`nil` であるはずが〜だった」と出る。

### `assert_raises(SomeError) do … end`

ブロックの中で指定した例外（またはその子孫）が上がることを確かめ、
**上がった例外オブジェクトを返す**。返ってきたオブジェクトの `message` を
`assert_equal` で確かめると、「例外の種類」と「メッセージ」の両方を判定できる。

引数の例外クラスを省くと `StandardError` が指定されたものとして扱われる。
ただし省くと「想定していない別のバグ」まで拾ってしまうので、クラスは書いたほうがよい。

### `skip "…"`

そのテストを「まだやらない」として飛ばす。飛ばしたテストは失敗にならず、
実行サマリの `skips` に数えられる。手本を走らせると `1 skips` が出るのはこれ。

### 実行サマリの読み方

```
6 runs, 8 assertions, 0 failures, 0 errors, 1 skips
```

- `runs` … 走ったテストメソッドの数。
- `assertions` … 実行された `assert` 系の呼び出しの回数。`assert_raises` も 1 回と数える。
- `failures` … `assert` が「期待と違う」で落ちた数。
- `errors` … テストの中で予期しない例外が上がった数（テスト自体のバグか、対象コードの例外）。
- `skips` … `skip` で飛ばした数。

`bin/check` の「写しのアサーション数」判定は、この `assertions` の数を読んでいる。
テストメソッドを 1 つ写し忘れると数が足りなくなって落ちる。

## JS ではこうだが Ruby では

### `expect(...).toBe(...)` と `assert_equal`

JS のテストフレームワーク（Jest / Vitest）は `expect(actual).toBe(expected)` の形で、
**実際の値が先、期待値が後**に来る。minitest の `assert_equal expected, actual` は逆である。
ここは高い確率で書き間違える場所なので、意識して覚える。

対応表:

| Jest / Vitest | minitest |
|---|---|
| `expect(a).toBe(b)` / `toEqual(b)` | `assert_equal b, a` |
| `expect(a).toBeNull()` | `assert_nil a` |
| `expect(a).toBeTruthy()` | `assert a` |
| `expect(a).toBeFalsy()` | `refute a` |
| `expect(fn).toThrow(E)` | `assert_raises(E) { … }` |
| `beforeEach(...)` | `def setup` |
| `test("…", () => {…})` / `it(...)` | `def test_…` |

### テストの入れ物

JS では `describe("…", () => { it("…", () => {}) })` と、文字列の説明とコールバック関数で書く。
minitest の `Minitest::Test` 版は**ただのクラスとただのメソッド**で、
説明文は書かずメソッド名がそのまま説明になる。minitest の README が rspec との対比で
「rspec はテスト用の DSL、minitest はただの Ruby」と言っているのがこの差である。

minitest にも `describe` / `it` の書き方（spec 記法）はあり、README の "Specs" 節に載っている。
この学習計画では**読めれば足りる**扱いにして、自分で書くのは `Minitest::Test` の形に統一する。

### 例外の確かめ方

JS は `throw new Error("…")` で投げ、`try { } catch (e) { }` で捕まえ、
種類を見分けたいときは `e instanceof TypeError` と自分で書く（MDN: try...catch）。
Ruby は `raise CustomError, "…"` で送出し、`assert_raises(CustomError)` のように
**クラスを渡すと minitest 側が種類で選んでくれる**。この差は課題 11 で改めて扱う。

## 底本の URL

Ruby / minitest 側（一次情報）:

- https://github.com/minitest/minitest/blob/v6.0.0/README.rdoc
- https://github.com/minitest/minitest/blob/v6.0.0/lib/minitest/assertions.rb
- https://docs.ruby-lang.org/en/4.0/standard_library_md.html
- https://docs.ruby-lang.org/en/4.0/language/exceptions_md.html

JS 側:

- https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/try...catch
- https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/throw
- https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Error
- https://jestjs.io/docs/expect （MDN はテストフレームワークを扱わないため、`expect` の対応表はこちらを底本にした）
