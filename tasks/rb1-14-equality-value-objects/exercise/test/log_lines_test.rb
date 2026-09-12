# frozen_string_literal: true

require "minitest/autorun"
require "log_lines"

# 確認課題の判定テスト（正本）。学習者が読んでよい。
class LogLinesTest < Minitest::Test
  BOOT = "2026-01-01T09:00:00 INFO サーバを起動した"
  STOP = "2026-01-01T09:30:00 WARN 応答が遅い"

  def test_parse_reads_the_level_and_the_message
    line = LogLines.parse(BOOT)

    assert_equal "INFO", line.level
    assert_equal "サーバを起動した", line.message
  end

  def test_parsed_line_is_an_immutable_value_object
    line = LogLines.parse(BOOT)

    assert_kind_of Data, line
    refute_respond_to line, :level=
  end

  def test_the_same_text_parses_into_equal_objects
    a = LogLines.parse(BOOT)
    b = LogLines.parse(BOOT)

    assert_equal a, b
    assert a.eql?(b)
    assert_equal a.hash, b.hash
    refute a.equal?(b)
  end

  def test_a_set_treats_the_same_text_as_one_element
    assert_equal 1, Set[LogLines.parse(BOOT), LogLines.parse(BOOT)].size
  end

  def test_unique_drops_duplicates_and_keeps_the_first_order
    result = LogLines.unique([BOOT, STOP, BOOT])

    assert_equal 2, result.size
    assert_equal "サーバを起動した", result[0].message
    assert_equal "応答が遅い", result[1].message
  end
end
