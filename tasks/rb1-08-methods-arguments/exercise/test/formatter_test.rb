# frozen_string_literal: true

require "minitest/autorun"
require "formatter"

# 確認課題の判定テスト。読んでよい（これが実装の仕様そのものになっている）。
class Rb108FormatterExerciseTest < Minitest::Test
  def test_label_is_required
    assert_raises(ArgumentError) { Formatter.line }
  end

  def test_values_after_the_label_are_gathered_and_joined
    assert_equal "total: 1, 2, 3", Formatter.line("total", 1, 2, 3)
  end

  def test_no_values_leaves_the_right_side_empty
    assert_equal "total: ", Formatter.line("total")
  end

  def test_separator_is_a_keyword_argument_with_a_default
    assert_equal "total: 1 / 2", Formatter.line("total", 1, 2, separator: " / ")
  end

  def test_prefix_is_a_keyword_argument_that_defaults_to_nothing
    assert_equal "#total: 1, 2", Formatter.line("total", 1, 2, prefix: "#")
  end

  def test_keyword_arguments_may_be_given_in_any_order
    assert_equal "#total: 1 / 2", Formatter.line("total", 1, 2, prefix: "#", separator: " / ")
    assert_equal "#total: 1 / 2", Formatter.line("total", 1, 2, separator: " / ", prefix: "#")
  end

  def test_an_unknown_keyword_is_an_error
    assert_raises(ArgumentError) { Formatter.line("total", 1, suffix: "!") }
  end

  def test_a_block_transforms_every_value
    assert_equal "total: 10, 20", Formatter.line("total", 1, 2) { |value| value * 10 }
  end

  def test_without_a_block_the_values_are_used_as_they_are
    assert_equal "total: a, b", Formatter.line("total", "a", "b")
  end
end
