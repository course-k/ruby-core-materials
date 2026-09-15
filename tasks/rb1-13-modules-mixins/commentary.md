# 模範解説 — rb1-13-modules-mixins

`why.md` の §1〜§3 を書き終えてから開く。読み終えたら §4「突き合わせで変わったこと」を書く。

この解説は **前の節で分かったことの上に次の節が乗る順序**で並べてある。
§4・§5（Comparable と Enumerable）は §3（include が何をするか）の応用で、
§6（extend）は §3 との対比で立つ。飛ばさずに読む。

## 1. この手本は何を見せているか

課題 10 でクラスをやりました。**モジュールはクラスによく似ていますが、
「インスタンスを作らない」という 1 点が違います。** そこから 2 つの使い道が生まれる。

> **Modules serve two purposes in Ruby, namespacing and mix-in functionality.**
> A namespace can be used to organize code by package or functionality that separates common
> names from interference by other packages.
> Mix-in functionality allows sharing common methods across multiple classes or modules.
> — https://docs.ruby-lang.org/en/4.0/syntax/modules_and_classes_rdoc.html

手本はその 2 つを順に見せます。

| 定義 | 主題 |
|---|---|
| `Outer::Inner` | **名前空間**の側（§2） |
| `A` と `include A` | **mixin** の側——`include` が何をするか（§3） |
| `StringSorter` + `Comparable` | 1 つ書くと 7 つもらえる（§4） |
| `Foo` + `Enumerable` | 1 つ書くと大量にもらえる（§5） |
| `Mod` / `Klass` + `extend` | `include` との違い（§6） |

## 2. 名前空間としての module

```ruby
module Outer
  module Inner
  end
end
```

中に書いた定数・クラス・メソッドの名前を `Outer::Inner` という形で囲います。実測でも
`Outer::Inner` で参照でき、`Outer::Inner.name` は `"Outer::Inner"` になる——**囲われた名前が
その形で世界に登録される**。

公式ドキュメントは名前空間の例として、irb の `Context` が他の `Context` とぶつからないことを
挙げています。ライブラリを書くときに、自分の名前を他人の名前から守る仕組みです。

**ここまでで分かったこと**: 名前を囲う側。次は、もう 1 つの用途。

## 3. `include` が何をするか

```ruby
module A
  Z = 1

  def z
    Z
  end
end

include A
```

**module の中に `def` で定義したメソッドは、そのままでは呼べません。** 公式ドキュメントの
言い方は「Instance methods defined in a module are only callable when included」。
モジュールはインスタンスを作れないので、呼ぶ相手がいない。

`include` して初めて呼べるようになります。手本は**トップレベル**で `include A` しているので、
足された先は `Object`——つまり全部のオブジェクトです。実測: トップレベルで `z` が `1` を返し、
`Klass.ancestors` に `A` が入っている（`[Klass, Object, A]`）。

> ancestors: Returns a list of modules included/prepended in _mod_ (including _mod_ itself).
> — https://docs.ruby-lang.org/en/4.0/Module.html

**`ancestors` がメソッド探索の順序です。** `include` したモジュールはクラスの**後ろ**に入る。
同じ名前のメソッドがあったときどちらが勝つかは、この並びで決まります。

（トップレベルの `include` は全クラスに影響するので、自分のコードでは避ける形です。
ここでは「`include` がどこに何を足すか」を見るために使われている。）

**ここまでで分かったこと**: `include` はクラスのインスタンスにメソッドを足し、
`ancestors` の後ろに入る。次は、それを使った標準ライブラリの 2 つの定番。

## 4. `Comparable` — `<=>` を 1 つ書くと 7 つもらえる

```ruby
class StringSorter
  include Comparable

  attr :str

  def <=>(other)
    str.size <=> other.str.size
  end
  ...
end
```

**自分で書いたのは `<=>` だけ**です。

> The class must define the `<=>` operator, which compares the receiver against another
> object, returning a value less than 0, returning 0, or returning a value greater than 0,
> depending on whether the receiver is less than, equal to, or greater than the other object.
> — https://docs.ruby-lang.org/en/4.0/Comparable.html

`Comparable` はその `<=>` を呼んで、`<`・`<=`・`==`・`>`・`>=`・`between?`・`clamp` を
組み立てます。実測: `a < b`・`a.between?(a, b)`・`a.clamp(a, b)`・`[b,a].sort` が全部動く。

`str.size <=> other.str.size` は Integer の `<=>` に丸投げしています。**比較の基準だけを
決めれば、比較の道具一式が付いてくる。**

（`Array#sort` も `<=>` を使うので、`Comparable` を include しなくても `sort` は動きます。
ただし `<` や `between?` は `Comparable` が無いと生えません。）

`attr :str` は読み取りメソッド `str` を作ります。`attr_reader :str` と同じ（手本は公式
ドキュメントの原文をそのまま写している）。

**ここまでで分かったこと**: 1 つ実装すると一式もらえる形。次は、その極端な例。

## 5. `Enumerable` — `each` を 1 つ書くと全部もらえる

```ruby
class Foo
  include Enumerable

  def each
    yield 1
    yield 1, 2
    yield
  end
end
```

