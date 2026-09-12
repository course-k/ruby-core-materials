# frozen_string_literal: true

require "minitest/autorun"
require "stringio"

# 写しの照合テスト（教材が配る。読んでよい。写さない）。
# 学習者の写し control_flow_and_io.rb（定義だけ）を読み込み、原典が示している呼び出しをここで行って確かめる。
# 標準入力の差し替え・ARGV の書き換え・SystemExit の捕捉は判定のための道具なので、写しには置かずここで使う。
class Rb105ControlFlowAndIoCopyTest < Minitest::Test
  def test_if_elsif_else_runs_the_first_matching_branch
    assert_equal "a is zero", label_for(0)
    assert_equal "a is one", label_for(1)
    assert_equal "a is some other value", label_for(9)
  end

  def test_unless_is_the_opposite_of_if
    assert_equal "the value is true", unless_label(true)
    assert_equal "the value is false", unless_label(false)
  end

  def test_a_case_without_a_subject_works_like_if_elsif
    assert_equal "a is one or two", case_label(2)
    assert_equal "a is three", case_label(3)
    assert_equal "I don't know what a is", case_label(9)
  end

  def test_modifier_if_puts_the_test_on_the_right
    assert_equal 1, bumped_if_zero(0)
    assert_equal 5, bumped_if_zero(5)
  end

  def test_while_and_until_loops
    assert_equal 10, count_with_while(10)
    assert_equal 11, count_with_until(10)
  end

  def test_and_binds_more_loosely_than_assignment
    assert_equal [false, true], and_versus_double_ampersand
  end

  def test_safe_navigation_skips_only_the_next_call
    assert_equal "Ruby - great", safely_joined("Ruby is great!")
    assert_nil safely_joined("Python is fascinating!")
    assert_raises(NoMethodError) { joined_without_the_second_guard("Python is fascinating!") }
  end

  def test_warn_writes_to_standard_error
    assert_output("", "warning 1\nwarning 2\n") { warn_twice }
  end

  def test_exit_carries_a_status_for_the_operating_system
    exit_with(1)
  rescue SystemExit => e
    assert_equal 1, e.status
  end

  def test_argv_holds_the_arguments_given_on_the_command_line
    ARGV.replace(["report.csv", "--verbose"])
    assert_equal "report.csv", first_argument
  ensure
    ARGV.clear
  end

  def test_stdin_read_returns_the_whole_input_at_once
    original = $stdin
    $stdin = StringIO.new("first\nsecond\n")
    assert_equal "first\nsecond\n", read_all_input
  ensure
    $stdin = original
  end
end

require "control_flow_and_io"
