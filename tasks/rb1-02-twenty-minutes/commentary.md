# 模範解説 — rb1-02-twenty-minutes

`why.md` の §1〜§3 を書き終えてから開く。読み終えたら §4「突き合わせで変わったこと」を書く。

この解説は、手本を上から順に説明するのではなく、**前の節で分かったことの上に次の節が乗る順序**で
並べてある。§4 は §3 が分かって初めて意味を持ち、§5 は §2 と §3 の両方を使う。飛ばさずに読む。

## 1. この手本は何をするプログラムか

**何も起こらないプログラムである。** 手本にあるのは定義だけで、定義したものを呼び出す行が 1 つも無い。
`bundle exec ruby twenty_minutes.rb` を実行して何も表示されなかったのは、失敗ではなくこれが理由。

定義されているのは 4 つ。

| 定義 | 何を作るか |
|---|---|
| `def hi` | メソッドを 1 つ |
| `class Greeter` | 名前を覚えて挨拶するオブジェクトの型 |
| `class Greeter`（2 回目） | 同じ型に、あとから機能を足す |
| `class MegaGreeter` | 1 人でも大勢でも挨拶できる型 |

呼び出す側は照合テスト（`copy_test/twenty_minutes_test.rb`）にある。**定義と呼び出しが別ファイルに
分かれている**のがこの課題の形で、自分が定義したものを他所から呼んで確かめる、という実務の形と同じ。

以降、この 4 つを上の順に 1 つずつ開いていく。

## 2. メソッドを 1 つ読む — `hi`

```ruby
def hi(name = "World")
  puts "Hello #{name.capitalize}!"
end
```

**`def` で始まり `end` で終わる**のがメソッドの定義。

> The code `def hi` starts the definition of the method.
> Finally, the last line `end` tells Ruby we're done defining the method.

`= "World"` は**引数の既定値**。

> What this is saying is "If the name isn't supplied, use the default name of `"World"`".

`hi` と呼べば `"World"` が、`hi "chris"` と呼べば `"chris"` が入る。呼び出しの括弧は省略できる
（原典が `hi "chris"` と書いているとおり）。

`#{ }` は**文字列の式展開**。

