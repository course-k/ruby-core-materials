# 模範解説 — rb1-10-classes-objects

`why.md` を書き終えてから開く。

## 原典との差分（教材がこの手本に加えた編集）

底本は、公式リファレンスの Modules and Classes（Classes / Defining a class / Inheritance /
Visibility の各節）、Object#inspect、Module#attr_accessor、
および公式入門「Ruby in Twenty Minutes」の第 2・3 部。加えた編集は次のとおり。

1. **クラス名の重複を避けるために改名した。** 原典は継承の例・可視性の例・再オープンの例で
   どれも `A` / `B` / `C` / `D` という名前を使い回している。1 つのファイルに並べると
   後の定義が前を壊すので、可視性の例を `Owner`、再オープンの例を `Reopened`、
   `attr_accessor` の例を `Attrs` に改名した。継承の例（`A` / `B` と定数 `Z`）は原典のままである。
   メソッド名（`z` / `without` / `with_self` / `with_other` / `m`）と本体は変えていない。
2. **`# => ` のコメントを `assert` に置き換えた。** `Foo.new.inspect #=> "#<Foo:0x0300c868>"` は
   アドレスが実行ごとに変わるので、`assert_match` に正規表現を渡す形にした。
3. **`protected` の例は手本から外した。** 原典の Visibility 節には `protected` の例
   （`A` / `B` / `C` の 3 クラス）もあるが、手本の行数の上限に収まらないので落とした。
   内容は下の「読み解き」に引用してある。
4. **`with_renamed` の例を落とした。** 原典の `private` の例は
   `copy = self; copy.m`（`self` を別の変数に入れてから呼ぶと `NoMethodError`）という
   4 つ目のメソッドを持つが、`with_other` と同じことを示すので 1 つにした。
5. **再オープンの例は「Ruby in Twenty Minutes」第 3 部どおり、`attr_accessor` を足すだけにした。**
   クラスメソッドは底本を Modules and Classes の Singleton Classes 節へ移し、
   その節の `class C / class << self` と `def my_method / 1 + 1` をつないで原文の形で載せている。
   `to_s` は上書きせず、Object の既定の `to_s`（クラス名とオブジェクト id の符号を出す）を
   `inspect` と同じテストで確かめる形にした。

## 読み解き

### クラスの定義とインスタンスの生成

```ruby
class Reopened
  def initialize(one)
    @one = one
  end
end
```

`Reopened.new(1)` と書くと、Ruby は空のオブジェクトを作ってから `initialize` を呼ぶ。
`new` は言語のキーワードではなく `Class` のメソッドである。

`@one` は**インスタンス変数**。宣言は要らず、代入した時点で生まれる。
代入していないインスタンス変数を読むと `nil` が返る（エラーにはならない）。

### 継承

`class B < A` と書くと `B` は `A` のメソッドも定数も受け継ぐ。
`<` を書かなければ `Object` を継承する。
再オープンのときに違う親クラスを書くと `TypeError: superclass mismatch` になる。

### `attr_accessor` とその仲間

```ruby
class Attrs
  attr_accessor :one, :two
end
```

- `attr_reader :x` … `x` を定義する（読み出しだけ）。
- `attr_writer :x` … `x=` を定義する（書き込みだけ）。
- `attr_accessor :x` … 両方。

`Attrs.instance_methods(false)` に `:one` と `:one=` の 2 つが現れるのがその証拠である。
**既定は「読めない・書けない」**（インスタンス変数は外から見えない）ので、
公開したいものだけを `attr_*` で開ける、という順序になる。

`object.one = 2` は代入文に見えるが、実体は `one=` というメソッドの呼び出しである。

### クラス自身が持つメソッド（特異クラス）

```ruby
class C
  class << self
    def my_method
      1 + 1
    end
  end
end
```

`class << self` で開くのは**特異クラス**——そのオブジェクトだけがメソッドを持つための入れ物。
クラスの中で開けば、そこに定義したメソッドは `C.my_method` の形で呼べる。
底本は「これで `def self.my_method` と書かずにクラスのメソッドと属性を定義できる」と説明している。
`def self.名前` も同じものを作る短い書き方で、どちらを使ってもよい。

### `to_s` と `inspect`

- `to_s` … 人に見せる表現。`puts` と文字列の式展開 `#{ }` が呼ぶ。
- `inspect` … 中身が分かる表現。`p` と配列・ハッシュの表示、デバッガが呼ぶ。

既定の `inspect` は「クラス名・メモリアドレス・インスタンス変数の一覧」を返し、
既定の `to_s` は「クラス名とオブジェクト id の符号」を返す（インスタンス変数は出ない）。
原典は「自分のクラスではこのメソッドを上書きして、もっと良い表現を返すべきである」と書いている。

### 可視性

3 段階ある。既定は `public`。

