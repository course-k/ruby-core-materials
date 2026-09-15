# 模範解説 — rb1-05-control-flow-io

`why.md` の §1〜§3 を書き終えてから開く。読み終えたら §4「突き合わせで変わったこと」を書く。

この解説は **前の節で分かったことの上に次の節が乗る順序**で並べてある。
§4（`&.`）は §3（優先順位）と同じ「記号の見た目に引きずられると落ちる」話で、
§5（入出力）は §1〜§4 を使って道具として成立させる節。飛ばさずに読む。

## 1. この手本は何を見せているか

課題 4 で「`if` は式で値を返す」「偽は `nil` と `false` だけ」を見た。
**この手本はその上に、分岐の書き方の選択肢と、プログラムの外との出入口を足す。**

| 定義 | 何を見せるか |
|---|---|
| `label_for` / `unless_label` / `case_label` | 分岐の 3 つの書き方 |
| `bumped_if_zero` / `count_with_until` | 後置（修飾子）形式 |
| `count_with_while` | `while` |
| `and_versus_double_ampersand` | `and` と `&&` の優先順位の差 |
| `safely_joined` / `joined_without_the_second_guard` | `&.` の効く範囲 |
| `warn_twice` / `exit_with` / `first_argument` | 外との出入口 |

**後半 3 組が本題**です。前半は課題 4 の復習にあたるので、そこは軽く流して構いません。

## 2. 分岐の書き方は 3 つあり、どれも値を返す

```ruby
label = if a == 0
          "a is zero"
        elsif a == 1
          "a is one"
        else
          "a is some other value"
        end
```

課題 4 のとおり `if` は値を返します。`unless` も同じ。

> The `unless` expression is the opposite of the `if` expression. If the value is false,
> the "then" expression is executed.
> The result value of an `unless` expression is the last value executed in the expression.
> — https://docs.ruby-lang.org/en/4.0/syntax/control_expressions_rdoc.html

`unless` に `elsif` はありません（`else` は使えます）。「否定の条件が読みにくいとき」に限って使う。

`case_label` は**主語の無い `case`** です。

```ruby
case
when a == 1, a == 2 then "a is one or two"
when a == 3 then "a is three"
else "I don't know what a is"
end
```

課題 4 の `case` は `case a` と値を置き、`when` の値と `===` で照合していました。ここは
`case` の後ろに何も無く、**`when` に書いた式そのものの真偽**で分岐します。`if`/`elsif` の
連なりと同じ意味ですが、条件が並ぶときはこちらが読みやすい。

そして**後置（修飾子）形式**。

> `if` and `unless` can also be used to modify an expression. When used as a modifier the
> left-hand side is the "then" statement and the right-hand side is the "test" expression.
> — control_expressions_rdoc

```ruby
a += 1 if a.zero?       # bumped_if_zero
b += 1 until b > limit  # count_with_until
```

左が本体、右が条件。1 行で読み切れる短い条件のときに使います。

**1 つ罠があります。後置の条件で変数を作らない。** `p a if a = 0.zero?` は `NameError` に
なります。Ruby は左から構文解析するので、本体の `a` を先にメソッド呼び出しと見なしてしまい、
あとから来る代入では手遅れになる。

`while` / `until` は条件が真／偽のあいだ回ります。どちらも値は `nil` です（`break` に値を
渡したときだけその値）。

**ここまでで分かったこと**: 分岐と繰り返しの書き方。ここまでは見た目の選択の話でした。
次の 2 節は、**見た目に引きずられると結果が変わる**場所です。

## 3. `and` と `&&` は別物 — 優先順位

手本の `and_versus_double_ampersand` は 2 行しかありません。

```ruby
a = true && false
b = true and false
[a, b]
```

**結果は `[false, true]`**（実測）。同じ意味なら両方 `false` のはずです。

一次情報の優先順位表を、高い順に抜き出します。

> … `&&` / `||` / `..`, `...` / `?`, `:` / modifier-rescue /
> **`=`, `+=`, `-=`, etc.** / `defined?` / `not` / **`or`, `and`** / modifier-if, …
> — https://docs.ruby-lang.org/en/4.0/syntax/precedence_rdoc.html

