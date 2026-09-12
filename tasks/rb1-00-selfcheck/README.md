# rb1-00-selfcheck — 基盤の検体（学習者向け課題ではない）

この課題ディレクトリは `bin/check` の全 judge を一度に動かすための**検体**である。
学習の課題一覧（設計文書「Ruby 基礎」§3）には含まれない。学習者はこれを解かない。

教材の課題を作る人は、この課題を「judge ごとにファイルがどこに要るか」の実例として読む。
書き方の手引きは `docs/materials-guide.md`、`check.yml` のスキーマは `docs/check-yml.md`。

## 含まれるもの

| パス | 対応する judge |
|---|---|
| `original/greeting_test.rb` | `copy_run` / `assertion_count` / `rubocop` |
| `why.md` | `why_diff`（雛形。学習者は成果リポ側に自分の `why.md` を書く） |
| `commentary.md` | judge なし（`why.md` を書いた後に開く） |
| `exercise/lib/shout.rb`・`exercise/test/shout_test.rb` | `exercise_test`（テストの正本は教材リポ側） |
| `sealed/*.enc` | `sealed_test`（`judge_only`）、`--start` の開封（`on_start`）、完了後開封（`on_complete`） |
| `predict/01.rb` | `predict`（学習者は成果リポ側に `predict/01.txt` を書く） |
| `template/lib/fizzbuzz.rb`・`template/test/fizzbuzz_test.rb` | `template_test`（雛形を成果リポへ置いて動かす） |

## 動かし方

```sh
export RUBY_LEARNING_SEAL_KEY_FILE=<鍵ファイル>
bin/check --start rb1-00-selfcheck <成果リポのパス>
bin/check         rb1-00-selfcheck <成果リポのパス>
bin/check --report rb1-00-selfcheck <成果リポのパス>
```

実機で走らせた記録は `docs/selfcheck-log.md`。
