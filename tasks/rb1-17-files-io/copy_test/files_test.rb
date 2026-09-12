# frozen_string_literal: true

require "minitest/autorun"
require "tmpdir"
require "pathname"
require "fileutils"

# 写しの照合テスト（教材が配る。読んでよい。写さない）。
# 学習者の写し files.rb（定義だけ）を読み込み、原典が示している呼び出しをここで行って確かめる。
# 一時ディレクトリを作る Dir.mktmpdir は判定のための道具なので、写しには置かずここで使う。
class Rb117FilesCopyTest < Minitest::Test
  def test_write_and_read_a_whole_file_in_one_call
    Dir.mktmpdir do |dir|
      content, size = write_then_read(File.join(dir, "t.txt"))

      assert_equal TEXT, content
      assert_equal TEXT.bytesize, size
    end
  end

  def test_open_with_a_block_closes_the_stream_for_you
    Dir.mktmpdir do |dir|
      path = File.join(dir, "t.txt")
      write_then_read(path)
      lines, file = each_line_with_block(path)

      assert_equal 5, lines.size
      assert_predicate file, :closed?
    end
  end

  def test_foreach_and_readlines_split_the_file_into_lines
    Dir.mktmpdir do |dir|
      path = File.join(dir, "t.txt")
      write_then_read(path)

      assert_equal ["First line\n", "Second line\n", "\n", "Fourth line\n", "Fifth line\n"],
                   collected_lines(path)
      assert_equal collected_lines(path), read_lines(path)
    end
  end

  def test_appending_uses_the_a_mode
    Dir.mktmpdir do |dir|
      path = File.join(dir, "t.txt")
      File.write(path, "foo")

      assert_equal "foobar", append(path, "bar")
    end
  end

  def test_pathname_manipulates_paths_as_objects
    Dir.mktmpdir do |dir|
      path = song_path(dir)

      assert_equal Pathname.new("song.rb"), path.basename
      assert_equal Pathname.new(dir) + "lib", path.parent

      written = write_song(dir)

      assert_equal "# song\n", written.read
      assert_predicate written, :file?
      assert_equal [Pathname.new("song.rb")], written.parent.children.map(&:basename)
    end
  end

  def test_dir_lists_the_entries_of_a_directory
    Dir.mktmpdir do |dir|
      FileUtils.mkdir_p(File.join(dir, "lib"))
      File.write(File.join(dir, "config.h"), "")
      File.write(File.join(dir, "main.rb"), "")

      assert_equal ["config.h", "lib", "main.rb"], entries_of(dir)
      assert_equal ["config.h", "main.rb"], sources_in(dir)
    end
  end
end

require "files"
