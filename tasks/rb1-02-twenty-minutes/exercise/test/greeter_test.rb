# frozen_string_literal: true

require "minitest/autorun"
require "greeter"

# 確認課題の判定テスト。読んでよい（これが「どう変えるか」の指示そのものになっている）。
class Rb102GreeterExerciseTest < Minitest::Test
  def test_keeps_greeting_the_given_name
    assert_equal "Hi Pat!", Greeter.new("Pat").say_hi
  end

  def test_keeps_the_default_name
    assert_equal "Hi World!", Greeter.new.say_hi
  end

  def test_says_only_dots_when_the_name_is_nil
    assert_equal "...", Greeter.new(nil).say_hi
  end

  def test_still_reflects_a_changed_name
    greeter = Greeter.new("Andy")
    greeter.name = "Betty"
    assert_equal "Hi Betty!", greeter.say_hi
  end
end
