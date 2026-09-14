# rb1-04-values-truth — 値と真偽

## この課題を終えると何ができるようになるか / 全体のどこにいるか

**位置**: Ruby 軸・レベル「基礎」・課題 4（全 21 課題の 4 本目）。

**到達点**: この課題を終えると、次のことができるようになる。

- Ruby では**すべての式が値を持つ**ことを説明でき、`if` や `case` の結果をそのまま変数へ代入できる。
- **偽になるのは `nil` と `false` の 2 つだけ**であることを説明でき、`0` や `""` を偽だと思って書いた
  コードがなぜ壊れるかを言える。
- `nil` が「値が無いこと」を表すオブジェクトであり、`nil.nil?` や `nil.class` が呼べることを説明できる。
- `===` が等値ではなく `case` の照合に使われる演算子であることを説明できる。
- irb を使って、式の値をその場で確かめられる。

## 初めて使う道具

なし。

## 前提

- 課題 3（`tasks/rb1-03-testing-basics/README.md`）までが完了していること。
- 成果リポ `~/lab/ruby-learning/ruby-core` と教材リポ `~/lab/ruby-learning/ruby-core-materials` の
  両方で `bundle install` が済んでいること（課題 1 の手順 2・3）。
- 手を動かす前に irb を 1 度起動しておくと確かめやすい（`cd ~/lab/ruby-learning/ruby-core` して
  `bundle exec irb`。`exit` で抜ける）。この課題の式はどれも irb にそのまま打ち込める。

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

開くファイル: `~/lab/ruby-learning/ruby-core-materials/tasks/rb1-04-values-truth/original/values_and_truth.rb`

この手本は、公式リファレンスの Literals（Boolean and Nil Literals）・Control Expressions と、
公式サイトの「Ruby From Other Languages」の Everything has a value / The universal truth 節に
載っている例をつないだもの。
手本は**定義だけ**。定義を呼び出して結果を確かめるコードは、教材が配る照合テスト
`copy_test/values_and_truth_test.rb` にある。**写さない。読んでよい。**
底本の URL はファイル冒頭のコメントにある。先にそのページを読んでおくと分かりやすい。

### 手順 2 — 成果リポへ手で打ち込む

実行する場所: `~/lab/ruby-learning/ruby-core`

```sh
cd ~/lab/ruby-learning/ruby-core
mkdir -p rb1-04-values-truth
```

エディタで `rb1-04-values-truth/values_and_truth.rb` を新規作成し、手本を手で打ち込む。

- 1 行目の `# frozen_string_literal: true` は写す（何をする行かは課題 6 で扱う）。その下の底本の URL を書いたコメント群は写さなくてよい。
- クラス名・メソッド名・変数名・文字列は手本どおりに写す。

### 手順 3 — 写しを照合テストで確かめる

実行する場所: `~/lab/ruby-learning/ruby-core`

```sh
cd ~/lab/ruby-learning/ruby-core
bundle exec ruby -Irb1-04-values-truth \
    ../ruby-core-materials/tasks/rb1-04-values-truth/copy_test/values_and_truth_test.rb
```

最終行に `8 runs, 20 assertions, 0 failures, 0 errors, 0 skips` が出れば写しは正しい。
`failures` や `errors` が 0 でないときは、表示される
「期待した値（Expected）／実際の値（Actual）」を読んで打ち間違いを探す。

書式も確かめておく。

実行する場所: `~/lab/ruby-learning/ruby-core-materials`

```sh
cd ~/lab/ruby-learning/ruby-core-materials
bundle exec rubocop --config .rubocop.yml ../ruby-core/rb1-04-values-truth/values_and_truth.rb
```

`no offenses detected` になるまで直す。

### 手順 4 — 「なぜこう書くか」を書く

教材リポの `tasks/rb1-04-values-truth/why.md` を、成果リポの `rb1-04-values-truth/why.md` へコピーする。

実行する場所: `~/lab/ruby-learning`

```sh
cd ~/lab/ruby-learning
cp ruby-core-materials/tasks/rb1-04-values-truth/why.md ruby-core/rb1-04-values-truth/why.md
```

コピーしたファイルを開き、**§1〜§3** を自分の言葉で書く（§4 は手順 5 で書く）。
§3「分からなかったこと」は 1 行 1 問の問いの形で書く。§1 に「〜だろうか」と書いた疑問はここへ移す。
課題の範囲を先取りする問いでも構わない——手順 5.5 で答えが返る。
**模範解説（`commentary.md`）はまだ開かない。**

### 手順 5 — 模範解説と突き合わせる

