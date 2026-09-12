# 模範解説 — rb1-05-control-flow-io

`why.md` を書き終えてから開く。

## 原典との差分（教材がこの手本に加えた編集）

底本は、公式リファレンスの Control Expressions・Precedence・Calling Methods（Safe Navigation Operator 節）と、
Kernel の `puts` / `warn` / `exit` の項、Object の `ARGV` の項、IO の項、
それに Exceptions ガイドの Begin-Less Exception Handlers 節。加えた編集は次のとおり。

1. **`puts` で表示していた例を「値を返す形」に直した。** Control Expressions の
   `if` / `unless` / `case` の例は `puts` で結果を表示している。教材は
   「`if` 式の値」「`case` 式の値」を確かめたかったので、同じ分岐の各枝が文字列を返す形にして、
   その値を変数に代入した。原典自身が「The result value of an if expression is the last value
   executed in the expression」と書いている性質を使っている。分岐の構造は変えていない。
2. **`warn` の例は Kernel#warn の項の `warn("warning 1", "warning 2")` をそのまま使った。**
   出力が標準エラーへ行くことを確かめるため `assert_output` の第 2 引数で受けた。
3. **`exit` の例は Kernel#exit の項の「`SystemExit` は捕まえられる」という記述に基づく。**
   原典の例は `begin / rescue SystemExit / end` の形。教材はメソッド本体がそのまま
   例外ハンドラになる書き方（Exceptions ガイドの Begin-Less Exception Handlers 節）で書き、
   `SystemExit#status` が引数の値になることを確かめた。
4. **`ARGV` と `$stdin` はテストの中で差し替えている。** 本来この 2 つは端末から呼ばれたときに
   外から与えられるものなので、テストの中では `ARGV.replace(...)` と
   `$stdin = StringIO.new(...)` で値を作り、`ensure` で元に戻している。
   端末から本物の `ARGV` と標準入力を使う手順は README の手順 6 にある。
5. **`&.` の例は Calling Methods の Safe Navigation Operator 節の 2 つの例をつないだ。**
   原典が `# NoMethodError` とコメントで書いている箇所を `assert_raises(NoMethodError)` にした。
   `REGEX` という定数名も原典のまま。
6. **主語なし `case` の例は、Control Expressions の 2 つの例を合成したものである。**
   原典の主語なし `case` の節は `when a == 1, a == 2` と `when a == 3` の 2 枝、
   `else` 節の文言 `"I don't know what a is"` は同じ節の別の例から取っている。
   分岐の構造と各枝の式はいずれも原文のまま。
7. **`and` と `&&` を並べた 2 行（`a = true && false` / `b = true and false`）は教材が書いた。**
   底本の Precedence の項は演算子の優先順位を表として示すだけでコード例を持たない。
   表の「`&&` は代入より強く、`and` は代入より弱い」という記述を、
   2 行のコードと 1 つの `assert_equal` に起こしたもの。

8. **後置 `until` の例は変数名を `a` から `b` に改名した。** 底本（Control Expressions の Modifier until）は
   `a += 1 until a > 10`。同じテストメソッド内で先に `a` を使っているため衝突を避けて `b` にした。

## 読み解き

### 分岐は全部「値を返す式」

```ruby
label = if a.zero?
          "a is zero"
        elsif a == 1
          "a is one"
        else
          "a is some other value"
        end
```

`if` は最後に評価した式の値を返す。`unless` も `case` も同じ。
`else` が無くてどの枝にも入らなかったときは `nil` が返る。

`unless` は `if not` と同じで、`elsif` は使えない（`else` は使える）。
「否定の条件が読みにくいとき」に使うと素直に読める。

### 主語の無い `case`

```ruby
label = case
        when a == 1, a == 2 then "a is one or two"
        ...
```

`case` のあとに値を書かないと、`when` に書いた式そのものの真偽で分岐する。
`if` / `elsif` の連なりと同じ意味だが、条件が並ぶときはこちらのほうが読みやすい。
1 つの `when` にカンマで複数条件を並べると「どれかが当たれば」になる。

### 後置の `if`

```ruby
a += 1 if a.zero?
```

左が本体、右が条件。**条件が先に評価される**。1 行で読み切れる短い条件のときに使う。

注意点が 1 つある。Control Expressions が挙げている例で、

```ruby
p a if a = 0.zero?
```

は `NameError` になる。Ruby は左から構文解析するので、本体の `a` を先に「メソッド呼び出し」と
見なしてしまい、あとから来る代入で `a` がローカル変数になっても手遅れになる。
**後置の条件で変数を作らない**のが実務上の結論。

### `while` と `until`

`while` は条件が真のあいだ回り、`until` は条件が偽のあいだ回る。
どちらも `do` を書いてよいが、省くのが普通。
`while` / `until` の値は `nil`（`break` に値を渡したときだけその値）。

後置形も使える（`b += 1 until b > 10`）。

### `and` / `or` は `&&` / `||` と優先順位が違う

Precedence の表で、上から順に `&&` → `||` → `=` → `not` → `or, and` という並びになっている。
つまり **`&&` は `=` より強く、`and` は `=` より弱い**。

```ruby
a = true && false   # a には (true && false) が入る → false
b = true and false  # (b = true) and false と解釈される → b は true
```

`b` の行は代入が先に済んでしまい、`and false` は捨てられる。
**代入と一緒に使うときは `&&` / `||` を使う。** `and` / `or` は
「`do_something or raise ...`」のような制御の流れを書くときに限って使う、というのが通例である。

### `&.` は「次の 1 呼び出しだけ」を飛ばす

```ruby
"Python is fascinating!".match(REGEX)&.values_at(1, 2).join(" - ")   # NoMethodError
"Python is fascinating!".match(REGEX)&.values_at(1, 2)&.join(" - ")  # nil
```

`match` が `nil` を返すと、`&.values_at` は呼ばずに `nil` を返す。
しかしそこで**短絡は終わる**ので、続く `.join` は `nil` に対して呼ばれ `NoMethodError` になる。
連鎖のすべての段に `&.` を書く必要がある。

### `puts` / `warn` / `exit`

- `puts` … 標準出力へ書く。戻り値は `nil`。
- `warn` … 標準エラーへ書く。複数の文字列を渡すと 1 行ずつ出る。戻り値は `nil`。
- `exit` … `SystemExit` を**送出**してプログラムを終える。例外なので `rescue` で捕まえられるし、
  `ensure` は実行される。引数に整数を渡すとそれが OS へ返す終了コードになる。
  `exit` / `exit(true)` は成功（0）、`exit(false)` は失敗を意味する。

「正常な結果は標準出力へ、異常の報告は標準エラーへ、成否は終了コードで」というのが
コマンドラインの道具の約束である。この約束は課題 12・21 で作る道具でも守る。

### `ARGV` と `$stdin`

`ARGV` はコマンドラインで渡された語の配列（プログラム名は含まない）。
`$stdin` は標準入力の `IO` オブジェクトで、`read` で全部を 1 つの文字列として読む。

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
