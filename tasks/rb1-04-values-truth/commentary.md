# 模範解説 — rb1-04-values-truth

`why.md` を書き終えてから開く。

## 読み解き

### すべての式が値を持つ

```ruby
z = if x < y
      true
    else
      false
    end
```

Ruby には「文（statement）」と「式（expression）」の区別が実質的に無い。
`if` も `case` も `while` も値を返し、その値を代入できる。返るのは
**最後に評価された式の値**である。

この性質は至る所に効く。メソッドの戻り値に `return` が要らないのも
（メソッド本体の最後の式の値が戻る）、`x = y = 0` と書けるのも、同じ理由である。

### `nil` と `false` だけが偽

Literals の Boolean and Nil Literals 節がこう書いている——
「`nil` と `false` はどちらも偽の値」「`nil` と `false` 以外のすべてのオブジェクトは、
条件式で真の値に評価される」。

つまり `0`・`""`（空文字列）・`[]`（空配列）・`{}`（空ハッシュ）・`"0"` は**すべて真**である。
「Ruby From Other Languages」がわざわざ節（The universal truth）を立てているのは、
他の言語から来た人がここで踏むからである。

### `nil` はオブジェクト

`nil` は「何も無い」を表す**オブジェクト**であり、`NilClass` の唯一のインスタンスである。
だから `nil.nil?` も `nil.to_s`（`""` が返る）も呼べる。
`nil` に対して定義されていないメソッドを呼ぶと `NoMethodError` になるが、
これは「`nil` が特別だから」ではなく「`NilClass` にそのメソッドが無いから」である。

### `puts` の戻り値

`result = puts "Hello World"` の `result` は `nil` になる。
「すべての式が値を持つ、たとえその値が `nil` であっても」という原典の言い方がそのまま当てはまる。

### `===` は等値ではない

`case … when` は、`when` に書いたものを左辺にして `===` を呼ぶ。
つまり `case "12345" / when /^1/` は `/^1/ === "12345"` を評価している。

`===` の意味は受け手のクラスごとに違う。

- `Object#===` … 既定では `==` と同じ（つまり等値）。
- `Module#===` … 右辺がそのクラス（か子孫）のインスタンスかどうか。`String === "12345"` は真。
- `Regexp#===` … 右辺が正規表現に一致するかどうか。

**`===` は「等しいか」を尋ねる演算子ではない**。「この `when` の枝はこの値を引き受けるか」を
尋ねる演算子だと読む。等値を確かめたいときは `==` を使う。

### `when 1, 2 then …`

1 つの `when` に複数の条件を並べられる。`then` を付けると 1 行に書ける。
上から順に試し、最初に当たった枝だけが実行される。

## JS ではこうだが Ruby では

### 偽になる値の数

JS で偽になる値は `false` / `0` / `-0` / `0n` / `""` / `null` / `undefined` / `NaN` の 8 つ
（MDN: Falsy。加えて `document.all` だけが唯一の偽になるオブジェクトである、とも書かれている）。
Ruby は `nil` と `false` の 2 つだけ。

差として効くのはこの 3 つである。

| 値 | JS | Ruby |
|---|---|---|
| `0` | 偽 | **真** |
| `""` | 偽 | **真** |
| `NaN` / `Float::NAN` | 偽 | **真** |

`[]` と `{}` は JS でも Ruby でも真なので、ここは差ではない。

実務で効くのは `if (x)` の書き方である。JS で
`const limit = options.limit || 10` と書くと `limit` が `0` のときに `10` になってしまう
（だから JS には `??` がある）。Ruby で `overrides[key] || DEFAULTS[key]` と書くと、
`0` や `""` は真なので素通りするが、**`false` は偽なので既定値に落ちる**。
この課題の確認課題はその形の欠陥である。

### `null` と `undefined` の 2 本立てが無い

JS は「値が無い」を `null`（明示的に無い）と `undefined`（まだ無い）の 2 つで表す
（MDN の `null` の項と `undefined` の項。Falsy の一覧はこの区別を書いていない）。
Ruby は `nil` の 1 つだけ。存在しない Hash のキーを引いても `nil`、
初期化していないインスタンス変数も `nil` である。

### `===` の意味が逆向き

JS の `===` は**厳密等価**（型変換なしの等しさ）で、`switch` の照合にも使われる
（MDN: switch「using the strict equality comparison」）。
Ruby の `===` は等値ではなく `case` の照合演算子で、クラスごとに意味が違う。
**同じ記号で意味が違う**ので、JS の癖で `a === b` と書くと意図しない判定になる。
Ruby で等値を見たいときは `==`。

### `if` が値を返す

JS の `if` は文であり値を返さないので、同じことをするには三項演算子か即時関数を使う。
Ruby は `if` 自体が値を返すので、`z = if … else … end` と書ける。
Ruby にも三項演算子（`a ? b : c`）はあり、Control Expressions は
「単純な条件のときだけ使うこと」と勧めている。

## 底本の URL

Ruby 側（一次情報）:

- https://docs.ruby-lang.org/en/4.0/syntax/literals_rdoc.html
- https://docs.ruby-lang.org/en/4.0/syntax/control_expressions_rdoc.html
- https://www.ruby-lang.org/en/documentation/ruby-from-other-languages/
- https://www.ruby-lang.org/en/documentation/quickstart/
- https://docs.ruby-lang.org/en/4.0/NilClass.html
- https://docs.ruby-lang.org/en/4.0/TrueClass.html
- https://docs.ruby-lang.org/en/4.0/Object.html#method-i-nil-3F
- https://docs.ruby-lang.org/en/4.0/Object.html#method-i-3D-3D-3D
- https://docs.ruby-lang.org/en/4.0/Module.html#method-i-3D-3D-3D
- https://docs.ruby-lang.org/en/4.0/Kernel.html#method-i-puts

JS 側（MDN）:

- https://developer.mozilla.org/en-US/docs/Glossary/Falsy
- https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/switch
- https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/Equality
