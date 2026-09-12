# frozen_string_literal: true

require "minitest/autorun"
require "shout"

# 確認課題の判定テスト（正本）。封緘しない——学習者が読んでよい（根幹 §3.1）。
class ShoutTest < Minitest::Test
  def test_upcases_and_adds_bang
    assert_equal "ADA!", Shout.call("ada")
  end

  def test_strips_surrounding_spaces
    assert_equal "GRACE!", Shout.call("  grace  ")
  end
end
