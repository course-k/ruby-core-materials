# rb1-01-tooling — 道具を 1 周する

## この課題を終えると何ができるようになるか / 全体のどこにいるか

**位置**: Ruby 軸・レベル「基礎」・課題 1（全 21 課題の 1 本目）。基礎レベルの最初の課題なので、
ここだけは Ruby そのものが手元に無い状態から書き起こす。

**到達点**: この課題を終えると、次のことができるようになる。

- Ruby 4.0 を自分のマシンに入れ、どの版が使われているかを確認できる。
- 自分の作業用リポジトリ（以下「成果リポ」）を作り、そこで `bundle install` して
  テストとデバッガを走らせられる。
- `Gemfile` / `Gemfile.lock` / `.ruby-version` の 3 つが何をするファイルかを、
  JS の `package.json` / `package-lock.json` / `.nvmrc` と対応づけて説明できる。
- テスト（minitest）・書式検査（RuboCop）・対話環境（irb）・デバッガ（debug）を
  それぞれ 1 回ずつ動かし、**わざと壊して失敗させ、元に戻す**ところまでできる。
- 判定ツール `bin/check` を実行して、この課題の完了を機械に確認させられる。

この課題が終わった時点で、動くリポジトリが 1 つ手元に残る。以降の全課題はこのリポジトリに書き足していく。

## 用語（この教材で使う呼び名）

- **教材リポ**: `~/lab/ruby-learning/ruby-core-materials`。課題文・手本・雛形・判定ツールが入っている。公開元は https://github.com/course-k/ruby-core-materials （手元に無い環境では `git clone git@github.com:course-k/ruby-core-materials.git ~/lab/ruby-learning/ruby-core-materials` で取れる。このリポジトリには封緘の鍵は入っていない）。
  読むだけで、ここには何も書かない。
- **成果リポ**: `~/lab/ruby-learning/ruby-core`。あなたが書いたものを置く場所。
  課題ごとに `<課題番号>/` というディレクトリを作る。
- **課題番号**: `rb1-01-tooling` のような名前。`rb1` は「Ruby 軸の基礎レベル」を表す。
  教材リポの `tasks/<課題番号>/` と成果リポの `<課題番号>/` が 1 対 1 で対応する。

## 初めて使う道具

この課題で初めて使う道具は 8 つ。どれも「何をする道具か」と「なぜこの学習計画で要るか」を
先に読んでから手を動かす。

### 1. mise — Ruby 本体の版を切り替える道具

**何をする道具か**: 言語処理系（ここでは Ruby）を版ごとにインストールし、
ディレクトリごと・全体ごとに「どの版を使うか」を切り替える。JS の nvm / Volta にあたる。

**なぜ要るか**: macOS には古い Ruby が最初から入っているが、更新できない。
この学習計画は Ruby 4.0 系を使うと決めている（教材の手本もその版の公式ドキュメントから取っている）ので、
OS 付属の Ruby ではなく自分で入れた 4.0 を使う。Rails の公式インストールガイドが
macOS で mise を勧めているのも理由の 1 つ。

### 2. Bundler — 使う gem とその版を固定する道具

**何をする道具か**: `Gemfile` に「使う gem」を書くと、Bundler がそれらを入れ、
実際に入った版を `Gemfile.lock` に記録する。`bundle exec <コマンド>` で実行すると、
その記録どおりの版が使われる。JS の npm / package.json にあたる。

**なぜ要るか**: 教材が想定した版と、あなたの手元で動く版を一致させるため。
判定ツールもあなたのコードを `bundle exec` 経由で走らせるので、`bundle install` が済んでいないと動かない。

### 3. minitest — テストを書いて走らせる道具

**何をする道具か**: `assert_equal` のような「こうなっているはず」を書き並べ、
実際にそうなっているかを確かめるライブラリ。Ruby に同梱されている。

**なぜ要るか**: この学習計画では、課題の合否をすべて minitest で機械判定する。
手本を書き写す課題でも、写したものがテストの形になっていて、
「写したコードが自分で自分を検証する」ようにしてある。JS の Jest / Vitest にあたる。

