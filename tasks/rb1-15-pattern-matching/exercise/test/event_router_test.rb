# frozen_string_literal: true

require "minitest/autorun"
require "event_router"

# 確認課題の判定テスト（正本）。学習者が読んでよい。
class EventRouterTest < Minitest::Test
  def test_a_user_event_reports_the_name
    event = { type: "user", name: "Alice", age: 30 }

    assert_equal "user Alice", EventRouter.describe(event)
  end

  def test_a_user_event_under_twenty_is_reported_as_a_minor
    event = { type: "user", name: "Bob", age: 12 }

    assert_equal "minor user Bob", EventRouter.describe(event)
  end

  def test_a_nested_error_event_reports_the_inner_message
    event = { type: "error", detail: { message: "disk full", code: 28 } }

    assert_equal "error: disk full (28)", EventRouter.describe(event)
  end

  def test_a_pair_array_is_reported_as_a_measurement
    assert_equal "measure 3 m", EventRouter.describe([3, "m"])
  end

  def test_a_longer_array_reports_the_head_and_the_rest
    assert_equal "batch 1 + 2 more", EventRouter.describe([1, 2, 3])
  end

  def test_an_unknown_shape_is_reported_as_unknown
    assert_equal "unknown", EventRouter.describe({ foo: 1 })
    assert_equal "unknown", EventRouter.describe("plain string")
  end
end
