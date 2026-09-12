# rb1-19-optparse-executable — 実行できる Ruby ファイルと OptionParser

## この課題を終えると何ができるようになるか / 全体のどこにいるか

**位置**: Ruby 軸・レベル「基礎」・課題 19（全 21 課題の 19 本目）。

**到達点**: この課題を終えると、次のことができるようになる。

- shebang と実行権限を付けて、Ruby ファイルを `ruby` と打たずに実行できる形にできる。
- 実行の入口（`exe/`）と処理の本体（`lib/`）を分けて置ける。
- `OptionParser` でオプションを定義し、`parse!` で受け取れる。ヘルプが自動で作られることを確かめられる。
- `if __FILE__ == $0` が何を分けているかを説明できる。

## 初めて使う道具

この課題で初めて使うものが 2 つある。

- **`chmod +x <ファイル>`** — ファイルに「実行してよい」という印（実行権限）を付ける
  OS のコマンド。Ruby の機能ではない。shebang の行を書いただけでは
  `./exe/count` と打っても `Permission denied` になる。この 2 つが揃って初めて
  「コマンドとして起動できるファイル」になる。この計画では、Ruby 応用で作る gem が
  実行ファイルを同梱するため、その形をここで 1 度踏んでおく。
- **`bundle exec` を通さない直接実行** — これまでは `bundle exec ruby <ファイル>` と打ってきた。
  実行権限を付けたファイルは `./exe/count` のように直接起動でき、
  どの ruby が使われるかは shebang の `#!/usr/bin/env ruby` が決める
  （`env` が PATH の先頭にある `ruby` を選ぶ）。判定テストもこの形で起動する。

## 前提

- 課題 18（`tasks/rb1-18-stdlib-lookup/README.md`）までが完了していること。
- 成果リポ `~/lab/ruby-learning/ruby-core` と教材リポ `~/lab/ruby-learning/ruby-core-materials` の
  両方で `bundle install` が済んでいること（課題 1 の手順 2・3）。
- 課題 5 で `ARGV` と `$stdin.read`・パイプ `|`・`printf ... > ファイル` を、
  課題 17 でファイルの読み書きを済ませていること。
- `mise` で入れた Ruby 4.0 が `ruby -v` で出ること（shebang の `env ruby` が同じものを選ぶ）。

## この課題の進め方（全体像）

1. 手本のファイルを読む。
2. **手で打ち込んで**成果リポに写す。
3. 写しを走らせて通す。
4. 「なぜこう書くか」を自分の言葉で書く。
5. 模範解説を開いて突き合わせる。
6. 確認課題を解く。
7. `bin/check` を通す。

**写しは手で打ち込む。コピー＆ペーストはしない。** 機械はコピーと打ち込みを区別できないので、
これは自分で守る約束として運用する。打ち込むこと自体が、書式の癖（行末のセミコロン、
`camelCase` の変数名、4 スペースのインデント）を自分の手に気づかせるための工程である。

## 手順

### 手順 1 — 手本を読む

開くファイル: `~/lab/ruby-learning/ruby-core-materials/tasks/rb1-19-optparse-executable/original/executable_test.rb`

この手本は、公式リファレンスの OptionParser のチュートリアルと OptionParser の項、
および公式入門「Ruby in Twenty Minutes」第 4 部に載っている例をつないだもの。
底本の URL はファイル冒頭のコメントにある。先にそのページを読んでおくと分かりやすい。

### 手順 2 — 成果リポへ手で打ち込む

実行する場所: `~/lab/ruby-learning/ruby-core`

```sh
cd ~/lab/ruby-learning/ruby-core
mkdir -p rb1-19-optparse-executable
```

エディタで `rb1-19-optparse-executable/executable_test.rb` を新規作成し、手本を手で打ち込む。

- 1 行目の `# frozen_string_literal: true` は写す（何をする行かは課題 6 で扱う）。その下の底本の URL を書いたコメント群は写さなくてよい。
- クラス名・メソッド名・変数名・文字列は手本どおりに写す。
- ヒアドキュメントの中の `\#{name}` は、バックスラッシュまで含めてそのまま写す
  （ヒアドキュメントの中で `#{}` を「そのままの文字」として書くための書き方）。

### 手順 3 — 写しを走らせる

実行する場所: `~/lab/ruby-learning/ruby-core`

```sh
cd ~/lab/ruby-learning/ruby-core
bundle exec ruby rb1-19-optparse-executable/executable_test.rb
```

最終行に `4 runs, 13 assertions, 0 failures, 0 errors, 0 skips` が出れば写しは正しい。
`failures` や `errors` が 0 でないときは、表示される
「期待した値（Expected）／実際の値（Actual）」を読んで打ち間違いを探す。

書式も確かめておく。

実行する場所: `~/lab/ruby-learning/ruby-core-materials`

```sh
cd ~/lab/ruby-learning/ruby-core-materials
bundle exec rubocop --config .rubocop.yml ../ruby-core/rb1-19-optparse-executable/executable_test.rb
```

`no offenses detected` になるまで直す。

### 手順 4 — 「なぜこう書くか」を書く

教材リポの `tasks/rb1-19-optparse-executable/why.md` を、成果リポの `rb1-19-optparse-executable/why.md` へコピーする。