### 4. RuboCop — Ruby の書式を検査する道具

**何をする道具か**: インデント幅・空行・引用符・命名などが Ruby の慣習どおりかを検査する。
JS の ESLint / Prettier にあたる。

**なぜ要るか**: JS の書き癖（行末のセミコロン、`camelCase` の変数名、4 スペースのインデント）は
Ruby でも動いてしまうため、テストだけでは検出できない。書式検査を判定に入れることで、
「動くが Ruby らしくない」状態を見つける。教材リポに検査設定が置いてあり、判定はその設定で行う。

### 5. irb — 式を 1 つずつ試せる対話環境

**何をする道具か**: 起動して式を打つと、その場で評価して結果を表示する。JS のブラウザコンソール / `node` にあたる。

**なぜ要るか**: 公式の入門（Ruby in Twenty Minutes）が irb から始まる。
以降の課題でも「この式は何を返すのか」を確かめる道具として何度も使う。

### 6. debug — 実行を止めて中を見るデバッガ

**何をする道具か**: コードに `binding.break` と書いた行で実行が止まり、
そこで変数の中身を見たり式を評価したりできる。JS の `debugger` 文にあたる。

**なぜ要るか**: 後の課題には「壊れたコードの欠陥を自分で見つける」ものがある。
`puts` を差し込む以外の調べ方を、最初に 1 度通しておく。

### 7. `bin/check` — 課題の完了を判定するツール

**何をする道具か**: 教材リポにある実行ファイル。`bin/check <課題番号> <成果リポのパス>` の形で呼ぶと、
その課題で見るべき項目（テストが通るか・書式が通るかなど）をまとめて確認し、
項目ごとに「合格 / 失敗 / 未着手」を表示する。

**なぜ要るか**: 各課題の「終わった」を、自己申告ではなく機械で確かめるため。
判定の結果は成果リポの `.check/<課題番号>.yml` に記録される（この記録ファイルは自分で編集しない）。

### 8. 封緘と鍵 — 先に読んではいけない課題文を閉じておく仕組み

**何をする道具か**: 課題によっては、要件や判定テストを暗号化した状態で教材リポに置いてある
（この教材ではこれを**封緘**と呼ぶ）。`bin/check --start <課題番号> <成果リポのパス>` を実行した
ときだけ要件が開き、判定テストは判定の瞬間だけ開いてすぐ消える。開ける鍵は 1 つのファイルで、
教材リポにも成果リポにも入っていない。

**なぜこの計画で要るか**: 「自分で設計して実装する」課題は、先に答え（要件の詳細や判定条件）を
読んでしまうと課題として成立しない。人間の意思だけで「読まない」を保つより、
開けられない形にしておくほうが確実である。鍵を両リポの外に置くのは、リポジトリを公開しても
封緘が破れないようにするため。

鍵は手順 3 で置く。

## 前提

- macOS（Apple Silicon）で作業する。ターミナルを開ける。
- Homebrew が入っている。入っていなければ https://brew.sh の手順で入れる。
- git が使える。
- 教材リポが `~/lab/ruby-learning/ruby-core-materials` にある（このファイルがそのリポジトリの中にある）。
- 封緘の鍵ファイル `~/.config/ruby-learning/seal.key` が置いてある（手順 3 で確認する。教材を作った AI のセッションが、教材と同時にこの場所へ置いている）。
- Ruby は入っていなくてよい。この課題で入れる。

## 手順

以下、`$` で始まる行がターミナルに打つコマンド。各手順の冒頭に「どこで実行するか」（cwd）を書く。

### 手順 1 — mise を入れて Ruby 4.0 を入れる

実行する場所: どこでもよい（ホームディレクトリで構わない）。

```sh
brew install openssl@3 libyaml gmp rust
curl https://mise.run | sh
echo 'eval "$(~/.local/bin/mise activate)"' >> ~/.zshrc
source ~/.zshrc
mise use -g ruby@4.0
```

最後の行が、この学習計画で使う版の指定である。
（Rails の公式インストールガイドは同じ場所で `mise use -g ruby@3` と書いているが、
この計画は Ruby 4.0 系を使うので `ruby@4.0` に読み替える。）

