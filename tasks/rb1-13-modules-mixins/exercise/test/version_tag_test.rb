# frozen_string_literal: true

require "minitest/autorun"
require "version_tag"

# 確認課題の判定テスト（正本）。学習者が読んでよい。
class VersionTagTest < Minitest::Test
  def setup
    @v1 = VersionTag.new(1, 2, 3)
    @v2 = VersionTag.new(1, 10, 0)
    @v3 = VersionTag.new(2, 0, 0)
  end

  def test_comparable_is_included
    assert_includes VersionTag.ancestors, Comparable
  end

  def test_older_version_is_less_than_newer_one
    assert_operator @v1, :<, @v2
    assert_operator @v2, :<, @v3
    assert_operator @v3, :>, @v1
  end

  def test_same_numbers_compare_equal
    assert_equal VersionTag.new(1, 2, 3), @v1
  end

  def test_sort_uses_the_spaceship_operator
    assert_equal [@v1, @v2, @v3], [@v3, @v1, @v2].sort
  end

  def test_between_comes_from_comparable
    assert @v2.between?(@v1, @v3)
    refute @v1.between?(@v2, @v3)
  end
end
