# 課題担当者向けの手引き

最終更新: 2026-09-12

本書は `ruby-core-materials` に課題本文（`tasks/` 配下）を作る担当者のためのもの。
規定の正本は根幹文書 `~/lab/ruby-learning/docs/01-core-spec.md` と設計文書
`~/lab/ruby-learning/docs/10-design-ruby-basic.md` にあり、本書は**基盤側の実装がそれを
どう受けるか**だけを書く。両者が食い違ったら根幹文書が正。

`check.yml` のキーの一覧は `docs/check-yml.md`。実例は `tasks/rb1-00-selfcheck/`
（`bin/check` の judge 8 種すべてを動かす検体。学習者向けの課題ではない）。

## 1. 課題ディレクトリの構成

```
tasks/<課題番号>/
  README.md                    課題文書。根幹 §4.2 の 5 要素を必ず持つ
  check.yml                    judge の構成（docs/check-yml.md）
  original/<name>.rb           手本の原本（実行スクリプト。学習者が写すのはこれだけ）
  copy_test/<name>_test.rb     写しの照合テスト（非封緘。学習者は読んでよいが写さない）
  why.md                       「なぜこう書くか」欄の雛形
  commentary.md                模範解説。why.md を書いた後に開く（非封緘）
  exercise/lib/<name>.rb       確認課題の雛形（学習者が成果リポへ置いて実装する）
  exercise/test/<name>_test.rb 確認課題の判定テストの正本（非封緘。学習者が読んでよい）
  predict/NN.rb                出力予測の対象コード（学習者は成果リポに NN.txt を書く）
  template/lib/・template/test/ 雛形一式（課題 1 のような「雛形を動かす」課題のみ）
  band/<name>/                 中間帯（完成問題・デバッグ課題）の雛形とテスト。デバッグ課題のテストは非封緘、
                               完成問題の判定テストは sealed/ に置く
  template/<name>.rb           ミニ統合・ゼロ実装の雛形（根幹 §3.2: 判定が読む 1 ファイル、中身は
                               `# frozen_string_literal: true` の 1 行のみ）
  sealed/<name>.enc            封緘物。平文はここに置かない
```

課題 3（minitest の読み書きが学習対象）は例外で、手本が `original/<name>_test.rb`（minitest のテストクラス）のまま、`copy_test/` を持たない（根幹 §3.1）。

実際の配置は各課題の `check.yml` が正。上の一覧に無い置き方が要るときは `check.yml` に書き、
本節へ追記する（課題担当が置いた配置の記録は教材リポの外、`~/lab/ruby-learning/docs/impl-notes/` にある）。

課題番号の書式は `rb1-NN-<slug>`（設計文書 §3）。成果リポ側は `<成果リポ>/<課題番号>/` が
一対一で対応する（根幹 §6 の配置契約）。

命名の約束:

- 手本の原本は `original/<name>.rb`（`_test` を付けない——テストではない）。写しの照合テストは
  `copy_test/<name>_test.rb`。課題 3 のみ手本が `original/<name>_test.rb`。`shakyo.rb` のような統治側の符丁を
  ファイル名にしない（根幹 §4.2「語彙の自己完結」——学習者が読むパスに未定義語を出さない）。
- 確認課題・封緘テストのクラス名は課題ごとに一意にする。判定が同じプロセスで走ることはないが、
  失敗表示に出るのはクラス名＋メソッド名だけなので、そこから課題が分かる名前にする。
- 封緘テストのテストメソッド名は、**仕様本文に書いた境界条件の語だけ**で作る。テスト名から
  仕様を超えた情報が漏れない線を引く（根幹 §7）。

その課題で使わないディレクトリは作らない。ただし `README.md` と `check.yml` は全課題に要る。

## 2. `check.yml` の書き方

形式別のひな型は `docs/check-yml.md` 末尾の表にある。設計文書 §5 の judge 表がそのまま対応する。
書くときに間違えやすい点は 3 つ。

1. **パスの基準が judge ごとに違う。** 教材リポ側（`tasks/<課題番号>/` から）か成果リポ側
   （`<成果リポ>/<課題番号>/` から）かは `docs/check-yml.md` の各表に書いてある。取り違えると
   judge が「未着手」のまま黙って通る。作った直後に模擬の成果リポで 1 度走らせて確かめる。
2. **`assertion_count` の `min` と `runs_min` は実測値を書く。** 課題 3 と検体 rb1-00 だけに要る手順。原本を数えて書かない:

   ```sh
   bundle exec ruby tasks/<課題番号>/original/<name>_test.rb   # 最終行の "N runs, M assertions" を読む
   ```

   `refute_empty` のように内部で 2 回 assert する呼び出しがあるので、目で数えると必ずずれる。
   `N` を `runs_min`、`M` を `min` に書く。`runs_min` が無いと、1 つのテストメソッドに
   `N.times { assert true }` と書いただけの写しが通ってしまう。
3. **`sealed_test` が指す封緘物の `open` は `judge_only`。** `on_start` の封緘物を判定に使うと
   判定失敗として報告される。

## 3. 封緘の手順

平文は**教材リポの外の作業場**で作る（根幹 §7）。`bin/seal` は作業場のディレクトリを丸ごと
暗号化して `tasks/<課題番号>/sealed/` へ置く。平文を教材リポへコピーすることはない
（教材リポ配下を平文ディレクトリに渡すと止まる）。

```sh
# 1. 鍵を用意する（初回のみ）。鍵は両リポの外に置く。
mkdir -p ~/.config/ruby-learning
umask 077 && head -c 64 /dev/urandom | base64 > ~/.config/ruby-learning/seal.key

