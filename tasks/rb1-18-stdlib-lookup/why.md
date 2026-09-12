# なぜこう書くか（rb1-18-stdlib-lookup）

模範解説（`commentary.md`）を開く**前**に、自分の言葉で書く。判定は「この雛形と差分があること」だけを見る。
中身の合否は付かない。

## 書き写して気づいたこと

<!-- ここに書く -->

## 次の問いに自分の言葉で答える

- `JSON.parse` が既定で文字列のキーを返すのはなぜだと思うか。`symbolize_names` を使うのはどんなときか。
- `ERB#result(binding)` の `binding` は何を渡しているのか。渡さないとどうなるか。
- `CSV.parse` に `headers: true` を付けると、戻り値の型が変わる。型が変わることの利点と面倒はどこか。
- Logger の「レベル」は何を決めているか。`logger.info?` が偽を返すのはどういう状態か。
- csv と logger を `Gemfile` に書かないと `require` が失敗する。minitest や json との違いは何か。

## 分からなかったこと

<!-- ここに書く -->
