# 模範解説 — rb1-14-equality-value-objects

`why.md` を自分の言葉で書き終えてから読む。

## 読み解き

- `obj = "a"; other = obj.dup` — `dup` は中身の同じ別のオブジェクトを作る。だから
  `obj == other` は真、`obj.equal?(other)` は偽になる。公式ドキュメントは `equal?` について
  「should never be overridden by subclasses as it is used to determine object identity」と書く。
  つまり `equal?` は「同じオブジェクトか（同じ番地か）」専用で、書き換えてはいけない。
- `1 == 1.0` は真、`1.eql?(1.0)` は偽 — 公式ドキュメントの言い方では、数値型は `==` では
  型変換をするが `eql?` ではしない。`eql?` は「Hash のキーとして同じか」を答えるメソッドで、
  `Hash` は `eql?` と `hash` の 2 つでキーの同一性を決める。
- `class Measurement` — `==` を自分で定義し、`alias eql? ==` で `eql?` を同じ実装に向けている。
  公式ドキュメントが書く型（「Subclasses normally continue this tradition by aliasing eql?
  to their overridden == method」）そのまま。`hash` は
  `[self.class, amount, unit].hash` と書く。これも公式ドキュメントが挙げる best practice で、
  `Array#hash` に「クラス名と、そのインスタンスで意味のある値」を渡す型。
  `{ a => :first, b => :second }.size` が 1 になるのは、`eql?` と `hash` が揃って初めて
  「同じキー」になるため。片方だけ書くとここが 2 になる。
- `Customer = Struct.new("Customer", :name, :address, :zip)` — 第 1 引数の文字列は
  作るクラスの名前で、`Struct::Customer` として登録される（だから `Customer.name` は
  `"Struct::Customer"`）。メンバーごとに読み取りと書き込みの 2 つのメソッドができるので、
  `joe.name = "Joseph Smith"` のように**中身を変えられる**。
- `Measure = Data.define(:amount, :unit)` — こちらは書き込みメソッドを作らない。
  公式ドキュメントは「Data provides no member writers, or enumerators: it is meant to be
  a storage for immutable atomic values」と書く。位置引数（`Measure.new(100, "km")`）・
  キーワード引数（`Measure.new(amount: 50, unit: "kg")`）・`Measure[10, "mPh"]` の
  3 つの作り方が最初から付き、`==` と `to_h` と（課題 15 で使う）`deconstruct_keys` も付く。
  ただし「中身が可変クラスなら中身までは凍らない」とも書かれている（配列のメンバーは `<<` できる）。
- `Set[1, 2]` と `[1, 2].to_set` — Ruby 4.0 では `Set` を `require` せずに使える。
  `s1.merge([2, 6])` のあと `s1` は `{1, 2, "foo", 6}` なので、`s1.subset?(s2)` は偽、
  `s2.subset?(s1)` は真。最後の行は `Measurement` を 2 つ入れても 1 件になることを見ている——
  公式ドキュメントの「Equality of elements is determined according to Object#eql? and
  Object#hash」がここで効く。

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
