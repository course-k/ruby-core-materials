# frozen_string_literal: true

# 手本の底本（Ruby 4.0 の公式ドキュメント）。行に出てくる道具ごとに、それが載っている節を指す。
#   File.open（モードとブロック付き open）
#     https://docs.ruby-lang.org/en/4.0/File.html
#   File.write / File.read（実体は IO のクラスメソッド）
#     https://docs.ruby-lang.org/en/4.0/IO.html#method-c-write
#     https://docs.ruby-lang.org/en/4.0/IO.html#method-c-read
#   IO#each_line / IO#readlines / File.foreach（1 行ずつ読む）
#     https://docs.ruby-lang.org/en/4.0/IO.html
#   Pathname（パスをオブジェクトとして扱う。+ / parent / basename / children / read）
#     https://docs.ruby-lang.org/en/4.0/Pathname.html
#   FileUtils.mkdir_p（途中のディレクトリごと作る）
#     https://docs.ruby-lang.org/en/4.0/FileUtils.html
#   Dir.children / Dir.glob（ディレクトリの中身を数える）
#     https://docs.ruby-lang.org/en/4.0/Dir.html

require "pathname"
require "fileutils"

TEXT = <<~EOT
  First line
  Second line

  Fourth line
  Fifth line
EOT

def write_then_read(path)
  File.write(path, TEXT)
  [File.read(path), File.size(path)]
end

def each_line_with_block(path)
  lines = []
  file = File.open(path) do |f|
    f.each_line { |line| lines << line }
    f
  end
  [lines, file]
end

def collected_lines(path)
  collected = []
  File.foreach(path) { |line| collected << line }
  collected
end

def read_lines(path)
  File.readlines(path)
end

def append(path, text)
  File.write(path, text, mode: "a")
  File.read(path)
end

def song_path(dir)
  Pathname.new(dir) + "lib/song.rb"
end

def write_song(dir)
  path = song_path(dir)
  FileUtils.mkdir_p(path.parent)
  path.write("# song\n")
  path
end

def entries_of(dir)
  Dir.children(dir).sort
end

def sources_in(dir)
  Dir.glob("*.{h,rb}", base: dir).sort
end