実行する場所: `~/lab/ruby-learning`

```sh
cd ~/lab/ruby-learning
cp ruby-core-materials/tasks/rb1-19-optparse-executable/why.md ruby-core/rb1-19-optparse-executable/why.md
```

コピーしたファイルを開き、見出しの下に自分の言葉で書き足す。
**模範解説（`commentary.md`）はまだ開かない。**

### 手順 5 — 模範解説と突き合わせる

書き終えたら、教材リポの `tasks/rb1-19-optparse-executable/commentary.md` を開いて読む。
自分が書いたことと食い違う箇所、思いつかなかった箇所を `why.md` に追記してよい。

### 手順 6 — 確認課題

行数と語数を数える小さな CLI を、実行の入口（`exe/`）と処理の本体（`lib/`）に分けて作る。

まず雛形を成果リポへ置く。

実行する場所: `~/lab/ruby-learning`

```sh
cd ~/lab/ruby-learning
mkdir -p ruby-core/rb1-19-optparse-executable/exercise/lib \
           ruby-core/rb1-19-optparse-executable/exercise/exe \
           ruby-core/rb1-19-optparse-executable/exercise/test
cp ruby-core-materials/tasks/rb1-19-optparse-executable/exercise/lib/counter.rb \
     ruby-core/rb1-19-optparse-executable/exercise/lib/counter.rb
cp ruby-core-materials/tasks/rb1-19-optparse-executable/exercise/exe/count \
     ruby-core/rb1-19-optparse-executable/exercise/exe/count
```

- `exercise/lib/counter.rb` の 2 つのメソッドを実装する。
- `exercise/exe/count` に、shebang・`lib/counter.rb` の読み込み・`OptionParser` による
  `-w` / `--words` の受け取りを足す。仕様は雛形のコメントに書いてある。
- 実行権限を付ける。

  ```sh
  $ cd ~/lab/ruby-learning/ruby-core
  $ chmod +x rb1-19-optparse-executable/exercise/exe/count
  ```

- 自分で 1 度動かす（パイプ `|` は課題 5 の道具節にある形）。

  ```sh
  $ cd ~/lab/ruby-learning/ruby-core
  $ printf 'alpha beta\ngamma\n' | ./rb1-19-optparse-executable/exercise/exe/count
  $ printf 'alpha beta\ngamma\n' | ./rb1-19-optparse-executable/exercise/exe/count --words
  ```

判定テストは教材リポの `tasks/rb1-19-optparse-executable/exercise/test/counter_test.rb` にある。**読んでよい。**

自分でテストを走らせて確かめる。

実行する場所: `~/lab/ruby-learning/ruby-core`

```sh
cd ~/lab/ruby-learning/ruby-core
bundle exec ruby -Irb1-19-optparse-executable/exercise/lib \
    ../ruby-core-materials/tasks/rb1-19-optparse-executable/exercise/test/counter_test.rb
```

判定テストに自分の `assert` を足したくなったら、成果リポ側に自分のテストファイルを作って書く
（教材リポのファイルは編集しない）。自分で足した `assert` は判定の対象にはならないが、
書くこと自体がこの学習計画の狙いの一部である。

### 手順 7 — `bin/check` を通す

実行する場所: `~/lab/ruby-learning/ruby-core-materials`

```sh
cd ~/lab/ruby-learning/ruby-core-materials
bin/check rb1-19-optparse-executable ../ruby-core
```

全項目が `[合格]` になるまで直す。

## 他の書き写し課題との差について

この課題の確認課題だけ、置くファイルが 2 つ（`exercise/lib/counter.rb` と `exercise/exe/count`）あり、
`chmod +x` の手順が入る。根拠は設計文書「Ruby 基礎」§3.2 の「各課題で初めて使う道具」の表で、
課題 19 に「`chmod +x`、`bundle exec` 経由の実行ファイル」が割り当てられている。
実行ファイルとライブラリを分けること自体がこの課題で身につける形である。

## 完了の判定

次がすべて満たされたときに完了とする。判定の正本はこの節である。

1. `bin/check rb1-19-optparse-executable ../ruby-core` の全項目が `[合格]`（終了コード 0）。
   内訳は「写しの実行」「写しのアサーション数」「写しの書式」「`why.md` が雛形と差分あり」「確認課題テスト」の 5 項目。
   終了コードは `echo $?` で見る。
2. 機械判定に載らない工程として、次の 2 つを終えている。
   - `why.md` を、模範解説（`commentary.md`）を開く前に自分の言葉で書いた。
   - `commentary.md` を読み、自分の説明と食い違った点を `why.md` に書き足した。
3. `progress.md` に `完了` と日付が書かれている。

## 進捗の記録

記録先は成果リポの `progress.md`。課題ごとの記録の表に `rb1-19-optparse-executable` の行を足し、
状態（`完了`）・日付・一言メモを書く。書いたらコミットする。

```sh
cd ~/lab/ruby-learning/ruby-core
git add .
git commit -m "rb1-19: 実行ファイルと OptionParser の手本を写し、count を実装した"
```

## 次の課題

次に開くファイル: `~/lab/ruby-learning/ruby-core-materials/tasks/rb1-20-zero-impl/README.md`
