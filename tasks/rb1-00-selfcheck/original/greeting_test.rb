# frozen_string_literal: true

require "minitest/autorun"

# 書き写しの原本（検体）。公式ドキュメントから取った手本ではなく、
# bin/check の judge を一通り動かすためだけの最小サンプルである。
class GreetingTest < Minitest::Test
  def setup
    @names = %w[ada grace linus]
  end

  def test_interpolation_builds_a_greeting
    name = "ada"
    assert_equal "Hello, ada!", "Hello, #{name}!"
  end

  def test_map_upcases_every_name
    assert_equal %w[ADA GRACE LINUS], @names.map(&:upcase)
  end

  def test_select_and_reduce
    long = @names.select { |n| n.length > 3 }
    assert_equal %w[grace linus], long
    assert_equal 10, long.reduce(0) { |sum, n| sum + n.length }
  end

  def test_nil_and_false_are_the_only_falsy_objects
    assert_nil [].first
    refute_empty @names
  end
end
