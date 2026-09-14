# rb1-11-exceptions — 例外

## この課題を終えると何ができるようになるか / 全体のどこにいるか

**位置**: Ruby 軸・レベル「基礎」・課題 11（全 21 課題の 11 本目）。

**到達点**: この課題を終えると、次のことができるようになる。

- `begin` / `rescue` / `else` / `ensure` / `end` の並びと、それぞれがいつ走るかを説明できる。
- メソッド本体やブロックがそのまま例外ハンドラになる書き方を使える。
- `rescue` にクラスを書かないと `StandardError` とその子孫が捕まることを説明できる。
- `raise` / `retry` / 引数なしの `raise`（再送出）を使える。
- 組み込みの例外階層を読み、`StandardError` を継承した自作の例外クラスを定義できる。
- **どこで例外を捕まえ、どこで送出するか**を自分で決められる。

## 初めて使う道具

なし。

## 前提

- 課題 10（`tasks/rb1-10-classes-objects/README.md`）までが完了していること。
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

開くファイル: `~/lab/ruby-learning/ruby-core-materials/tasks/rb1-11-exceptions/original/exceptions.rb`

この手本は、公式リファレンスの Exceptions ガイド（Rescued Exceptions / Else Clause / Ensure Clause /
Begin-Less Exception Handlers / Re-Raising an Exception / Retrying / Custom Exceptions の各節）と、
Exception Handling の構文の項に載っている例をつないだもの。
手本は**定義だけ**。定義を呼び出して結果を確かめるコードは、教材が配る照合テスト
`copy_test/exceptions_test.rb` にある。**写さない。読んでよい。**
底本の URL はファイル冒頭のコメントにある。先にそのページを読んでおくと分かりやすい。

### 手順 2 — 成果リポへ手で打ち込む

実行する場所: `~/lab/ruby-learning/ruby-core`

```sh
cd ~/lab/ruby-learning/ruby-core
mkdir -p rb1-11-exceptions
```

エディタで `rb1-11-exceptions/exceptions.rb` を新規作成し、手本を手で打ち込む。

- 1 行目の `# frozen_string_literal: true` は写す（何をする行かは課題 6 で扱う）。その下の底本の URL を書いたコメント群は写さなくてよい。
- クラス名・メソッド名・変数名・文字列は手本どおりに写す。

### 手順 3 — 写しを照合テストで確かめる

実行する場所: `~/lab/ruby-learning/ruby-core`

照合テストは教材リポにあり、写しを置いたディレクトリを `-I` で教える。

```sh
cd ~/lab/ruby-learning/ruby-core
bundle exec ruby -Irb1-11-exceptions \
    ../ruby-core-materials/tasks/rb1-11-exceptions/copy_test/exceptions_test.rb
```

最終行に `8 runs, 19 assertions, 0 failures, 0 errors, 0 skips` が出れば写しは正しい。
`failures` や `errors` が 0 でないときは、表示される
「期待した値（Expected）／実際の値（Actual）」を読んで打ち間違いを探す。

書式も確かめておく。

実行する場所: `~/lab/ruby-learning/ruby-core-materials`

```sh
cd ~/lab/ruby-learning/ruby-core-materials
bundle exec rubocop --config .rubocop.yml ../ruby-core/rb1-11-exceptions/exceptions.rb
```

`no offenses detected` になるまで直す。

### 手順 4 — 「なぜこう書くか」を書く

教材リポの `tasks/rb1-11-exceptions/why.md` を、成果リポの `rb1-11-exceptions/why.md` へコピーする。

実行する場所: `~/lab/ruby-learning`

```sh
cd ~/lab/ruby-learning
cp ruby-core-materials/tasks/rb1-11-exceptions/why.md ruby-core/rb1-11-exceptions/why.md
```

コピーしたファイルを開き、**§1〜§3** を自分の言葉で書く（§4 は手順 5 で書く）。
§3「分からなかったこと」は 1 行 1 問の問いの形で書く。§1 に「〜だろうか」と書いた疑問はここへ移す。
課題の範囲を先取りする問いでも構わない——手順 5.5 で答えが返る。
**模範解説（`commentary.md`）はまだ開かない。**

### 手順 5 — 模範解説と突き合わせる

書き終えたら、教材リポの `tasks/rb1-11-exceptions/commentary.md` を開いて読む。
食い違った箇所・思いつかなかった箇所を、`why.md` の **§4「突き合わせで変わったこと」** に書く。
変わらなかったなら「変わらなかった」と書く。§1〜§3 は書き換えない——自力で到達した理解と
模範解説で到達した理解を分けて残すための欄分けなので、混ぜると手順 5.5 の照合が意味を失う。

