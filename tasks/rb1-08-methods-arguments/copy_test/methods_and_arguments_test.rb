# frozen_string_literal: true

require "minitest/autorun"

# 写しの照合テスト（教材が配る。読んでよい。写さない）。
# 学習者の写し methods_and_arguments.rb（定義だけ）を読み込み、原典が示している呼び出しをここで行って確かめる。
class Rb108MethodsAndArgumentsCopyTest < Minitest::Test
  def test_positional_arguments_are_required_and_ordered
    assert_equal 2, add_one(1)
    assert_raises(ArgumentError) { add_one }
  end

  def test_the_last_expression_evaluated_is_the_return_value
    assert_equal 2, one_plus_one
    assert_equal 4, two_plus_two
  end

  def test_default_values_are_filled_in_from_the_left
    assert_equal 2, sum_with_default(1)
    assert_equal 5, sum_with_default(1, 4)
    assert_equal 2, sum_referring_to_earlier
    assert_equal [1, 2, 3, 4], fill_in_the_middle(1, 4)
    assert_equal [1, 5, 3, 6], fill_in_the_middle(1, 5, 6)
  end

  def test_a_star_gathers_the_remaining_arguments_into_an_array
    assert_equal [1, 2, 3], gather_arguments(1, 2, 3)
    assert_equal [1, [2, 3], 4], gather_middle(1, 2, 3, 4)
  end

  def test_keyword_arguments_may_be_given_in_any_order
    assert_equal 3, add_keywords
    assert_equal 30, add_keywords(second: 20, first: 10)
    assert_raises(ArgumentError) { require_keywords }
    assert_equal 3, require_keywords(second: 2, first: 1)
    assert_equal [1, { second: 2, third: 3 }], gather_keywords(first: 1, second: 2, third: 3)
  end

  def test_a_block_can_be_captured_or_yielded_to
    assert_equal 6, call_the_block(3) { |n| n * 2 }
    assert_equal 9, yields_once(3) { |n| n * 3 }
  end

  def test_question_marks_and_bangs_are_naming_conventions
    assert_equal true, "".empty?
    s = +"ruby"
    assert_equal "RUBY", s.upcase!
    assert_equal "RUBY", s
    assert_nil "RUBY".dup.upcase!
  end
end

require "methods_and_arguments"