- **`public`** … 誰からでも呼べる。
- **`private`** … **レシーバを書かずに**呼ぶか、`self.` と書いて呼ぶときだけ呼べる。
  `other.m` の形（`self` 以外のレシーバ）では `NoMethodError`。
  手本の `with_other`（`Owner.new.m`）が落ちるのはこれである。
- **`protected`** … そのクラス（かその子孫）を継承したオブジェクトの中からなら、
  他のオブジェクトをレシーバにして呼べる。`==` のような比較メソッドで、
  相手の内部状態を見たいが外には見せたくないときに使う。原典の例:

  ```ruby
  class A
    def n(other)
      other.m
    end
  end

  class B < A
    def m
      1
    end

    protected :m
  end

  class C < B
  end

  a = A.new
  b = B.new
  c = C.new

  c.n b #=> 1 -- C is a subclass of B
  b.n b #=> 1 -- m called on defining class
  a.n b # raises NoMethodError A is not a subclass of B
  ```

書き方は 2 つある。手本が使っている `private :m`（定義したあとで指定する）と、
`private` と 1 行書いて**それ以降**を private にする形。
後者は「スコープの終わりまで効く」ので、あとからメソッドを足すときに位置に注意が要る。

### クラスの再オープン

```ruby
class Reopened
  def initialize(one)
    @one = one
  end
end

class Reopened
  attr_accessor :one
end
```

2 回目の `class Reopened` は新しいクラスを作らず、**すでにあるクラスを開き直す**。
別のファイルからでも、標準ライブラリのクラス（`String` など）に対してでもできる。

この課題では「そういう仕組みがある」と読めれば足りる。
自分の設計として使うのは Ruby 中級の範囲である。

## JS ではこうだが Ruby では

### 生成の書き順が逆

JS は `new Greeter("Pat")`。Ruby は `Greeter.new("Pat")`。
JS の `new` は**演算子**、Ruby の `new` は**メソッド**である（MDN: Classes）。
だから Ruby では `klass = Greeter; klass.new("Pat")` のように、クラスを変数に入れて呼べる。

### コンストラクタと `this`

| JS | Ruby |
|---|---|
| `constructor(x) { this.x = x }` | `def initialize(x); @x = x; end` |
| `this` | `self` |
| `extends` | `<` |
| `super(...)` | `super(...)`（引数を省くと同じ引数がそのまま渡る） |
| `static foo() {}` | `def self.foo; end` |
| `#private` フィールド / `#method()` | `private`（ただし意味が違う。下記） |
| `get x() {}` / `set x(v) {}` | `attr_reader :x` / `attr_writer :x` |
| `toString()` | `to_s` |

`super` の振る舞いには差がある。Ruby の `super` は**引数を省くと、いま受け取っている引数を
そのまま親へ渡す**。引数を渡さずに呼びたいときは `super()` と括弧を書く。

### `this` の束縛の悩みが無い

JS ではメソッドを値として取り出すと `this` を失う（`const f = obj.method; f()`）。
Ruby の `self` はメソッドの実行中つねにレシーバを指し、ブロックの中でも外と同じものを指す。
`bind` / アロー関数に相当する対処は要らない。

### プロパティは既定で見えない

JS のオブジェクトのプロパティは既定で外から読み書きできる（`#` を付けたときだけ private）。
Ruby のインスタンス変数は**既定で外から見えない**。`attr_*` で開けたものだけが見える。
向きが逆なので、JS の感覚で書くと「なぜ読めないのか」と戸惑う。

### `private` の意味

JS の `#field` は**外から完全に触れない**。
Ruby の `private` は「**レシーバを書いた呼び出しを禁じる**」という構文上の規則であり、
`send(:m)` を使えば外からでも呼べてしまう。隠蔽の強さが違う。
「触るなという印」であって「触れない仕組み」ではない。

### 後からメソッドを足す

JS で既存クラスに足すにはプロトタイプに代入する（`Foo.prototype.bar = function () {}`）。
Ruby は `class Foo` を書き直すだけでよく、これが言語の正規の書き方である。
標準クラスにさえ足せる（この自由さが「オープンクラス」と呼ばれる）。

## 底本の URL

Ruby 側（一次情報）:

- https://docs.ruby-lang.org/en/4.0/syntax/modules_and_classes_rdoc.html
- https://docs.ruby-lang.org/en/4.0/Object.html#method-i-inspect
- https://docs.ruby-lang.org/en/4.0/Object.html#method-i-to_s
- https://docs.ruby-lang.org/en/4.0/Module.html#method-i-attr_accessor
- https://www.ruby-lang.org/en/documentation/quickstart/2/
- https://www.ruby-lang.org/en/documentation/quickstart/3/

JS 側（MDN）:

- https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/class
- https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Classes/Private_properties
- https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/super
