# frozen_string_literal: true

# 手本の原本 — 制御構造と、スクリプトの入出力。
#
# 底本と、行の文言に現れる識別子が実在する節:
#   if / elsif / else / unless / 後置 if と後置 unless / case と when / then /
#   while / until / break / next
#     https://docs.ruby-lang.org/en/4.0/syntax/control_expressions_rdoc.html
#   && || と and or の優先順位の違い
#     https://docs.ruby-lang.org/en/4.0/syntax/precedence_rdoc.html
#   &. （safe navigation operator）
#     https://docs.ruby-lang.org/en/4.0/syntax/calling_methods_rdoc.html
#   puts / warn / exit と SystemExit
#     https://docs.ruby-lang.org/en/4.0/Kernel.html#method-i-puts
#     https://docs.ruby-lang.org/en/4.0/Kernel.html#method-i-warn
#     https://docs.ruby-lang.org/en/4.0/Kernel.html#method-i-exit
#   ARGV
#     https://docs.ruby-lang.org/en/4.0/Object.html#ARGV
#   SystemExit#status（exit に渡した値が載る）
#     https://docs.ruby-lang.org/en/4.0/SystemExit.html#method-i-status
#   $stdin と read
#     https://docs.ruby-lang.org/en/4.0/IO.html
#   StringIO（テストの中で $stdin を差し替えるための入れ物。教材が足した道具）
#     https://docs.ruby-lang.org/en/4.0/StringIO.html
#   begin-less な rescue（メソッド本体がそのまま例外ハンドラになる形）
#     https://docs.ruby-lang.org/en/4.0/language/exceptions_md.html
#
# 教材がこの手本に加えた編集は commentary.md の「原典との差分」に書いてある。

require "minitest/autorun"
require "stringio"

REGEX = /(ruby) is (\w+)/i

class ControlFlowAndIoTest < Minitest::Test
  def test_if_elsif_else_runs_the_first_matching_branch
    a = 1
    label = if a == 0
              "a is zero"
            elsif a == 1
              "a is one"
            else
              "a is some other value"
            end
    assert_equal "a is one", label
  end

  def test_unless_is_the_opposite_of_if
    label = unless true
              "the value is false"
            else
              "the value is true"
            end
    assert_equal "the value is true", label
  end

  def test_a_case_without_a_subject_works_like_if_elsif
    a = 2
    label = case
            when a == 1, a == 2 then "a is one or two"
            when a == 3 then "a is three"
            else "I don't know what a is"
            end
    assert_equal "a is one or two", label
  end

  def test_modifier_if_puts_the_test_on_the_right
    a = 0
    a += 1 if a.zero?
    assert_equal 1, a
  end

  def test_while_and_until_loops
    a = 0
    while a < 10
      a += 1
    end
    assert_equal 10, a

    b = 0
    b += 1 until b > 10
    assert_equal 11, b
  end

  def test_and_binds_more_loosely_than_assignment
    a = true && false
    b = true and false
    assert_equal [false, true], [a, b]
  end

  def test_safe_navigation_skips_only_the_next_call
    assert_nil "Python is fascinating!".match(REGEX)&.values_at(1, 2)&.join(" - ")
    assert_raises(NoMethodError) do
      "Python is fascinating!".match(REGEX)&.values_at(1, 2).join(" - ")
    end
  end

  def test_warn_writes_to_standard_error
    assert_output("", "warning 1\nwarning 2\n") { warn("warning 1", "warning 2") }
  end

  def test_exit_carries_a_status_for_the_operating_system
    exit(1)
  rescue SystemExit => e
    assert_equal 1, e.status
  end

  def test_argv_holds_the_arguments_given_on_the_command_line
    ARGV.replace(["report.csv", "--verbose"])
    assert_equal "report.csv", ARGV[0]
  ensure
    ARGV.clear
  end

  def test_stdin_read_returns_the_whole_input_at_once
    original = $stdin
    $stdin = StringIO.new("first\nsecond\n")
    assert_equal "first\nsecond\n", $stdin.read
  ensure
    $stdin = original
  end
end
