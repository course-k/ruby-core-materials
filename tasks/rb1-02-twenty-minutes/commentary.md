# 模範解説 — rb1-02-twenty-minutes

`why.md` を書き終えてから開く。

## 原典との差分（教材がこの手本に加えた編集）

底本の「Ruby in Twenty Minutes」は、第 1〜3 部が irb（対話環境）のやりとりの形で書かれていて、
第 3 部の最後に 1 つのスクリプト（`MegaGreeter`）が載っている。教材は次の編集をした。
コードの型（式とイディオム）は原典のまま変えていない。

1. **irb のやりとりを実行できるファイルの形に直した。** `irb(main):001:0>` のような
   プロンプト表示を落とし、`=> 5` のように irb が返していた値は `p 3 + 2` の形で表示する行にした。
   `p` は値を `inspect` の形で表示するので、`"Betty"` は引用符付きで出る。
2. **定義を先に、使う部分を後にまとめた。** 原典は第 1〜3 部で定義と使用が交互に現れる。
   手本は `hi` / `Greeter` / `Greeter` の再オープン / `MegaGreeter` の定義を前半に集め、
   それを使って表示する部分を後半に置いた。このため `greeter.respond_to?("name")` は
   原典（再オープンの前に評価して `false`）と違い、最初から `true` になる。
   写しの照合テスト（`copy_test/twenty_minutes_test.rb`）は教材が配るもので、手本には
   minitest の骨格を足していない。
3. **`def hi` は最終形だけを置いた。** 原典は同じメソッドを 3 段階で組み立てている:

   ```ruby
   def hi
     puts "Hello World!"
   end

   def hi(name)
     puts "Hello #{name}!"
   end

   def hi(name = "World")
     puts "Hello #{name.capitalize}!"
   end
   ```

   同じ名前のメソッドを 1 ファイルに 3 回書くと後の定義が前を上書きするだけなので、
   手本には 3 つ目だけを置いた。1 つ目・2 つ目は上に引用したとおり。
4. **`if __FILE__ == $0` の囲いを外した。** 原典のスクリプトは末尾に `if __FILE__ == $0` で
   囲まれた実行部分を持つ。この書き方（ファイルを直接実行したときだけ動かす）は課題 19 で扱うので、
   ここでは囲いを外して実行部分をそのまま末尾に置いた。中身（`mg = MegaGreeter.new` から
   `mg.names = nil` までの 4 段階）は原典どおり。`#!/usr/bin/env ruby` の行も同じ理由で落とした。
5. **書式を教材の RuboCop 設定に合わせた。** `3 ** 2` は `3**2` に、`a+b` は `a + b` に直した
   （`**` の前後に空白を置かず、`+` の前後には置くのが RuboCop の既定）。ほかに空白・引用符の変更はない。

## 読み解き

### `puts "Hello #{name.capitalize}!"`

`#{ }` は**文字列の式展開**。二重引用符の文字列の中でだけ働き、`{ }` の中の式を評価して
結果を文字列に埋める。単一引用符の文字列では働かない（`'#{1 + 1}'` は `"\#{1 + 1}"` のまま）。

`capitalize` は先頭 1 文字を大文字にした**新しい文字列**を返す。`name` 自体は変わらない。
末尾に `!` が付く `capitalize!` は受け手そのものを書き換える（この対比は課題 6 で扱う）。

`puts` は標準出力へ書き、戻り値は `nil` である。原典の irb ログで
`puts "Hello World"` の下に `=> nil` と出ているのがそれ。

### `def hi(name = "World")`

`= "World"` は引数の既定値。`hi` と呼べば `"World"` が、`hi "chris"` と呼べば `"chris"` が入る。
呼び出しの括弧は省略できる（原典が `hi "chris"` と書いているとおり）。

メソッドの戻り値は、`return` を書かなければ**最後に評価した式の値**になる。
`hi` の最後の式は `puts …` なので、`hi` の戻り値は `nil` である。

### `class Greeter` / `def initialize` / `@name`

`Greeter.new("Pat")` と書くと、Ruby は新しいオブジェクトを作ってから、そのオブジェクトの
`initialize` を `"Pat"` を渡して呼ぶ。`@name` は**インスタンス変数**で、
`@` で始まる名前を持ち、そのオブジェクトの中だけで見える。外から `greeter.@name` とは書けない
（原典が SyntaxError になる例として見せている）。

