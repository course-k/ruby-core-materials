# rb1-10-classes-objects — クラスとオブジェクト

## この課題を終えると何ができるようになるか / 全体のどこにいるか

**位置**: Ruby 軸・レベル「基礎」・課題 10（全 21 課題の 10 本目）。

**到達点**: この課題を終えると、次のことができるようになる。

- `class` / `initialize` / インスタンス変数 `@x` / `attr_reader` と `attr_accessor` / `self` を使ってクラスを書ける。
- クラスメソッド（`def self.名前`）とインスタンスメソッドの違いを説明できる。
- `to_s` と `inspect` を上書きして、表示を自分で決められる。
- `private` が「レシーバを書いて呼べない」という意味であることを説明できる。
- すでにあるクラスを**開き直して**メソッドを足せることを説明できる（使う側として）。
- 継承したクラスがメソッドと定数を受け継ぐことを説明できる。

## 初めて使う道具

なし。

## 前提

- 課題 9（`tasks/rb1-09-blocks-procs/README.md`）までが完了していること。
- 成果リポ `~/lab/ruby-learning/ruby-core` と教材リポ `~/lab/ruby-learning/ruby-core-materials` の
  両方で `bundle install` が済んでいること（課題 1 の手順 2・3）。
- この課題のために新しく入れるものは無い。

## この課題の進め方（全体像）

1. 手本のファイルを読む。
2. **手で打ち込んで**成果リポに写す。
3. 写しを照合テストで確かめる。
4. 「なぜこう書くか」を自分の言葉で書く。
5. 模範解説を開いて突き合わせる。
6. 確認課題を解く。
7. `bin/check` を通す。

**写しは手で打ち込む。コピー＆ペーストはしない。** 機械はコピーと打ち込みを区別できないので、
これは自分で守る約束として運用する。打ち込むこと自体が、書式の癖（行末のセミコロン、
`camelCase` の変数名、4 スペースのインデント）を自分の手に気づかせるための工程である。

## 手順

### 手順 1 — 手本を読む

開くファイル: `~/lab/ruby-learning/ruby-core-materials/tasks/rb1-10-classes-objects/original/classes_and_objects.rb`

この手本は、公式リファレンスの Modules and Classes（Classes / Inheritance / Visibility の各節）と、
Object#inspect・Module#attr_accessor の項に載っている例をつないだもの。
手本は**定義だけ**。定義を呼び出して結果を確かめるコードは、教材が配る照合テスト
`copy_test/classes_and_objects_test.rb` にある。**写さない。読んでよい。**
底本の URL はファイル冒頭のコメントにある。先にそのページを読んでおくと分かりやすい。

### 手順 2 — 成果リポへ手で打ち込む

実行する場所: `~/lab/ruby-learning/ruby-core`

```sh
cd ~/lab/ruby-learning/ruby-core
mkdir -p rb1-10-classes-objects
```

エディタで `rb1-10-classes-objects/classes_and_objects.rb` を新規作成し、手本を手で打ち込む。

- 1 行目の `# frozen_string_literal: true` は写す（何をする行かは課題 6 で扱う）。その下の底本の URL を書いたコメント群は写さなくてよい。
- クラス名・メソッド名・変数名・文字列は手本どおりに写す。

### 手順 3 — 写しを照合テストで確かめる

実行する場所: `~/lab/ruby-learning/ruby-core`

照合テストは教材リポにあり、写しを置いたディレクトリを `-I` で教える。

```sh
cd ~/lab/ruby-learning/ruby-core
bundle exec ruby -Irb1-10-classes-objects \
    ../ruby-core-materials/tasks/rb1-10-classes-objects/copy_test/classes_and_objects_test.rb
```

最終行に `6 runs, 16 assertions, 0 failures, 0 errors, 0 skips` が出れば写しは正しい。
`failures` や `errors` が 0 でないときは、表示される
「期待した値（Expected）／実際の値（Actual）」を読んで打ち間違いを探す。

書式も確かめておく。

実行する場所: `~/lab/ruby-learning/ruby-core-materials`

```sh
cd ~/lab/ruby-learning/ruby-core-materials
bundle exec rubocop --config .rubocop.yml ../ruby-core/rb1-10-classes-objects/classes_and_objects.rb
```

`no offenses detected` になるまで直す。

### 手順 4 — 「なぜこう書くか」を書く

