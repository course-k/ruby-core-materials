# 模範解説 — rb1-14-equality-value-objects

`why.md` の §1〜§3 を書き終えてから開く。読み終えたら §4「突き合わせで変わったこと」を書く。

この解説は **前の節で分かったことの上に次の節が乗る順序**で並べてある。
§3（なぜ `hash` も要るか）は §2（3 つの等価）が分かって初めて立ち、§4（Struct / Data）は
§3 の手間を省く道具として、§5（Set）は §3 の約束が効く場所として立つ。飛ばさずに読む。

## 1. この手本は何を見せているか

課題 4 で `==` に触れ、「等価性は課題 14 で扱う」と送りました。**その回収です。**

手本は 3 つの定義しかありませんが、**同じことを 3 通りのやり方で**見せています。

| 定義 | やり方 |
|---|---|
| `Measurement` | `==`・`eql?`・`hash` を**全部自分で書く** |
| `Customer = Struct.new(...)` | 既成の道具に任せる（中身を**変えられる**） |
| `Measure = Data.define(...)` | 既成の道具に任せる（中身を**変えられない**） |

**`Measurement` を先に読むと、`Struct` / `Data` が何を省いてくれているかが分かります。**

## 2. 「同じ」には 3 種類ある

Ruby は「同じ」を問うメソッドを 3 つ持っています。

> **equal?**: should never be overridden by subclasses as it is used to determine object identity.
> **eql?**: Returns `true` if `obj` and `other` refer to the same hash key.
> This is used by Hash to test members for equality.
> For objects of class Object, `eql?` is synonymous with `==`.
> — https://docs.ruby-lang.org/en/4.0/Object.html

| メソッド | 問うていること | 上書きしてよいか |
|---|---|---|
| `equal?` | **同じオブジェクトか**（同じ番地か） | **してはいけない** |
| `==` | 値として等しいか | する |
| `eql?` | **Hash のキーとして**同じか | する |

実測で 3 つの差が出ます。

```ruby
a = "x"; b = "x"
a == b        #=> true
a.eql?(b)     #=> true
a.equal?(b)   #=> false   ← 別のオブジェクト

1 == 1.0      #=> true    ← 型を越えて等しい
1.eql?(1.0)   #=> false   ← Hash のキーとしては別物
1.equal?(1)   #=> true
```

**`==` と `eql?` の差がいちばん分かりにくい**ですが、数値がそれを見せてくれます。原文の
説明どおり「Numeric は `==` では型変換をするが `eql?` ではしない」。`1` と `1.0` を Hash の
別のキーとして使いたいからです。

**ここまでで分かったこと**: 3 つの「同じ」。次は、自分のクラスでそれを定義するとき、
なぜ `hash` まで書かなければならないのか。

## 3. `eql?` を書いたら `hash` も書く — その理由

手本の `Measurement` は 3 つとも書いています。

```ruby
def ==(other)
  other.is_a?(self.class) && amount == other.amount && unit == other.unit
end

alias eql? ==

def hash
  [self.class, amount, unit].hash
end
```

`alias eql? ==` は「`==` の定義を `eql?` の名前でも使う」という 1 行。公式ドキュメントが
書く型（「Subclasses normally continue this tradition by aliasing `eql?` to their overridden
`==` method」）そのままです。

**問題は `hash` のほうです。なぜ要るのか。**

> hash: Returns the integer hash value for `self`; **has the property that if `foo.eql?(bar)`
> then `foo.hash == bar.hash`**.
> Hash uses **both** `hash` and `eql?` to determine whether two objects used as hash keys are
> to be treated as the same key.
> — Object.html

**Hash は `hash` を先に引きます。** その値でバケツを選び、同じバケツの中だけを `eql?` で
照合する。だから `hash` が違うと、**`eql?` まで到達しません**。

実測で壊れ方が見えます。

```ruby
# eql? だけ書いて hash を書かないクラス
h = {}
h[NoHash.new(1)] = :a
h[NoHash.new(1)]        #=> nil    ← 入れたのに引けない

# 手本の Measurement（hash も書いてある）
{ Measurement.new(1,"km") => :ok }[Measurement.new(1,"km")]   #=> :ok
```

**これが「片方だけ書くと壊れる」の正体**です。`hash` の中身は
`[self.class, amount, unit].hash` と書く定石——`Array#hash` に「クラス名と、そのインスタンスで
意味のある値」を渡す形です。

**ここまでで分かったこと**: 3 つ揃えないといけない理由。
**この 3 つを毎回書くのは面倒です。** 次はそれを省く道具。

## 4. `Struct` と `Data` — 3 つを書かずに済ませる

```ruby
Customer = Struct.new("Customer", :name, :address, :zip)
Measure = Data.define(:amount, :unit)
```

どちらも**`==` を最初から持っています**（実測: 同じ値で作った 2 つが `==` で真）。
§3 の手間がまるごと不要になる。

違いは 1 点です。

> Class Data provides a convenient way to define simple classes for value-alike objects.
> **Data provides no member writers, or enumerators**: it is meant to be a storage for
> immutable atomic values.
> See also Struct, which is a similar concept, but has **more container-alike API, allowing
> to change contents of the object** and enumerate it.
> — https://docs.ruby-lang.org/en/4.0/Data.html

