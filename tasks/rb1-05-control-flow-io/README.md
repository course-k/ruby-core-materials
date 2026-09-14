# rb1-05-control-flow-io — 制御構造とスクリプトの入出力

## この課題を終えると何ができるようになるか / 全体のどこにいるか

**位置**: Ruby 軸・レベル「基礎」・課題 5（全 21 課題の 5 本目）。

**到達点**: この課題を終えると、次のことができるようになる。

- `if` / `elsif` / `else` / `unless` / `case` / `while` / `until` と、後置の `if` を書ける。
- `&&` / `||` と `and` / `or` の優先順位の違いを説明でき、`x = a and b` が何を代入するかを言える。
- `&.` が「次の 1 呼び出しだけを飛ばす」ことを説明でき、連鎖の途中で `nil` になる式を安全に書ける。
- 標準出力（`puts`）と標準エラー（`warn`）を使い分け、`exit` で終了コードを返せる。
- コマンドライン引数（`ARGV`）と標準入力（`$stdin.read`）を受け取るスクリプトを書ける。

## 初めて使う道具

この課題で初めて使う道具は 5 つある。どれも道具というよりシェルの操作である。

### 1. `ruby` コマンドで直接スクリプトを走らせる

これまではテストファイルを走らせてきたが、この課題からは「スクリプト」——
端末から呼ばれて、引数を受け取り、出力し、終了コードを返すプログラム——を意識する。
`bundle exec ruby <ファイル>` に続けて書いた語は、そのままプログラムの `ARGV` に入る。

```sh
bundle exec ruby some_script.rb report.csv --verbose
```

### 2. 標準入力のリダイレクト `<`

`<` はファイルの中身をプログラムの標準入力に流し込むシェルの記法。
プログラム側は `$stdin.read` で受け取る。

```sh
bundle exec ruby some_script.rb < input.txt
```

この学習計画で要る理由: 課題 12 と課題 21 で「標準入力を受けて標準出力へ出す」小さな道具を作る。
その形はここで 1 度踏んでおく。

### 3. `echo $?` で終了コードを見る

直前に終了したプログラムの終了コードを表示するシェルの記法。
`0` は成功、`0` 以外は失敗を表すのが慣習である。

```sh
bundle exec ruby some_script.rb
echo $?
```

この学習計画で要る理由: `bin/check` 自身も終了コードで合否を返している（課題 1 の手順 10）。
自分の書くプログラムでも同じ約束に従う。

### 4. `printf ... > ファイル` でテキストファイルを作る

`printf` は文字を書き出すシェルのコマンド。`\n` は改行として書き出される
（`echo` と違い、改行の扱いがシェルによって変わらない）。`>` は、書き出す先を画面から
ファイルへ切り替えるシェルの記法である。同名のファイルがあれば中身は置き換わる。

```sh
printf 'alpha\nbeta\n' > input.txt
```

この学習計画で要る理由: 標準入力から読むプログラムを手元で試すには、流し込む入力が要る。
手順 6 と、課題 12・19・21 の動作確認で使う。

### 5. パイプ `|` で前のプログラムの出力を次の標準入力にする

`A | B` は、`A` が標準出力に書いたものを、そのまま `B` の標準入力に渡すシェルの記法。
`<` が「ファイルから流し込む」のに対し、`|` は「別のプログラムの出力から流し込む」。

```sh
printf 'alpha\nbeta\n' | bundle exec ruby some_script.rb
```

この学習計画で要る理由: 課題 19 で作る実行ファイルの動作確認をこの形で行う。
ファイルを残さずに 1 行で試せる。

## 前提

- 課題 4（`tasks/rb1-04-values-truth/README.md`）までが完了していること。
- 成果リポ `~/lab/ruby-learning/ruby-core` と教材リポ `~/lab/ruby-learning/ruby-core-materials` の
  両方で `bundle install` が済んでいること（課題 1 の手順 2・3）。
- この課題のために新しく入れるものは無い。

## この課題の進め方（全体像）

1. 手本のファイルを読む。
2. **手で打ち込んで**成果リポに写す。
3. 写しを照合テストで確かめる。
4. 「なぜこう書くか」を自分の言葉で書く。
5. 模範解説を開いて突き合わせる。
6. スクリプトとして端末から 1 度動かす。
7. 確認課題を解く。
8. `bin/check` を通す。

**写しは手で打ち込む。コピー＆ペーストはしない。** 機械はコピーと打ち込みを区別できないので、
これは自分で守る約束として運用する。打ち込むこと自体が、書式の癖（行末のセミコロン、
`camelCase` の変数名、4 スペースのインデント）を自分の手に気づかせるための工程である。

