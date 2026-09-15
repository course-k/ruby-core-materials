# rb1-09-blocks-procs — ブロックと Proc と lambda

## この課題を終えると何ができるようになるか / 全体のどこにいるか

**位置**: Ruby 軸・レベル「基礎」・課題 9（全 21 課題の 9 本目）。

**到達点**: この課題を終えると、次のことができるようになる。

- `yield` / `block_given?` / `&block` を使って、ブロックを受け取るメソッドを書ける。
- Proc と lambda の違い——`return` の効き方と引数の厳しさ——を説明でき、用途で選べる。
- `Proc.new` / `proc` / `lambda` / `->() {}` / `&block` の 5 通りの作り方を読める。
- `&:sym` が何をしているか（Symbol を Proc に変換してブロックとして渡している）を説明できる。
- ブロックの中の `return` / `break` / `next` がそれぞれどこまで抜けるかを、実行前に予測できる。

## 初めて使う道具

なし。

## 前提

- 課題 8（`tasks/rb1-08-methods-arguments/README.md`）までが完了していること。
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

開くファイル: `~/lab/ruby-learning/ruby-core-materials/tasks/rb1-09-blocks-procs/original/blocks_and_procs.rb`

この手本は、公式リファレンスの Proc（クラスの説明・Creation・Lambda and non-lambda semantics・
Conversion of other objects to procs の各節）と、Methods の Block Argument 節、
Kernel#block_given? の項に載っている例をつないだもの。
手本は**定義だけ**（`gen_times` / `make_proc` / `returns_from_the_enclosing_method` / `try`）。
定義を呼び出して結果を確かめるコードは、教材が配る照合テスト
`copy_test/blocks_and_procs_test.rb` にある。**写さない。読んでよい。**
底本の URL はファイル冒頭のコメントにある。先にそのページを読んでおくと分かりやすい。

### 手順 2 — 成果リポへ手で打ち込む

実行する場所: `~/lab/ruby-learning/ruby-core`

```sh
cd ~/lab/ruby-learning/ruby-core
mkdir -p rb1-09-blocks-procs
```

エディタで `rb1-09-blocks-procs/blocks_and_procs.rb` を新規作成し、手本を手で打ち込む。

- 1 行目の `# frozen_string_literal: true` は写す（何をする行かは課題 6 で扱う）。その下の底本の URL を書いたコメント群は写さなくてよい。
- クラス名・メソッド名・変数名・文字列は手本どおりに写す。

### 手順 3 — 写しを照合テストで確かめる

実行する場所: `~/lab/ruby-learning/ruby-core`

照合テストは教材リポにあり、写しを置いたディレクトリを `-I` で教える。

```sh
cd ~/lab/ruby-learning/ruby-core
bundle exec ruby -Irb1-09-blocks-procs \
    ../ruby-core-materials/tasks/rb1-09-blocks-procs/copy_test/blocks_and_procs_test.rb
```

最終行に `9 runs, 25 assertions, 0 failures, 0 errors, 0 skips` が出れば写しは正しい。
`failures` や `errors` が 0 でないときは、表示される
「期待した値（Expected）／実際の値（Actual）」を読んで打ち間違いを探す。

書式も確かめておく。

実行する場所: `~/lab/ruby-learning/ruby-core-materials`

```sh
cd ~/lab/ruby-learning/ruby-core-materials
bundle exec rubocop --config .rubocop.yml ../ruby-core/rb1-09-blocks-procs/blocks_and_procs.rb
```

`no offenses detected` になるまで直す。

### 手順 4 — 「なぜこう書くか」を書く

教材リポの `tasks/rb1-09-blocks-procs/why.md` を、成果リポの `rb1-09-blocks-procs/why.md` へコピーする。

実行する場所: `~/lab/ruby-learning`

```sh
cd ~/lab/ruby-learning
cp ruby-core-materials/tasks/rb1-09-blocks-procs/why.md ruby-core/rb1-09-blocks-procs/why.md
```

コピーしたファイルを開き、**§1〜§3** を自分の言葉で書く（§4 は手順 5 で書く）。
§3「分からなかったこと」は 1 行 1 問の問いの形で書く。§1 に「〜だろうか」と書いた疑問はここへ移す。
課題の範囲を先取りする問いでも構わない——手順 5.5 で答えが返る。
**模範解説（`commentary.md`）はまだ開かない。**

### 手順 5 — 模範解説と突き合わせる

書き終えたら、教材リポの `tasks/rb1-09-blocks-procs/commentary.md` を開いて読む。
食い違った箇所・思いつかなかった箇所を、`why.md` の **§4「突き合わせで変わったこと」** に書く。
変わらなかったなら「変わらなかった」と書く。§1〜§3 は書き換えない——自力で到達した理解と
模範解説で到達した理解を分けて残すための欄分けなので、混ぜると手順 5.5 の照合が意味を失う。

### 手順 5.5 — 一次情報と照らす（任意）

**これは端末で打つコマンドではない。** Claude Code（対話しながら作業を頼める道具。
端末で `claude` と打って起動する）を立ち上げた状態で、その入力欄に次の 1 行を打つ。

> `/why-review rb1-09-blocks-procs`

`/why-review` は、この学習計画のために用意した Claude Code の **skill**——手順をあらかじめ
書いておいて名前で呼び出す仕組みで、端末のコマンドとは別物。Claude Code を使っていなければ
**この手順は飛ばす**。任意の手順なので、飛ばしても課題は完了する。

