# frozen_string_literal: true

require "minitest/autorun"
require "settings"

# 確認課題の判定テスト。読んでよい。
# このテストは仕様を書いたものであり、欠陥の所在は書いていない。
class Rb104SettingsExerciseTest < Minitest::Test
  def test_returns_the_override_when_it_is_given
    assert_equal 5, Settings.fetch({ "limit" => 5 }, "limit")
  end

  def test_returns_the_default_when_the_key_is_absent
    assert_equal 10, Settings.fetch({}, "limit")
    assert_equal true, Settings.fetch({}, "retry")
  end

  def test_keeps_an_override_of_false
    assert_equal false, Settings.fetch({ "retry" => false }, "retry")
  end

  def test_keeps_an_override_of_zero
    assert_equal 0, Settings.fetch({ "limit" => 0 }, "limit")
  end

  def test_keeps_an_override_of_an_empty_string
    assert_equal "", Settings.fetch({ "verbose" => "" }, "verbose")
  end
end
