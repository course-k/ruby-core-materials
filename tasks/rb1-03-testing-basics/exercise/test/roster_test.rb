# frozen_string_literal: true

require "minitest/autorun"
require "roster"

# 確認課題の判定テスト。読んでよい（これが実装の仕様そのものになっている）。
class Rb103RosterExerciseTest < Minitest::Test
  def setup
    @roster = Roster.new(["ada", "grace", "linus"])
  end

  def test_find_returns_the_matching_name
    assert_equal "grace", @roster.find("grace")
  end

  def test_find_returns_nil_when_the_name_is_absent
    assert_nil @roster.find("matz")
  end

  def test_find_raises_argument_error_for_an_empty_name
    error = assert_raises(ArgumentError) do
      @roster.find("")
    end
    assert_equal "name must not be empty", error.message
  end

  def test_size_counts_the_names
    assert_equal 3, @roster.size
    refute @roster.size.zero?
  end
end
