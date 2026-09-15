# 模範解説 — rb1-03-testing-basics

`why.md` の §1〜§3 を書き終えてから開く。読み終えたら §4「突き合わせで変わったこと」を書く。

この解説は **前の節で分かったことの上に次の節が乗る順序**で並べてある。
§3 以降は §2（何がテストとして拾われるか）が分かっていることを前提にする。飛ばさずに読む。

## 1. このファイルは何をするプログラムか

課題 2 の手本は定義だけで何も起きなかった。**この手本は逆で、実行すると全部走る。**
理由は 1 行目にある。

```ruby
require "minitest/autorun"
```

これ 1 行で、minitest 本体の読み込みと「このファイルの実行が終わったらテストを全部走らせる」
という予約が同時に行われる。`autorun` の名前どおりで、「走らせる」と書く行は要らない。

ファイルの中身は 3 つに分かれている。

| 定義 | 役割 |
|---|---|
| `class Meme` | テストされる側。ただの普通のクラス |
| `class CustomError < StandardError` | テストで投げるための自作例外 |
| `class TestMeme < Minitest::Test` | テストする側 |

**テストされる側とテストする側が同じファイルにある**のは、この課題だけの形。手本自体が
テストファイルだからで、課題 4 以降は元に戻る（テストは教材が配り、写すのは定義だけ）。

## 2. 何がテストとして拾われるか

走らせる仕組みは分かった。では**どれが走るのか**。条件は 2 つある。

**①`Minitest::Test` を継承したクラスであること。**

**②メソッド名が `test_` で始まること。**

> Define your tests as methods beginning with `test_`.
> Use assertions to test for results or state.
> — https://github.com/minitest/minitest/blob/v6.0.0/README.rdoc

**この 2 つだけ**で、登録する行も、説明文を書く引数もない。手本の `TestMeme` に
`def check_something` というメソッドを足しても走りません（実測: `test_` で始まらない
メソッドは `runs` に数えられない）。

魔法が無いことは README が明言しています。

> minitest/test is meant to have a clean implementation for language implementors that need
> a minimal set of methods to bootstrap a working test suite.
> **For example, there is no magic involved for test-case discovery.**

**`setup` だけは別扱い**で、`test_` で始まらないのにテストのたびに呼ばれる。

> class TestMeme < Minitest::Test
>   def setup
>     @meme = Meme.new
>   end

各テストが `@meme` を作り直した状態から始まるので、あるテストが `@meme` を壊しても
次のテストに影響しない。**テストの独立性**を作っているのがこの 4 行。

**ここまでで分かったこと**: 何が走るか。次は、走った先で何を確かめるか。

## 3. いちばん単純な確かめ方 — `assert` と `refute`

> Fails unless `test` is truthy. / Fails if `test` is truthy.
> — https://github.com/minitest/minitest/blob/v6.0.0/lib/minitest/assertions.rb

`assert x` は `x` が**真**なら通り、`refute x` はその逆。手本の
`test_assert_and_refute_are_about_truthiness` がこの 2 つを並べている。

**「true と等しいか」ではなく「真であるか」**を見ているのが要点。Ruby で偽なのは
`nil` と `false` の 2 つだけなので、`assert 0` も `assert ""` も通ります（JS の falsy とは
範囲が違う。課題 4 で正式に扱う）。

だから `assert` / `refute` は、`respond_to?` のような**真偽値を返すメソッドの結果を
そのまま渡す**ときに使う。値そのものを比べたいときは次の節。

**ここまでで分かったこと**: 真偽で確かめる形。次は値で確かめる形。

## 4. 値を確かめる — `assert_equal` と `assert_nil`

> Fails unless `exp == act` printing the difference between the two, if possible.
> — assertions.rb

定義の並びがそのまま引数の順です。

```ruby
def assert_equal exp, act, msg = nil
```

**第 1 引数が期待値（expected）、第 2 引数が実際の値（actual）。** 実測で、
`assert_equal "expected", "actual"` の失敗表示はこう出ます。

```
Expected: "expected"
  Actual: "actual"
```

