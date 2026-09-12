# frozen_string_literal: true

require "minitest/autorun"
require "counter"

# 確認課題の判定テスト（正本）。学習者が読んでよい。
class CounterTest < Minitest::Test
  TEXT = "alpha beta\ngamma\n"

  # 実行ファイルは $LOAD_PATH に足されたディレクトリ（exercise/exe）から探す。
  EXE = $LOAD_PATH.map { |dir| File.join(dir, "count") }.find { |path| File.file?(path) }

  def test_lines_counts_the_lines
    assert_equal 2, Counter.lines(TEXT)
    assert_equal 2, Counter.lines("alpha\nbeta")
    assert_equal 0, Counter.lines("")
  end

  def test_words_counts_the_words
    assert_equal 3, Counter.words(TEXT)
    assert_equal 0, Counter.words("   \n")
  end

  def test_the_executable_is_in_place_with_a_shebang_and_the_executable_bit
    refute_nil EXE, "exercise/exe/count が見つかりません"
    assert File.executable?(EXE), "exercise/exe/count に実行権限がありません（chmod +x）"
    assert_equal "#!/usr/bin/env ruby", File.readlines(EXE).first.chomp
  end

  def test_the_executable_prints_the_line_count_by_default
    assert_equal "2\n", run_exe([], TEXT)
  end

  def test_the_executable_prints_the_word_count_with_the_words_option
    assert_equal "3\n", run_exe(["--words"], TEXT)
    assert_equal "3\n", run_exe(["-w"], TEXT)
  end

  private

  def run_exe(args, input)
    IO.popen([EXE, *args], "r+") do |io|
      io.write(input)
      io.close_write
      io.read
    end
  end
end
