# frozen_string_literal: true

require "minitest/autorun"
require "normalizer"

# 確認課題の判定テスト。読んでよい（これが実装の仕様そのものになっている）。
class Rb106NormalizerExerciseTest < Minitest::Test
  def test_call_strips_both_ends
    assert_equal "ruby", Normalizer.call("  ruby  ")
  end

  def test_call_collapses_runs_of_whitespace_into_one_space
    assert_equal "ruby on rails", Normalizer.call("ruby   on \t rails")
  end

  def test_call_downcases
    assert_equal "sales report", Normalizer.call("Sales  REPORT")
  end

  def test_call_returns_an_empty_string_for_blank_input
    assert_equal "", Normalizer.call("   ")
  end

  def test_call_does_not_change_the_string_it_was_given
    given = +"  Ruby  "
    Normalizer.call(given)
    assert_equal "  Ruby  ", given
  end

  def test_key_returns_a_symbol_with_underscores
    assert_equal :sales_report, Normalizer.key("  Sales Report ")
    assert_equal :ruby, Normalizer.key("RUBY")
  end
end
