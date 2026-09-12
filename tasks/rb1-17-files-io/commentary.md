# 模範解説（rb1-17-files-io）

`why.md` を自分の言葉で書き終えてから読む。

## 原典との差分（教材がこの手本に加えた編集）

底本は、公式リファレンスの File・IO・Pathname・FileUtils・Dir の各項。加えた編集は次のとおり。

1. **5 つの項の例を 1 ファイルに連結し、`Dir.mktmpdir` で囲った。** 原典の例はどれも
   `t.txt` のような既存のファイルがある前提で書かれている。テストとして走らせるために、
   一時ディレクトリを作ってその中にファイルを書いてから原文の呼び出しを行う形にした。
   呼び出しの式（`File.write` / `File.read` / `File.open` とブロック / `each_line` /
   `readlines` / `File.foreach` / `Pathname` の `+` と `parent` と `basename` /
   `FileUtils.mkdir_p` / `Dir.children` / `Dir.glob`）は原文のままである。
2. **`# => ` のコメントを `assert` に置き換えた。**
3. **`TEXT` の中身は教材が決めた。** 原典の例は「すでにそこにあるファイル」を読む形で書かれていて
   中身を示さないので、行数と空行の扱いを確かめられるテキストをヒアドキュメントで用意した。
4. **`File.write` / `File.read` の実体は IO のクラスメソッドである。** File の項からはリンクで辿るため、
   原本の冒頭コメントには IO 側の URL も並べてある。

## 手本の各行がしていること

- `Dir.mktmpdir do |dir| ... end` — 一時ディレクトリを作り、ブロックを抜けるときに丸ごと消す。
  手本が毎回これで囲っているのは、テストが作業ディレクトリを汚さないようにするため。
  `require "tmpdir"` が要る（`Dir` の本体には入っていない）。
- `File.write(path, TEXT)` — 開く・書く・閉じるを 1 つにまとめた呼び出し。戻り値は書いたバイト数。
  公式ドキュメントのファイル例はすべてこの形で作られている。
- `File.read(path)` — 同じく、開く・全部読む・閉じるを 1 つにした呼び出し。
- `File.open(path) do |file| ... end` — ブロックを渡すと、**ブロックを抜けるときに必ず閉じる**。
  手本は最後に `assert_predicate f, :closed?` を置いて、抜けたあと本当に閉じていることを見ている。
  ブロックを渡さない `File.open` / `File.new` は自分で `close` しなければならない。
- `file.each_line { |line| ... }` — ストリームから 1 行ずつ読む。ファイル全体をメモリに載せない。
- `File.foreach(path) { |line| ... }` と `File.readlines(path)` — 前者は 1 行ずつ渡す、
  後者は全行の配列を返す。手本は両者の結果が同じであることを 1 つの `assert_equal` で示している。
  改行文字は落とされない（`"First line\n"`）。空行は `"\n"` の 1 要素として現れる。
- `File.write(path, "bar", mode: "a")` — `mode` は「読み書きモード」を表す文字列で、
  `"a"` は追記。既定は `"w"`（既存の中身を捨てて書く）。ここが手本で唯一の破壊的な違い。
- `Pathname.new(dir)` と `p1 + "lib/song.rb"` — `Pathname` は**パス文字列をオブジェクトにしたもの**。
  `+` で継ぎ足し、`parent` で 1 つ上、`basename` でファイル名部分、`children` で中身の一覧が取れる。
  公式ドキュメントは「It is essentially a facade for all of these（File・FileTest・Dir・FileUtils）」と
  書いており、`p2.write` / `p2.read` / `p2.file?` のようにファイル操作もそのまま呼べる。
  `Pathname` は不変で、破壊的更新のメソッドを持たない。
- `FileUtils.mkdir_p(p2.parent)` — 途中のディレクトリが無ければまとめて作る。
  `Dir.mkdir` は親が無いと `Errno::ENOENT` になるので、深い場所を作るときはこちらを使う。
- `Dir.children(dir)` — `.` と `..` を含まない名前の配列。`Dir.glob("*.{h,rb}", base: dir)` は
  パターンに合う名前を返し、`base:` で基準ディレクトリを指定できる（返るのは基準からの相対名）。
  手本が `.sort` を付けているのは、ファイルシステムが返す順序を当てにしないため。

## JS 対比

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

## 底本 URL

- https://docs.ruby-lang.org/en/4.0/File.html
- https://docs.ruby-lang.org/en/4.0/IO.html
- https://docs.ruby-lang.org/en/4.0/Pathname.html
- https://docs.ruby-lang.org/en/4.0/FileUtils.html
- https://docs.ruby-lang.org/en/4.0/Dir.html
- https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/try...catch
- https://nodejs.org/docs/latest-v24.x/api/fs.html
