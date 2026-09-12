# frozen_string_literal: true

# 手本の底本（Ruby 4.0 の公式ドキュメント）。この課題で出てくる道具はすべて次の 1 節にある。
#   case / in、値パターン、配列パターン、ハッシュパターン、変数束縛、
#   ピン演算子 ^、ガード節 if、deconstruct / deconstruct_keys、=> と in の単独形
#     https://docs.ruby-lang.org/en/4.0/syntax/pattern_matching_rdoc.html
#   NoMatchingPatternKeyError（底本のページ本文には出てこない。例外クラスの側の項を指す）
#     https://docs.ruby-lang.org/en/4.0/NoMatchingPatternKeyError.html

require "minitest/autorun"

class Point
  def initialize(x, y)
    @x = x
    @y = y
  end

  def deconstruct
    puts "deconstruct called"
    [@x, @y]
  end

  def deconstruct_keys(keys)
    puts "deconstruct_keys called with #{keys.inspect}"
    { x: @x, y: @y }
  end
end

class PatternMatchingTest < Minitest::Test
  CONFIG = { db: { user: "admin", password: "abc123" } }.freeze

  def test_case_in_checks_the_structure_and_binds_the_parts
    matched = case CONFIG
              in db: { user: }
                "Connect with user '#{user}'"
              in connection: { username: }
                "Connect with user '#{username}'"
              else
                "Unrecognized structure of config"
              end

    assert_equal "Connect with user 'admin'", matched
  end

  def test_the_rightward_operator_unpacks_a_known_structure
    CONFIG => { db: { user: } }

    assert_equal "admin", user
    assert_raises(NoMatchingPatternKeyError) { CONFIG => { web: { user: } } }
  end

  def test_a_value_pattern_matches_like_the_case_when_operator
    assert((5 in Integer))
    assert((5 in 0..9))
    refute((5 in String))
  end

  def test_an_array_pattern_matches_only_a_whole_array
    assert(([1, 2, 3] in [Integer, Integer, Integer]))
    refute(([1, 2, 3] in [Integer, Integer]))
    assert(([1, 2, 3] in [Integer, *]))
  end

  def test_a_hash_pattern_matches_even_when_other_keys_are_present
    assert(({ a: 1, b: 2, c: 3 } in { a: Integer }))
    refute(({ a: 1, b: 2 } in { a: Integer, **nil }))
    assert(({ a: 1, b: 2 } in { a: Integer, b: Integer, **nil }))
  end

  def test_the_pin_operator_uses_a_variable_as_a_value_not_as_a_binding
    expectation = 18

    matched = case [1, 2]
              in ^expectation, *rest
                "matched: #{rest}"
              else
                "not matched. expectation was: #{expectation}"
              end

    assert_equal "not matched. expectation was: 18", matched
  end

  def test_a_guard_clause_adds_a_condition_to_the_pattern
    matched = case [1, 2]
              in a, b if b == a * 2
                "matched"
              else
                "not matched"
              end

    assert_equal "matched", matched
  end

  def test_deconstruct_and_deconstruct_keys_let_any_object_be_matched
    matched = case Point.new(1, -2)
              in px, Integer
                "matched: #{px}"
              end

    assert_equal "matched: 1", matched

    keyed = case Point.new(1, -2)
            in x: 0.. => px
              "matched: #{px}"
            end

    assert_equal "matched: 1", keyed
  end
end
