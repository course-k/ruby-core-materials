# 模範解説 — rb1-15-pattern-matching

`why.md` の §1〜§3 を書き終えてから開く。読み終えたら §4「突き合わせで変わったこと」を書く。

この解説は **前の節で分かったことの上に次の節が乗る順序**で並べてある。
§3（配列と Hash の非対称）は §2（束縛とは何か）の上に、§4（`^`）は §2 の「裸の名前は束縛する」
の帰結として立つ。飛ばさずに読む。

## 1. この手本は何を見せているか

課題 4 で `case ... when` をやりました。**`case ... in` はそれとは別物です。**

> (Note that `in` and `when` branches can NOT be mixed in one `case` expression.)
> — https://docs.ruby-lang.org/en/4.0/syntax/pattern_matching_rdoc.html

混ぜることすらできない。何が違うのか——それがこの課題の主題です。

| 段 | 主題 | 定義 |
|---|---|---|
| §2 | 照合と**束縛**を同時にやる | `describe_config` / `user_of` / `integer?` |
| §3 | 配列と Hash で**余りの扱いが違う** | `three_integers?` / `starts_with_integer?` / `has_integer_a?` / `only_integer_a?` |
| §4 | 裸の名前は束縛する——だから `^` が要る | `pinned` / `doubled?` |
| §5 | 自作クラスを分解できるようにする | `Point` |

## 2. `in` は「確かめる」と「取り出す」を同時にやる

`case ... when` は「値が `===` で一致するか」を聞くだけでした。`in` は**構造を確かめて、
合った部分をローカル変数に入れます**。公式ドキュメントの言い方は「checking the structure and
binding the matched parts to local variables」。

```ruby
def describe_config(config)
  case config
  in db: { user: }
    "Connect with user '#{user}'"
  ...
end
```

**`db: { user: }` の `user:` は値を書いていません。** これが「そのキーの値を `user` という
変数に入れる」という意味です。`when` にはこの働きがありません。

取り出すだけなら `case` すら要りません。

> the `=>` operator is most useful when the expected data structure is known beforehand,
> to just unpack parts of it

```ruby
def user_of(config)
  config => { db: { user: } }
  user
end
```

実測: `CONFIG => { db: { user: } }` の後、`user` は `"admin"`。

真偽が欲しいだけなら `in` を単独で書けます。

> `<expression> in <pattern>` is the same as
> `case <expression>; in <pattern>; true; else false; end`

実測: `(1 in Integer)` は `true`、`("x" in Integer)` は `false`。

**3 つの形の使い分けは「合わなかったときどうなるか」で決まります。**

| 形 | 合わないとき |
|---|---|
| `case ... in`（`else` あり） | `else` へ |
| `case ... in`（`else` なし） | `NoMatchingPatternError` |
| `式 => パターン` | **例外**（実測: ハッシュのキー不足は `NoMatchingPatternKeyError`、配列は `NoMatchingPatternError`） |
| `式 in パターン` | `false` |

`=>` は「一致するはず」と分かっている場所で、`in` は「どちらか分からない」場所で使う。

**書き方の注意**: `assert((5 in Integer))` の括弧が二重なのは書き癖ではなく**必要**です。
`assert(5 in Integer)` は構文エラーになる（`in` は引数の並びの中に置けない）。内側の括弧が
`5 in Integer` を 1 つの式にまとめています。

値パターン（`Integer` / `0..9` / `String`）は `===` で照合されます。**課題 4 の `when` と
同じ演算子**なので、「クラスかどうか」「範囲に入るか」がそのまま書ける。

**ここまでで分かったこと**: 照合と束縛、3 つの形。次は、構造の照合で最初につまずく点。

## 3. 配列は全体、Hash は部分

> An important difference between array and hash pattern behavior is that arrays match
> **only a _whole_ array** ... while the hash matches **even if there are other keys** besides
> the specified part.
> — pattern_matching_rdoc

**この非対称は公式ドキュメントが明示しています。** 実測で並べます。

```ruby
[1,2,3] in [Integer, Integer, Integer]   #=> true
[1,2,3] in [Integer, Integer]            #=> false   ← 数が足りない
[1,2,3] in [Integer, *]                  #=> true    ← * で余りを許す

{a: 1, b: 2} in {a: Integer}             #=> true    ← b があっても一致
```

配列で余りを許したければ `*` を明示する。**Hash は逆に、余りを許さない書き方のほうが明示です。**

> with `**nil`: this will not match the pattern having keys other than a

```ruby
{a: 1, b: 2} in {a: Integer, **nil}   #=> false
{a: 1}       in {a: Integer, **nil}   #=> true
```

手本の `starts_with_integer?`（`[Integer, *]`）と `only_integer_a?`（`{a: Integer, **nil}`）が、
それぞれの「明示」の側です。

**ここまでで分かったこと**: 余りの扱い。次は、束縛の便利さが罠になる場所。