入ったことを確認する。

```sh
ruby -v
```

`ruby 4.0.6` で始まる行が出れば成功。別の版が出たときは `source ~/.zshrc` をやり直す。

### 手順 2 — 成果リポを作る

実行する場所: `~/lab/ruby-learning`（無ければ `mkdir -p ~/lab/ruby-learning` で作る）。

```sh
cd ~/lab/ruby-learning
mkdir ruby-core
cd ruby-core
git init
```

次の 5 つのファイルを作る。中身はここに書いてあるとおりにする。

**`.ruby-version`**（この 1 行だけ）

```
4.0.6
```

**`Gemfile`**

```ruby
# frozen_string_literal: true

source "https://rubygems.org"

gem "debug", "1.11.1"
gem "irb", "1.16.0"
gem "minitest", "6.0.0"
```

**`.gitignore`**

```
/vendor/
/.bundle/
```

`.check/` はここに書かない。判定の記録はコミットする（学習の履歴として残す）。

**`progress.md`**（進捗の記録。中身は下の「進捗の記録」節で説明する）

```markdown
# 学習の進捗

## 週あたりの目標

週に <自分で決めた数> セッション。1 セッションは 1 回まとまって机に向かう時間を指す。
（この数は自分で決めて書き込む。決め方: 最初の 2 週間は実際にできた回数を記録し、
その平均を目標として書き直す。）

## 状態の言葉

- **未着手**: まだ開いていない。
- **進行中**: 着手したが完了していない。
- **完了**: `bin/check` が全項目「合格」を返した。
- **未消化**: 先へ進むために飛ばした。後で戻るかもしれないし、戻らないかもしれない。

## 課題ごとの記録

| 課題番号 | 状態 | 日付 | メモ |
|---|---|---|---|
| rb1-01-tooling | 進行中 | | |

## 想起セッションの記録

過去にやった課題から 1 題を教材を見ずに解き直したときに、日付・題・結果をここに書く。

| 日付 | 題 | 結果 |
|---|---|---|
```

**`README.md`**

```markdown
# ruby-core — Ruby 基礎・中級の学習記録

これは Ruby / Ruby on Rails を学ぶための**学習記録**のリポジトリである。
製品コードではない。

## AI の関与について

教材（課題文・仕様・テスト・雛形・模範解説）は AI が生成した。
**解答はすべて本人が書いた。** 課題のコードと「なぜこう書くか」の記述に AI は使っていない。
```

作ったら Bundler で gem を入れる。

実行する場所: `~/lab/ruby-learning/ruby-core`

```sh
bundle config set --local path vendor/bundle
bundle install
```

`Bundle complete!` と出れば成功。`Gemfile.lock` が生成されているはずなので中を見ておく。

```sh
cat Gemfile.lock
```

ここまでで、`Gemfile`（使う gem の宣言）・`Gemfile.lock`（実際に入った版の記録）・
`.ruby-version`（使う Ruby 本体の版）の 3 つが揃った。
JS でいう `package.json` / `package-lock.json` / `.nvmrc` と同じ役割分担である。

### 手順 3 — 教材リポで `bundle install` し、封緘の鍵があることを確かめる

教材リポは `~/lab/ruby-learning/ruby-core-materials` にある前提で進む（前提の節）。

まず封緘の鍵があることを確かめる。この教材は AI が作った（ルートの README の開示のとおり）。封緘物はそのときの鍵で暗号化してあり、
鍵は教材と同時に `~/.config/ruby-learning/seal.key` へ置いてある。**鍵は自分で作らない**——自分で作った鍵では開かない。
無い場合（別のマシンで学ぶ等）は、教材を作った環境の `~/.config/ruby-learning/seal.key` を同じ場所へコピーする。

実行する場所: どこでもよい（ホームディレクトリで構わない）。

```sh
ls -l ~/.config/ruby-learning/seal.key
```