# 2. 作業場で平文を作る
mkdir -p ~/work/seal-plain/rb1-20-zero-impl
$EDITOR ~/work/seal-plain/rb1-20-zero-impl/spec-01.md
$EDITOR ~/work/seal-plain/rb1-20-zero-impl/spec_01_test.rb

# 3. 封緘する
bin/seal ~/work/seal-plain/rb1-20-zero-impl rb1-20-zero-impl

# 4. check.yml の sealed: に開封タイミングを書く（on_start / judge_only / on_complete）

# 5. 作業場を消す
rm -rf ~/work/seal-plain/rb1-20-zero-impl
```

方式は openssl の対称鍵（AES-256-CBC、pbkdf2、salt あり）。鍵ファイルの既定は
`~/.config/ruby-learning/seal.key` で、`RUBY_LEARNING_SEAL_KEY_FILE` で場所を変えられる。
鍵が無いときは `bin/check` も `bin/seal` も終了コード 2 で止まる（判定失敗の 1 と区別する）。

開封タイミングの割付は設計文書 §5「封緘の範囲」が決めている。まとめると:

| 何を | `open` |
|---|---|
| 仕様本文・要件 | `on_start` |
| 判定用テスト | `judge_only` |
| 参照実装・テスト全文 | `on_complete` |

復号先は教材リポの `unsealed/<課題番号>/`（`.gitignore` 済み）。成果リポには展開しない
——AI 生成物を学習者のコミットに混ぜないため（根幹 §6）。

**封緘物を作り直したとき**は `sealed/*.enc` を消してから `bin/seal` を掛け直す。
`bin/seal` は同名ファイルを上書きするが、名前を変えた場合の古い `.enc` は残る。

## 3.5 README のコマンドの書き方

- コードブロックのコマンドにプロンプト記号（`$ `）を付けない。学習者がそのまま貼って実行できる形にする（根幹 §4.2）。
- 実行結果を見せるときは、コマンドのブロックと分けて別のブロックか地の文に書く。同じブロックにコマンドと出力を混ぜない。
- 長いコマンドは `\` で折り返してよい（継続行はそのまま貼れる）。

## 4. RuboCop の掛け方

cop の構成の正本は根幹 §3.1 で、それを写したのが `.rubocop.yml`。ここに列挙された cop だけが動く
（`DisabledByDefault: true` で全 cop を切ってから、Layout 部門全体と 5 つの cop を戻している）。

```sh
bundle exec rubocop --config .rubocop.yml tasks/ bin/     # 教材リポの全コード
bundle exec rubocop --config .rubocop.yml tasks/<課題番号>/original/<name>.rb tasks/<課題番号>/copy_test/<name>_test.rb
```

**原本ファイルと照合テストの両方がこの設定で指摘ゼロであること**を課題ごとに確かめる（根幹 §3.1・§7 の検品①）。
公式ドキュメントの原文は `{|x| x**2 }` のように既定の cop に当たる形で書かれていることがあるので、
原本側を整形する。整形は根幹 §7 の「課題化の編集」に含まれる。

書式検査が落とすのは既習言語の手癖（セミコロン・`camelCase`・4 スペース・単一引用符・
frozen 宣言なし）で、メソッド呼び出しの括弧は検査しない。実機での確認結果は
`docs/selfcheck-log.md` の経路 8。

## 5. 課題化の編集の範囲（根幹 §7）

手本は実在の一次資料から取る。AI が生成したコードを手本にしない。**認められる編集**は次のとおり。

- 断片の連結・スクリプト化
- 結果を表示する式の付加（`p` / `puts`。原典の `# =>` 注記を表示に置き替える。値でない結果〈例外・終了〉は `begin … rescue X => e; p e.class end` の形で表示する）
- 散文どおりの API 呼び出しの補完
- minitest の骨格（`require`・テストクラス・`def test_…`）の付加（課題 3 の手本のみ。他課題では照合テスト側に置く）
- `.rubocop.yml` に合わせた空白と引用符の整形
- セミコロンで 1 行に詰めた複文の改行展開
- minitest と衝突する識別子の改名（改名は `commentary.md` に明記する）

照合単位は個々の式とイディオム。**原文の構造を書き換える編集は認めない**（`def` を lambda に
置換する等）——必要なら別の節を底本に選ぶ。一次情報の URL は Ruby 4.0 に固定する
（`https://docs.ruby-lang.org/en/4.0/` 配下。`master` は開発版 4.1 の内容なので使わない）。

## 6. 作ったあとに走らせること

課題を 1 つ作り終えたら、模擬の成果リポを作って全経路を通す。`docs/selfcheck-log.md` が手順の見本。

```sh
export RUBY_LEARNING_SEAL_KEY_FILE=<鍵>
bin/check --start <課題番号> <模擬成果リポ>   # 開封先のパスが出るか
bin/check          <課題番号> <模擬成果リポ>   # 何も置かない状態で全 judge が「未着手」か
# 正解を置いて合格（終了コード 0）、壊した検体を置いて不合格（終了コード 1）を両方見る
```

検体には設計文書 §5 が指定するものを必ず含める——「`# frozen_string_literal: true` 1 行だけの写し」
「手本の 1 節を削った写し」「表示行の値を 1 箇所打ち間違えた写し」「セミコロン・4 スペース・`camelCase`
を混ぜた写し」「公式の原文どおりの空白（`{|x| x**2 }`）で書いた写し」「雛形をそのままコピーした
`why.md`」。課題 3 は「`require` 1 行だけの写し」「テストメソッドを 1 つ削った写し」。合格することだけでなく、
**壊した検体が落ちること**まで見る（根幹 §7 の検品②が言う検出力）。

## 7. 基盤担当が置いた仮定

根幹文書に規定が無いため基盤担当が決めた事柄。後で根幹へ書き写すか判定するために列挙する。

1. **`check.yml` のスキーマ全体**（キー名・judge 種別名・パスの基準）。根幹 §6 は「課題ごとの値を
   `check.yml` に持つ」とだけ書いている。定義は `docs/check-yml.md`。
2. **judge の種別を 8 つに固定した**（`copy_run` / `assertion_count` / `rubocop` / `why_diff` /
   `exercise_test` / `sealed_test` / `predict` / `template_test`）。設計文書 §5 の judge 表の各項を
   1 種別に対応させた結果で、根幹はこの分割を規定していない。
3. **確認課題テストの正本を教材リポ側に置き、学習者が自分で足した assert は判定対象にしない。**
   根幹 §3.1 は「自分で足す assert の内容」を学習者に残す判断としているが、それを判定へ含めるか
   どうかは書いていない。含めない側に倒した（含めると学習者が assert を足すほど落ちやすくなる）。
4. **「未着手」の判定基準をファイル・ディレクトリの存在に置いた。** どのファイルが揃えば着手済みと
   みなすかは `check.yml` の `requires` / `load_paths` / `submission` で課題ごとに書く。
5. **全 judge が未着手のときの終了コードを 0 にした。** 根幹 §6 は「未着手は失敗ではない」とだけ
   書いており、何も書いていない学習者が 0 を受け取ることの是非は規定が無い。表示では
   「まだ判定できる項目がありません」と区別している。
6. **`.check/<課題番号>.yml` のキー構成**（`task` / `started_at` / `unsealed` / `last_checked_at` /
   `status` / `passed_at`）。`status` の語彙は `in_progress` / `failed` / `passed` の 3 値。
   学習者が書く `progress.md` の状態語彙（未着手 / 進行中 / 完了 / 未消化、設計文書 §5）とは別物で、
   対応づけは決めていない。打ち切りの発動条件（根幹 §8）がこの記録を参照する。
7. **`--report` の書き出し先を `<成果リポ>/.check/<課題番号>-report.md` にし、状態記録を
   更新しないことにした。** 根幹 §5 は「判定ログのみを独立 AI 検品へ回す」としか書いていない。
   検品へ渡すのはこのファイル 1 本。標準出力にはパスだけを出す。
8. **`on_complete` の封緘物の開封契機を「全 judge 合格の `bin/check` 実行」にした。** 根幹は
   「完了後」としか書いていない。合格した回にその場で開く。
9. **課題ディレクトリの構成とファイル名**（§1）。根幹 §6 は成果リポ側の配置だけを規定している。
10. **出力予測の対象コードを教材リポの `predict/NN.rb` に置いた。** 設計文書 §5 は「`predict/NN.txt`
    と対象コードの実行時標準出力の完全一致」と書くが、対象コードの置き場を決めていない。比較は
    末尾の改行だけ無視する完全一致。
11. **判定の並び順は `check.yml` の `judges` の記述順**。根幹に順序の規定は無い。
12. **設計文書 §5 が課題 1 の judge に挙げる「`.check/` の存在」を judge にしなかった。**
    `.check/<課題番号>.yml` は `bin/check` 自身が毎回書くので、judge にすると必ず通る。
13. **教材リポの Gemfile を minitest 6.0.0・rubocop 1.91.0 に固定した。** 根幹 §6 は道具の名前だけを
    規定している。minitest を入れたのは、原本の実行・照合テストの実行・課題 3 のアサーション数の実測に要るため。
    rubocop 1.91.0 は `TargetRubyVersion: 4.0` を受け付けることを実機で確認した。
14. **`bin/seal` はディレクトリ単位で全ファイルを暗号化する**（ファイル単位の指定を持たない）。
15. **検体課題の番号を `rb1-00-selfcheck` にした。** 設計文書 §3 の課題一覧は 01 から始まるので
    00 が空いている。これは学習者向け課題ではなく、課題数にも数えない。
16. **基盤の作業では鍵を `~/.config/ruby-learning/seal.key` に作らず**、`RUBY_LEARNING_SEAL_KEY_FILE`
    で `~/lab/ruby-learning/.worktmp/keystore/seal.key` を指した。既定の場所に鍵を置くのは、実際に
    封緘物を作る担当者の作業（§3 の手順 1）。