**`&&` は `=` より強く、`and` は `=` より弱い。** だから

```ruby
b = true and false   # (b = true) and false と解釈される
```

代入が先に済み、`and false` の結果は捨てられます。`b` には `true` が入る。

JS に `and` / `or` に当たる低優先順位の語はありません。`&&` と `||` だけなので、
「同じものの別名」と思って代入の右辺に `and` を書くと結果が変わります。

**結論**: 代入と一緒に使うときは `&&` / `||`。`and` / `or` は
`do_something or raise ...` のような制御の流れを書くときに限る。

**ここまでで分かったこと**: 見た目が似ていても優先順位が違う組があること。
次はもう 1 つ、JS の同じ記号と挙動が違うものを見ます。

## 4. `&.` が守るのは「その 1 回」だけ

手本は 2 つのメソッドを並べて、違いを 1 文字で見せています。

```ruby
def safely_joined(text)
  text.match(REGEX)&.values_at(1, 2)&.join(" - ")
end

def joined_without_the_second_guard(text)
  text.match(REGEX)&.values_at(1, 2).join(" - ")
end
```

違いは 2 つ目の `&.` の有無だけ。マッチしない文字列を渡すと、上は `nil` を返し、
**下は `NoMethodError` で落ちます**（実測: `undefined method 'join' for nil`）。

> `&.`, called "safe navigation operator", allows to skip method call when receiver is `nil`.
> It returns `nil` and doesn't evaluate method's arguments if the call is skipped.
> — https://docs.ruby-lang.org/en/4.0/syntax/calling_methods_rdoc.html

**「その呼び出しを飛ばして `nil` を返す」だけ**です。返った `nil` に続けて `.join` と書けば、
それは `nil` に対する普通のメソッド呼び出しになる。

**ここが JS と決定的に違います。** JS の `a?.b.c` は `a` が `null` なら**連鎖ごと**短絡して
`undefined` を返します。Ruby の `&.` は短絡しません。だから**連鎖のすべての段に `&.` が要る**。

同じ記号の直観で書くと落ちる、いちばん踏みやすい差です。

**ここまでで分かったこと**: 記号の見た目に引きずられる 2 か所。
次は、ここまでの道具を使って「プログラムの外」とやり取りする。

## 5. 外との出入口 — 標準出力・標準エラー・終了コード

コマンドラインの道具には約束があります。**正常な結果は標準出力へ、異常の報告は標準エラーへ、
成否は終了コードで。** 手本の最後の 3 つがその 3 つの口です。

| 道具 | 行き先 | 戻り値 |
|---|---|---|
| `puts` | 標準出力 | `nil` |
| `warn` | 標準エラー | `nil` |
| `exit(n)` | — | 戻らない（プロセスが終わる） |

> puts: Equivalent to `$stdout.puts(*objects)` for the given objects.
> warn: Issue a warning based on the given messages and options.
> exit: Exits the current process after calling any registered `at_exit` handlers.
> — https://docs.ruby-lang.org/en/4.0/Kernel.html

実測で行き先を確かめられます。

```
ruby -e 'warn "e"; puts "o"' 2>/dev/null   # → o だけ残る
ruby -e 'warn "e"; puts "o"' 1>/dev/null   # → e だけ残る
```

`warn_twice` のように複数の文字列を渡すと 1 行ずつ出ます。

`exit(status)` の数値はそのまま OS へ返る終了コードになります（実測: `exit(3)` の後の `$?` は
`3`）。`exit` / `exit(true)` は成功（0）、`exit(false)` は失敗。

**`exit` は例外で実装されています。** `SystemExit` を送出するので `rescue` で捕まえられるし、
`ensure` は実行される（例外そのものは課題 11 で扱う）。「後片付けを必ずやってから終わる」が
成立するのはこの作りのためです。

`first_argument` が触っている `ARGV` は、コマンドラインで渡された語の配列（プログラム名は
含まない）。*引数の本格的な扱いは課題 19 で `OptionParser` とあわせて扱います。*