入れ替えても「通るときは通る」ので気づきにくく、**落ちたときに初めて表示が逆さになって
読めなくなる**。ここが JS のテストと逆なので（§「JS ではこうだが Ruby では」で対比）、
意識して覚える場所。

`nil` を期待するときは専用のものを使う。

> Fails unless `obj` is nil — assertions.rb（`assert_nil`）

`assert_equal nil, x` と書くと minitest 自身が止めます。定義にこの分岐が入っている:

```ruby
refute_nil exp, message { "Use assert_nil if expecting nil" } if exp.nil?
```

**ここまでで分かったこと**: 値の確かめ方と、引数の順序。次は、値ではなく「起きたこと」を
確かめる形。

## 5. 例外を確かめる — `assert_raises`

ここまでの `assert` 系は値を受け取っていた。`assert_raises` だけは**ブロックを受け取る**。

> Fails unless the block raises one of `exp`. **Returns the exception matched so you can
> check the message, attributes, etc.**
> `exp` takes an optional message on the end to help explain failures and defaults to
> StandardError if no exception class is passed.
> — assertions.rb

ブロックの中で指定した例外（またはその子孫）が上がることを確かめます。値を渡す形では
書けません——渡す時点で例外が上がってしまうので、**実行を遅らせる入れ物**が要る。
それがブロックです（ブロック自体は課題 9 で正面から扱う）。

そして**上がった例外オブジェクトを返す**のがこのメソッドの使いどころ。手本が 2 段で書いている
のがそれです。

```ruby
error = assert_raises(CustomError) do
  raise CustomError, "This is really bad"
end
assert_equal "This is really bad", error.message
```

1 行目で「種類」を、3 行目で「メッセージ」を確かめている。

引数の例外クラスを省くと `StandardError` が指定されたものとして扱われますが、省くと
**想定していない別のバグまで拾ってしまう**ので、クラスは書く。

投げる側の `CustomError` は `StandardError` を継承しています。

> To provide additional or alternate information, you may create custom exception classes.
> Each should be a subclass of one of the built-in exception classes
> (commonly StandardError or RuntimeError).
> — https://docs.ruby-lang.org/en/4.0/language/exceptions_md.html

*例外の設計そのもの（`rescue` / `ensure` / `retry`）は課題 11 で扱う。ここでは
`assert_raises` の的として出てくるだけ。*

**ここまでで分かったこと**: 4 種類の確かめ方。最後に、走らせないものと結果の読み方。

## 6. 走らせないもの、そして結果の読み方

> Skips the current run. If run in verbose-mode, the skipped run gets listed at the end of
> the run but doesn't cause a failure exit code.
> — assertions.rb（`skip`）

`skip "…"` はそのテストを「まだやらない」として飛ばす。**失敗にはならない**のが要点で、
落ちたまま放置するのと、意図して保留するのを区別できます。

走らせると最後にこの 1 行が出ます。

```
6 runs, 8 assertions, 0 failures, 0 errors, 1 skips
```

| 語 | 数えているもの |
|---|---|
| `runs` | 走ったテストメソッドの数（§2 の条件を満たしたもの） |
| `assertions` | 実行された `assert` 系の呼び出しの回数。`assert_raises` も 1 回と数える |
| `failures` | `assert` が「期待と違う」で落ちた数（§3・§4） |
| `errors` | 予期しない例外が上がった数。テスト自体のバグか、対象コードの例外 |
| `skips` | `skip` で飛ばした数（この節） |

**`failures` と `errors` の違い**が読めると、落ちたときの動きが変わります。`failures` は
「確かめた結果が違った」、`errors` は「確かめるところまで行けなかった」。

`bin/check` の判定はこの `assertions` の数を読んでいるので、テストメソッドを 1 つ写し忘れると
数が足りなくなって落ちます。

**ここまでで分かったこと**: この手本の全部。`require` で走る形（§1）→ 何が拾われるか（§2）
→ 真偽で確かめる（§3）→ 値で確かめる（§4）→ 例外で確かめる（§5）→ 飛ばす・読む（§6）。

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
