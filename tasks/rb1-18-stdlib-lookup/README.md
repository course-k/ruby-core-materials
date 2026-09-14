# rb1-18-stdlib-lookup — 標準ライブラリを公式ドキュメントから引く（JSON / CSV / Time / ERB / Logger）

## この課題を終えると何ができるようになるか / 全体のどこにいるか

**位置**: Ruby 軸・レベル「基礎」・課題 18（全 21 課題の 18 本目）。

**到達点**: この課題を終えると、次のことができるようになる。

- JSON / CSV / Time / ERB / Logger を、目的に合わせて選んで使える。
- **使ったことのないメソッドを、公式ドキュメントの該当ページから自分で引いて使える**
  （引数の並び・キーワード引数・戻り値の型を読み取れる）。
- `gem list` で手元に入っている gem の版を確かめ、`Gemfile` に書き足せる。
- 「Ruby に同梱されているのに `Gemfile` に書かないと使えない gem がある」ことを説明できる。

## 初めて使う道具

この課題で初めて使うものが 2 つある。

- **`gem list`** — 手元の Ruby に入っている gem とその版を一覧するコマンド。
  この計画では、教材が書いた版と手元の版がずれていないかを自分の目で確かめるために使う。
  引数に gem 名を渡すと、その名前を含むものだけが出る（`gem list csv logger`）。
- **`Gemfile` への gem の追加** — 課題 1 では教材が渡した `Gemfile` をそのまま使った。
  ここでは初めて自分で 1 行足す。Ruby には「同梱されてはいるが、`Gemfile` を使うプログラムからは
  `Gemfile` に書かないと `require` できない」gem（bundled gem）があり、`csv` と `logger` がそれにあたる。
  `minitest` を課題 1 で `Gemfile` に書いたのと同じ理由。

## 前提

- 課題 17（`tasks/rb1-17-files-io/README.md`）までが完了していること。
- 成果リポ `~/lab/ruby-learning/ruby-core` と教材リポ `~/lab/ruby-learning/ruby-core-materials` の
  両方で `bundle install` が済んでいること（課題 1 の手順 2・3）。
- 課題 7 で Hash と Array を、課題 17 でファイルの読み書きを済ませていること。

## この課題の進め方（全体像）

1. `gem list` で手元の版を確かめ、`Gemfile` に 2 行足して入れ直す。
2. 手本のファイルを読む。
3. **手で打ち込んで**成果リポに写す。
4. 写しを走らせて通す。
5. 「なぜこう書くか」を自分の言葉で書く。
6. 模範解説を開いて突き合わせる。
7. 確認課題を解く。
8. 公式ドキュメントから 3 つの API を自分で引く。
9. `bin/check` を通す。

**写しは手で打ち込む。コピー＆ペーストはしない。** 機械はコピーと打ち込みを区別できないので、
これは自分で守る約束として運用する。打ち込むこと自体が、書式の癖（行末のセミコロン、
`camelCase` の変数名、4 スペースのインデント）を自分の手に気づかせるための工程である。

## 手順

### 手順 1 — 手元の版を確かめ、`Gemfile` に足す

実行する場所: `~/lab/ruby-learning/ruby-core`

```sh
cd ~/lab/ruby-learning/ruby-core
gem list csv logger
```

`csv (3.3.5)` と `logger (1.7.0)` が出れば、この教材が前提にしている版と同じ。
違う版が出たら、次に書く版番号をその値に置き替える。

`~/lab/ruby-learning/ruby-core/Gemfile` の末尾に次の 2 行を足す。

```ruby
gem "csv", "3.3.5"
gem "logger", "1.7.0"
```

```sh
cd ~/lab/ruby-learning/ruby-core
bundle install
```

### 手順 2 — 手本を読む

開くファイル: `~/lab/ruby-learning/ruby-core-materials/tasks/rb1-18-stdlib-lookup/original/stdlib.rb`

この手本は、公式リファレンスの JSON・Time・ERB の各項と、bundled gem の csv 3.3.5・logger 1.7.0 の
リポジトリ（タグ固定）に載っている例をつないだもの。
手本は**定義だけ**。定義を呼び出して結果を確かめるコードは、教材が配る照合テスト
`copy_test/stdlib_test.rb` にある。**写さない。読んでよい。**
底本の URL はファイル冒頭のコメントにある。先にそのページを読んでおくと分かりやすい。

