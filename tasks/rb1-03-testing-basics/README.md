# rb1-03-testing-basics — minitest を読み書きする

## この課題を終えると何ができるようになるか / 全体のどこにいるか

**位置**: Ruby 軸・レベル「基礎」・課題 3（全 21 課題の 3 本目）。

**到達点**: この課題を終えると、次のことができるようになる。

- minitest のテストファイルの形（`require "minitest/autorun"` / `Minitest::Test` を継承したクラス /
  `test_` で始まるメソッド）を、何も見ずに書き起こせる。
- `assert_equal` / `assert` / `refute` / `assert_nil` / `assert_raises` を、目的に応じて使い分けられる。
- テストが落ちたときの出力（どのテストが・何を期待し・実際は何だったか）を読んで、原因の箇所に当たれる。
- `setup` が各テストメソッドの前に走ることを説明できる。

以降の全課題の合否はこの道具で判定される。ここで判定の読み方を手に入れておく。

## 初めて使う道具

なし。minitest は課題 1 で導入済みで、この課題ではその読み書きを深める。

## 前提

- 課題 2（`tasks/rb1-02-twenty-minutes/README.md`）までが完了していること。
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

開くファイル: `~/lab/ruby-learning/ruby-core-materials/tasks/rb1-03-testing-basics/original/meme_test.rb`

この手本は、minitest の README（Ruby 4.0.6 に同梱される版 v6.0.0）の "Unit tests" 節にある例と、
同じ版の `lib/minitest/assertions.rb` に書かれている用例をつないだもの。
底本の URL はファイル冒頭のコメントにある。先にそのページを読んでおくと分かりやすい。

**この課題だけ手本が minitest のテストファイルである。** 他の書き写し課題では、手本は定義だけで、
それを呼び出して確かめるコードは教材が配る照合テスト（`copy_test/`）に置いてある——判定のための
道具を学習者に打たせないため。この課題は minitest 自体が学習対象（能力行 B15）なので、
テストの書き方そのものが写す対象になる。だから手本がテストファイルのままで、
判定も「写しの実行」「写しのアサーション数」で行う。

### 手順 2 — 成果リポへ手で打ち込む

実行する場所: `~/lab/ruby-learning/ruby-core`

```sh
cd ~/lab/ruby-learning/ruby-core
mkdir -p rb1-03-testing-basics
```

エディタで `rb1-03-testing-basics/meme_test.rb` を新規作成し、手本を手で打ち込む。

- 1 行目の `# frozen_string_literal: true` は写す（何をする行かは課題 6 で扱う）。その下の底本の URL を書いたコメント群は写さなくてよい。
- クラス名・メソッド名・変数名・文字列は手本どおりに写す。

### 手順 3 — 写しを走らせる

実行する場所: `~/lab/ruby-learning/ruby-core`

```sh
cd ~/lab/ruby-learning/ruby-core
bundle exec ruby rb1-03-testing-basics/meme_test.rb
```

最終行に `6 runs, 8 assertions, 0 failures, 0 errors, 1 skips` が出れば写しは正しい。
`failures` や `errors` が 0 でないときは、表示される
「期待した値（Expected）／実際の値（Actual）」を読んで打ち間違いを探す。

書式も確かめておく。

実行する場所: `~/lab/ruby-learning/ruby-core-materials`

```sh
cd ~/lab/ruby-learning/ruby-core-materials
bundle exec rubocop --config .rubocop.yml ../ruby-core/rb1-03-testing-basics/meme_test.rb
```

`no offenses detected` になるまで直す。

### 手順 4 — 「なぜこう書くか」を書く

教材リポの `tasks/rb1-03-testing-basics/why.md` を、成果リポの `rb1-03-testing-basics/why.md` へコピーする。

実行する場所: `~/lab/ruby-learning`

```sh
cd ~/lab/ruby-learning
cp ruby-core-materials/tasks/rb1-03-testing-basics/why.md ruby-core/rb1-03-testing-basics/why.md
```

コピーしたファイルを開き、**§1〜§3** を自分の言葉で書く（§4 は手順 5 で書く）。
§3「分からなかったこと」は 1 行 1 問の問いの形で書く。§1 に「〜だろうか」と書いた疑問はここへ移す。
課題の範囲を先取りする問いでも構わない——手順 5.5 で答えが返る。
**模範解説（`commentary.md`）はまだ開かない。**

### 手順 5 — 模範解説と突き合わせる

書き終えたら、教材リポの `tasks/rb1-03-testing-basics/commentary.md` を開いて読む。
食い違った箇所・思いつかなかった箇所を、`why.md` の **§4「突き合わせで変わったこと」** に書く。
変わらなかったなら「変わらなかった」と書く。§1〜§3 は書き換えない——自力で到達した理解と
模範解説で到達した理解を分けて残すための欄分けなので、混ぜると手順 5.5 の照合が意味を失う。