書き終えたら、教材リポの `tasks/rb1-04-values-truth/commentary.md` を開いて読む。
食い違った箇所・思いつかなかった箇所を、`why.md` の **§4「突き合わせで変わったこと」** に書く。
変わらなかったなら「変わらなかった」と書く。§1〜§3 は書き換えない——自力で到達した理解と
模範解説で到達した理解を分けて残すための欄分けなので、混ぜると手順 5.5 の照合が意味を失う。

### 手順 5.5 — 一次情報と照らす（任意）

```
/why-review rb1-04-values-truth
```

教材リポの claim 表（`tasks/rb1-04-values-truth/claims.yml`）と `why.md` を突き合わせ、
claim ごとに一致度（一致 / 部分 / ずれ / 未言及）と到達時点（自力 / 突き合わせ後 / 未）を返す。
続けて §3 の質問に答える。答えには一次情報の URL と原文の引用が必ず付くので、
納得できないところは原典を自分で確かめられる。claim 表がまだ無い課題では、その場で作られる。

**合否には効かない。** `bin/check` の 4 項目とは別で、走らせなくても課題は完了する。
結果は `~/lab/ruby-learning/docs/grading/rb1-04-values-truth.md` に残る（成果リポには置かない）。

### 手順 6 — 確認課題

**壊れているコードを直す**課題。設定値を読み出す `Settings.fetch` が、判定テストの一部で落ちる。

まず雛形を成果リポへ置く。

実行する場所: `~/lab/ruby-learning`

```sh
cd ~/lab/ruby-learning
mkdir -p ruby-core/rb1-04-values-truth/exercise/lib
cp ruby-core-materials/tasks/rb1-04-values-truth/exercise/lib/settings.rb \
     ruby-core/rb1-04-values-truth/exercise/lib/settings.rb
```

判定テストは教材リポの `tasks/rb1-04-values-truth/exercise/test/settings_test.rb` にある。**読んでよい。**

**やること**: 雛形のコードには欠陥がある。判定テストを走らせて落ちたテストの名前と失敗メッセージを読み、
**欠陥の所在を自分で突き止めて直す**。どこが悪いかはこの課題文には書かない——見つけること自体がこの課題である。

直すときの条件:

- `Settings.fetch(overrides, key)` の仕様は「`overrides` にその `key` の指定があればその値を返し、
  無ければ `DEFAULTS` の値を返す」。この仕様は変えない。
- 判定テストは書き換えない。
- 落ちているテストを通したときに、いま通っているテストが落ちないようにする。

自分でテストを走らせて確かめる。

実行する場所: `~/lab/ruby-learning/ruby-core`

```sh
cd ~/lab/ruby-learning/ruby-core
bundle exec ruby -Irb1-04-values-truth/exercise/lib \
    ../ruby-core-materials/tasks/rb1-04-values-truth/exercise/test/settings_test.rb
```

判定テストに自分の `assert` を足したくなったら、成果リポ側に自分のテストファイルを作って書く
（教材リポのファイルは編集しない）。自分で足した `assert` は判定の対象にはならないが、
書くこと自体がこの学習計画の狙いの一部である。

### 手順 7 — `bin/check` を通す

実行する場所: `~/lab/ruby-learning/ruby-core-materials`

```sh
cd ~/lab/ruby-learning/ruby-core-materials
bin/check rb1-04-values-truth ../ruby-core
```

全項目が `[合格]` になるまで直す。

## 完了の判定

次がすべて満たされたときに完了とする。判定の正本はこの節である。

1. `bin/check rb1-04-values-truth ../ruby-core` の全項目が `[合格]`（終了コード 0）。
   内訳は「写しの照合」「写しの書式」「`why.md` が雛形と差分あり」「確認課題テスト」の 5 項目。
2. 機械判定に載らない工程として、次の 2 つを終えている。
   - `why.md` を、模範解説（`commentary.md`）を開く前に自分の言葉で書いた。
   - `commentary.md` を読み、自分の説明と食い違った点を `why.md` に書き足した。
3. `progress.md` に `完了` と日付が書かれている。

## 進捗の記録

記録先は成果リポの `progress.md`。課題ごとの記録の表に `rb1-04-values-truth` の行を足し、
状態（`完了`）・日付・一言メモを書く。書いたらコミットする。

```sh
cd ~/lab/ruby-learning/ruby-core
git add .
git commit -m "rb1-04: 値と真偽の手本を写し、Settings.fetch の欠陥を直した"
```

## 次の課題

次に開くファイル: `~/lab/ruby-learning/ruby-core-materials/tasks/rb1-05-control-flow-io/README.md`
