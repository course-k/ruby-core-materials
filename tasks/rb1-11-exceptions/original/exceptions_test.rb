# frozen_string_literal: true

# 手本の原本 — 例外。
#
# 底本と、行の文言に現れる識別子が実在する節:
#   begin / rescue / else / ensure / end の並び / メソッド本体やブロックが
#   そのまま例外ハンドラになる形 / rescue が既定で StandardError を捕まえること /
#   複数の rescue 節と最初に当たった節だけが実行されること /
#   rescue => 変数 で例外を受けること / $! / raise の引数なし再送出 / retry /
#   自作例外クラス / message
#     https://docs.ruby-lang.org/en/4.0/language/exceptions_md.html
#   rescue の構文と retry の位置の制約
#     https://docs.ruby-lang.org/en/4.0/syntax/exceptions_rdoc.html
#   組み込みの例外クラス階層
#     https://docs.ruby-lang.org/en/4.0/Exception.html
#   Errno::ENOENT
#     https://docs.ruby-lang.org/en/4.0/Errno.html
#
# 教材がこの手本に加えた編集は commentary.md の「原典との差分」に書いてある。

require "minitest/autorun"

class MyException < StandardError
end

def foo(boom: false)
  puts "Begin."
  raise "Boom!" if boom
rescue
  puts "Rescued an exception!"
else
  puts "No exception raised."
ensure
  puts "Always do this."
end

def capture_the_exception
  1 / 0
rescue => x
  [x.class, x.message]
end

def first_matching_clause
  Dir.open("nosuch")
rescue Errno::ENOTDIR
  "Rescued #{$!.class} as a directory error"
rescue Errno::ENOENT
  "Rescued #{$!.class}"
end

def retried
  retries = 0
  begin
    raise "Boom"
  rescue
    if (retries += 1) < 3
      retry
    else
      raise
    end
  end
end

def re_raised
  1 / 0
rescue ZeroDivisionError
  # Do needful things (like logging).
  raise # Raised exception will be ZeroDivisionError, not RuntimeError.
end

class ExceptionsTest < Minitest::Test
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