## 手順

### 手順 1 — 手本を読む

開くファイル: `~/lab/ruby-learning/ruby-core-materials/tasks/rb1-05-control-flow-io/original/control_flow_and_io.rb`

この手本は、公式リファレンスの Control Expressions・Precedence・Calling Methods（Safe Navigation Operator 節）と、
Kernel の `puts` / `warn` / `exit` の項に載っている例をつないだもの。
底本の URL はファイル冒頭のコメントにある。先にそのページを読んでおくと分かりやすい。

### 手順 2 — 成果リポへ手で打ち込む

実行する場所: `~/lab/ruby-learning/ruby-core`

```sh
cd ~/lab/ruby-learning/ruby-core
mkdir -p rb1-05-control-flow-io
```

エディタで `rb1-05-control-flow-io/control_flow_and_io.rb` を新規作成し、手本を手で打ち込む。

- 1 行目の `# frozen_string_literal: true` は写す（何をする行かは課題 6 で扱う）。その下の底本の URL を書いたコメント群は写さなくてよい。
- クラス名・メソッド名・変数名・文字列は手本どおりに写す。

### 手順 3 — 写しを照合テストで確かめる

実行する場所: `~/lab/ruby-learning/ruby-core`

```sh
cd ~/lab/ruby-learning/ruby-core
bundle exec ruby -Irb1-05-control-flow-io \
    ../ruby-core-materials/tasks/rb1-05-control-flow-io/copy_test/control_flow_and_io_test.rb
```

最終行に `11 runs, 14 assertions, 0 failures, 0 errors, 0 skips` が出れば写しは正しい。
`failures` や `errors` が 0 でないときは、表示される
「期待した値（Expected）／実際の値（Actual）」を読んで打ち間違いを探す。

書式も確かめておく。

実行する場所: `~/lab/ruby-learning/ruby-core-materials`

```sh
cd ~/lab/ruby-learning/ruby-core-materials
bundle exec rubocop --config .rubocop.yml ../ruby-core/rb1-05-control-flow-io/control_flow_and_io.rb
```

`no offenses detected` になるまで直す。

### 手順 4 — 「なぜこう書くか」を書く

教材リポの `tasks/rb1-05-control-flow-io/why.md` を、成果リポの `rb1-05-control-flow-io/why.md` へコピーする。

実行する場所: `~/lab/ruby-learning`

```sh
cd ~/lab/ruby-learning
cp ruby-core-materials/tasks/rb1-05-control-flow-io/why.md ruby-core/rb1-05-control-flow-io/why.md
```

コピーしたファイルを開き、**§1〜§3** を自分の言葉で書く（§4 は手順 5 で書く）。
§3「分からなかったこと」は 1 行 1 問の問いの形で書く。§1 に「〜だろうか」と書いた疑問はここへ移す。
課題の範囲を先取りする問いでも構わない——手順 5.5 で答えが返る。
**模範解説（`commentary.md`）はまだ開かない。**

### 手順 5 — 模範解説と突き合わせる

書き終えたら、教材リポの `tasks/rb1-05-control-flow-io/commentary.md` を開いて読む。
食い違った箇所・思いつかなかった箇所を、`why.md` の **§4「突き合わせで変わったこと」** に書く。
変わらなかったなら「変わらなかった」と書く。§1〜§3 は書き換えない——自力で到達した理解と
模範解説で到達した理解を分けて残すための欄分けなので、混ぜると手順 5.5 の照合が意味を失う。

### 手順 5.5 — 一次情報と照らす（任意）

```
/why-review rb1-05-control-flow-io
```

教材リポの claim 表（`tasks/rb1-05-control-flow-io/claims.yml`）と `why.md` を突き合わせ、
claim ごとに一致度（一致 / 部分 / ずれ / 未言及）と到達時点（自力 / 突き合わせ後 / 未）を返す。
続けて §3 の質問に答える。答えには一次情報の URL と原文の引用が必ず付くので、
納得できないところは原典を自分で確かめられる。claim 表がまだ無い課題では、その場で作られる。

**合否には効かない。** `bin/check` の 4 項目とは別で、走らせなくても課題は完了する。
結果は `~/lab/ruby-learning/docs/grading/rb1-05-control-flow-io.md` に残る（成果リポには置かない）。

### 手順 6 — スクリプトとして端末から 1 度動かす

この手順はこの課題だけにある。設計上、コマンドライン引数・標準入力のリダイレクト・終了コードの
3 つをここで初めて使うことになっているので（「初めて使う道具」節）、テストの中だけでなく
端末から 1 度動かして確かめる。

