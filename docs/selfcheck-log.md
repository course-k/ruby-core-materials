# 実機実行ログ（bin/check の検体 rb1-00-selfcheck）

最終更新: 2026-09-12

`tasks/rb1-00-selfcheck/` は `bin/check` の judge 8 種すべてを 1 課題で動かす**検体**であり、
学習者向けの課題ではない（`tasks/rb1-00-selfcheck/README.md`）。本書はその実機実行の記録。

## 実行環境

- Ruby 4.0.6（`ruby 4.0.6 (2026-07-14 revision 03b6d3f889) +PRISM [arm64-darwin23]`、mise で導入）
- 教材リポ: `ruby-core-materials`（minitest 6.0.0 / rubocop 1.91.0、`vendor/bundle`）
- 成果リポの模擬: `~/lab/ruby-learning/.worktmp/ruby-core-sample`（minitest 6.0.0 / irb 1.16.0 / debug 1.11.1、`vendor/bundle`）
- 封緘の鍵: `~/lab/ruby-learning/.worktmp/keystore/seal.key`（`RUBY_LEARNING_SEAL_KEY_FILE` で指定。
  既定の `~/.config/ruby-learning/seal.key` は基盤作業では作らなかった）

## 確認した経路

| 経路 | 期待 | 結果 |
|---|---|---|
| 1 鍵不在（`--start`） | 終了コード 2、着手を記録しない | 合 |
| 2 課題番号の誤り | 終了コード 2 | 合 |
| 3 成果リポ不在 | 終了コード 2 | 合 |
| 4 未着手 | 全 judge が「未着手」表示、終了コード 0 | 合 |
| 5 着手（`--start`） | `on_start` の封緘物を `unsealed/<課題番号>/` へ復号、パス表示、判定なし、終了コード 0 | 合 |
| 6 合格 | judge 8 種すべて合格、`on_complete` の封緘物を開封、終了コード 0 | 合 |
| 7 不合格（実装・写し・`why.md` の検体） | 該当 judge のみ失敗、終了コード 1 | 合 |
| 8 書式の逸脱 | RuboCop judge が手癖（セミコロン・4 スペース・`camelCase`・単一引用符・frozen 宣言なし）を落とす | 合 |
| 9 `--report` | 判定ログのみを `<成果リポ>/.check/<課題番号>-report.md` へ書き出す | 合 |

判定機構の検出力について確認した点（根幹 §7 の検品②が要求する検体のうち、基盤で確かめられるもの）:

- 「`require` 1 行だけの写し」はテスト実行だけでは落ちない（0 failures）。アサーション数 judge が
  `0 < 7` で落とす。根幹 §3.1 がアサーション数の条件を置いた理由がそのまま再現される。
- 「テストメソッドを 1 つ削った写し」も同じくアサーション数で落ちる（経路 8 は 1 メソッドのみの写しで
  `1 < 7`）。
- 封緘テストの失敗表示は「テスト名＋失敗メッセージ 1 行目」に限られ、テスト本文は出ない（経路 7）。
- 判定用テストの復号先は一時ディレクトリで、実行後に残らない（`find /var/folders -name 'ruby-learning-*'` が空）。

## 生の実行出力

### 経路 1: 鍵不在（--start）
```
封緘の鍵が見つかりません: /Users/kosukeyoshida/lab/ruby-learning/.worktmp/keystore/seal.key.missing
鍵は両リポの外に置きます。環境変数 RUBY_LEARNING_SEAL_KEY_FILE で場所を変えられます。
exit=2
```

### 経路 2: 課題番号の誤り
```
課題番号が違います（/Users/kosukeyoshida/lab/ruby-learning/ruby-core-materials/tasks/rb1-99-nope/check.yml がありません）: rb1-99-nope
exit=2
```

### 経路 3: 成果リポ不在
```
成果リポが見つかりません: /nonexistent/repo
exit=2
```

### 経路 4: 未着手
```
課題 rb1-00-selfcheck（基盤の検体（学習者向け課題ではない））
成果リポ: /Users/kosukeyoshida/lab/ruby-learning/.worktmp/ruby-core-sample
着手: 未着手（bin/check --start で着手します）

[未着手] 写しの実行
    写しがまだありません: rb1-00-selfcheck/greeting_test.rb
[未着手] 写しのアサーション数
    写しがまだありません: rb1-00-selfcheck/greeting_test.rb
[未着手] 写しの書式（RuboCop）
    検査対象がまだありません: rb1-00-selfcheck/greeting_test.rb
[未着手] why.md が雛形と差分あり
    why.md がまだありません: rb1-00-selfcheck/why.md
[未着手] 確認課題テスト
    確認課題がまだありません: rb1-00-selfcheck/exercise/lib
[未着手] 出力予測 01
    予測がまだありません: rb1-00-selfcheck/predict/01.txt
[未着手] 雛形テストの実行
    雛形テストがまだありません: rb1-00-selfcheck/template/test/fizzbuzz_test.rb
[未着手] 封緘テスト
    実装がまだありません: rb1-00-selfcheck/lib/normalizer.rb

判定: まだ判定できる項目がありません（未着手 8 件）
exit=0
```

