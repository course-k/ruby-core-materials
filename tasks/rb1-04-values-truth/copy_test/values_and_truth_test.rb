# frozen_string_literal: true

require "minitest/autorun"

# 写しの照合テスト（教材が配る。読んでよい。写さない）。
# 学習者の写し values_and_truth.rb（定義だけ）を読み込み、原典が示している呼び出しをここで行って確かめる。
class Rb104ValuesAndTruthCopyTest < Minitest::Test
  def test_every_expression_has_a_value
    assert_equal true, bigger?(10, 11)
    assert_equal false, bigger?(11, 10)
  end

  def test_zero_is_a_true_value_in_ruby
    assert_equal "0 is true", zero_is_true
  end

  def test_only_nil_and_false_are_false_values
    assert_equal [nil, false], falsey_values
    assert_equal [nil, false, 0, "", [], {}, "0"], FALSEY
  end

  def test_nil_and_true_are_objects
    assert_nil nil
    assert nil.nil?
    assert_equal NilClass, nil.class
    assert_equal TrueClass, true.class
  end

  def test_puts_writes_to_stdout_and_returns_nil
    result = :not_yet
    assert_output("Hello World\n") { result = print_hello_world }
    assert_nil result
  end

  def test_a_case_expression_matches_with_triple_equals
    assert_equal "the string starts with one", starts_with_one("12345")
    assert_equal "I don't know what the string starts with", starts_with_one("98765")
  end

  def test_triple_equals_is_not_equality
    assert(/^1/ === "12345")
    assert(String === "12345")
    refute(Integer === "12345")
    refute_equal("12345", /^1/)
  end

  def test_a_case_expression_has_a_value_too
    assert_equal "a is one or two", label_for(1)
    assert_equal "a is three", label_for(3)
    assert_equal "I don't know what a is", label_for(9)
  end
end

require "values_and_truth"