教材リポの `tasks/rb1-10-classes-objects/why.md` を、成果リポの `rb1-10-classes-objects/why.md` へコピーする。

実行する場所: `~/lab/ruby-learning`

```sh
cd ~/lab/ruby-learning
cp ruby-core-materials/tasks/rb1-10-classes-objects/why.md ruby-core/rb1-10-classes-objects/why.md
```

コピーしたファイルを開き、見出しの下に自分の言葉で書き足す。
**模範解説（`commentary.md`）はまだ開かない。**

### 手順 5 — 模範解説と突き合わせる

書き終えたら、教材リポの `tasks/rb1-10-classes-objects/commentary.md` を開いて読む。
自分が書いたことと食い違う箇所、思いつかなかった箇所を `why.md` に追記してよい。

### 手順 6 — 確認課題

温度を表すクラス `Temperature` を、判定テストが通るように実装する。

まず雛形を成果リポへ置く。

実行する場所: `~/lab/ruby-learning`

```sh
cd ~/lab/ruby-learning
mkdir -p ruby-core/rb1-10-classes-objects/exercise/lib
cp ruby-core-materials/tasks/rb1-10-classes-objects/exercise/lib/temperature.rb \
     ruby-core/rb1-10-classes-objects/exercise/lib/temperature.rb
```

判定テストは教材リポの `tasks/rb1-10-classes-objects/exercise/test/temperature_test.rb` にある。**読んでよい。**

**作るもの**: 次を満たすクラス。雛形は `class Temperature` と `end` だけなので、中身は自分で書く。

- `Temperature.new(degrees)` で作る。`#degrees` で読み出せるが、**書き換えるメソッドは持たない**。
- `Temperature.from_fahrenheit(value)` は**クラスメソッド**で、華氏の値から `Temperature` を作る
  （摂氏 = (華氏 − 32) × 5 ÷ 9。割り算で小数が落ちないように気をつける）。
- `#to_s` は `"20C"` のように、数値のうしろに単位を付けた文字列を返す。
- `#warmer_than?(other)` は、自分のほうが高いときだけ真を返す。
- 単位の文字列 `"C"` を返す `#unit` は **`private`** にする（外から `temperature.unit` と呼べない）。

自分でテストを走らせて確かめる。

実行する場所: `~/lab/ruby-learning/ruby-core`

```sh
cd ~/lab/ruby-learning/ruby-core
bundle exec ruby -Irb1-10-classes-objects/exercise/lib \
    ../ruby-core-materials/tasks/rb1-10-classes-objects/exercise/test/temperature_test.rb
```

判定テストに自分の `assert` を足したくなったら、成果リポ側に自分のテストファイルを作って書く
（教材リポのファイルは編集しない）。自分で足した `assert` は判定の対象にはならないが、
書くこと自体がこの学習計画の狙いの一部である。

### 手順 7 — `bin/check` を通す

実行する場所: `~/lab/ruby-learning/ruby-core-materials`

```sh
cd ~/lab/ruby-learning/ruby-core-materials
bin/check rb1-10-classes-objects ../ruby-core
```

全項目が `[合格]` になるまで直す。

## 完了の判定

次がすべて満たされたときに完了とする。判定の正本はこの節である。

1. `bin/check rb1-10-classes-objects ../ruby-core` の全項目が `[合格]`（終了コード 0）。
   内訳は「写しの照合」「写しの書式」「`why.md` が雛形と差分あり」「確認課題テスト」の 5 項目。
2. 機械判定に載らない工程として、次の 2 つを終えている。
   - `why.md` を、模範解説（`commentary.md`）を開く前に自分の言葉で書いた。
   - `commentary.md` を読み、自分の説明と食い違った点を `why.md` に書き足した。
3. `progress.md` に `完了` と日付が書かれている。

## 進捗の記録

記録先は成果リポの `progress.md`。課題ごとの記録の表に `rb1-10-classes-objects` の行を足し、
状態（`完了`）・日付・一言メモを書く。書いたらコミットする。

```sh
cd ~/lab/ruby-learning/ruby-core
git add .
git commit -m "rb1-10: クラスの手本を写し、Temperature を実装した"
```

## 次の課題

次に開くファイル: `~/lab/ruby-learning/ruby-core-materials/tasks/rb1-11-exceptions/README.md`