`-rw-------` で始まる行が表示されれば置いてある。無ければ上記のとおりコピーし、`chmod 600 ~/.config/ruby-learning/seal.key` で権限を絞る。
鍵を両リポの外（`~/.config/` の下）に置くのは、リポジトリを公開しても封緘が破れないようにするため。
このリポジトリには鍵は入っていない。**鍵を失うと封緘物は開けられず、課題 12・16・20・21 に
着手できなくなる**ので、鍵ファイルは別の場所にも控えておく。

次に教材リポ側でも gem を入れる。RuboCop は**教材リポの側で**動く（検査設定を教材が固定しているため）。

実行する場所: `~/lab/ruby-learning/ruby-core-materials`

```sh
cd ~/lab/ruby-learning/ruby-core-materials
bundle config set --local path vendor/bundle
bundle install
```

### 手順 4 — 教材の雛形を成果リポへ置く

教材リポには FizzBuzz の雛形が 2 ファイル入っている。
**これは AI が書いた雛形であり、書き写しの手本ではない。** そのままコピーして使う。

実行する場所: `~/lab/ruby-learning`

```sh
cd ~/lab/ruby-learning
mkdir -p ruby-core/rb1-01-tooling
cp -R ruby-core-materials/tasks/rb1-01-tooling/template ruby-core/rb1-01-tooling/template
ls ruby-core/rb1-01-tooling/template/lib ruby-core/rb1-01-tooling/template/test
```

`fizzbuzz.rb` と `fizzbuzz_test.rb` が出れば置けている。中身を読んでおく。

### 手順 5 — minitest でテストを走らせる

実行する場所: `~/lab/ruby-learning/ruby-core`

```sh
cd ~/lab/ruby-learning/ruby-core
bundle exec ruby -Irb1-01-tooling/template/lib -Irb1-01-tooling/template/test rb1-01-tooling/template/test/fizzbuzz_test.rb
```

`-I` は「このディレクトリからも `require` できるようにする」という指定。
最後に `5 runs, 9 assertions, 0 failures, 0 errors, 0 skips` のような行が出れば成功。
`0 failures, 0 errors` であることを確かめる。

### 手順 6 — RuboCop で書式を検査する

実行する場所: `~/lab/ruby-learning/ruby-core-materials`

```sh
cd ~/lab/ruby-learning/ruby-core-materials
bundle exec rubocop --config .rubocop.yml ../ruby-core/rb1-01-tooling/template
```

`no offenses detected` と出れば成功。

### 手順 7 — irb から呼んでみる

実行する場所: `~/lab/ruby-learning/ruby-core`

```sh
cd ~/lab/ruby-learning/ruby-core
bundle exec irb -Irb1-01-tooling/template/lib
```

irb が起動したら、次の 3 行を順に打つ。

```ruby
require "fizzbuzz"
FizzBuzz.say(15)
FizzBuzz.list(5)
```

それぞれ `true`、`"FizzBuzz"`、`["1", "2", "Fizz", "4", "Buzz"]` が返る。
`exit` と打つと irb を抜ける。

### 手順 8 — debug で 1 回止める

実行する場所: `~/lab/ruby-learning/ruby-core`

`rb1-01-tooling/template/lib/fizzbuzz.rb` を開き、`def self.say(number)` の**次の行**に
`binding.break` と書いた行を 1 行足す。足した状態は次のようになる。

```ruby
  def self.say(number)
    binding.break
    return "FizzBuzz" if (number % 15).zero?
```

その状態でテストを走らせる。

```sh
bundle exec ruby -Irb1-01-tooling/template/lib -Irb1-01-tooling/template/test rb1-01-tooling/template/test/fizzbuzz_test.rb
```

`(rdbg)` というプロンプトで止まる。そこで次を順に打つ。

- `number` … いま渡されている値が表示される。
- `c` … 次の停止位置まで実行を続ける（テストは何度も `say` を呼ぶので何度も止まる）。
- `q` そして `y` … デバッガを終了する。

**戻す**: 足した `binding.break` の 1 行を削除する。
**戻ったことの確認**: 手順 5 のコマンドをもう一度走らせ、`(rdbg)` で止まらずに
`0 failures, 0 errors` まで進むこと。

### 手順 9 — わざと壊して、戻す

