# 模範解説（rb1-13-modules-mixins）

`why.md` を自分の言葉で書き終えてから読む。

## 原典との差分（教材がこの手本に加えた編集）

底本は、公式リファレンスの Modules and Classes（module / 名前空間 / ネスト / include の各節）、
Comparable の項、Enumerable の項、Object#extend の項。加えた編集は次のとおり。

1. **4 つの節の例を 1 ファイルに連結した。** `Outer::Inner`・`module A` と `include A`・
   `StringSorter`（Comparable）・`Foo`（Enumerable）・`Mod` と `Klass`（extend）は、
   それぞれ別のページの例である。識別子・メソッド本体は原文のまま。
2. **`attr :str` は原文のまま残した。** Comparable の項の例がこの書き方をしている。
   いまは `attr_reader :str` と書くのが普通だが、原文の型を変えないためそのままにしてある
   （この差は「手本の各行がしていること」にも書いてある）。
3. **`# => ` のコメントと `puts` を `assert` に置き換えた。** 原典が
   `s1 < s2 # => true`、`[s3, s2, s5, s4, s1].sort # => [...]` と結果をコメントで示している箇所を、
   `assert_operator` / `assert_equal` に直した。分岐も式も変えていない。
4. **Enumerable の例は `each_entry` で受けた。** 原典の `Foo#each` は `yield 1` / `yield 1, 2` /
   `yield` の 3 通りを投げる例で、それを受けるのが `each_entry` であることも原文の説明にある。

## 手本の各行がしていること

- `module Outer; module Inner; end; end` — `module` は中に書いた定数・クラス・メソッドの名前を
  `Outer::Inner` という形で囲う。公式ドキュメントは「モジュールは名前空間と mixin の 2 つの目的を持つ」と
  書き、名前空間の例として irb の `Context` が他の `Context` とぶつからないことを挙げている。
  `Outer::Inner.name` が `"Outer::Inner"` になるのは、囲われた名前がその形で世界に登録されるため。
- `module A; Z = 1; def z; Z; end; end` と `include A` — module の中に `def` で定義したメソッドは、
  そのままでは呼べない。`include` して初めて呼べる。公式ドキュメントの言い方は
  「Instance methods defined in a module are only callable when included」。
  手本ではトップレベルで `include A` しているので、足された先は `Object` になる。だから
  テストクラスのインスタンスからも `z` が呼べ、`self.class.ancestors` に `A` が現れる。
- `class StringSorter; include Comparable; def <=>(other) ... end` — 自分で書くのは `<=>` 1 つだけ。
  `<` `<=` `==` `>=` `>` `between?` `clamp` は `Comparable` が `<=>` を呼んで組み立てる。
  `<=>` は「左が小さければ負の数・等しければ 0・大きければ正の数、比べられなければ `nil`」を返す約束。
  `str.size <=> other.str.size` は Integer の `<=>` に丸投げしている。
- `[s3, s2, s5, s4, s1].sort` — `Array#sort` も `<=>` を使う。`Comparable` を include していなくても
  `<=>` さえあれば `sort` は動くが、`<` や `between?` は `Comparable` が無いと生えない。
- `class Foo; include Enumerable; def each; yield 1; ...` — `Enumerable` は逆向きで、
  `each` を自分で書くと `map` / `select` / `count` などが生える。公式ドキュメントの使い方は
  「Include it」「Implement method each which must yield successive elements」の 2 段。
  手本の `each` は 1 個・2 個・0 個と引数の数を変えて `yield` しており、`each_entry` は
  それぞれを `1`・`[1, 2]`・`nil` として渡す。
- `k.extend(Mod)` — `include` がクラス全体に足すのに対し、`extend` は**そのオブジェクト 1 個**に足す。
  だから `k.hello` は `Mod` のものに変わり、新しく作った `Klass.new.hello` は元のままになる。
- `attr :str` — 読み取りメソッド `str` を作る。`attr_reader :str` と同じ。手本は公式ドキュメントの
  原文をそのまま写している。

## 書式について

- 手本はメソッド呼び出しの括弧を省く書き方（`assert_equal 1, z`）と付ける書き方（`k.extend(Mod)`）が
  混ざっている。Ruby では引数のある呼び出しの括弧は任意で、`assert_equal` のように
  「文のように読ませたい」呼び出しでは省くのが慣例。判定の書式検査は括弧を見ない。

## JS 対比

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

## 底本 URL

- https://docs.ruby-lang.org/en/4.0/syntax/modules_and_classes_rdoc.html
- https://docs.ruby-lang.org/en/4.0/Comparable.html
- https://docs.ruby-lang.org/en/4.0/Enumerable.html
- https://docs.ruby-lang.org/en/4.0/Object.html#method-i-extend
- https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Modules