### 手順 3 — 成果リポへ手で打ち込む

実行する場所: `~/lab/ruby-learning/ruby-core`

```sh
cd ~/lab/ruby-learning/ruby-core
mkdir -p rb1-18-stdlib-lookup
```

エディタで `rb1-18-stdlib-lookup/stdlib.rb` を新規作成し、手本を手で打ち込む。

- 1 行目の `# frozen_string_literal: true` は写す（何をする行かは課題 6 で扱う）。その下の底本の URL を書いたコメント群は写さなくてよい。
- クラス名・メソッド名・変数名・文字列は手本どおりに写す。

### 手順 4 — 写しを走らせる

実行する場所: `~/lab/ruby-learning/ruby-core`

```sh
cd ~/lab/ruby-learning/ruby-core
bundle exec ruby -Irb1-18-stdlib-lookup \
    ../ruby-core-materials/tasks/rb1-18-stdlib-lookup/copy_test/stdlib_test.rb
```

最終行に `8 runs, 19 assertions, 0 failures, 0 errors, 0 skips` が出れば写しは正しい。
`failures` や `errors` が 0 でないときは、表示される
「期待した値（Expected）／実際の値（Actual）」を読んで打ち間違いを探す。

手順 1 を飛ばしていると `cannot load such file -- csv` で止まる。

書式も確かめておく。

実行する場所: `~/lab/ruby-learning/ruby-core-materials`

```sh
cd ~/lab/ruby-learning/ruby-core-materials
bundle exec rubocop --config .rubocop.yml ../ruby-core/rb1-18-stdlib-lookup/stdlib.rb
```

`no offenses detected` になるまで直す。

### 手順 5 — 「なぜこう書くか」を書く

教材リポの `tasks/rb1-18-stdlib-lookup/why.md` を、成果リポの `rb1-18-stdlib-lookup/why.md` へコピーする。

実行する場所: `~/lab/ruby-learning`

```sh
cd ~/lab/ruby-learning
cp ruby-core-materials/tasks/rb1-18-stdlib-lookup/why.md ruby-core/rb1-18-stdlib-lookup/why.md
```

コピーしたファイルを開き、**§1〜§3** を自分の言葉で書く（§4 は手順 5 で書く）。
§3「分からなかったこと」は 1 行 1 問の問いの形で書く。§1 に「〜だろうか」と書いた疑問はここへ移す。
課題の範囲を先取りする問いでも構わない——手順 5.5 で答えが返る。
**模範解説（`commentary.md`）はまだ開かない。**

### 手順 6 — 模範解説と突き合わせる

書き終えたら、教材リポの `tasks/rb1-18-stdlib-lookup/commentary.md` を開いて読む。
食い違った箇所・思いつかなかった箇所を、`why.md` の **§4「突き合わせで変わったこと」** に書く。
変わらなかったなら「変わらなかった」と書く。§1〜§3 は書き換えない——自力で到達した理解と
模範解説で到達した理解を分けて残すための欄分けなので、混ぜると手順 5.5 の照合が意味を失う。

### 手順 5.5 — 一次情報と照らす（任意）

```
/why-review rb1-18-stdlib-lookup
```

教材リポの claim 表（`tasks/rb1-18-stdlib-lookup/claims.yml`）と `why.md` を突き合わせ、
claim ごとに一致度（一致 / 部分 / ずれ / 未言及）と到達時点（自力 / 突き合わせ後 / 未）を返す。
続けて §3 の質問に答える。答えには一次情報の URL と原文の引用が必ず付くので、
納得できないところは原典を自分で確かめられる。claim 表がまだ無い課題では、その場で作られる。

**合否には効かない。** `bin/check` の 4 項目とは別で、走らせなくても課題は完了する。
結果は `~/lab/ruby-learning/docs/grading/rb1-18-stdlib-lookup.md` に残る（成果リポには置かない）。

### 手順 7 — 公式ドキュメントから API を引く

次の 3 つは手本に出てこない。それぞれのページを開き、引数（キーワード引数を含む）と戻り値を
読み取って、`why.md` の末尾に 1 行ずつ書く。
この工程がこの課題の中心で、「使い方を教わる」のではなく「引けるようになる」ことを狙っている。

