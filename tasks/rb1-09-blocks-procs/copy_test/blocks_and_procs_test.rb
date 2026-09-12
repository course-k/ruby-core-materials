# frozen_string_literal: true

require "minitest/autorun"

# 写しの照合テスト（教材が配る。読んでよい。写さない）。
# 学習者の写し blocks_and_procs.rb（定義だけ）を読み込み、原典が示している呼び出しをここで行って
# 戻り値と例外を確かめる。Proc と lambda の差は B5 の「説明できる」側なので、ここで見せる。
class Rb109BlocksAndProcsCopyTest < Minitest::Test
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

require "blocks_and_procs"