**ここまでで分かったこと**: この手本の全部。分岐の選択肢（§2）→ 優先順位の罠（§3）→
`&.` の範囲（§4）→ 外との 3 つの口（§5）。この約束は課題 12・21 で作る道具でも守ります。

## JS ではこうだが Ruby では

### `switch` と `case`

JS の `switch` は**厳密等価 `===`** で比較する（MDN: switch）。
Ruby の `case … when` は `===` を呼ぶが、その `===` は等値ではなく「この枝が引き受けるか」を
尋ねる演算子で、クラス・正規表現・範囲を `when` に書ける（課題 4 の解説）。

さらに JS の `switch` は**フォールスルーする**ので各枝に `break` が要る。
Ruby は当たった枝だけを実行して抜けるので `break` は要らない。

### `?.` と `&.`

JS の `?.` は、左が `null` / `undefined` のとき**その連鎖全体**を短絡して `undefined` を返す
（MDN: Optional chaining「the expression short-circuits with a return value of undefined」、
「this short-circuiting behavior only happens along one continuous "chain" of property accesses」）。

```js
obj.first?.second.third   // obj.first が null なら undefined。third まで評価されない
```

Ruby の `&.` は**次の 1 呼び出しだけ**を飛ばす。

```ruby
obj.first&.second.third   # obj.first が nil なら nil.third で NoMethodError
obj.first&.second&.third  # こちらが JS の ?. に相当する
```

JS の感覚で 1 つだけ `&.` を書くと落ちる。**Ruby では連鎖の各段に書く。**

### `process.argv` / `process.exit` / `console.error`

対応は次のとおり。左の 3 つは Node.js の API で、ブラウザの JavaScript には無い
（MDN が扱うのは `console.error` まで）。

| Node.js / ブラウザ | Ruby |
|---|---|
| `process.argv`（0 番目が node、1 番目がスクリプト） | `ARGV`（引数だけ。プログラム名は `$0`） |
| `process.exit(1)` | `exit(1)` |
| `console.log(...)` | `puts ...` |
| `console.error(...)`（MDN: console.error） | `warn ...` |
| `fs.readFileSync(0, "utf8")` | `$stdin.read` |

`ARGV` の**添字がずれない**のが大きな差である。Node では `process.argv[2]` が最初の引数だが、
Ruby では `ARGV[0]` が最初の引数になる。

もう 1 つの差は `exit` の性質で、Node の `process.exit()` は即座にプロセスを終えるが、
Ruby の `exit` は `SystemExit` という**例外を送出する**。したがって `ensure` の後始末は走るし、
うっかり `rescue => e` で拾ってしまうこともない（`SystemExit` は `StandardError` の子孫ではない）。

### `&&` / `||` と `and` / `or`

JS には `and` / `or` というキーワードが無いので、この混乱は Ruby 固有である。
JS の `&&` / `||` は Ruby の `&&` / `||` と同じ感覚で使ってよい。
**Ruby でも代入と併用するなら記号のほうを使う**と覚えれば、差を意識せずに済む。

## 底本の URL

Ruby 側（一次情報）:

- https://docs.ruby-lang.org/en/4.0/syntax/control_expressions_rdoc.html
- https://docs.ruby-lang.org/en/4.0/syntax/precedence_rdoc.html
- https://docs.ruby-lang.org/en/4.0/syntax/calling_methods_rdoc.html
- https://docs.ruby-lang.org/en/4.0/Kernel.html#method-i-puts
- https://docs.ruby-lang.org/en/4.0/Kernel.html#method-i-warn
- https://docs.ruby-lang.org/en/4.0/Kernel.html#method-i-exit
- https://docs.ruby-lang.org/en/4.0/Object.html#ARGV
- https://docs.ruby-lang.org/en/4.0/IO.html
- https://docs.ruby-lang.org/en/4.0/language/exceptions_md.html

JS 側（MDN。`process.*` のみ Node.js のドキュメント）:

- https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/switch
- https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/Optional_chaining
- https://developer.mozilla.org/en-US/docs/Web/API/console/error_static
- https://nodejs.org/api/process.html#processargv
- https://nodejs.org/api/process.html#processexitcode