実行する場所: `~/lab/ruby-learning/ruby-core`

`rb1-05-control-flow-io/echo_lines.rb` を新規作成し、次を打ち込む。

```ruby
# frozen_string_literal: true

label = ARGV[0] || "line"
$stdin.read.each_line.with_index(1) do |line, number|
  puts "#{label} #{number}: #{line.chomp}"
end
warn "read #{label} lines" if ARGV.include?("--verbose")
exit(0)
```

入力にするファイルも作る。

```sh
cd ~/lab/ruby-learning/ruby-core
printf 'alpha\nbeta\n' > rb1-05-control-flow-io/input.txt
```

走らせる。

```sh
bundle exec ruby rb1-05-control-flow-io/echo_lines.rb row < rb1-05-control-flow-io/input.txt
echo $?
```

`row 1: alpha` と `row 2: beta` の 2 行が出て、`echo $?` が `0` を返せばよい。
引数を省いて

```sh
bundle exec ruby rb1-05-control-flow-io/echo_lines.rb < rb1-05-control-flow-io/input.txt
```

と打つと、`line 1: alpha` のように既定のラベルに変わる。

このファイルと `input.txt` は判定の対象ではないが、成果リポに残しておく（後で見返せるように）。

### 手順 7 — 確認課題

**壊れているコードを直す**課題。行を検査して報告する `LineReport.run` が、判定テストの一部で落ちる。

まず雛形を成果リポへ置く。

実行する場所: `~/lab/ruby-learning`

```sh
cd ~/lab/ruby-learning
mkdir -p ruby-core/rb1-05-control-flow-io/exercise/lib
cp ruby-core-materials/tasks/rb1-05-control-flow-io/exercise/lib/line_report.rb \
     ruby-core/rb1-05-control-flow-io/exercise/lib/line_report.rb
```

判定テストは教材リポの `tasks/rb1-05-control-flow-io/exercise/test/line_report_test.rb` にある。**読んでよい。**

**やること**: 雛形のコードには欠陥がある。判定テストを走らせて落ちたテストの名前と失敗メッセージを読み、
**欠陥の所在を自分で突き止めて直す**。どこが悪いかはこの課題文には書かない——見つけること自体がこの課題である。

直すときの条件:

- `LineReport.run(text)` の仕様は雛形のコメントに書いてあるとおり。この仕様は変えない。
- 判定テストは書き換えない。
- 落ちているテストを通したときに、いま通っているテストが落ちないようにする。

自分でテストを走らせて確かめる。

実行する場所: `~/lab/ruby-learning/ruby-core`

```sh
cd ~/lab/ruby-learning/ruby-core
bundle exec ruby -Irb1-05-control-flow-io/exercise/lib \
    ../ruby-core-materials/tasks/rb1-05-control-flow-io/exercise/test/line_report_test.rb
```

判定テストに自分の `assert` を足したくなったら、成果リポ側に自分のテストファイルを作って書く
（教材リポのファイルは編集しない）。自分で足した `assert` は判定の対象にはならないが、
書くこと自体がこの学習計画の狙いの一部である。

### 手順 8 — `bin/check` を通す

実行する場所: `~/lab/ruby-learning/ruby-core-materials`

```sh
cd ~/lab/ruby-learning/ruby-core-materials
bin/check rb1-05-control-flow-io ../ruby-core
```

全項目が `[合格]` になるまで直す。

## 完了の判定

次がすべて満たされたときに完了とする。判定の正本はこの節である。

1. `bin/check rb1-05-control-flow-io ../ruby-core` の全項目が `[合格]`（終了コード 0）。
   内訳は「写しの照合」「写しの書式」「`why.md` が雛形と差分あり」「確認課題テスト」の 5 項目。
2. 機械判定に載らない工程として、次の 2 つを終えている。
   - `why.md` を、模範解説（`commentary.md`）を開く前に自分の言葉で書いた。
   - `commentary.md` を読み、自分の説明と食い違った点を `why.md` に書き足した。
   - 手順 6 で、スクリプトとして端末から 1 度動かした。
3. `progress.md` に `完了` と日付が書かれている。

## 進捗の記録

記録先は成果リポの `progress.md`。課題ごとの記録の表に `rb1-05-control-flow-io` の行を足し、
状態（`完了`）・日付・一言メモを書く。書いたらコミットする。

```sh
cd ~/lab/ruby-learning/ruby-core
git add .
git commit -m "rb1-05: 制御構造と入出力の手本を写し、LineReport の欠陥を直した"
```

## 次の課題

次に開くファイル: `~/lab/ruby-learning/ruby-core-materials/tasks/rb1-06-strings-symbols/README.md`
