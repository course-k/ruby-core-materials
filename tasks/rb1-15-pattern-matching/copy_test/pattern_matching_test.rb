# frozen_string_literal: true

require "minitest/autorun"

# 写しの照合テスト（教材が配る。読んでよい。写さない）。
# 学習者の写し pattern_matching.rb（定義だけ）を読み込み、原典が示している呼び出しをここで行って確かめる。
class Rb115PatternMatchingCopyTest < Minitest::Test
  def test_case_in_checks_the_structure_and_binds_the_parts
    assert_equal "Connect with user 'admin'", describe_config(CONFIG)
    assert_equal "Connect with user 'root'", describe_config({ connection: { username: "root" } })
    assert_equal "Unrecognized structure of config", describe_config({ other: 1 })
  end

  def test_the_rightward_operator_unpacks_a_known_structure
    assert_equal "admin", user_of(CONFIG)
    assert_raises(NoMatchingPatternKeyError) { user_of({ web: { user: "x" } }) }
  end

  def test_a_value_pattern_matches_like_the_case_when_operator
    assert integer?(5)
    assert single_digit?(5)
    refute integer?("5")
  end

  def test_an_array_pattern_matches_only_a_whole_array
    assert three_integers?([1, 2, 3])
    refute three_integers?([1, 2])
    assert starts_with_integer?([1, 2, 3])
  end

  def test_a_hash_pattern_matches_even_when_other_keys_are_present
    assert has_integer_a?({ a: 1, b: 2, c: 3 })
    refute only_integer_a?({ a: 1, b: 2 })
    assert only_integer_a?({ a: 1 })
  end

  def test_the_pin_operator_uses_a_variable_as_a_value_not_as_a_binding
    assert_equal "not matched. expectation was: 18", pinned(18, [1, 2])
    assert_equal "matched: [2]", pinned(1, [1, 2])
  end

  def test_a_guard_clause_adds_a_condition_to_the_pattern
    assert_equal "matched", doubled?([1, 2])
    assert_equal "not matched", doubled?([1, 3])
  end

  def test_deconstruct_and_deconstruct_keys_let_any_object_be_matched
    assert_equal "matched: 1", first_of(Point.new(1, -2))
    assert_equal "matched: 1", positive_x_of(Point.new(1, -2))
  end
end

require "pattern_matching"
