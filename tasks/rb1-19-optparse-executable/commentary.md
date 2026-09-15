# 模範解説 — rb1-19-optparse-executable

`why.md` の §1〜§3 を書き終えてから開く。読み終えたら §4「突き合わせで変わったこと」を書く。

この解説は **前の節で分かったことの上に次の節が乗る順序**で並べてある。
§2〜§4 は「ファイルを 1 つのコマンドにするために要るもの」を 1 つずつ足していく順序で、
§5 でそれを分けます。飛ばさずに読む。

## 1. この課題は何を作れるようにするのか

基礎の最後の書き写し課題です。**ここまでの全部を「人が使える 1 つのコマンド」にまとめます。**

課題 5 で標準出力・標準エラー・終了コードという「外への口」を見ました。課題 17 でファイルを
扱いました。**残っているのは「起動される側になること」**です。

4 つ足すものがあります。

| 段 | 足すもの | 無いとどうなるか |
|---|---|---|
| §2 | shebang | シェルが自分で解釈しようとして失敗する |
| §3 | 実行権限 | `permission denied` |
| §4 | オプション解析 | 引数を自分で `ARGV` から拾うことになる |
| §5 | `exe/` と `lib/` の分離 | 中身をテストから直接呼べない |

## 2. shebang — 誰に向けて書いているのか

```ruby
#!/usr/bin/env ruby
```

**この 1 行を読むのは OS（カーネル）であって Ruby ではありません。**

> Comments are ignored by the Ruby interpreter.
> — https://docs.ruby-lang.org/en/4.0/syntax/comments_rdoc.html

Ruby から見れば `#` で始まるただのコメントです（課題 6 で見たマジックコメントは例外）。
**`ruby foo.rb` と打つ経路では shebang は一切使われません。** 意味を持つのは、OS がファイルを
**直接**実行しようとしたときだけ。

`/usr/bin/env ruby` と書くのは、ruby の置き場所を決め打ちせず `PATH` から探させるためです。
mise で入れた Ruby もこれで選ばれます。

（例外が 1 つ。Ruby も shebang 行のうち ruby のオプション（`-w` など）だけは読み取ります。
`#!/usr/bin/env ruby -w` で起動すると `$VERBOSE` が true になる。）

**ここまでで分かったこと**: 何で動かすか。次は、動かしてよいか。

## 3. 実行権限 — shebang とは別の条件

```ruby
FileUtils.chmod("+x", exe)
```

> chmod: Changes permissions on the entries at the paths given in `list`.
> — https://docs.ruby-lang.org/en/4.0/FileUtils.html

**shebang があっても、実行権限が無ければ起動できません。** 実測: shebang 付きのファイルを
`chmod -x` のまま直接実行すると `permission denied`、`chmod +x` した後は同じファイルが動く。

逆に、実行権限があっても shebang が無ければ、シェルが自分で解釈しようとして失敗します。

**2 つで 1 組**です。手本が付ける前に `refute File.executable?(exe)`、付けた後に
`assert File.executable?(exe)` を置いているのは、この 1 手で状態が変わることを見せるため。

**ここまでで分かったこと**: 起動できる条件。次は、起動された後に引数を読む。

## 4. オプション解析 — `OptionParser`

`ARGV` から自分で拾うこともできますが（課題 5 で触れた）、`--name` と `-n` の両方を受ける、
引数の有無を区別する、ヘルプを作る——を手で書くと大きくなります。標準ライブラリに入っています。

**`on` の書き方で、引数を取るかどうかが決まります。** 手本の 3 行が 3 通りです。

```ruby
parser.on("-x", "--xxx", "Short and long, no argument")        # 引数なし（真偽）
parser.on("-yYYY", "--yyy", "Short and long, required argument")   # 必須の引数
parser.on("-z [ZZZ]", "--zzz", "Short and long, optional argument") # 省略可能な引数
```

**ダミーの語（`YYY`）を後ろに付けると「引数が要る」**という意味になり、付けなければ
「引数を取らない」になる。角括弧なら省略可能。

そして `parse!` です。**名前の `!` が働きを表しています。**

> Method `parse!` ... **removes from `ARGV`** the options and arguments it finds, leaving
> other non-option arguments for the program to handle on its own.
> The method returns the possibly-reduced `ARGV` array.
> — https://docs.ruby-lang.org/en/4.0/optparse/tutorial_rdoc.html

実測:

```ruby
argv = ["-x", "--yyy", "v", "rest1", "rest2"]
rest = parser.parse!(argv, into: options)
rest              #=> ["rest1", "rest2"]
argv              #=> ["rest1", "rest2"]   ← 渡した配列自身が変わっている
rest.equal?(argv) #=> true                 ← 同じオブジェクト
```

**課題 6・8 で見た「`!` は受け手を書き換える」命名規約の実例**です。取り除かない `parse` も
あります。

`into:` は書く量を減らします。

> In parsing options, you can add keyword option `into` with a hash-like argument;
> each parsed option will be added as a name/value pair.

実測: `options` が `{xxx: true, yyy: "v"}` になる（キーは Symbol）。渡さない場合は `on` に
ブロックを書いて 1 つずつ受け取ることになる。**あらかじめ値を入れておけば既定値になります。**

ヘルプは `on` に渡した説明文から自動で組み立てられます。

> The program name is included in the default banner: `Usage: #{program_name} [options]`;
> you can change the program name.

`banner=` が 1 行目。知らないオプションを渡すと `OptionParser::InvalidOption` になります
（課題 11 の例外がここで効く）。

**ここまでで分かったこと**: コマンドとして成立する条件。最後に、中身の置き方。

## 5. `exe/` と `lib/` を分ける

**`exe/` に置くのは「コマンド行を読んで、本体を呼んで、出力する」だけ。** 数える・整える・
判断するといった中身は `lib/` に置きます。

理由は**テストできるかどうか**です。`lib/` に置けば `require` してテストから直接呼べる。
手本の最初の 3 つのテストが `OptionParser` をプロセス起動なしに試せているのと同じ理屈です。

`exe/` 側から隣を読むのは `require_relative`。

```ruby
require_relative "../lib/greeter"
```

`require_relative` は「このファイルの場所から見た相対パス」で探します（`require` は
`$LOAD_PATH` を探す）。

そして最後の 1 行。

```ruby
if __FILE__ == $0
  # コマンドとして呼ばれたときだけ動かす
end
```

`__FILE__` は「いま実行しているこのファイルの名前」、`$0` は「ruby が起動するときに渡された
プログラムの名前」。実測:

```
ruby main.rb が require_relative "lib" したとき
  lib 側:  __FILE__=lib.rb   $0=main.rb   → 一致しない
  main 側: __FILE__=main.rb  $0=main.rb   → 一致する
```

**「ライブラリとして読み込まれたときは実行しない」を書くための定石**です。

**ここまでで分かったこと**: この課題の全部。shebang（§2）→ 実行権限（§3）→ オプション解析（§4）
→ 中身の分離（§5）。

この 4 つが、**gem として配布できる形の入口**です（`00-policy.md` §3 が Ruby 軸の到達地点に
置いている「CLI ツールを設計から公開まで作れる」）。gem の標準構成そのものは Ruby 中級で扱います。

なお手本が `IO.popen([exe], &:read)` で別プロセスを起動しているのは、**実際にコマンドとして
動くこと**を確かめるためです。配列で渡すとシェルを経由しないので、引数に空白が入っても壊れません。

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
