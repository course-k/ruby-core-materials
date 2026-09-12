# rb1-07-collections-enumerable — Array / Hash / Range と Enumerable

## この課題を終えると何ができるようになるか / 全体のどこにいるか

**位置**: Ruby 軸・レベル「基礎」・課題 7（全 21 課題の 7 本目）。

**到達点**: この課題を終えると、次のことができるようになる。

- 配列・ハッシュ・範囲のリテラルを書け、ハッシュのキーには任意のオブジェクトを使えることを説明できる。
- `each` / `map` / `select` / `reject` / `reduce`（`inject`）/ `each_with_object` / `group_by` /
  `tally` / `sort_by` / `uniq` を、目的に応じて使い分けられる。
- `each` がレシーバを返し `map` が新しい配列を返すという違いを説明できる。
- ブロックを渡す `{ |x| ... }` と `do |x| ... end` の 2 つの書き方を読める。
- 連鎖した Enumerable の式を**実行する前に**読んで、何が出るかを予測できる。

## 初めて使う道具

なし。

## 前提

- 課題 6（`tasks/rb1-06-strings-symbols/README.md`）までが完了していること。
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
7. 出力予測を書く。
8. `bin/check` を通す。

**写しは手で打ち込む。コピー＆ペーストはしない。** 機械はコピーと打ち込みを区別できないので、
これは自分で守る約束として運用する。打ち込むこと自体が、書式の癖（行末のセミコロン、
`camelCase` の変数名、4 スペースのインデント）を自分の手に気づかせるための工程である。

## 手順

### 手順 1 — 手本を読む

開くファイル: `~/lab/ruby-learning/ruby-core-materials/tasks/rb1-07-collections-enumerable/original/collections_and_enumerable.rb`

この手本は、公式リファレンスの Literals（Array / Hash / Range Literals 節）と
Enumerable の各メソッドの項に載っている例をつないだもの。
手本は**定義だけ**。定義を呼び出して結果を確かめるコードは、教材が配る照合テスト
`copy_test/collections_and_enumerable_test.rb` にある。**写さない。読んでよい。**
底本の URL はファイル冒頭のコメントにある。先にそのページを読んでおくと分かりやすい。

### 手順 2 — 成果リポへ手で打ち込む

実行する場所: `~/lab/ruby-learning/ruby-core`

```sh
cd ~/lab/ruby-learning/ruby-core
mkdir -p rb1-07-collections-enumerable
```

エディタで `rb1-07-collections-enumerable/collections_and_enumerable.rb` を新規作成し、手本を手で打ち込む。

- 1 行目の `# frozen_string_literal: true` は写す（何をする行かは課題 6 で扱う）。その下の底本の URL を書いたコメント群は写さなくてよい。
- クラス名・メソッド名・変数名・文字列は手本どおりに写す。

### 手順 3 — 写しを照合テストで確かめる

実行する場所: `~/lab/ruby-learning/ruby-core`

```sh
cd ~/lab/ruby-learning/ruby-core
bundle exec ruby -Irb1-07-collections-enumerable \
    ../ruby-core-materials/tasks/rb1-07-collections-enumerable/copy_test/collections_and_enumerable_test.rb
```

最終行に `13 runs, 24 assertions, 0 failures, 0 errors, 0 skips` が出れば写しは正しい。
`failures` や `errors` が 0 でないときは、表示される
「期待した値（Expected）／実際の値（Actual）」を読んで打ち間違いを探す。

書式も確かめておく。

実行する場所: `~/lab/ruby-learning/ruby-core-materials`

```sh
cd ~/lab/ruby-learning/ruby-core-materials
bundle exec rubocop --config .rubocop.yml ../ruby-core/rb1-07-collections-enumerable/collections_and_enumerable.rb
```

`no offenses detected` になるまで直す。

### 手順 4 — 「なぜこう書くか」を書く

教材リポの `tasks/rb1-07-collections-enumerable/why.md` を、成果リポの `rb1-07-collections-enumerable/why.md` へコピーする。

実行する場所: `~/lab/ruby-learning`

```sh
cd ~/lab/ruby-learning
cp ruby-core-materials/tasks/rb1-07-collections-enumerable/why.md ruby-core/rb1-07-collections-enumerable/why.md
```

コピーしたファイルを開き、見出しの下に自分の言葉で書き足す。
**模範解説（`commentary.md`）はまだ開かない。**

### 手順 5 — 模範解説と突き合わせる

書き終えたら、教材リポの `tasks/rb1-07-collections-enumerable/commentary.md` を開いて読む。
自分が書いたことと食い違う箇所、思いつかなかった箇所を `why.md` に追記してよい。

### 手順 6 — 確認課題

集めた記事の一覧を正規化・集計する `FeedDigest` を、判定テストが通るように実装する。

まず雛形を成果リポへ置く。

実行する場所: `~/lab/ruby-learning`

