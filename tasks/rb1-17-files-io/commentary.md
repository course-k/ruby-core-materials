# 模範解説 — rb1-17-files-io

`why.md` の §1〜§3 を書き終えてから開く。読み終えたら §4「突き合わせで変わったこと」を書く。

この解説は **前の節で分かったことの上に次の節が乗る順序**で並べてある。
§3（1 行ずつ）は §2（一括）の限界から立ち、§4（Pathname）は §2・§3 で使った
`File` / `Dir` / `FileUtils` の散らばりを見た後でこそ意味が分かる。飛ばさずに読む。

## 1. この手本は何を見せているか

課題 5 で標準出力・標準エラーという「外への口」を見ました。**ファイルはもう 1 つの外**です。

読み書きの粒度で 3 段に分かれます。

| 段 | 粒度 | 定義 |
|---|---|---|
| §2 | **一括** | `write_then_read` / `append` |
| §3 | **1 行ずつ** | `each_line_with_block` / `collected_lines` / `read_lines` |
| §4 | パスそのものを扱う | `song_path` / `write_song` / `entries_of` / `sources_in` |

**同じ結果を出す方法が複数あります。** 使い分けの基準は「どれだけメモリに載せるか」と
「後片付けを誰がするか」の 2 つです。

## 2. 一括で読み書きする

```ruby
File.write(path, TEXT)
File.read(path)
```

> write: Writes the given string to `self`.
> read: Returns a string with all or a subset of bytes from the given file.
> — https://docs.ruby-lang.org/en/4.0/IO.html

**開く・読み書きする・閉じるを 1 回にまとめた呼び出し**です。`File.write` の戻り値は書いた
バイト数。公式ドキュメントのファイル例はすべてこの形で作られています。

既定は上書きですが、`mode:` で変えられます。

> :mode — Stream mode.

```ruby
File.write(path, text, mode: "a")   # 追記
```

実測: `"one\ntwo\n"` のファイルに `mode: "a"` で `"three\n"` を書くと
`"one\ntwo\nthree\n"`。**既定の `"w"` は既存の中身を捨てる**ので、ここが手本で唯一の
破壊的な違いです。

**一括の限界は明らかです。** 大きなファイルを `File.read` すると全部がメモリに載る。
次の節がその答えです。

## 3. 1 行ずつ読む — そして「閉じる」を誰が保証するか

3 つの書き方が出てきます。

```ruby
File.open(path) { |f| f.each_line { |line| ... } }   # each_line_with_block
File.foreach(path) { |line| ... }                    # collected_lines
File.readlines(path)                                 # read_lines
```

> foreach: Reads each line and passes it to the given block.
> readlines: Reads and returns all lines in an array.
> — IO.html

実測では**3 つとも同じ内容**になります（`["one\n", "two\n"]`）。改行は落ちません。空行は
`"\n"` の 1 要素として現れます。

**違うのは途中の持ち方です。** `readlines` は全行をメモリに載せ、`foreach` と `each_line` は
1 行ずつ渡す。**大きなファイルでは `foreach`。**

そして `File.open` のブロックには、もう 1 つの役割があります。

> Same as `::new`, but when given a block will yield the file to the block,
> **and close the file upon exiting the block**.
> — https://docs.ruby-lang.org/en/4.0/File.html

実測で確かめられます。

```ruby
File.open(path) { |f| f }.closed?   #=> true    ← 抜けた時点で閉じている
h = File.open(path); h.closed?      #=> false   ← 自分で close が要る
```

**手本の `each_line_with_block` がブロックから `f` を返しているのは、まさにこれを見せるため**です。

**課題 11 の `ensure` と同じ考え方**——必ず後片付けする、を構文で保証している。Node.js の `fs` には
この保証が無く、自分で閉じるか読み切るかのどちらかです。

**ここまでで分かったこと**: 読み書きの粒度と、閉じる保証。
ここまで `File` と `IO` を使ってきました。次は**パスそのもの**の扱い。

## 4. パスをオブジェクトにする — `Pathname`

§2・§3 では、パスはただの文字列でした。文字列のままだと、操作があちこちのモジュールに
散らばります。

> Pathname represents the name of a file or directory on the filesystem, but not the file itself.
> **The goal of this class is to manipulate file path information in a neater way than
> standard Ruby provides.**
> — https://docs.ruby-lang.org/en/4.0/Pathname.html

公式ドキュメントが並べている比較がそのまま答えです。

```ruby
# 文字列のまま
size  = File.size(pn)
isdir = File.directory?(pn)
dir   = File.dirname(pn)

# Pathname
size  = pn.size
isdir = pn.directory?
dir   = pn.dirname
```

