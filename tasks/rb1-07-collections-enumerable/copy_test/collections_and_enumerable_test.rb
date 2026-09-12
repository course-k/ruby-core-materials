# frozen_string_literal: true

require "minitest/autorun"

# 写しの照合テスト（教材が配る。読んでよい。写さない）。
# 学習者の写し collections_and_enumerable.rb（定義だけ）を読み込み、原典が示している呼び出しをここで行って確かめる。
class Rb107CollectionsAndEnumerableCopyTest < Minitest::Test
  def test_array_literals_may_hold_expressions
    assert_equal [1, 2, 3], literal_with_expressions
    assert_equal [1, [2, [3]]], nested_literal
  end

  def test_range_literals_include_or_exclude_the_end
    assert_equal [1, 2], inclusive_range
    assert_equal [1], exclusive_range
  end

  def test_hash_values_can_be_omitted
    assert_equal({ x: 100, y: 200 }, omitted_values)
  end

  def test_both_the_key_and_the_value_may_be_any_object
    h = any_key_hash

    assert_equal "pair", h[[1, 2]]
    assert_equal "symbol", h[:sym]
    assert_equal "string", h["str"]
  end

  def test_each_returns_the_receiver
    seen, result = each_collects([1, 2, 3])

    assert_equal [1, 2, 3], seen
    assert_equal [1, 2, 3], result
  end

  def test_map_returns_what_the_block_returned
    assert_equal [0, 1, 4, 9, 16], squares(0..4)
    assert_equal [0, 2, 4], doubled_values({ foo: 0, bar: 1, baz: 2 })
  end

  def test_select_and_reject_are_opposites
    assert_equal [0, 3, 6, 9], multiples_of_three(0..9)
    assert_equal [1, 3, 5, 7, 9], not_doubled_evens(0..9)
  end

  def test_inject_folds_the_elements_into_one_value
    assert_equal 24, product_with_inject([2, 3, 4])
    assert_equal 24, product_with_reduce([2, 3, 4])
  end

  def test_each_with_object_carries_a_container_along
    assert_equal [1, 4, 9, 16], squares_into_array(1..4)
    assert_equal({ 0 => :foo, 1 => :bar, 2 => :baz }, inverted({ foo: 0, bar: 1, baz: 2 }))
  end

  def test_group_by_builds_a_hash_of_arrays
    assert_equal({ 1 => [1, 4], 2 => [2, 5], 0 => [3, 6] }, grouped_by_remainder(1..6))
  end

  def test_tally_counts_the_occurrences
    assert_equal({ "a" => 2, "b" => 3, "c" => 3 }, counted(%w[a b c b c a c b]))
  end

  def test_sort_by_orders_with_the_value_the_block_returns
    assert_equal %w[x xx xxx xxxx], by_length(%w[xx xxx x xxxx])
    assert_equal %w[xxxx xxx xx x], by_length_descending(%w[xx xxx x xxxx])
  end

  def test_uniq_keeps_the_first_of_each_kind
    assert_equal %w[a b c], unique(%w[a b c c b a a b c])
    assert_equal [0, 2, 4], unique_by_evenness([0, 1, 2, 3, 4, 5, 5, 4, 3, 2, 1])
  end
end

require "collections_and_enumerable"
