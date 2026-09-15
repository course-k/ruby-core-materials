# 模範解説 — rb1-10-classes-objects

`why.md` の §1〜§3 を書き終えてから開く。読み終えたら §4「突き合わせで変わったこと」を書く。

この解説は **前の節で分かったことの上に次の節が乗る順序**で並べてある。
§4（可視性）は §2（インスタンス変数は外から見えない）の延長で、§5・§6 は §3（`self` が何を指すか）
が分かって初めて立つ。飛ばさずに読む。

## 1. この手本は何を見せているか

課題 2 で `Greeter` と `attr_accessor` と「クラスの再オープン」を通り過ぎました。
**この手本はその全部を正面から扱い直します。**

手本の 8 つのクラスは、それぞれ 1 つの問いに答えるために置かれています。

| クラス | 答える問い |
|---|---|
| `Foo` / `Bar` | オブジェクトは何を持っているか |
| `A` / `B` | 継承で何が引き継がれるか |
| `Attrs` | `attr_accessor` は何を作るか |
| `Owner` | **`private` は何を禁じているか** |
| `Reopened` | 再オープンで何が起きるか |
| `C` | クラス自身のメソッドはどう書くか |

**`Owner` が山場**です。4 つのメソッドの差が 1 つのことを示しています。

## 2. オブジェクトが持つもの — インスタンス変数

手本は空のクラスと、変数を 1 つ持つクラスを並べています。

```ruby
class Foo
end

class Bar
  def initialize
    @bar = 1
  end
end
```

差は `inspect` に出ます（実測）。

```
Foo.new.inspect   #=> "#<Foo:0x...>"
Bar.new.inspect   #=> "#<Bar:0x... @bar=1>"
Bar.new.instance_variables   #=> [:@bar]
```

> An instance variable must start with a `@` ("at" sign or commercial at).
> An uninitialized instance variable has a value of `nil`.
> — https://docs.ruby-lang.org/en/4.0/syntax/assignment_rdoc.html

**宣言する場所がありません。** 代入した時点で作られる。Java のメンバ変数宣言や TS の
フィールド宣言に当たるものが無く、未定義のものを読んでも `nil` でエラーになりません。

そして課題 2 で見たとおり、**外からは触れない**。触れるようにするのが `attr_accessor` です。

> Defines a named attribute for this module, where the name is _symbol_.`id2name`,
> creating an instance variable (`@name`) and a corresponding access method to read it.
> Also creates a method called `name=` to set the attribute.
> — https://docs.ruby-lang.org/en/4.0/Module.html

実測で「何が生えるか」が見えます。

```ruby
class Attrs
  attr_accessor :one, :two
end
Attrs.instance_methods(false)   #=> [:one, :one=, :two, :two=]
```

**2 つ書くと 4 つのメソッド。** 読み取りだけなら `attr_reader`、書き込みだけなら `attr_writer`。

`to_s` と `inspect` も押さえておきます。`to_s` は人に見せる表現で `puts` と `#{ }` が呼び、
`inspect` は中身が分かる表現で `p` とデバッガが呼ぶ。原典は「自分のクラスではこのメソッドを
上書きして、もっと良い表現を返すべきである」と書いています。

**ここまでで分かったこと**: オブジェクトの中身と、外への開け方。
次は「中」と「外」を決めている `self`。

## 3. `self` が指すもの

> `self` refers to the object that defines the current scope.
> `self` will change when entering a different method or when defining a new module.
> — https://docs.ruby-lang.org/en/4.0/syntax/modules_and_classes_rdoc.html

**「いまのスコープを定義しているオブジェクト」。** 位置によって変わります。

| 書いた場所 | `self` が指すもの |
|---|---|
| クラス定義の直下 | そのクラス自身 |
| インスタンスメソッドの中 | そのインスタンス |

だから `class Attrs` の直下に書いた `attr_accessor :one` は、**`Attrs` というオブジェクトに対する
メソッド呼び出し**です（課題 2 で「文法ではなくメソッド」と言ったのはこれ）。