**`File`・`FileTest`・`Dir`・`FileUtils` に散らばっていたものが、1 つのオブジェクトの
メソッドになる。** 手本の `song_path` と `write_song` がその形です。

```ruby
Pathname.new(dir) + "lib/song.rb"   # + で継ぎ足せる
path.parent                          # 1 つ上
path.write("# song\n")              # ファイル操作もそのまま
```

`Pathname` は不変で、破壊的更新のメソッドを持ちません。

ディレクトリを作るところで、もう 1 つ差が出ます。

> （ディレクトリを作るメソッド群）create directories, **also creating ancestor directories as
> needed**.
> — https://docs.ruby-lang.org/en/4.0/FileUtils.html

実測: 親の無いパスに `Dir.mkdir` すると `Errno::ENOENT`。`FileUtils.mkdir_p` は同じパスで成功
します。**手本の `write_song` が `mkdir_p` → `path.write` の順で書いているのはこのため**です。

中身を見る 2 つも押さえます。

> children: Returns an array of the entry names in the directory, except for `"."` and `".."`.
> glob: Forms an array _entries_ of the entry names selected by the pattern.
> — https://docs.ruby-lang.org/en/4.0/Dir.html

```ruby
Dir.children(dir)                    # ["a.txt", "lib"] — . と .. は含まない
Dir.glob("*.{h,rb}", base: dir)      # ["x.h", "y.rb"] — base からの相対名
```

`{h,rb}` は「どちらか」を意味する波括弧のパターン。**手本が `.sort` を付けているのは、
ファイルシステムが返す順序を当てにしないため**です。

**ここまでで分かったこと**: この手本の全部。一括（§2）→ 1 行ずつと閉じる保証（§3）→
パスをオブジェクトにする（§4）。

なお手本が全体を `Dir.mktmpdir do |dir| ... end` で囲っているのは、テストが作業ディレクトリを
汚さないためです（`require "tmpdir"` が要る）。ブロックを抜けるときに丸ごと消える——
§3 で見た「ブロックが後片付けを保証する」形の、もう 1 つの例です。

## JS ではこうだが Ruby では

### 同期 API との対応（Node.js の `fs`）

ブラウザの JavaScript にファイルシステムは無いため、対応するのは Node.js の `node:fs` になる
（MDN の範囲外。底本は Node.js の API ドキュメント）。対応は素直で、
`fs.readFileSync(path, "utf8")` が `File.read(path)`、`fs.writeFileSync(file, data)` が
`File.write(path, text)`、`fs.mkdirSync(path, { recursive: true })` が `FileUtils.mkdir_p(path)`、
`fs.readdirSync(dir)` が `Dir.children(dir)` にあたる。
差は**既定がどちらか**にある。Node.js はファイル I/O を非同期（Promise / コールバック）で書くのが既定で、
`...Sync` は明示的に選ぶ例外側。Ruby の `File.read` はそもそも同期しかなく、
「同期であること」を名前で断る必要が無い。Ruby で非同期にしたいときは Thread を使う（中級で扱う）。
もう 1 つの差は文字列の扱いで、Node.js の `readFileSync` はエンコーディングを渡さないと
`Buffer`（バイト列）を返すが、Ruby の `File.read` は既定で外部エンコーディング（多くは UTF-8）の
String を返す。バイト列が欲しいときは `File.binread` を使う。

### ブロック付き `open` と `try / finally`

MDN の「try...catch」は `finally` ブロックについて
「The finally block will always execute before control flow exits the
try...catch...finally construct. It always executes, regardless of whether an exception was
thrown or caught」と書く。JS で確実に後始末をするには、この `finally` に `close` を自分で書く。
Ruby の `File.open(path) { |f| ... }` は、その `begin / ensure / close` の組をメソッドの側に
畳み込んだ形。呼ぶ側は `ensure` を書かない。手本が閉じたことを確認しているのは、
「ブロックを渡した」という事実だけで後始末が済むのを見るため。
なお Ruby にも `begin / ensure` はあり（課題 11）、ブロック付き `open` はその糖衣ではなく
「後始末を持つメソッドを設計する型」そのもので、中級で自分でも書けるようになる。

## 底本の URL

- https://docs.ruby-lang.org/en/4.0/File.html
- https://docs.ruby-lang.org/en/4.0/IO.html
- https://docs.ruby-lang.org/en/4.0/Pathname.html
- https://docs.ruby-lang.org/en/4.0/FileUtils.html
- https://docs.ruby-lang.org/en/4.0/Dir.html
- https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/try...catch
- https://nodejs.org/docs/latest-v24.x/api/fs.html
