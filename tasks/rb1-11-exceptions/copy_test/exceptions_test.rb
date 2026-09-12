# frozen_string_literal: true

require "minitest/autorun"

# 写しの照合テスト（教材が配る。読んでよい。写さない）。
# 学習者の写し exceptions.rb（定義だけ）を読み込み、原典が示している呼び出しをここで行って確かめる。
class Rb111ExceptionsCopyTest < Minitest::Test
  def test_a_handler_may_have_rescue_else_and_ensure
    assert_output("Begin.\nRescued an exception!\nAlways do this.\n") { foo(boom: true) }
    assert_output("Begin.\nNo exception raised.\nAlways do this.\n") { foo(boom: false) }
  end

  def test_a_bare_rescue_catches_standard_error_and_its_subclasses
    assert_equal [ZeroDivisionError, "divided by 0"], capture_the_exception
  end

  def test_only_the_first_matching_rescue_clause_runs
    assert_equal "Rescued Errno::ENOENT", first_matching_clause
  end

  def test_retry_runs_the_begin_clause_again_until_it_gives_up
    error = assert_raises(RuntimeError) { retried }
    assert_equal "Boom", error.message
  end

  def test_raise_without_an_argument_re_raises_the_current_exception
    error = assert_raises(ZeroDivisionError) { re_raised }
    assert_equal "divided by 0", error.message
  end

  def test_a_custom_exception_is_a_subclass_of_standard_error
    assert_operator MyException, :<, StandardError
    error = assert_raises(MyException) { raise MyException, "custom" }
    assert_equal "custom", error.message
  end

  def test_the_built_in_hierarchy_puts_standard_error_under_exception
    assert_operator ZeroDivisionError, :<, StandardError
    assert_operator StandardError, :<, Exception
    refute_operator SystemExit, :<, StandardError
  end

  def test_a_block_can_be_its_own_handler
    result = [0, 1, 2].map do |i|
      10 / i
    rescue ZeroDivisionError
      nil
    end
    assert_equal [nil, 10, 5], result
  end
end

require "exceptions"