JS の `this` は呼び出し方で変わり、`bind` や アロー関数で束縛し直す必要がありました。
**Ruby の `self` は書いた場所で決まる**ので、その悩みがありません。

**ここまでで分かったこと**: `self` の決まり方。次は、それを使って可視性が定義されている。

## 4. `private` が禁じているのは「レシーバを書くこと」

手本の `Owner` が山場です。4 つのメソッドを比べます。

```ruby
class Owner
  def without    = m              # レシーバ無し
  def with_self  = self.m         # self がレシーバ
  def with_other = Owner.new.m    # 別のインスタンスがレシーバ
  def m = 1
  private :m
end
```

実測の結果:

| 呼び方 | 結果 |
|---|---|
| `without`（レシーバ無し） | `1` |
| `with_self`（`self.m`） | `1` |
| `with_other`（`Owner.new.m`） | **`NoMethodError: private method 'm' called`** |
| 外から `o.m` | **`NoMethodError`** |

> A private method may only be called from inside the owner class **without a receiver**,
> or **with a literal `self` as a receiver**.
> — modules_and_classes_rdoc

**`private` が禁じているのは「レシーバを書くこと」です。** 「誰が呼べるか」ではなく
「どう書けるか」の制限。だから**同じクラスの別インスタンスでも呼べません**（`with_other`）。

ここは JS と切り方が違います。JS の `#private` は同じクラスの別インスタンスからでも触れます
（`this.#x` も `other.#x` も可）。「クラス単位」の JS に対して、Ruby は「レシーバの書き方」単位。

可視性は 3 段階で、既定は `public`。3 つ目の `protected` は、その切り方の違いを埋めるためにあります。

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

書き方は 2 つあります。手本が使っている `private :m`（定義したあとで指定する）と、
`private` と 1 行書いて**それ以降**を private にする形。後者は「スコープの終わりまで効く」ので、
あとからメソッドを足すときに位置に注意が要ります。

**ここまでで分かったこと**: 外から見えるものの決め方。次は、クラス自身に手を入れる 2 つの形。

## 5. クラス自身のメソッド — `class << self`

`self` がクラスを指す場所（§3）にメソッドを定義すると、そのクラス自身のメソッドになります。

```ruby
class C
  class << self
    def my_method
      1 + 1
    end
  end
end
```

実測: `C.my_method` は `2`。

> This allows definition of methods and attributes on a class (or module) without needing to
> write `def self.my_method`.
> — modules_and_classes_rdoc

`def self.my_method` と同じ意味です。**まとめて何本も定義するときに `class << self` が便利**という
だけの違い。

継承で引き継がれるものも確かめておきます。

```ruby
class A
  Z = 1
  def z = Z
end

class B < A
end
```

> The same is true for constants.（継承について）
> — modules_and_classes_rdoc

実測: `B.new.z` は `1`、`B::Z` も `1`。**メソッドだけでなく定数も引き継がれます。**

**ここまでで分かったこと**: クラス自身に対する定義。最後に、定義を後から足す形。

## 6. クラスの再オープン

課題 2 の `Greeter` で見た仕組みの、正式な回収です。

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

> Just like modules, classes can also be reopened.
> You can omit its superclass when you reopen a class.
> — modules_and_classes_rdoc

2 回目の `class Reopened` は**新しいクラスを作らず、すでにあるクラスを開き直します**。
実測: `Reopened.new(7).one` は `7`——2 つのブロックで定義したものが 1 つのクラスに揃っている。

別のファイルからでも、**標準ライブラリのクラス（`String` など）に対してでも**できます。
JS でこれをするにはプロトタイプに代入する必要がありますが、Ruby は言語の正規の書き方として
公式入門に載っている。

この課題では「そういう仕組みがある」と読めれば足ります。**自分の設計として使うのは
Ruby 中級の範囲**（オープンクラスとメタプログラミング）です。

**ここまでで分かったこと**: この手本の全部。オブジェクトの中身（§2）→ `self`（§3）→
可視性（§4）→ クラス自身への定義（§5）→ 後から足す（§6）。

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