実測:

```ruby
c = Customer.new("Dave", "123 Main", "12345")
c.name = "Changed"          # 通る。Struct は書き換えられる

m = Measure.new(amount: 1, unit: "km")
m.respond_to?(:amount=)     #=> false   ← 書き込みメソッドが無い
```

**選ぶ基準は「後から中身を変えるか」。変えないなら `Data`。**

`Struct.new` の第 1 引数の文字列は作るクラスの名前で、`Struct::Customer` として登録されます
（だから `Customer.name` は `"Struct::Customer"`）。

`Data` には 3 つの作り方（`Measure.new(100, "km")` / `Measure.new(amount: 50, unit: "kg")` /
`Measure[10, "mPh"]`）と、`to_h`、そして課題 15 で使う `deconstruct_keys` が最初から付きます。

**ただし不変性は浅い**ことに注意。

> But note that if some of data members is of a mutable class, Data does no additional
> immutability enforcement.

配列のメンバーは `<<` で中身を足せます。

**ここまでで分かったこと**: 自分で書く形と、任せる形。最後に、§3 の約束が効く場所。

## 5. `Set` — `eql?` と `hash` がそのまま効く

> Equality of elements is determined according to `Object#eql?` and `Object#hash`.
> — https://docs.ruby-lang.org/en/4.0/Set.html

**`==` ではありません。** `Set` は内部で `Hash` を使っているので、§3 で見た約束がそのまま
重複判定に効きます。

実測:

```ruby
Set[Measurement.new(1,"km"), Measurement.new(1,"km")].size   #=> 1   ← eql? と hash が揃っている
Set[NoHash.new(1), NoHash.new(1)].size                       #=> 2   ← hash が無いと別物扱い
```

**「`==` では等しいのに `Set` が重複と見なさない」という症状が出たら、`hash` を書き忘れています。**

Ruby 4.0 では `Set` を `require` せずに使えます。`Set[1, 2]` や `[1, 2].to_set` で作れる。

**ここまでで分かったこと**: この手本の全部。3 つの等価（§2）→ `hash` が要る理由（§3）→
書かずに済ませる道具（§4）→ 約束が効く場所（§5）。

**この課題で得た「何を同じとみなすかを自分で決める」力は、応用の重複排除でそのまま使います**
（`00-policy.md` §3 の情報収集ツールが、収集した item の重複を除くところ）。

## JS ではこうだが Ruby では

### JS にはオブジェクトの「値としての等価性」を定義する手段が無い

MDN の「Equality comparisons and sameness」は、`==`・`===`・`Object.is()` の 3 つを挙げたうえで
「For any non-primitive objects x and y which have the same structure but are distinct objects
themselves, all of the above forms will evaluate to false」「JavaScript does not provide a
general deep comparison operator」と書く。つまり `{a: 1} === {a: 1}` は偽で、
JS 側でこれを真にする言語機能は無い（ライブラリの deep equal を持ち込むしかない）。
Ruby は `==` を自分で定義できるので、`Measurement.new(100, "km") == Measurement.new(100, "km")` を
真にできる。`Data` を使えばその定義を書かずに手に入る。

### Map / Set のキーは JS では常に同一性で比べられる

MDN によれば `Map` と `Set` のキー比較は SameValueZero で、これは
「`NaN` を等しいとみなす」点以外は `===` と同じ。だから JS の `new Set([{a:1},{a:1}]).size` は 2 で、
オブジェクトを値として重複排除することはできない（キーを文字列に直して回避するのが定石）。
Ruby の `Set` は `eql?` と `hash` を見るので、その 2 つを定義した自作クラスや `Data` を
そのまま入れれば重複が消える。手本の最後の行がこの差そのもの。

### 「同一性」を問う演算子の位置がずれている

JS で「同じオブジェクトか」を問うのは `===`（プリミティブでは値の比較も兼ねる）。
Ruby で「同じオブジェクトか」を問うのは `equal?` であり、`==` ではない。
JS 経験から `==` を「ゆるい比較」と読むと逆になる——Ruby の `==` は
クラスごとに意味を定義する側で、`equal?` が動かせない側。
なお Ruby の `===` は等価性の演算子ではなく `case` の照合に使う別物（課題 4 で扱った）。

### `Struct` / `Data` に相当するものは JS に無い

JS でこの形に一番近いのは `Object.freeze` した plain object だが、凍らせても等価性は同一性のままで、
アクセサも生えない。Ruby の `Data.define(:amount, :unit)` 1 行が作るのは
「読み取り専用アクセサ・3 通りのコンストラクタ・`==`・`to_h`・`hash`」までを含んだクラス。

## 底本の URL

- https://docs.ruby-lang.org/en/4.0/Object.html#method-i-3D-3D
- https://docs.ruby-lang.org/en/4.0/Object.html#method-i-hash
- https://docs.ruby-lang.org/en/4.0/Struct.html
- https://docs.ruby-lang.org/en/4.0/Data.html
- https://docs.ruby-lang.org/en/4.0/Set.html
- https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Equality_comparisons_and_sameness
