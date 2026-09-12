# rb1-21-mini-integration-2 — ミニ統合② 重複を除く小さな CLI

## この課題の位置と到達点

- 位置: Ruby 軸 / 基礎 / 課題 21（基礎は全 21 課題。この課題が基礎の最後）。
  前は `rb1-20-zero-impl`。次は基礎の出口の判定課題（この文書の末尾）。
- 到達点: この課題を終えると、次ができるようになる。
  - 値オブジェクト・ファイルの読み込み・重複の除去・`OptionParser` を束ねて、
    1 本のコマンドにできる。
  - 実行の入口（`exe/`）と処理の本体（`lib/`）を分けて設計できる。
  - 仕様から**自分のテストを先に書き**、実装し、判定に通せる。
- 課題 12 と同じく、何をどう書くかは指示されない。要件だけが渡される。
  課題 12 との違いは、①ファイルを 2 つ以上に分けること、
  ②自分でもテストを書くことが完了条件に入っていること。

## 初めて使う道具

なし。この課題で新しく入れる道具・新しく覚えるコマンドは無い
（封緘物の開封は課題 12、`chmod +x` は課題 19 で説明した）。

## 前提

- 課題 1 で作った成果リポに `Gemfile` / `.ruby-version` があり、`bundle install` が済んでいること。
- 教材リポ（このファイルがあるリポジトリ）で `bundle install` が済んでいること。
- 課題 20 までをすべて終えていること。
- 封緘の鍵が `~/.config/ruby-learning/seal.key` にあること（置き方は課題 1 の README の手順 3）。
  無いと `bin/check` は終了コード 2 で止まる。

以降、`<成果リポ>` は自分の成果リポジトリのパス、`<教材リポ>` はこのファイルがあるリポジトリのパスを指す。

## 手順

1. 着手して要件を開く。

   ```sh
   cd <教材リポ>
   bin/check --start rb1-21-mini-integration-2 <成果リポ>
   ```

   `<教材リポ>/unsealed/rb1-21-mini-integration-2/requirements.md` が開かれる。
   **判定条件の正本はこの 1 ファイル**で、README は手順だけを持つ。

2. 雛形を置く。

   ```sh
   cd <成果リポ>
   mkdir -p rb1-21-mini-integration-2/lib rb1-21-mini-integration-2/exe rb1-21-mini-integration-2/test
   cp <教材リポ>/tasks/rb1-21-mini-integration-2/template/lib/records.rb rb1-21-mini-integration-2/lib/records.rb
   cp <教材リポ>/tasks/rb1-21-mini-integration-2/template/exe/dedup      rb1-21-mini-integration-2/exe/dedup
   chmod +x rb1-21-mini-integration-2/exe/dedup
   ```

   どちらも中身は 1 行だけ（`# frozen_string_literal: true`）。
   `exe/dedup` の 1 行目に shebang を足すのは自分の仕事（要件に書いてある）。

3. **自分のテストを先に書く。** 要件の「機能要件 — ライブラリ側」を読み、
   `<成果リポ>/rb1-21-mini-integration-2/test/records_test.rb` に minitest のテストを書く。
   この時点ではまだ実装が無いので全部落ちる。落ちることを確かめてから 4 へ進む。

   ```sh
   cd <成果リポ>
   bundle exec ruby -Irb1-21-mini-integration-2/lib rb1-21-mini-integration-2/test/records_test.rb
   ```

   押さえるべき観点は要件の「完了条件」の 2 に 4 つ挙げてある。どう書くかは自由。

4. 実装する。`lib/records.rb` を先に通し、そのあと `exe/dedup` を書く。

   手元で動かすときは、**開封した要件の「例」の節にある入力**をそのままファイルに書いて渡す。

   ```sh
   cd <成果リポ>/rb1-21-mini-integration-2
   ./exe/dedup items.txt
   echo $?
   ```

   `items.txt` は自分の確認用なので、中身も名前も置き場所も自由。判定には使われない。

5. 書式を整える。RuboCop はこの課題の判定に含まれない。自分で掛けて直す。

   ```sh
   cd <教材リポ>
   bundle exec rubocop --config .rubocop.yml <成果リポ>/rb1-21-mini-integration-2
   ```

6. 判定する。

   ```sh
   cd <教材リポ>
   bin/check rb1-21-mini-integration-2 <成果リポ>
   ```

7. 判定に通ったら、**自分のテストと判定の結果を突き合わせる**。
   判定テストの中身は読めないが、落ちたテスト名は見えている。
   自分のテストが拾えていなかった条件（自分が書かなかった境界条件）を 8 の記録に書く。

## 完了の判定

次の 2 つが揃ったらこの課題は完了。

- `bin/check rb1-21-mini-integration-2 <成果リポ>` が「合格」で、終了コードが 0 になる
  （`echo $?` で見る）。
- `<成果リポ>/rb1-21-mini-integration-2/test/records_test.rb` に自分のテストがあり、
  要件の「完了条件」の 2 に挙げた 4 つの観点を押さえていて、全部通る。
  これは機械では見ていない（自分で確かめる工程）。

判定条件の正本は開封した `requirements.md` の「完了条件」の節。

## 進捗の記録

`<成果リポ>/progress.md` に、日付と次の 3 つを書き足し、この課題の状態を「完了」にする。

- 先に書いた自分のテストのうち、実装してみて直したくなったもの。
- 判定が落ちたテスト名のうち、自分のテストが拾えていなかった条件。
- `exe/` と `lib/` の境目をどこに引いたか、その理由。

書いたらコミットする。

```sh
cd <成果リポ>
git add .
git commit -m "rb1-21: 重複を除く CLI を実装した"
```

## 次にすること — 基礎の出口の判定課題

これで基礎の 21 課題は終わり。次は**基礎の出口の判定課題**を受ける。教材を見ずに解く課題で、
通ることが中級へ進む条件になる（消化していない課題があっても、通れば先へ進んでよい）。

- 出題は 3 題。未見コードの出力予測または完成問題 1 題、小さな仕様からのゼロ実装 1 題、
  記述 1 題。形式はこの基礎で練習したものと同じ。
- 課題本文はこの教材リポには入っていない。受けると決めた時点で用意される。
- 参照してよいのは公式ドキュメント（各課題の README と模範解説に挙げた URL）だけ。
  教材リポ・自分の過去の解答・AI は参照しない。
- 受けるには、`<成果リポ>/progress.md` に「基礎の出口を受ける」と日付を書いたうえで、
  **独立コンテキストの AI セッションを新たに開き**、`~/lab/ruby-learning/docs/01-core-spec.md` の §5 と
  `~/lab/ruby-learning/docs/10-design-ruby-basic.md` の §1 のパスだけを渡して、
  出口課題の生成を依頼する。渡すのはこの 2 つのパスだけで、
  自分の解答も教材リポの中身も渡さない（渡すと出口の意味が無くなる）。

不合格だったときは、落ちた範囲の課題を復習し、別の問題で作り直された出口課題に挑戦する。
同じ出口で 3 回不合格になったら、進め方そのものを見直す（`progress.md` に「打ち切り判断」を起票する）。
