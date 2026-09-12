# frozen_string_literal: true

require "minitest/autorun"
require "line_report"

# 確認課題の判定テスト。読んでよい。
# このテストは仕様を書いたものであり、欠陥の所在は書いていない。
# assert_output の第 1 引数が標準出力、第 2 引数が標準エラーの期待値である。
class Rb105LineReportExerciseTest < Minitest::Test
  def test_clean_lines_go_to_standard_output_with_no_warning
    assert_output("alpha\nbeta\n", "") { LineReport.run("alpha\n beta \n") }
  end

  def test_empty_lines_are_reported_to_standard_error
    assert_output("alpha\n", "line 2: empty\n") { LineReport.run("alpha\n\n") }
  end

  def test_returns_zero_when_every_line_is_clean
    status = nil
    capture_io { status = LineReport.run("alpha\nbeta\n") }
    assert_equal 0, status
  end

  def test_returns_one_when_any_line_is_empty
    status = nil
    capture_io { status = LineReport.run("alpha\n   \n") }
    assert_equal 1, status
  end
end