### `attr_accessor :name` とクラスの再オープン

手本は `class Greeter` を 2 回書いている。2 回目は新しいクラスを作るのではなく、
**すでにあるクラスを開き直して**メソッドを足している。これが Ruby の「クラスの再オープン」で、
標準ライブラリのクラスにさえ後からメソッドを足せる。

`attr_accessor :name` は、`name`（読み出し）と `name=`（書き込み）の 2 つのメソッドを
自動で定義する。`greeter.name = "Betty"` は代入文のように見えるが、実体は
`name=` というメソッドの呼び出しである。

### `respond_to?` と `instance_methods`

`greeter.respond_to?("say_hi")` は「このオブジェクトは `say_hi` という呼びかけに応えるか」を
真偽値で返す。`MegaGreeter#say_hi` はこれを使って、`@names` が「`each` に応えるもの（＝配列のようなもの）」か
「そうでないもの（＝ただの文字列）」かを見分けている。型の名前で分岐せず、
**その呼びかけに応えるかどうか**で分岐するのが Ruby の常套手段である。

### `if` / `elsif` / `else`

`@names.nil?` が最初に来ている順序に意味がある。`nil` は `each` にも `join` にも応えないので、
先に `nil` を弾いておかないと後の分岐で `NoMethodError` になる。

### `@names.each do |name| … end`

`do |name| … end` が**ブロック**。`each` は配列の要素を 1 つずつ取り出してブロックに渡す。
`|name|` がブロックの引数。ブロックは課題 9 で正面から扱う。

### `@names.join(", ")`

配列の要素を区切り文字でつないだ文字列を返す。

## JS ではこうだが Ruby では

### オブジェクトの生成は `new Foo()` ではなく `Foo.new`

JS は `new` 演算子が先に来て `new Greeter("Pat")` と書く（MDN: Classes）。
Ruby は `Greeter.new("Pat")` で、`new` は `Greeter` に対するメソッド呼び出しである。
書き順が逆になるだけでなく、`new` が言語のキーワードではなくメソッドだという点が違う。

### コンストラクタの名前

JS は `constructor(...) { }`（MDN: Classes）。Ruby は `def initialize(...)`。
JS の `this.name = name` に当たるのが Ruby の `@name = name` で、Ruby では
`this.` に相当する接頭辞ではなく `@` で始まる変数名そのものがインスタンス変数を表す。

### 文字列の埋め込み

JS のテンプレートリテラルはバッククォートで囲んで `` `Hello ${name}` `` と書く
（MDN: Template literals）。Ruby は二重引用符の中で `#{ }`。
JS は `${}`、Ruby は `#{}` で、記号が 1 文字違う。

### 引数の既定値

これは**差ではない**。JS も Ruby も既定値は呼び出しのたびに評価され
（MDN: Default parameters「Evaluated at call time」）、左の引数を右の既定値から参照できる
（MDN: 同ページ「Earlier parameters are available to later default parameters」、
Ruby は `R/syntax/methods_rdoc.html` の Default Values 節）。
JS 経験者はここを素直に持ち込んでよい。

### クラスの再オープン

JS で既存のクラスに後からメソッドを足すには、プロトタイプに代入する
（`Greeter.prototype.sayBye = function () {…}`）。Ruby は `class Greeter` を書き直すだけでよく、
これは言語の正規の書き方として公式入門に載っている。この差は課題 10 で改めて扱う。

### `puts` の戻り値

JS の `console.log()` も `undefined` を返すので、ここは似ている。差になるのは、
Ruby では**すべての式が値を持つ**ため「戻り値が `nil`」であることが常に意味を持つ点で、
これは課題 4 で扱う。

## 底本の URL

Ruby 側（一次情報）:

- https://www.ruby-lang.org/en/documentation/quickstart/
- https://www.ruby-lang.org/en/documentation/quickstart/2/
- https://www.ruby-lang.org/en/documentation/quickstart/3/
- https://www.ruby-lang.org/en/documentation/quickstart/4/
- https://docs.ruby-lang.org/en/4.0/syntax/methods_rdoc.html
- https://docs.ruby-lang.org/en/4.0/syntax/literals_rdoc.html
- https://docs.ruby-lang.org/en/4.0/syntax/modules_and_classes_rdoc.html

JS 側（MDN）:

- https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/class
- https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Template_literals
- https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Functions/Default_parameters