> That's Ruby's way of inserting something into a string. The bit between the braces is
> turned into a string (if it isn't one already) and then substituted into the outer string
> at that point.

二重引用符の文字列の中でだけ働く。単一引用符では働かない（`'#{1 + 1}'` は `"\#{1 + 1}"` のまま）。

`capitalize` は先頭 1 文字を大文字にした**新しい文字列**を返す。`name` 自体は変わらない。
末尾に `!` が付く `capitalize!` は受け手そのものを書き換える（この対比は課題 6 で扱う）。

`puts` は標準出力へ書き、**戻り値は `nil`**。原典の irb ログで `puts "Hello World"` の下に
`=> nil` と出ているのがそれ。そしてメソッドの戻り値は、`return` を書かなければ**最後に評価した式の値**
になる。`hi` の最後の式は `puts …` なので、`hi` の戻り値は `nil` である。

**ここまでで分かったこと**: メソッドの作り方、引数の渡り方、文字列への埋め込み方。
次はこれを「データを持つもの」の中に入れる。

## 3. データを持つオブジェクトを作る — `Greeter`

```ruby
class Greeter
  def initialize(name = "World")
    @name = name
  end

  def say_hi
    puts "Hi #{@name}!"
  end
end
```

§2 のメソッドは呼ばれるたびに引数を受け取っていた。ここでは**名前を覚えておく**形にする。

`Greeter.new("Pat")` と書くと、Ruby は新しいオブジェクトを作ってから、そのオブジェクトの
`initialize` を `"Pat"` を渡して呼ぶ。`initialize` の中で `@name = name` としているので、
渡された名前がそのオブジェクトに残る。

`@name` が**インスタンス変数**。

> This is an instance variable, and is available to all the methods of the class.

だから `say_hi` は引数を 1 つも取らないのに `@name` を使える。§2 の `hi` が毎回 `name` を
受け取っていたのと、ここが違う。

**`@` の数で別物になる。** `@name` はオブジェクトごとに別の値を持ち、`@@name`（`@` が 2 つ）は
クラス全体で 1 つを共有する**クラス変数**という別のものになる。手本に `@@` は出てこない。

**ここまでで分かったこと**: オブジェクトが自分のデータを持てること。
ただし、そのデータは**まだ外から触れない**。次はそこを開ける。

## 4. 外から触れるようにする — `attr_accessor` とクラスの再オープン

§3 で `@name` にデータが入った。では外から `greeter.name` と書いて読めるか。**読めない。**

> Instance variables are hidden away inside the object.
> Ruby uses the good object-oriented approach of keeping data sort-of hidden away.

`greeter.@name` と書くこともできない（原典が SyntaxError になる例として見せている）。
**この「読めない」が分かって初めて、次の 1 行が何のためにあるかが立つ。**

```ruby
class Greeter
  attr_accessor :name
end
```

`attr_accessor :name` が、

> defined two new methods for us, `name` to get the value, and `name=` to set it.

**メソッドを 2 つ定義する。** 設定でも宣言でもなく、`name` と `name=` という普通のメソッドが
生えるだけ。だから `greeter.name = "Betty"` は代入文のように見えて、実体は `name=` という
メソッドの呼び出しである。

そして `attr_accessor` 自体も**文法ではなくメソッド呼び出し**で、`class` の中で書けるのは
そこがクラスを定義している文脈だから。Rails の `has_many` や `validates` も同じ構造で、
「文法に見えるが誰かが Ruby で定義したメソッド」を追える力は、この学習計画が Ruby 軸の
到達地点に置いているものの 1 つ（課題 10・13 で改めて扱う）。

**`class Greeter` が 2 回書かれている**のは、新しいクラスを作っているのではない。

> In Ruby, you can reopen a class and modify it. The changes will be present in any new
> objects you create and even available in existing objects of that class.

**すでにあるクラスを開き直して**メソッドを足している。1 つにまとめて書いても同じように動く。
原典が 2 つに分けているのは、まさに今読んだ順序——「読めない」と気づいてから「読めるようにする」——
を見せるため。標準ライブラリのクラスにさえ後からメソッドを足せる（この差は課題 10 で扱う）。

**ここまでで分かったこと**: オブジェクトの内と外の境目と、その開け方。
次はこれを使って、渡されたものの種類によって振る舞いを変える。

## 5. 型を聞かずに分岐する — `MegaGreeter`

```ruby
def say_hi
  if @names.nil?
    puts "..."
  elsif @names.respond_to?("each")
    @names.each do |name|
      puts "Hello #{name}!"
    end
  else
    puts "Hello #{@names}!"
  end
end
```

`MegaGreeter` は 1 人でも大勢でも挨拶する。渡されるのが文字列か配列か `nil` か分からないのに、
どう見分けているか。

`greeter.respond_to?("say_hi")` は「このオブジェクトは `say_hi` という呼びかけに応えるか」を
真偽値で返す。ここではそれを使って、`@names` が「`each` に応えるもの（＝配列のようなもの）」か
「そうでないもの（＝ただの文字列）」かを見分けている。

> If the `@names` object responds to `each`, it is something that you can iterate over,
> so iterate over it and greet each person in turn.

**型の名前で分岐していない。** 「Array か」ではなく「`each` に応えるか」を聞く。原典はこれを
**Duck Typing** と呼んでいる。Ruby で繰り返し出てくる考え方で、`say_bye` も同じく
`respond_to?("join")` で分岐している。

`?` で終わるメソッド名にも意味がある。

> By convention, methods that answer questions end in question marks
> (e.g. `Array#empty?`, which returns `true` if the receiver is empty).

`nil?` も `respond_to?` もこれ。ただし**規約であって文法ではない**——`?` はメソッド名に使える
文字にすぎず、処理系が真偽値を強制するわけではない。対になる規約として、`!` で終わるものは
「危険な」メソッド（`self` や引数を書き換えるもの）を表す。§2 で触れた `capitalize!` がそれ。

**`@names.nil?` が最初に来ている順序に意味がある。** `nil` は `each` にも `join` にも応えないので、
先に `nil` を弾いておかないと後の分岐で `NoMethodError` になる。

`do |name| … end` が**ブロック**。`each` は配列の要素を 1 つずつ取り出してブロックに渡し、
`|name|` がブロックの引数になる。ブロックは課題 9 で正面から扱う。
`@names.join(", ")` は配列の要素を区切り文字でつないだ文字列を返す。

**ここまでで分かったこと**: この手本の 4 つの定義すべて。
`hi`（メソッド）→ `Greeter`（データを持つ）→ `attr_accessor`（外に開く）→
`MegaGreeter`（応答で分岐する）という順に積み上がっている。

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
- https://www.ruby-lang.org/en/documentation/ruby-from-other-languages/ （「?」「!」の命名規約）

JS 側（MDN）:

- https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/class
- https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Template_literals
- https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Functions/Default_parameters
