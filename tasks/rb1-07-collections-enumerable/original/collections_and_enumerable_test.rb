# frozen_string_literal: true

# 手本の原本 — Array / Hash / Range と Enumerable。
#
# 底本と、行の文言に現れる識別子が実在する節:
#   配列リテラル / ハッシュリテラルと Symbol キー記法 / 値の省略記法 { x:, y: } /
#   範囲リテラル .. と ...
#     https://docs.ruby-lang.org/en/4.0/syntax/literals_rdoc.html
#   Array のメソッド全般
#     https://docs.ruby-lang.org/en/4.0/Array.html
#   Hash のメソッド全般（任意のオブジェクトをキーにできること）
#     https://docs.ruby-lang.org/en/4.0/Hash.html
#   each / map / select / reject / inject（reduce）/ each_with_object /
#   group_by / tally / sort_by / uniq
#     https://docs.ruby-lang.org/en/4.0/Enumerable.html
#   each がレシーバを返すこと
#     https://docs.ruby-lang.org/en/4.0/Array.html#method-i-each
#
# 教材がこの手本に加えた編集は commentary.md の「原典との差分」に書いてある。

require "minitest/autorun"

class CollectionsAndEnumerableTest < Minitest::Test
  def test_array_literals_may_hold_expressions
    assert_equal [1, 2, 3], [1, 1 + 1, 1 + 2]
    assert_equal [1, [2, [3]]], [1, [1 + 1, [1 + 2]]]
  end

  def test_range_literals_include_or_exclude_the_end
    assert_equal [1, 2], (1..2).to_a
    assert_equal [1], (1...2).to_a
  end

  def test_hash_values_can_be_omitted
    x = 100
    y = 200
    h = { x:, y: }
    assert_equal({ x: 100, y: 200 }, h)
  end

  def test_both_the_key_and_the_value_may_be_any_object
    h = { [1, 2] => "pair", :sym => "symbol", "str" => "string" }
    assert_equal "pair", h[[1, 2]]
    assert_equal "symbol", h[:sym]
  end

  def test_each_returns_the_receiver
    seen = []
    result = [1, 2, 3].each { |value| seen << value }
    assert_equal [1, 2, 3], seen
    assert_equal [1, 2, 3], result
  end

  def test_map_returns_what_the_block_returned
    assert_equal [0, 1, 4, 9, 16], (0..4).map { |i| i * i }
    assert_equal [0, 2, 4], { foo: 0, bar: 1, baz: 2 }.map { |key, value| value * 2 }
  end

  def test_select_and_reject_are_opposites
    assert_equal [0, 3, 6, 9], (0..9).select { |element| element % 3 == 0 }
    assert_equal [1, 3, 5, 7, 9], (0..9).reject { |i| i * 2 if i.even? }
  end

  def test_inject_folds_the_elements_into_one_value
    product = [2, 3, 4].inject(1) do |result, next_value|
      result * next_value
    end
    assert_equal 24, product
    assert_equal 24, [2, 3, 4].reduce { |result, next_value| result * next_value }
  end

  def test_each_with_object_carries_a_container_along
    assert_equal [1, 4, 9, 16], (1..4).each_with_object([]) { |i, a| a.push(i**2) }
    assert_equal({ 0 => :foo, 1 => :bar, 2 => :baz },
                 { foo: 0, bar: 1, baz: 2 }.each_with_object({}) { |(k, v), h| h[v] = k })
  end

  def test_group_by_builds_a_hash_of_arrays
    assert_equal({ 1 => [1, 4], 2 => [2, 5], 0 => [3, 6] }, (1..6).group_by { |i| i % 3 })
  end

  def test_tally_counts_the_occurrences
    assert_equal({ "a" => 2, "b" => 3, "c" => 3 }, %w[a b c b c a c b].tally)
  end

  def test_sort_by_orders_with_the_value_the_block_returns
    a = %w[xx xxx x xxxx]
    assert_equal %w[x xx xxx xxxx], a.sort_by { |s| s.size }
    assert_equal %w[xxxx xxx xx x], a.sort_by { |s| -s.size }
  end

  def test_uniq_keeps_the_first_of_each_kind
    assert_equal %w[a b c], %w[a b c c b a a b c].uniq
    a = [0, 1, 2, 3, 4, 5, 5, 4, 3, 2, 1]
    assert_equal [0, 2, 4], a.uniq { |i| i.even? ? i : 0 }
  end
end