### 手順 5.5 — 一次情報と照らす（任意）

```
/why-review rb1-11-exceptions
```

教材リポの claim 表（`tasks/rb1-11-exceptions/claims.yml`）と `why.md` を突き合わせ、
claim ごとに一致度（一致 / 部分 / ずれ / 未言及）と到達時点（自力 / 突き合わせ後 / 未）を返す。
続けて §3 の質問に答える。答えには一次情報の URL と原文の引用が必ず付くので、
納得できないところは原典を自分で確かめられる。claim 表がまだ無い課題では、その場で作られる。

**合否には効かない。** `bin/check` の 4 項目とは別で、走らせなくても課題は完了する。
結果は `~/lab/ruby-learning/docs/grading/rb1-11-exceptions.md` に残る（成果リポには置かない）。

### 手順 6 — 確認課題

在庫を表す `Inventory` に**自作の例外クラスを足して**、判定テストが通るように実装する。

まず雛形を成果リポへ置く。

実行する場所: `~/lab/ruby-learning`

```sh
cd ~/lab/ruby-learning
mkdir -p ruby-core/rb1-11-exceptions/exercise/lib
cp ruby-core-materials/tasks/rb1-11-exceptions/exercise/lib/inventory.rb \
     ruby-core/rb1-11-exceptions/exercise/lib/inventory.rb
```

判定テストは教材リポの `tasks/rb1-11-exceptions/exercise/test/inventory_test.rb` にある。**読んでよい。**

**作るもの**: `Inventory#take(name, count)` と、そこから送出される 3 つの例外クラス。

- `Inventory::Error` — `StandardError` を継承した、この在庫の失敗すべての親。
- `Inventory::UnknownItem` — `Inventory::Error` を継承。知らない品目を求められたとき。
  メッセージは `"unknown item: banana"` の形。
- `Inventory::OutOfStock` — `Inventory::Error` を継承。残りより多く求められたとき。
  メッセージは `"out of stock: apple (asked 5, left 3)"` の形。
- `#take(name, count)` — 取り出せたときは**残りの個数**を返す。失敗したときは在庫を変えずに送出する。

**ここは自分で決める**: どこで送出するか（`take` の先頭でまとめて確かめるか、進めながら確かめるか）と、
親の `Inventory::Error` をどう位置づけるか。判定テストは「2 つの例外が同じ親を持ち、
親で `rescue` すると両方捕まる」ことだけを要求する。

自分でテストを走らせて確かめる。

実行する場所: `~/lab/ruby-learning/ruby-core`

```sh
cd ~/lab/ruby-learning/ruby-core
bundle exec ruby -Irb1-11-exceptions/exercise/lib \
    ../ruby-core-materials/tasks/rb1-11-exceptions/exercise/test/inventory_test.rb
```

判定テストに自分の `assert` を足したくなったら、成果リポ側に自分のテストファイルを作って書く
（教材リポのファイルは編集しない）。自分で足した `assert` は判定の対象にはならないが、
書くこと自体がこの学習計画の狙いの一部である。

### 手順 7 — `bin/check` を通す

実行する場所: `~/lab/ruby-learning/ruby-core-materials`

```sh
cd ~/lab/ruby-learning/ruby-core-materials
bin/check rb1-11-exceptions ../ruby-core
```

全項目が `[合格]` になるまで直す。

## 完了の判定

次がすべて満たされたときに完了とする。判定の正本はこの節である。

1. `bin/check rb1-11-exceptions ../ruby-core` の全項目が `[合格]`（終了コード 0）。
   内訳は「写しの照合」「写しの書式」「`why.md` が雛形と差分あり」「確認課題テスト」の 5 項目。
2. 機械判定に載らない工程として、次の 2 つを終えている。
   - `why.md` を、模範解説（`commentary.md`）を開く前に自分の言葉で書いた。
   - `commentary.md` を読み、自分の説明と食い違った点を `why.md` に書き足した。
3. `progress.md` に `完了` と日付が書かれている。

## 進捗の記録

記録先は成果リポの `progress.md`。課題ごとの記録の表に `rb1-11-exceptions` の行を足し、
状態（`完了`）・日付・一言メモを書く。書いたらコミットする。

```sh
cd ~/lab/ruby-learning/ruby-core
git add .
git commit -m "rb1-11: 例外の手本を写し、Inventory に自作例外を足した"
```

## 次の課題

次に開くファイル: `~/lab/ruby-learning/ruby-core-materials/tasks/rb1-12-mini-integration-1/README.md`
