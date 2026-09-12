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

require "minitest/autorun"
require "tmpdir"
require "pathname"
require "fileutils"

class FilesTest < Minitest::Test
  TEXT = <<~EOT
    First line
    Second line

    Fourth line
    Fifth line
  EOT

  def test_write_and_read_a_whole_file_in_one_call
    Dir.mktmpdir do |dir|
      path = File.join(dir, "t.txt")
      File.write(path, TEXT)

      assert_equal TEXT, File.read(path)
      assert_equal TEXT.bytesize, File.size(path)
    end
  end

  def test_open_with_a_block_closes_the_stream_for_you
    Dir.mktmpdir do |dir|
      path = File.join(dir, "t.txt")
      File.write(path, TEXT)
      lines = []
      f = File.open(path) do |file|
        file.each_line { |line| lines << line }
        file
      end

      assert_equal 5, lines.size
      assert_predicate f, :closed?
    end
  end

  def test_foreach_and_readlines_split_the_file_into_lines
    Dir.mktmpdir do |dir|
      path = File.join(dir, "t.txt")
      File.write(path, TEXT)
      collected = []
      File.foreach(path) { |line| collected << line }

      assert_equal ["First line\n", "Second line\n", "\n", "Fourth line\n", "Fifth line\n"], collected
      assert_equal collected, File.readlines(path)
    end
  end

  def test_appending_uses_the_a_mode
    Dir.mktmpdir do |dir|
      path = File.join(dir, "t.txt")
      File.write(path, "foo")
      File.write(path, "bar", mode: "a")

      assert_equal "foobar", File.read(path)
    end
  end

  def test_pathname_manipulates_paths_as_objects
    Dir.mktmpdir do |dir|
      p1 = Pathname.new(dir)
      p2 = p1 + "lib/song.rb"

      assert_equal Pathname.new("song.rb"), p2.basename
      assert_equal p1 + "lib", p2.parent
      FileUtils.mkdir_p(p2.parent)
      p2.write("# song\n")

      assert_equal "# song\n", p2.read
      assert_predicate p2, :file?
      assert_equal [Pathname.new("song.rb")], p2.parent.children.map(&:basename)
    end
  end

  def test_dir_lists_the_entries_of_a_directory
    Dir.mktmpdir do |dir|
      FileUtils.mkdir_p(File.join(dir, "lib"))
      File.write(File.join(dir, "config.h"), "")
      File.write(File.join(dir, "main.rb"), "")

      assert_equal ["config.h", "lib", "main.rb"], Dir.children(dir).sort
      assert_equal ["config.h", "main.rb"], Dir.glob("*.{h,rb}", base: dir).sort
    end
  end
end