## 4. 裸の名前は必ず束縛する — だから `^` が要る

§2 で「パターンの中の裸の名前は束縛する」と言いました。**これは既にある変数でも同じです。**

```ruby
def pinned(expectation, value)
  case value
  in ^expectation, *rest
    "matched: #{rest}"
  ...
end
```

`^` を外すと、`expectation` は**新しい束縛**になります。渡された値が何であれそこに入るので、
**常に一致してしまう**。公式ドキュメントはこの落とし穴を「local variable just rewritten」として
挙げています。

> For this case, the pin operator `^` can be used, to tell Ruby
> "just use this value as part of the pattern".

実測: `exp = 5` のとき `[5,1,2] in ^exp, *rest` は一致して `rest` が `[1,2]`、
`[9,1,2]` は一致しない。

**JS の分割代入と向きが逆**なのがここです。JS は `const { a } = obj` で「a に入れる」だけで、
「a の値と比べる」書き方はありません。Ruby は束縛が既定で、比較のほうに記号が要る。

束縛した変数を条件に使いたいときは**ガード**を足します。

> `if` can be used to attach an additional condition (guard clause) when the pattern matches
> in case/in expressions.

```ruby
in a, b if b == a * 2
```

`unless` も書けます。ただし `=>` と `in` の単独形にガードは付けられません。

**ここまでで分かったこと**: 束縛の既定と、その外し方。最後に、自作クラスへの適用。

## 5. 自作クラスを分解できるようにする

> array, find, and hash patterns besides literal arrays and hashes will try to match any
> object implementing `deconstruct` (for array/find patterns) or `deconstruct_keys`
> (for hash patterns)
> — pattern_matching_rdoc

**どちらのパターンを書いたかで、呼ばれるメソッドが違います。**

```ruby
class Point
  def deconstruct
    puts "deconstruct called"
    [@x, @y]
  end

  def deconstruct_keys(keys)
    puts "deconstruct_keys called with #{keys.inspect}"
    { x: @x, y: @y }
  end
end
```

**手本が `puts` を残しているのは、それを目に見せるためです。** 実測:

```
case Point.new(1,2); in px, Integer ...   → "deconstruct called"
case Point.new(1,2); in {x:} ...          → "deconstruct_keys called with [:x]"
```

`deconstruct_keys` には**パターンが要求したキーの一覧**が渡されます（`[:x]`）。値の計算が
重いときに、要求されたキーだけを作るために使えます。

標準で最初から持っているのは `MatchData` / `Time` / `Date` / `DateTime` の 4 つ。
`Struct` と `Data` も各クラスのページに `deconstruct` が載っています——**だから課題 14 の
`Data` はそのまま `in` で分解できます。**

**ここまでで分かったこと**: この手本の全部。照合と束縛（§2）→ 配列と Hash の非対称（§3）→
`^` が要る理由（§4）→ 自作クラスへの適用（§5）。

## JS ではこうだが Ruby では

### 分割代入は「取り出す」だけ、パターンマッチは「見分けてから取り出す」

MDN の「Destructuring」は、この構文を
「makes it possible to unpack values from arrays, or properties from objects, into distinct
variables」と説明する。つまり JS の分割代入がするのは**取り出し**で、形が違っても失敗しない——
`const { a } = { b: 1 }` は `a` が `undefined` になるだけで、例外にはならない。
Ruby の `case ... in` は形が合わないと次の `in` へ進み、どれにも合わなければ例外になる。
「取り出せたかどうか」が分岐の材料になる点が違う。
Ruby の `CONFIG => { db: { user: } }` は JS の分割代入に最も近い形だが、
これも合わなければ例外を投げる（黙って `undefined` にしない）。

### JS には「構造による分岐」の構文が無い

JS の `switch` は 1 つの値を `===` で比べるだけで、オブジェクトの形で分岐する構文は無い。
実務では `if (obj.type === "user")` のように**自分で目印のプロパティを見る**か、
分割代入と `typeof` / `Array.isArray` を組み合わせて手で書く。
Ruby の `in` は、クラス・範囲・正規表現・配列の長さ・ハッシュのキーの有無・入れ子の中身までを
1 つの式で同時に確かめられる。手本の `in db: { user: }` は JS なら
`obj.db && typeof obj.db.user !== "undefined"` を書いてから `const { user } = obj.db` と続ける形になる。

### 「変数を値として使う」ときの向きが逆

JS の分割代入では、左辺に書いた名前はつねに**新しい変数**で、既存の変数の値と比べる機能は無い
（比べたければ分割代入のあとに `if` を書く）。Ruby も既定は同じ（新しい束縛）だが、
`^` を付けると既存の変数の**値**をパターンとして使える。JS から来ると
「パターンに変数名を書いたら比較になるはず」と読みがちで、そこが手本のピン演算子のテストの意味。

## 底本の URL

- https://docs.ruby-lang.org/en/4.0/syntax/pattern_matching_rdoc.html
- https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/Destructuring