```sh
cd ~/lab/ruby-learning
mkdir -p ruby-core/rb1-07-collections-enumerable/exercise/lib
cp ruby-core-materials/tasks/rb1-07-collections-enumerable/exercise/lib/feed_digest.rb \
     ruby-core/rb1-07-collections-enumerable/exercise/lib/feed_digest.rb
```

判定テストは教材リポの `tasks/rb1-07-collections-enumerable/exercise/test/feed_digest_test.rb` にある。**読んでよい。**

**作るもの**: 記事のハッシュの配列を受け取る 6 つのメソッド。記事 1 件は
`{ title:, source:, tag:, words: }` の形で渡される。

- `.normalize(entries)` — title の前後の空白を落とし、tag を小文字にした**新しい**配列を返す。
- `.from_source(entries, name)` — その source のものだけを、渡された順のまま返す。
- `.sources(entries)` — 登場する source を重複なく辞書順で返す。
- `.by_source(entries)` — source をキー、記事の配列を値とするハッシュを返す。
- `.tag_counts(entries)` — tag をキー、件数を値とするハッシュを返す。
- `.total_words(entries)` — words の合計。0 件なら 0。

**ここが狙い**: 6 つとも Enumerable の別のメソッドで書ける。どれにどれを使うかを選ぶこと自体が
この課題である（`map` / `select` / `uniq` / `group_by` / `tally` / `reduce`）。
渡された配列とハッシュを書き換えてはいけない——`.normalize` が元を壊していないかを判定テストが見る。

この題材は応用（情報収集ツール）の正規化・集計の部品にあたる。

自分でテストを走らせて確かめる。

実行する場所: `~/lab/ruby-learning/ruby-core`

```sh
cd ~/lab/ruby-learning/ruby-core
bundle exec ruby -Irb1-07-collections-enumerable/exercise/lib \
    ../ruby-core-materials/tasks/rb1-07-collections-enumerable/exercise/test/feed_digest_test.rb
```

判定テストに自分の `assert` を足したくなったら、成果リポ側に自分のテストファイルを作って書く
（教材リポのファイルは編集しない）。自分で足した `assert` は判定の対象にはならないが、
書くこと自体がこの学習計画の狙いの一部である。

### 手順 7 — 出力予測

教材リポの `tasks/rb1-07-collections-enumerable/predict/` に `predict/01.rb`・`predict/02.rb` が入っている。
**実行する前に**、それぞれが標準出力へ何を出すかを読んで予測し、
成果リポの `rb1-07-collections-enumerable/predict/` に `predict/01.txt`・`predict/02.txt` として書き下す。

実行する場所: `~/lab/ruby-learning/ruby-core`

```sh
cd ~/lab/ruby-learning/ruby-core
mkdir -p rb1-07-collections-enumerable/predict
```

書き方: 出力される行をそのままの順序で並べたテキストファイルにする。
行末の改行の有無は判定で無視されるが、行の中身と行数は完全に一致していなければならない。

書き終えてから、`bin/check`（手順 7）で照合する。
先に `ruby` で実行してしまうと予測の練習にならないので、**予測を書き終えるまで実行しない。**
予測が外れたときは、`bin/check` が「最初に食い違う行」の行番号だけを返す。
正解の出力は表示されないので、その行のコードを読み直して考える。

### 手順 8 — `bin/check` を通す

実行する場所: `~/lab/ruby-learning/ruby-core-materials`

```sh
cd ~/lab/ruby-learning/ruby-core-materials
bin/check rb1-07-collections-enumerable ../ruby-core
```

全項目が `[合格]` になるまで直す。

## 完了の判定

次がすべて満たされたときに完了とする。判定の正本はこの節である。

1. `bin/check rb1-07-collections-enumerable ../ruby-core` の全項目が `[合格]`（終了コード 0）。
   内訳は「写しの照合」「写しの書式」「`why.md` が雛形と差分あり」「確認課題テスト」「出力予測 01」「出力予測 02」の 7 項目。
2. 機械判定に載らない工程として、次の 2 つを終えている。
   - `why.md` を、模範解説（`commentary.md`）を開く前に自分の言葉で書いた。
   - `commentary.md` を読み、自分の説明と食い違った点を `why.md` に書き足した。
3. `progress.md` に `完了` と日付が書かれている。

## 進捗の記録

記録先は成果リポの `progress.md`。課題ごとの記録の表に `rb1-07-collections-enumerable` の行を足し、
状態（`完了`）・日付・一言メモを書く。書いたらコミットする。

```sh
cd ~/lab/ruby-learning/ruby-core
git add .
git commit -m "rb1-07: Enumerable の手本を写し、連鎖の出力を予測した"
```

## 次の課題

次に開くファイル: `~/lab/ruby-learning/ruby-core-materials/tasks/rb1-08-methods-arguments/README.md`
