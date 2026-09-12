# rb1-17-files-io — ファイルとディレクトリ

## この課題を終えると何ができるようになるか / 全体のどこにいるか

**位置**: Ruby 軸・レベル「基礎」・課題 17（全 21 課題の 17 本目）。

**到達点**: この課題を終えると、次のことができるようになる。

- `File.read` / `File.write` / ブロック付き `File.open` を目的で使い分けられる。
- `File.foreach` と `File.readlines` の違い（1 行ずつ渡すか、全行の配列を作るか）を説明できる。
- `Pathname` でパスを組み立て、親・ファイル名・中身の一覧を取れる。
- `FileUtils.mkdir_p` と `Dir.children` / `Dir.glob` でディレクトリを作り、中身を数えられる。

## 初めて使う道具

なし。

## 前提

- 課題 16（`tasks/rb1-16-band/README.md`）までが完了していること。
- 成果リポ `~/lab/ruby-learning/ruby-core` と教材リポ `~/lab/ruby-learning/ruby-core-materials` の
  両方で `bundle install` が済んでいること（課題 1 の手順 2・3）。
- 課題 11 で `begin` / `rescue` / `ensure` を、課題 7 で Array と Enumerable を済ませていること。
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

開くファイル: `~/lab/ruby-learning/ruby-core-materials/tasks/rb1-17-files-io/original/files.rb`

この手本は、公式リファレンスの File・IO・Pathname・FileUtils・Dir の各項に載っている例を
つないで、一時ディレクトリの中で動くようにしたもの。
手本は**定義だけ**。定義を呼び出して結果を確かめるコードは、教材が配る照合テスト
`copy_test/files_test.rb` にある。**写さない。読んでよい。**
底本の URL はファイル冒頭のコメントにある。先にそのページを読んでおくと分かりやすい。

### 手順 2 — 成果リポへ手で打ち込む

実行する場所: `~/lab/ruby-learning/ruby-core`

```sh
cd ~/lab/ruby-learning/ruby-core
mkdir -p rb1-17-files-io
```

エディタで `rb1-17-files-io/files.rb` を新規作成し、手本を手で打ち込む。

- 1 行目の `# frozen_string_literal: true` は写す（何をする行かは課題 6 で扱う）。その下の底本の URL を書いたコメント群は写さなくてよい。
- クラス名・メソッド名・変数名・文字列は手本どおりに写す。

### 手順 3 — 写しを照合テストで確かめる

実行する場所: `~/lab/ruby-learning/ruby-core`

```sh
cd ~/lab/ruby-learning/ruby-core
bundle exec ruby -Irb1-17-files-io \\
    ../ruby-core-materials/tasks/rb1-17-files-io/copy_test/files_test.rb
```

最終行に `6 runs, 16 assertions, 0 failures, 0 errors, 0 skips` が出れば写しは正しい。
`failures` や `errors` が 0 でないときは、表示される
「期待した値（Expected）／実際の値（Actual）」を読んで打ち間違いを探す。

書式も確かめておく。

実行する場所: `~/lab/ruby-learning/ruby-core-materials`

```sh
cd ~/lab/ruby-learning/ruby-core-materials
bundle exec rubocop --config .rubocop.yml ../ruby-core/rb1-17-files-io/files.rb
```

`no offenses detected` になるまで直す。

### 手順 4 — 「なぜこう書くか」を書く

教材リポの `tasks/rb1-17-files-io/why.md` を、成果リポの `rb1-17-files-io/why.md` へコピーする。

実行する場所: `~/lab/ruby-learning`

```sh
cd ~/lab/ruby-learning
cp ruby-core-materials/tasks/rb1-17-files-io/why.md ruby-core/rb1-17-files-io/why.md
```

コピーしたファイルを開き、見出しの下に自分の言葉で書き足す。
**模範解説（`commentary.md`）はまだ開かない。**

### 手順 5 — 模範解説と突き合わせる

書き終えたら、教材リポの `tasks/rb1-17-files-io/commentary.md` を開いて読む。
自分が書いたことと食い違う箇所、思いつかなかった箇所を `why.md` に追記してよい。

### 手順 6 — 確認課題

1 つのディレクトリの下にテキストを出し入れする `TextStore` の 4 つのメソッドを実装する。
各メソッドが何を返すかは雛形のコメントと判定テストに書いてある。

まず雛形を成果リポへ置く。

実行する場所: `~/lab/ruby-learning`

```sh
cd ~/lab/ruby-learning
mkdir -p ruby-core/rb1-17-files-io/exercise/lib ruby-core/rb1-17-files-io/exercise/test
cp ruby-core-materials/tasks/rb1-17-files-io/exercise/lib/text_store.rb \
     ruby-core/rb1-17-files-io/exercise/lib/text_store.rb
```

判定テストは教材リポの `tasks/rb1-17-files-io/exercise/test/text_store_test.rb` にある。**読んでよい。**

自分でテストを走らせて確かめる。

実行する場所: `~/lab/ruby-learning/ruby-core`

```sh
cd ~/lab/ruby-learning/ruby-core
bundle exec ruby -Irb1-17-files-io/exercise/lib \
    ../ruby-core-materials/tasks/rb1-17-files-io/exercise/test/text_store_test.rb
```

判定テストに自分の `assert` を足したくなったら、成果リポ側に自分のテストファイルを作って書く
（教材リポのファイルは編集しない）。自分で足した `assert` は判定の対象にはならないが、
書くこと自体がこの学習計画の狙いの一部である。

### 手順 7 — `bin/check` を通す

実行する場所: `~/lab/ruby-learning/ruby-core-materials`

```sh
cd ~/lab/ruby-learning/ruby-core-materials
bin/check rb1-17-files-io ../ruby-core
```

全項目が `[合格]` になるまで直す。

## 完了の判定

次がすべて満たされたときに完了とする。判定の正本はこの節である。

1. `bin/check rb1-17-files-io ../ruby-core` の全項目が `[合格]`（終了コード 0）。
   内訳は「写しの照合」「写しの書式」「`why.md` が雛形と差分あり」「確認課題テスト」の 5 項目。
   終了コードは `echo $?` で見る。
2. 機械判定に載らない工程として、次の 2 つを終えている。
   - `why.md` を、模範解説（`commentary.md`）を開く前に自分の言葉で書いた。
   - `commentary.md` を読み、自分の説明と食い違った点を `why.md` に書き足した。
3. `progress.md` に `完了` と日付が書かれている。

## 進捗の記録

記録先は成果リポの `progress.md`。課題ごとの記録の表に `rb1-17-files-io` の行を足し、
状態（`完了`）・日付・一言メモを書く。書いたらコミットする。

```sh
cd ~/lab/ruby-learning/ruby-core
git add .
git commit -m "rb1-17: ファイルとディレクトリの手本を写し、TextStore を実装した"
```

## 次の課題

次に開くファイル: `~/lab/ruby-learning/ruby-core-materials/tasks/rb1-18-stdlib-lookup/README.md`