道具が「失敗を検出できる」ことを自分の目で見る。3 つとも、壊す → 確かめる → 戻す →
戻ったことを確かめる、の 4 段階で行う。

**(a) テストを 1 つ落とす**

- 壊す: `rb1-01-tooling/template/lib/fizzbuzz.rb` の `return "Fizz" if (number % 3).zero?` の
  `"Fizz"` を `"fizz"`（小文字）に書き換える。
- 確かめる: 手順 5 のコマンド。2 つのテストが落ちて `2 failures` と出て、
  `Expected: "Fizz"` / `Actual: "fizz"` の形で食い違いが表示される。
- 戻す: `"Fizz"` に書き戻す。
- 戻ったことの確認: 手順 5 のコマンドで `0 failures, 0 errors` に戻ること。

**(b) 書式を崩す**

- 壊す: 同じファイルの `number.to_s` の行の行頭に空白を 4 つ足し、行末に `;`（セミコロン）を足す。
- 確かめる: 手順 6 のコマンド。Layout の指摘（`Layout/IndentationConsistency`）と `Style/Semicolon` の指摘が出る。
  **このときテスト（手順 5）は通ったままである**ことも確かめる。テストは書式の逸脱を見つけられない。
- 戻す: 足した空白とセミコロンを消す。
- 戻ったことの確認: 手順 6 のコマンドで `no offenses detected` に戻ること。

**(c) 雛形を消してしまった場合の戻し方**

- 壊す前に知っておく: 成果リポ側の `template/` を消したり編集しすぎたりしても、
  教材リポ側の原本は無傷である。
- 戻す: 手順 4 の `cp -R` をもう一度実行する（`ruby-core/rb1-01-tooling/template` を
  先に `rm -rf` してから実行する）。
- 戻ったことの確認: 手順 5 と手順 6 のコマンドが両方とも成功すること。

### 手順 10 — `bin/check` を通す

実行する場所: `~/lab/ruby-learning/ruby-core-materials`

```sh
cd ~/lab/ruby-learning/ruby-core-materials
bin/check rb1-01-tooling ../ruby-core
```

表示された各項目が `[合格]` になっていることを確かめる。
`[失敗]` が残っているときは、その行に出ている理由を読んで手順 5・6 に戻る。

終了コードでも確かめられる。

```sh
echo $?
```

`0` なら合格、`1` なら失敗が残っている。

### 手順 11 — 成果リポに記録を残す

実行する場所: `~/lab/ruby-learning/ruby-core`

`progress.md` の表の `rb1-01-tooling` の行を `完了` に変え、日付と一言メモを書く。
そのうえでコミットする。

```sh
cd ~/lab/ruby-learning/ruby-core
git add .
git commit -m "rb1-01: 道具を 1 周し、FizzBuzz の雛形を動かした"
```

## 完了の判定

次の 5 つがすべて満たされたときに、この課題は完了とする。

1. `bin/check rb1-01-tooling ../ruby-core` の全項目が `[合格]`（終了コード 0）。
2. 手順 7（irb）と手順 8（debug）を実際に実行した。これらは機械判定の対象ではないので、
   自分で「やった」と言えることが条件になる。
3. 手順 9 の (a) (b) を実際に壊して失敗を見て、戻した。
4. 手順 3 で `~/.config/ruby-learning/seal.key` を置き、`ls -l` で確かめた。
5. `progress.md` に `完了` と日付が書かれ、成果リポにコミットされている。

## 進捗の記録

記録先は成果リポの `progress.md`（手順 2 で作ったファイル）。
この課題を終えた時点で次を書く。

- 課題ごとの記録の表: `rb1-01-tooling` の行を `完了` にし、日付と一言メモを入れる。
- 週あたりの目標: `<自分で決めた数>` の箇所に数字を入れる（今は仮でよい。2 週間後に書き直す）。

`.check/rb1-01-tooling.yml` は `bin/check` が自動で書く機械の記録で、`progress.md` とは役割が違う。
自分では編集しない。

## 次の課題

次に開くファイル: `~/lab/ruby-learning/ruby-core-materials/tasks/rb1-02-twenty-minutes/README.md`