### 経路 5: 着手（--start、着手後開封の封緘物を復号）
```
着手を記録しました: .check/rb1-00-selfcheck.yml（rb1-00-selfcheck）
開封しました: /Users/kosukeyoshida/lab/ruby-learning/ruby-core-materials/unsealed/rb1-00-selfcheck/requirements.md
作業場所: /Users/kosukeyoshida/lab/ruby-learning/.worktmp/ruby-core-sample/rb1-00-selfcheck
exit=0
```

### 経路 6: 合格（judge 8 種すべて）
```
課題 rb1-00-selfcheck（基盤の検体（学習者向け課題ではない））
成果リポ: /Users/kosukeyoshida/lab/ruby-learning/.worktmp/ruby-core-sample
着手: 2026-09-12T07:35:22+09:00

[合格] 写しの実行
    4 runs, 7 assertions
[合格] 写しのアサーション数
    7 assertions（原本 7 以上）
[合格] 写しの書式（RuboCop）
    指摘ゼロ
[合格] why.md が雛形と差分あり
    雛形との差分あり
[合格] 確認課題テスト
    2 runs, 2 assertions
[合格] 出力予測 01
    実行出力と一致
[合格] 雛形テストの実行
    4 runs, 4 assertions
[合格] 封緘テスト
    3 runs, 3 assertions

判定: 合格
完了後開封: /Users/kosukeyoshida/lab/ruby-learning/ruby-core-materials/unsealed/rb1-00-selfcheck/reference.rb
exit=0
```

### 経路 7: 不合格（require 1 行だけの写し・雛形のままの why.md・壊した実装・外した予測）
```
課題 rb1-00-selfcheck（基盤の検体（学習者向け課題ではない））
成果リポ: /Users/kosukeyoshida/lab/ruby-learning/.worktmp/ruby-core-sample
着手: 2026-09-12T07:35:22+09:00

[合格] 写しの実行
    0 runs, 0 assertions
[失敗] 写しのアサーション数
    アサーション数が原本に足りません: 0 < 7
[合格] 写しの書式（RuboCop）
    指摘ゼロ
[失敗] why.md が雛形と差分あり
    why.md が雛形のままです（自分の言葉で書き足してください）
[失敗] 確認課題テスト
    ShoutTest#test_strips_surrounding_spaces: Failure: Expected: "GRACE!"
[失敗] 出力予測 01
    予測と実行出力が一致しません（最初に食い違う行: 2 行目）
[合格] 雛形テストの実行
    4 runs, 4 assertions
[失敗] 封緘テスト
    NormalizerContractTest#test_downcases_letters: Failure: Expected: "grace hopper"
    NormalizerContractTest#test_squeezes_inner_whitespace: Failure: Expected: "ada lovelace"

判定: 失敗 5 件
exit=1
```

### 経路 8: 書式の逸脱（セミコロン・4 スペース・camelCase・単一引用符・frozen 宣言なし）
```
課題 rb1-00-selfcheck（基盤の検体（学習者向け課題ではない））
成果リポ: /Users/kosukeyoshida/lab/ruby-learning/.worktmp/ruby-core-sample
着手: 2026-09-12T07:35:22+09:00

[合格] 写しの実行
    1 runs, 1 assertions
[失敗] 写しのアサーション数
    アサーション数が原本に足りません: 1 < 7
[失敗] 写しの書式（RuboCop）
    rb1-00-selfcheck/greeting_test.rb:1:1: C: [Correctable] Style/FrozenStringLiteralComment: Missing frozen string literal comment.
    rb1-00-selfcheck/greeting_test.rb:1:9: C: [Correctable] Style/StringLiterals: Prefer double-quoted strings unless you need single quotes to avoid extra backslashes for escaping.
    rb1-00-selfcheck/greeting_test.rb:4:1: C: [Correctable] Layout/IndentationWidth: Use 2 (not 4) spaces for indentation.
    rb1-00-selfcheck/greeting_test.rb:5:5: C: [Correctable] Layout/IndentationWidth: Use 2 (not 4) spaces for indentation.
    rb1-00-selfcheck/greeting_test.rb:5:9: C: Naming/VariableName: Use snake_case for variable names.
    rb1-00-selfcheck/greeting_test.rb:5:23: C: [Correctable] Style/Semicolon: Do not use semicolons to terminate expressions.
    rb1-00-selfcheck/greeting_test.rb:5:63: C: Naming/VariableName: Use snake_case for variable names.
[失敗] why.md が雛形と差分あり
    why.md が雛形のままです（自分の言葉で書き足してください）
[失敗] 確認課題テスト
    ShoutTest#test_strips_surrounding_spaces: Failure: Expected: "GRACE!"
[失敗] 出力予測 01
    予測と実行出力が一致しません（最初に食い違う行: 2 行目）
[合格] 雛形テストの実行
    4 runs, 4 assertions
[失敗] 封緘テスト
    NormalizerContractTest#test_squeezes_inner_whitespace: Failure: Expected: "ada lovelace"
    NormalizerContractTest#test_downcases_letters: Failure: Expected: "grace hopper"

判定: 失敗 6 件
exit=1
```

### 経路 9: --report（判定ログのみを書き出す）
```
/Users/kosukeyoshida/lab/ruby-learning/.worktmp/ruby-core-sample/.check/rb1-00-selfcheck-report.md
exit=1
```