| 引く対象 | 開くページ |
|---|---|
| `JSON.pretty_generate` | https://docs.ruby-lang.org/en/4.0/JSON.html |
| `CSV.generate` のキーワード引数 `headers:` と `write_headers:` | https://ruby.github.io/csv/ （csv 3.3.5 の API。入口は https://github.com/ruby/csv/tree/v3.3.5 ） |
| `Time#strftime` の書式指定子 `%F` と `%T` | https://docs.ruby-lang.org/en/4.0/Time.html |

### 手順 8 — 確認課題

手順 7 で引いた 3 つを使って、`Report` の 3 つのメソッドを実装する。

まず雛形を成果リポへ置く。

実行する場所: `~/lab/ruby-learning`

```sh
cd ~/lab/ruby-learning
mkdir -p ruby-core/rb1-18-stdlib-lookup/exercise/lib ruby-core/rb1-18-stdlib-lookup/exercise/test
cp ruby-core-materials/tasks/rb1-18-stdlib-lookup/exercise/lib/report.rb \
     ruby-core/rb1-18-stdlib-lookup/exercise/lib/report.rb
```

判定テストは教材リポの `tasks/rb1-18-stdlib-lookup/exercise/test/report_test.rb` にある。**読んでよい。**

自分でテストを走らせて確かめる。

実行する場所: `~/lab/ruby-learning/ruby-core`

```sh
cd ~/lab/ruby-learning/ruby-core
bundle exec ruby -Irb1-18-stdlib-lookup/exercise/lib \
    ../ruby-core-materials/tasks/rb1-18-stdlib-lookup/exercise/test/report_test.rb
```

判定テストに自分の `assert` を足したくなったら、成果リポ側に自分のテストファイルを作って書く
（教材リポのファイルは編集しない）。自分で足した `assert` は判定の対象にはならないが、
書くこと自体がこの学習計画の狙いの一部である。

### 手順 9 — `bin/check` を通す

実行する場所: `~/lab/ruby-learning/ruby-core-materials`

```sh
cd ~/lab/ruby-learning/ruby-core-materials
bin/check rb1-18-stdlib-lookup ../ruby-core
```

全項目が `[合格]` になるまで直す。

## 他の書き写し課題との差について

この課題だけ手順 1（`gem list` と `Gemfile` への追加）と手順 7（API を引く）が多い。根拠は設計文書にある。

- 手順 1: 設計文書「Ruby 基礎」§3.2 の「各課題で初めて使う道具」の表が、課題 18 に
  「`gem list` での同梱版の確認、Gemfile への追加」を割り当てている。`csv` と `logger` は
  `Gemfile` に書かないと `require` できない gem なので、この工程を飛ばすと写しが動かない。
- 手順 7: 設計文書「Ruby 基礎」§3.1 の「学習者に残す判断」が、課題 18 に
  「公式ドキュメントから API を引く工程。引く対象の API は課題文書が名指しし、引数と戻り値の
  読み取りを残す」を挙げている。他の課題では使うメソッドを教材が全部見せているが、
  ここだけは引くこと自体が身につける能力である。

## 完了の判定

次がすべて満たされたときに完了とする。判定の正本はこの節である。

1. `bin/check rb1-18-stdlib-lookup ../ruby-core` の全項目が `[合格]`（終了コード 0）。
   内訳は「写しの照合」「写しの書式」「`why.md` が雛形と差分あり」「確認課題テスト」の 5 項目。
   終了コードは `echo $?` で見る。
2. 機械判定に載らない工程として、次の 2 つを終えている。
   - `why.md` を、模範解説（`commentary.md`）を開く前に自分の言葉で書いた。
   - `commentary.md` を読み、自分の説明と食い違った点を `why.md` に書き足した。
3. 手順 7 で 3 つの API の引数と戻り値を `why.md` の末尾に書いた。
4. `progress.md` に `完了` と日付が書かれている。

## 進捗の記録

記録先は成果リポの `progress.md`。課題ごとの記録の表に `rb1-18-stdlib-lookup` の行を足し、
状態（`完了`）・日付・一言メモを書く。`Gemfile` に足した 2 行もここに書いておく（次に環境を作り直すときの手掛かりになる）。書いたらコミットする。

```sh
cd ~/lab/ruby-learning/ruby-core
git add .
git commit -m "rb1-18: 標準ライブラリの手本を写し、Report を実装した"
```

## 次の課題

次に開くファイル: `~/lab/ruby-learning/ruby-core-materials/tasks/rb1-19-optparse-executable/README.md`
