# 模範解説 — rb1-19-optparse-executable

`why.md` を自分の言葉で書き終えてから読む。

## 読み解き

- `LIB_SOURCE` / `EXE_SOURCE` — ヒアドキュメント（`<<~RUBY ... RUBY`）で、
  テストの中から一時ディレクトリへ書き出す**別のプログラムの中身**を持っている。
  `<<~` は行頭の余分なインデントを落とす形。`\#{name}` のバックスラッシュは
  「ここは書き出す側では展開せず、`#{name}` という文字のまま書き出す」という指示。
- `#!/usr/bin/env ruby` — shebang。ファイルの 1 行目に書くと、OS がそのファイルを起動するときに
  「このコマンドに渡して実行しろ」と読む。インタプリタのパスの部分を使うのは OS の側だが、
  Ruby も shebang 行のうち ruby のオプション（`-w` など）だけは読み取る
  （`#!/usr/bin/env ruby -w` で起動すると `$VERBOSE` が true になる）。
  `/usr/bin/env ruby` と書くのは、ruby の置き場所を決め打ちせず PATH から探させるため。
  mise で入れた Ruby もこれで選ばれる。
- `FileUtils.chmod("+x", exe)` — 実行権限。手本は付ける前に `refute File.executable?(exe)`、
  付けた後に `assert File.executable?(exe)` を置いて、この 1 手で状態が変わることを見ている。
  shebang があっても実行権限が無ければ起動できず、実行権限があっても shebang が無ければ
  シェルが自分で解釈しようとして失敗する。**2 つで 1 組**。
- `require_relative "../lib/greeter"` — `exe/` から見て隣の `lib/` を読む。
  `require_relative` は「このファイルの場所から見た相対パス」で探す（`require` は `$LOAD_PATH` を探す）。
- `exe/` と `lib/` の分け方 — `exe/` に置くのは「コマンド行を読んで、本体を呼んで、出力する」だけ。
  数える・整える・判断するといった中身は `lib/` に置く。こうすると本体を
  `require` してテストから直接呼べる（手本の最初の 3 つのテストが `OptionParser` を
  プロセス起動なしに試せているのと同じ理屈）。これは Ruby の gem の標準構成でもある。
- `OptionParser.new do |parser| ... end.parse!(into: options)` — `on` でオプションを 1 つずつ定義する。
  `"-n NAME", "--name NAME"` のように**ダミーの語**を後ろに付けると「引数が要る」という意味になり、
  `"-l", "--loud"` のように付けなければ「引数を取らない（真偽）」になる。
  `into: options` を渡すと、解析結果が Hash へ書き込まれる。あらかじめ値を入れておけば既定値になる
  （手本の 2 つ目のテストの `{ yyy: "AAA", zzz: "BBB" }`）。
- `parse!` の `!` — 渡した配列（既定では `ARGV`）から、解釈したオプションを**取り除く**という意味。
  戻り値は残りの引数。手本の 1 つ目のテストで `["bam"]` が返るのがそれ。
  取り除かない `parse` もある。
- `parser.help` — `on` に渡した説明文から、ヘルプ本文が自動で組み立てられる。
  `banner=` は 1 行目の書式。知らないオプションを渡すと `OptionParser::InvalidOption` になる。
- `if __FILE__ == $0` — `__FILE__` は「いま実行しているこのファイルの名前」、`$0` は
  「ruby が起動するときに渡されたプログラムの名前」。直接起動したときは一致し、
  他のファイルから `require` されたときは一致しない。つまり
  「このファイルがコマンドとして呼ばれたときだけ動かす」ための条件。
  公式チュートリアルはこれを「the magic variable that contains the name of the current file」と説明する。
- `IO.popen([exe], &:read)` — 別プロセスとして起動し、その標準出力を読む。
  配列で渡すとシェルを経由しないので、引数に空白が入っても壊れない。

## JS ではこうだが Ruby では

### shebang は同じ、置き場所の宣言が違う

Node.js でも実行ファイルの 1 行目は `#!/usr/bin/env node` で、仕組みは同じ。
違うのは**どこに「これはコマンドだ」と書くか**で、npm では `package.json` の `bin` フィールドに
`{ "bin": { "my-program": "path/to/program" } }` と書く。npm の公式ドキュメントは
「Please make sure that your file(s) referenced in bin starts with `#!/usr/bin/env node`;
otherwise, the scripts are started without the node executable!」と注意している——
つまり `bin` に書いただけでは足りず、shebang も要るのは Ruby と同じ。
Ruby 側は `gemspec` の `executables` が `bin` にあたり、慣例として `exe/` に置く。
実行権限については、npm は install 時に付け直すが、Ruby では自分で `chmod +x` して
その状態を git に記録する（git はファイルの実行ビットを記録する）。

### オプション解析は標準に入っているかどうかが違う

JS / Node.js には長く標準のオプション解析が無く、`commander` や `yargs` を入れるのが定石だった
（近年 `util.parseArgs` が入ったが、ヘルプ生成は持たない）。
`OptionParser` は Ruby に同梱で、しかも **`on` に書いた説明文からヘルプを自動で組み立てる**。
commander の `.option("-n, --name <name>", "Who to greet")` と `.parse()` は形がよく似ていて、
「定義と処理を同じ場所に書く」という設計思想も同じ。差は、commander が結果をオブジェクトに集めるのが
既定なのに対し、`OptionParser` は既定ではブロックを呼ぶだけで、集めたいときに `into:` を明示する点。

### `if __FILE__ == $0` に相当するもの

CommonJS の `if (require.main === module)` が同じ役割。ES modules では
`import.meta.main`（Node.js 24 以降）を使う。どちらも
「ライブラリとして読まれたときは走らせない」ための条件で、考え方は同じ。

## 底本の URL

- https://docs.ruby-lang.org/en/4.0/optparse/tutorial_rdoc.html
- https://docs.ruby-lang.org/en/4.0/OptionParser.html
- https://www.ruby-lang.org/en/documentation/quickstart/4/
- https://docs.npmjs.com/cli/v11/configuring-npm/package-json （`bin` フィールド）
- https://nodejs.org/docs/latest-v24.x/api/fs.html （実行権限とファイルの扱い）
