# 模範解説（rb1-15-pattern-matching）

`why.md` を自分の言葉で書き終えてから読む。

## 原典との差分（教材がこの手本に加えた編集）

底本は、公式リファレンスの Pattern Matching の 1 ページ（値パターン / 配列パターン /
ハッシュパターン / 変数束縛 / ピン演算子 / ガード節 / `deconstruct` と `deconstruct_keys` /
`=>` と `in` の単独形の各節）。加えた編集は次のとおり。

1. **1 ページの中の複数の例を 1 ファイルに連結した。** `CONFIG` のハッシュと `case ... in` の例、
   `Point` の `deconstruct` / `deconstruct_keys` の例は、いずれも同じページの別の節である。
2. **`# => ` のコメントを `assert` に置き換えた。** ただし `deconstruct` の例だけは原典どおり
   `puts` を残してある——どちらのメソッドがいつ呼ばれるかが標準出力に出ることが例の要点だからである。
3. **`NoMatchingPatternKeyError` は底本のページ本文に名前が出てこない。** `=>`（単独形）が
   合わなかったときに投げられる例外として教材が `assert_raises` を足した。出典は例外クラスの側の項で、
   原本の冒頭コメントに URL を書いてある。
4. **原典のローカル変数 `config` を定数 `CONFIG` にして `freeze` した。** 同じ値を複数のテストから
   使うためである。値の中身（`{ db: { user: "admin", password: "abc123" } }`）は原文のまま。
   引用符が二重引用符なのは教材の書式設定に合わせた整形。

## 手本の各行がしていること

- `case CONFIG / in db: { user: }` — `case ... in` は「構造を確かめる」と「合った部分を
  ローカル変数へ入れる」を同時にする。公式ドキュメントの言い方は
  「checking the structure and binding the matched parts to local variables」。
  `db: { user: }` のように**値を書かないキー**は、そのキーの値を同じ名前の変数へ入れる。
  `case ... in` に `when` は混ぜられない（公式ドキュメントの注記どおり）。
- `else` が無く、どの `in` にも合わないと `NoMatchingPatternError` になる。手本の最初のテストは
  `else` を置いているので例外にならない。
- `CONFIG => { db: { user: } }` — 「形が分かっているものを取り出すだけ」のときの書き方。
  合わなければその場で例外になる。手本は `web:` を要求して `NoMatchingPatternKeyError` を確かめている
  （ハッシュのキーが足りないときは `NoMatchingPatternError` ではなくこの型になる）。
- `assert((5 in Integer))` — `<expression> in <pattern>` は真偽値を返す形。公式ドキュメントは
  「the same as `case <expression>; in <pattern>; true; else false; end`」と説明する。
  **括弧が二重なのは書き癖ではなく必要**で、`assert(5 in Integer)` と書くと構文エラーになる
  （`in` は引数の並びの中には置けない）。内側の括弧が `5 in Integer` を 1 つの式にまとめている。
- 値パターン（`Integer` / `0..9` / `String`）は `===` で照合される。`case ... when` と同じ演算子で、
  だから「クラスかどうか」「範囲に入るか」がそのまま書ける。
- 配列パターンは**全体**に一致しないと通らない（`[1, 2, 3]` は `[Integer, Integer]` に一致しない）。
  ハッシュパターンは指定したキーさえあれば通る。全部のキーを縛りたいときは `**nil` を足す。
  この非対称は公式ドキュメントが明示している。
- `in ^expectation, *rest` — ピン演算子 `^` が無いと `expectation` は**新しい束縛**になり、
  1 が入って必ず一致してしまう。公式ドキュメントはこの落とし穴を
  「local variable just rewritten」として並べている。
- `in a, b if b == a * 2` — ガード節。束縛した変数を条件に使える。`unless` も書ける。
  なお `=>` と `in` の単独形にガード節は付けられない。
- `class Point` の `deconstruct` / `deconstruct_keys` — 配列パターンは `deconstruct` を、
  ハッシュパターンは `deconstruct_keys` を呼ぶ。手本が `puts` を残しているのはそのため——
  テストを走らせると `deconstruct called` と `deconstruct_keys called with [:x]` が出て、
  「どちらのパターンを書いたときにどちらが呼ばれるか」「必要なキーだけが渡される」ことが見える。
  底本の Pattern Matching の節が「最初から持っている」として挙げているのは
  `MatchData` / `Time` / `Date` / `DateTime` の 4 つ。`Struct` と `Data` については
  各クラスのページ（`Struct#deconstruct` / `Data#deconstruct`）に載っている——
  だから課題 14 の `Data` はそのまま `in` で分解できる。

## JS 対比

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

## 底本 URL

- https://docs.ruby-lang.org/en/4.0/syntax/pattern_matching_rdoc.html
- https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/Destructuring