走らせると、教材リポの claim 表（`tasks/rb1-09-blocks-procs/claims.yml`）と `why.md` を突き合わせ、
claim ごとに一致度（一致 / 部分 / ずれ / 未言及）と到達時点（自力 / 突き合わせ後 / 未）を返す。
続けて §3 の質問に答える。答えには一次情報の URL と原文の引用が必ず付くので、
納得できないところは原典を自分で確かめられる。claim 表がまだ無い課題では、その場で作られる。

**合否には効かない。** `bin/check` の 4 項目とは別で、走らせなくても課題は完了する。
結果は `~/lab/ruby-learning/docs/grading/rb1-09-blocks-procs.md` に残る（成果リポには置かない）。

### 手順 6 — 確認課題

手順をあとから足せる `Pipeline` を、判定テストが通るように実装する。

まず雛形を成果リポへ置く。

実行する場所: `~/lab/ruby-learning`

```sh
cd ~/lab/ruby-learning
mkdir -p ruby-core/rb1-09-blocks-procs/exercise/lib
cp ruby-core-materials/tasks/rb1-09-blocks-procs/exercise/lib/pipeline.rb \
     ruby-core/rb1-09-blocks-procs/exercise/lib/pipeline.rb
```

判定テストは教材リポの `tasks/rb1-09-blocks-procs/exercise/test/pipeline_test.rb` にある。**読んでよい。**

**作るもの**: 「値を変換する手順」をいくつでも登録でき、登録した順に適用するクラス。

- `Pipeline.new` — 手順が 0 個の状態で作る。
- `#add { |value| ... }` — 手順を 1 つ足す。**自分自身を返す**ので `add { }.add { }` とつなげられる。
- `#call(value)` — 登録した順に手順を適用した結果を返す。手順が 0 個なら値をそのまま返す。
- `#size` — 登録されている手順の数。

**ここは自分で決める**: 受け取ったブロックを、`&step` で受け取った Proc のまま持つか、
自分で lambda に包んで持つか。**判定はどちらでも通る**（このテストは引数の数の厳しさにも
`return` の挙動にも依存しない）。選んだ理由を `why.md` に 1 行書いておくとよい。

自分でテストを走らせて確かめる。

実行する場所: `~/lab/ruby-learning/ruby-core`

```sh
cd ~/lab/ruby-learning/ruby-core
bundle exec ruby -Irb1-09-blocks-procs/exercise/lib \
    ../ruby-core-materials/tasks/rb1-09-blocks-procs/exercise/test/pipeline_test.rb
```

判定テストに自分の `assert` を足したくなったら、成果リポ側に自分のテストファイルを作って書く
（教材リポのファイルは編集しない）。自分で足した `assert` は判定の対象にはならないが、
書くこと自体がこの学習計画の狙いの一部である。

### 手順 7 — 出力予測

教材リポの `tasks/rb1-09-blocks-procs/predict/` に `predict/01.rb` が入っている。
**実行する前に**、それぞれが標準出力へ何を出すかを読んで予測し、
成果リポの `rb1-09-blocks-procs/predict/` に `predict/01.txt` として書き下す。

実行する場所: `~/lab/ruby-learning/ruby-core`

```sh
cd ~/lab/ruby-learning/ruby-core
mkdir -p rb1-09-blocks-procs/predict
```

書き方: 出力される行をそのままの順序で並べたテキストファイルにする。
行末の改行の有無は判定で無視されるが、行の中身と行数は完全に一致していなければならない。

書き終えてから、`bin/check`（手順 8）で照合する。
先に `ruby` で実行してしまうと予測の練習にならないので、**予測を書き終えるまで実行しない。**
予測が外れたときは、`bin/check` が「最初に食い違う行」の行番号だけを返す。
正解の出力は表示されないので、その行のコードを読み直して考える。

### 手順 8 — `bin/check` を通す

実行する場所: `~/lab/ruby-learning/ruby-core-materials`

```sh
cd ~/lab/ruby-learning/ruby-core-materials
bin/check rb1-09-blocks-procs ../ruby-core
```

全項目が `[合格]` になるまで直す。

## 完了の判定

次がすべて満たされたときに完了とする。判定の正本はこの節である。

1. `bin/check rb1-09-blocks-procs ../ruby-core` の全項目が `[合格]`（終了コード 0）。
   内訳は「写しの照合」「写しの書式」「`why.md` が雛形と差分あり」「確認課題テスト」「出力予測 01」の 6 項目。
2. 機械判定に載らない工程として、次の 2 つを終えている。
   - `why.md` を、模範解説（`commentary.md`）を開く前に自分の言葉で書いた。
   - `commentary.md` を読み、自分の説明と食い違った点を `why.md` に書き足した。
3. `progress.md` に `完了` と日付が書かれている。

## 進捗の記録

記録先は成果リポの `progress.md`。課題ごとの記録の表に `rb1-09-blocks-procs` の行を足し、
状態（`完了`）・日付・一言メモを書く。書いたらコミットする。

```sh
cd ~/lab/ruby-learning/ruby-core
git add .
git commit -m "rb1-09: ブロックと Proc の手本を写し、Pipeline を実装し、出力を予測した"
```

## 次の課題

次に開くファイル: `~/lab/ruby-learning/ruby-core-materials/tasks/rb1-10-classes-objects/README.md`
