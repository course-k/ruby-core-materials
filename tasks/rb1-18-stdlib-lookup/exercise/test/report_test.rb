# frozen_string_literal: true

require "minitest/autorun"
require "report"

# 確認課題の判定テスト（正本）。学習者が読んでよい。
class ReportTest < Minitest::Test
  ROWS = [{ name: "alpha", count: 1 }, { name: "beta", count: 2 }].freeze

  def test_to_json_indents_with_two_spaces
    expected = <<~JSON.chomp
      [
        {
          "name": "alpha",
          "count": 1
        },
        {
          "name": "beta",
          "count": 2
        }
      ]
    JSON

    assert_equal expected, Report.to_json(ROWS)
  end

  def test_to_csv_writes_a_header_row_first
    assert_equal "name,count\nalpha,1\nbeta,2\n", Report.to_csv(ROWS)
  end

  def test_to_csv_of_an_empty_list_is_an_empty_string
    assert_equal "", Report.to_csv([])
  end

  def test_stamp_formats_a_time_down_to_the_second
    assert_equal "2026-01-02 03:04:05", Report.stamp(Time.new(2026, 1, 2, 3, 4, 5))
  end
end