### 手順 5.5 — 一次情報と照らす（任意）

**これは端末で打つコマンドではない。** Claude Code（対話しながら作業を頼める道具。
端末で `claude` と打って起動する）を立ち上げた状態で、その入力欄に次の 1 行を打つ。

> `/why-review rb1-03-testing-basics`

`/why-review` は、この学習計画のために用意した Claude Code の **skill**——手順をあらかじめ
書いておいて名前で呼び出す仕組みで、端末のコマンドとは別物。Claude Code を使っていなければ
**この手順は飛ばす**。任意の手順なので、飛ばしても課題は完了する。

走らせると、教材リポの claim 表（`tasks/rb1-03-testing-basics/claims.yml`）と `why.md` を突き合わせ、
claim ごとに一致度（一致 / 部分 / ずれ / 未言及）と到達時点（自力 / 突き合わせ後 / 未）を返す。
続けて §3 の質問に答える。答えには一次情報の URL と原文の引用が必ず付くので、
納得できないところは原典を自分で確かめられる。claim 表がまだ無い課題では、その場で作られる。

**合否には効かない。** `bin/check` の 4 項目とは別で、走らせなくても課題は完了する。
結果は `~/lab/ruby-learning/docs/grading/rb1-03-testing-basics.md` に残る（成果リポには置かない）。

### 手順 6 — 確認課題

名簿クラス `Roster` を、判定テストが通るように実装する。

まず雛形を成果リポへ置く。

実行する場所: `~/lab/ruby-learning`

```sh
cd ~/lab/ruby-learning
mkdir -p ruby-core/rb1-03-testing-basics/exercise/lib
cp ruby-core-materials/tasks/rb1-03-testing-basics/exercise/lib/roster.rb \
     ruby-core/rb1-03-testing-basics/exercise/lib/roster.rb
```

判定テストは教材リポの `tasks/rb1-03-testing-basics/exercise/test/roster_test.rb` にある。**読んでよい。**

**作るもの**: `Roster.new(names)` で名前の配列を受け取り、次のメソッドを持つクラス。

- `find(name)` — 名簿にあればその名前を返し、無ければ `nil` を返す。空文字列を渡されたときは
  `ArgumentError` を、メッセージ `name must not be empty` で送出する。
- `size` — 名簿の人数を返す。

（`raise` と `ArgumentError` の書き方は手本の `test_assert_raises_returns_the_exception` にある。
例外そのものは課題 11 で正面から扱うので、ここでは手本の形を真似れば足りる。）

自分でテストを走らせて確かめる。

実行する場所: `~/lab/ruby-learning/ruby-core`

```sh
cd ~/lab/ruby-learning/ruby-core
bundle exec ruby -Irb1-03-testing-basics/exercise/lib \
    ../ruby-core-materials/tasks/rb1-03-testing-basics/exercise/test/roster_test.rb
```

判定テストに自分の `assert` を足したくなったら、成果リポ側に自分のテストファイルを作って書く
（教材リポのファイルは編集しない）。自分で足した `assert` は判定の対象にはならないが、
書くこと自体がこの学習計画の狙いの一部である。

### 手順 7 — `bin/check` を通す

実行する場所: `~/lab/ruby-learning/ruby-core-materials`

```sh
cd ~/lab/ruby-learning/ruby-core-materials
bin/check rb1-03-testing-basics ../ruby-core
```

全項目が `[合格]` になるまで直す。

## 完了の判定

次がすべて満たされたときに完了とする。判定の正本はこの節である。

1. `bin/check rb1-03-testing-basics ../ruby-core` の全項目が `[合格]`（終了コード 0）。
   内訳は「写しの実行」「写しのアサーション数」「写しの書式」「`why.md` が雛形と差分あり」「確認課題テスト」の 5 項目。
2. 機械判定に載らない工程として、次の 2 つを終えている。
   - `why.md` を、模範解説（`commentary.md`）を開く前に自分の言葉で書いた。
   - `commentary.md` を読み、自分の説明と食い違った点を `why.md` に書き足した。
3. `progress.md` に `完了` と日付が書かれている。

## 進捗の記録

記録先は成果リポの `progress.md`。課題ごとの記録の表に `rb1-03-testing-basics` の行を足し、
状態（`完了`）・日付・一言メモを書く。書いたらコミットする。

```sh
cd ~/lab/ruby-learning/ruby-core
git add .
git commit -m "rb1-03: minitest の assert を写し、Roster を実装した"
```

## 次の課題

次に開くファイル: `~/lab/ruby-learning/ruby-core-materials/tasks/rb1-04-values-truth/README.md`