> Implement method `each` which must yield successive elements of the collection.
> — https://docs.ruby-lang.org/en/4.0/Enumerable.html

**課題 7 で「Enumerable が要求するのは `each` ただ 1 つ」と言った回収**です。実測で、
`each` しか書いていない `Foo` に `to_a`・`map`・`sort_by` が全部生えています。

`each` を書かずに `map` を呼ぶと `NoMethodError`。**土台の 1 つが無いと、その上の全部が
動かない**——`Comparable` と `<=>` の関係と同じ構造です。

手本の `each` は `yield` に渡す引数の数を 1 個・2 個・0 個と変えていて、実測で
`to_a` は `[1, [1, 2], nil]` になります。**`yield` に渡した値がそのまま要素になる**ことと、
複数渡すと配列に、渡さないと `nil` になることが見えます。

**ここまでで分かったこと**: `include` の使いどころ。最後に、`include` ではない足し方。

## 6. `extend` — 1 つのオブジェクトだけに足す

```ruby
module Mod
  def hello = "Hello from Mod.\n"
end

class Klass
  def hello = "Hello from Klass.\n"
end
```

> extend: Adds to _obj_ the instance methods from each module given as a parameter.
> — https://docs.ruby-lang.org/en/4.0/Object.html

実測で差がはっきりします。

```
k = Klass.new
k.hello            #=> "Hello from Klass."
k.extend(Mod)
k.hello            #=> "Hello from Mod."     ← k だけ変わった
Klass.new.hello    #=> "Hello from Klass."   ← 新しいインスタンスは元のまま
```

**`include` はクラスに、`extend` はそのオブジェクト 1 個に足す。**

`ancestors` で見ると位置の違いが読めます。

```
Klass.ancestors                  #=> [Klass, Object, A]
k.singleton_class.ancestors      #=> [#<Class:#<Klass:...>>, Mod, Klass]
```

**`Mod` が `Klass` より前に、`k` だけの層として差し込まれている。** だから `k.hello` で
`Mod` のほうが勝ちます。§3 で見た「`ancestors` の並びで決まる」がそのまま効いている。

**ここまでで分かったこと**: この手本の全部。名前空間（§2）→ `include` の仕組み（§3）→
`Comparable`（§4）→ `Enumerable`（§5）→ `extend` との違い（§6）。

## 書式について

- 手本はメソッド呼び出しの括弧を省く書き方（`assert_equal 1, z`）と付ける書き方（`k.extend(Mod)`）が
  混ざっている。Ruby では引数のある呼び出しの括弧は任意で、`assert_equal` のように
  「文のように読ませたい」呼び出しでは省くのが慣例。判定の書式検査は括弧を見ない。

## JS ではこうだが Ruby では

### ES modules と Ruby の module は別物（名前空間の側）

JS の `import` / `export`（MDN「JavaScript modules」）は**ファイル**の単位で、
`export` した名前を別ファイルから `import` する仕組み。名前空間が欲しいときは
`import * as Module from "./modules/module.js"` と書いて `Module.foo` の形にする。
Ruby の `module` は**ファイルと無関係**で、`Outer::Inner` という名前の入れ物をコード上で作る。
1 ファイルに複数の module を書いてもよいし、1 つの module を複数ファイルで開き直してもよい
（公式ドキュメント「A module may be reopened any number of times」）。
逆に Ruby でファイルを読み込む `require` / `require_relative` は名前空間を作らない——
読み込むと、そのファイルが定義した名前がそのまま今の世界に現れる。
JS の「1 ファイル 1 モジュール、default export は 1 つ」という制約は Ruby には無い。

### 多重継承の代替（mixin の側）

JS の `class` は `extends` で 1 つの親しか持てず、複数のクラスの機能を混ぜる標準構文は無い
（MDN の Modules ガイドにも mixin の構文は無く、`Object.assign(Class.prototype, ...)` のような
手作業になる）。Ruby は `include` が同じ役割を担い、1 つのクラスに複数のモジュールを混ぜられる。
`Comparable` と `Enumerable` は標準ライブラリがその形で提供している能力の代表例で、
「決められた 1 メソッド（`<=>` / `each`）を書くと、残りが生える」という契約になっている。
JS で同じことをするなら、`Symbol.iterator` を実装して `for...of` やスプレッドを使えるようにする
のが近いが、`map` / `filter` は生えない（配列に変換してから呼ぶ）。

### `extend` に相当するものが JS には見えにくい

Ruby の `k.extend(Mod)` は、インスタンス 1 個だけに機能を足す。JS で近いのは
`Object.assign(k, mod)` でプロパティを直接そのオブジェクトへ写す形だが、
Ruby の `extend` は写しではなく**そのオブジェクトの探索経路（ancestors）にモジュールを挿す**ので、
あとから `Mod` にメソッドを足せば `k` からも呼べるようになる。

## 底本の URL

- https://docs.ruby-lang.org/en/4.0/syntax/modules_and_classes_rdoc.html
- https://docs.ruby-lang.org/en/4.0/Comparable.html
- https://docs.ruby-lang.org/en/4.0/Enumerable.html
- https://docs.ruby-lang.org/en/4.0/Object.html#method-i-extend
- https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Modules
