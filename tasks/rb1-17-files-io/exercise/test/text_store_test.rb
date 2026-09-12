# frozen_string_literal: true

require "minitest/autorun"
require "tmpdir"
require "text_store"

# 確認課題の判定テスト（正本）。学習者が読んでよい。
class TextStoreTest < Minitest::Test
  def test_save_creates_the_directory_and_writes_the_file
    Dir.mktmpdir do |root|
      dir = File.join(root, "notes", "2026")
      written = TextStore.save(dir, "boot", "hello\n")

      assert_equal 6, written
      assert_path_exists File.join(dir, "boot.txt")
      assert_equal "hello\n", File.read(File.join(dir, "boot.txt"))
    end
  end

  def test_load_returns_the_text_and_nil_for_a_missing_name
    Dir.mktmpdir do |dir|
      TextStore.save(dir, "boot", "hello\n")

      assert_equal "hello\n", TextStore.load(dir, "boot")
      assert_nil TextStore.load(dir, "missing")
    end
  end

  def test_names_lists_only_txt_files_in_sorted_order
    Dir.mktmpdir do |dir|
      TextStore.save(dir, "beta", "b\n")
      TextStore.save(dir, "alpha", "a\n")
      File.write(File.join(dir, "notes.md"), "ignored")

      assert_equal %w[alpha beta], TextStore.names(dir)
    end
  end

  def test_line_count_counts_lines_and_returns_zero_for_a_missing_name
    Dir.mktmpdir do |dir|
      TextStore.save(dir, "boot", "one\ntwo\nthree\n")

      assert_equal 3, TextStore.line_count(dir, "boot")
      assert_equal 0, TextStore.line_count(dir, "missing")
    end
  end
end
