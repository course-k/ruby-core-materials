# rb1-08-methods-arguments — メソッドと引数

## この課題を終えると何ができるようになるか / 全体のどこにいるか

**位置**: Ruby 軸・レベル「基礎」・課題 8（全 21 課題の 8 本目）。

**到達点**: この課題を終えると、次のことができるようになる。

- 位置引数・既定値つき引数・可変長引数（`*`）・キーワード引数（`key:` と `**`）・ブロック引数（`&` と `yield`）を
  書き分けられる。
- 既定値が左から順に埋まること、既定値が中ほどにあるときにどう埋まるかを説明できる。
- `return` を書かなければ最後に評価した式が戻り値になることを説明できる。
- メソッド名の末尾の `?` と `!` が何を意味する慣習かを説明でき、`!` 版が変更なしのとき `nil` を返す例を挙げられる。
- 引数の数が合わないときに `ArgumentError` になることを説明できる。

## 初めて使う道具

なし。

## 前提

- 課題 7（`tasks/rb1-07-collections-enumerable/README.md`）までが完了していること。
- 成果リポ `~/lab/ruby-learning/ruby-core` と教材リポ `~/lab/ruby-learning/ruby-core-materials` の
  両方で `bundle install` が済んでいること（課題 1 の手順 2・3）。
- この課題のために新しく入れるものは無い。

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

開くファイル: `~/lab/ruby-learning/ruby-core-materials/tasks/rb1-08-methods-arguments/original/methods_and_arguments_test.rb`

この手本は、公式リファレンスの Methods（Method Names / Return Values / Arguments の各節）と
Calling Methods（Default Positional Arguments / Keyword Arguments の各節）に載っている例をつないだもの。
底本の URL はファイル冒頭のコメントにある。先にそのページを読んでおくと分かりやすい。

### 手順 2 — 成果リポへ手で打ち込む

実行する場所: `~/lab/ruby-learning/ruby-core`

```sh
$ cd ~/lab/ruby-learning/ruby-core
$ mkdir -p rb1-08-methods-arguments
```

エディタで `rb1-08-methods-arguments/methods_and_arguments_test.rb` を新規作成し、手本を手で打ち込む。

- 1 行目の `# frozen_string_literal: true` は写す（何をする行かは課題 6 で扱う）。その下の底本の URL を書いたコメント群は写さなくてよい。
- クラス名・メソッド名・変数名・文字列は手本どおりに写す。

### 手順 3 — 写しを走らせる

実行する場所: `~/lab/ruby-learning/ruby-core`

```sh
$ cd ~/lab/ruby-learning/ruby-core
$ bundle exec ruby rb1-08-methods-arguments/methods_and_arguments_test.rb
```

最終行に `7 runs, 22 assertions, 0 failures, 0 errors, 0 skips` が出れば写しは正しい。
`failures` や `errors` が 0 でないときは、表示される
「期待した値（Expected）／実際の値（Actual）」を読んで打ち間違いを探す。

書式も確かめておく。

実行する場所: `~/lab/ruby-learning/ruby-core-materials`

```sh
$ cd ~/lab/ruby-learning/ruby-core-materials
$ bundle exec rubocop --config .rubocop.yml ../ruby-core/rb1-08-methods-arguments/methods_and_arguments_test.rb
```

`no offenses detected` になるまで直す。

### 手順 4 — 「なぜこう書くか」を書く

教材リポの `tasks/rb1-08-methods-arguments/why.md` を、成果リポの `rb1-08-methods-arguments/why.md` へコピーする。

実行する場所: `~/lab/ruby-learning`

```sh
$ cd ~/lab/ruby-learning
$ cp ruby-core-materials/tasks/rb1-08-methods-arguments/why.md ruby-core/rb1-08-methods-arguments/why.md
```

コピーしたファイルを開き、見出しの下に自分の言葉で書き足す。
**模範解説（`commentary.md`）はまだ開かない。**

