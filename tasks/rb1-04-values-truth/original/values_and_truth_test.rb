# frozen_string_literal: true

# 手本の原本 — 値と真偽の規則。
#
# 底本と、行の文言に現れる識別子が実在する節:
#   nil と false だけが偽であること
#     https://docs.ruby-lang.org/en/4.0/syntax/literals_rdoc.html （Boolean and Nil Literals）
#   すべての式が値を持つこと（if の結果を代入できる）/ 0 が真であること
#     https://www.ruby-lang.org/en/documentation/ruby-from-other-languages/
#     （Everything has a value / The universal truth）
#   if / else / elsif / case / when と、その結果が値になること /
#   case が === で照合すること
#     https://docs.ruby-lang.org/en/4.0/syntax/control_expressions_rdoc.html
#   puts の戻り値が nil であること
#     https://docs.ruby-lang.org/en/4.0/Kernel.html#method-i-puts
#     https://www.ruby-lang.org/en/documentation/quickstart/
#   nil? / ===
#     https://docs.ruby-lang.org/en/4.0/Object.html#method-i-nil-3F
#     https://docs.ruby-lang.org/en/4.0/Object.html#method-i-3D-3D-3D
#   nil と true がオブジェクトであること
#     https://docs.ruby-lang.org/en/4.0/NilClass.html
#     https://docs.ruby-lang.org/en/4.0/TrueClass.html
#   Module#=== がクラスの所属を見ること
#     https://docs.ruby-lang.org/en/4.0/Module.html#method-i-3D-3D-3D
#
# 教材がこの手本に加えた編集は commentary.md の「原典との差分」に書いてある。

require "minitest/autorun"

class ValuesAndTruthTest < Minitest::Test
  def test_every_expression_has_a_value
    x = 10
    y = 11
    z = if x < y
          true
        else
          false
        end
    assert_equal true, z
  end

  def test_zero_is_a_true_value_in_ruby
    assert_output("0 is true\n") do
      if 0
        puts "0 is true"
      else
        puts "0 is false"
      end
    end
  end

  def test_only_nil_and_false_are_false_values
    values = [nil, false, 0, "", [], {}, "0"]
    assert_equal [nil, false], values.reject { |value| value }
  end

  def test_nil_and_true_are_objects
    assert_nil nil
    assert nil.nil?
    assert_equal NilClass, nil.class
    assert_equal TrueClass, true.class
  end

  def test_puts_writes_to_stdout_and_returns_nil
    result = :not_yet
    assert_output("Hello World\n") { result = puts "Hello World" }
    assert_nil result
  end

  def test_a_case_expression_matches_with_triple_equals
    assert_output("the string starts with one\n") do
      case "12345"
      when /^1/
        puts "the string starts with one"
      else
        puts "I don't know what the string starts with"
      end
    end
  end

  def test_triple_equals_is_not_equality
    assert(/^1/ === "12345")
    assert(String === "12345")
    refute(Integer === "12345")
    refute_equal("12345", /^1/)
  end

  def test_a_case_expression_has_a_value_too
    a = 1
    label = case a
            when 1, 2 then "a is one or two"
            when 3 then "a is three"
            else "I don't know what a is"
            end
    assert_equal "a is one or two", label
  end
end
