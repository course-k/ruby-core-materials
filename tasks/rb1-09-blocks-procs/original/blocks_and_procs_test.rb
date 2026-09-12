# frozen_string_literal: true

# 手本の原本 — ブロックと Proc と lambda。
#
# 底本と、行の文言に現れる識別子が実在する節:
#   Proc.new / call / .() / [] / クロージャであること（gen_times）/
#   proc / lambda / ->(x) { } / lambda? /
#   lambda と非 lambda の引数の厳しさの違い / return の違い /
#   & による Symbol から Proc への変換（to_proc）/ & を通しても lambda の性質が残ること
#     https://docs.ruby-lang.org/en/4.0/Proc.html
#   & でブロックを受け取る / yield
#     https://docs.ruby-lang.org/en/4.0/syntax/methods_rdoc.html
#   block_given?
#     https://docs.ruby-lang.org/en/4.0/Kernel.html#method-i-block_given-3F
#
# 教材がこの手本に加えた編集は commentary.md の「原典との差分」に書いてある。

require "minitest/autorun"

def gen_times(factor)
  Proc.new { |n| n * factor } # remembers the value of factor at the moment of creation
end

def make_proc(&block)
  block
end

def returns_from_the_enclosing_method
  -> { return 3 }.call   # just returns from lambda into method body
  proc { return 4 }.call # returns from method
  return 5
end

def try
  if block_given?
    yield
  else
    "no block"
  end
end

class BlocksAndProcsTest < Minitest::Test
  def test_a_proc_can_be_called_in_several_ways
    square = Proc.new { |x| x**2 }
    assert_equal 9, square.call(3)
    assert_equal 9, square.(3)
    assert_equal 9, square[3]
  end

  def test_procs_are_closures
    times3 = gen_times(3)
    times5 = gen_times(5)
    assert_equal 36, times3.call(12)
    assert_equal 25, times5.call(5)
    assert_equal 60, times3.call(times5.call(4))
  end

  def test_the_several_ways_to_create_a_proc
    proc1 = Proc.new { |x| x**2 }
    proc2 = proc { |x| x**2 }
    proc3 = make_proc { |x| x**2 }
    lambda1 = lambda { |x| x**2 }
    lambda2 = ->(x) { x**2 }
    assert_equal [9, 9, 9, 9, 9], [proc1, proc2, proc3, lambda1, lambda2].map { |f| f.call(3) }
    refute proc1.lambda?
    assert lambda1.lambda?
    assert lambda2.lambda?
  end

  def test_regular_procs_accept_arguments_generously
    p = proc { |x, y| "x=#{x}, y=#{y}" }
    assert_equal "x=1, y=2", p.call(1, 2)
    assert_equal "x=1, y=2", p.call([1, 2])
    assert_equal "x=1, y=2", p.call(1, 2, 8)
    assert_equal "x=1, y=", p.call(1)
  end

  def test_lambdas_are_strict_about_arguments
    l = lambda { |x, y| "x=#{x}, y=#{y}" }
    assert_equal "x=1, y=2", l.call(1, 2)
    assert_raises(ArgumentError) { l.call([1, 2]) }
    assert_raises(ArgumentError) { l.call(1, 2, 8) }
    assert_raises(ArgumentError) { l.call(1) }
  end

  def test_return_inside_a_proc_leaves_the_whole_method
    assert_equal 4, returns_from_the_enclosing_method
  end

  def test_block_given_tells_whether_a_block_was_passed
    assert_equal "no block", try
    assert_equal "hello", try { "hello" }
  end

  def test_an_ampersand_turns_a_symbol_into_a_block
    assert_equal "1", :to_s.to_proc.call(1)
    assert_equal ["1", "2"], [1, 2].map(&:to_s)
  end

  def test_lambda_semantics_survive_the_ampersand
    p = proc { |x, y| x }
    l = lambda { |x, y| x }
    assert_equal [1, 3], [[1, 2], [3, 4]].map(&p)
    assert_raises(ArgumentError) { [[1, 2], [3, 4]].map(&l) }
  end
end