### 手順 5 — 模範解説と突き合わせる

書き終えたら、教材リポの `tasks/rb1-08-methods-arguments/commentary.md` を開いて読む。
自分が書いたことと食い違う箇所、思いつかなかった箇所を `why.md` に追記してよい。

### 手順 6 — 確認課題

1 行の文字列を組み立てる `Formatter.line` を、判定テストが通るように実装する。

まず雛形を成果リポへ置く。

実行する場所: `~/lab/ruby-learning`

```sh
$ cd ~/lab/ruby-learning
$ mkdir -p ruby-core/rb1-08-methods-arguments/exercise/lib
$ cp ruby-core-materials/tasks/rb1-08-methods-arguments/exercise/lib/formatter.rb \
     ruby-core/rb1-08-methods-arguments/exercise/lib/formatter.rb
```

判定テストは教材リポの `tasks/rb1-08-methods-arguments/exercise/test/formatter_test.rb` にある。**読んでよい。**

**作るもの**: `Formatter.line` という 1 つのメソッド。手本に出てきた引数の形を全部使う。

- 第 1 引数 `label` は**必須の位置引数**。
- そのあとに続く値は**いくつでも受け取る**（`*`）。
- `separator:` は**既定値 `", "` のキーワード引数**。値をつなぐ区切り。
- `prefix:` は**既定値が「何も付けない」のキーワード引数**。付けたときは戻り値の先頭に置く。
- **ブロックを渡せる**。渡されたときは各値をブロックに通してから並べる。渡されなければそのまま並べる。

戻り値は `"<prefix><label>: <値を separator でつないだもの>"` の形の文字列。
雛形には `label` しか書いていないので、引数の並びから自分で書く。

自分でテストを走らせて確かめる。

実行する場所: `~/lab/ruby-learning/ruby-core`

```sh
$ cd ~/lab/ruby-learning/ruby-core
$ bundle exec ruby -Irb1-08-methods-arguments/exercise/lib \
    ../ruby-core-materials/tasks/rb1-08-methods-arguments/exercise/test/formatter_test.rb
```

判定テストに自分の `assert` を足したくなったら、成果リポ側に自分のテストファイルを作って書く
（教材リポのファイルは編集しない）。自分で足した `assert` は判定の対象にはならないが、
書くこと自体がこの学習計画の狙いの一部である。

### 手順 7 — `bin/check` を通す

実行する場所: `~/lab/ruby-learning/ruby-core-materials`

```sh
$ cd ~/lab/ruby-learning/ruby-core-materials
$ bin/check rb1-08-methods-arguments ../ruby-core
```

全項目が `[合格]` になるまで直す。

## 完了の判定

次がすべて満たされたときに完了とする。判定の正本はこの節である。

1. `bin/check rb1-08-methods-arguments ../ruby-core` の全項目が `[合格]`（終了コード 0）。
   内訳は「写しの実行」「写しのアサーション数」「写しの書式」「`why.md` が雛形と差分あり」「確認課題テスト」の 5 項目。
2. 機械判定に載らない工程として、次の 2 つを終えている。
   - `why.md` を、模範解説（`commentary.md`）を開く前に自分の言葉で書いた。
   - `commentary.md` を読み、自分の説明と食い違った点を `why.md` に書き足した。
3. `progress.md` に `完了` と日付が書かれている。

## 進捗の記録

記録先は成果リポの `progress.md`。課題ごとの記録の表に `rb1-08-methods-arguments` の行を足し、
状態（`完了`）・日付・一言メモを書く。書いたらコミットする。

```sh
$ cd ~/lab/ruby-learning/ruby-core
$ git add .
$ git commit -m "rb1-08: 引数の形の手本を写し、Formatter.line を実装した"
```

## 次の課題

次に開くファイル: `~/lab/ruby-learning/ruby-core-materials/tasks/rb1-09-blocks-procs/README.md`
