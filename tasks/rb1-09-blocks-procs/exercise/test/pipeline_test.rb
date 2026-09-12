# frozen_string_literal: true

require "minitest/autorun"
require "pipeline"

# 確認課題の判定テスト。読んでよい（これが実装の仕様そのものになっている）。
# 手順を Proc として持っても lambda として持っても、このテストは同じように通る。
class Rb109PipelineExerciseTest < Minitest::Test
  def test_a_pipeline_with_no_steps_returns_the_value_unchanged
    assert_equal "ab", Pipeline.new.call("ab")
    assert_equal 0, Pipeline.new.size
  end

  def test_steps_are_applied_in_the_order_they_were_added
    pipeline = Pipeline.new
    pipeline.add { |s| s.strip }
    pipeline.add { |s| s.upcase }
    assert_equal "AB", pipeline.call("  ab  ")
  end

  def test_the_order_of_the_steps_matters
    pipeline = Pipeline.new
    pipeline.add { |s| "#{s}!" }
    pipeline.add { |s| s.upcase }
    assert_equal "AB!", pipeline.call("ab")
  end

  def test_add_returns_the_pipeline_so_that_calls_can_be_chained
    pipeline = Pipeline.new.add { |n| n + 1 }.add { |n| n * 2 }
    assert_equal 6, pipeline.call(2)
    assert_equal 2, pipeline.size
  end

  def test_steps_work_on_any_kind_of_value
    pipeline = Pipeline.new.add { |list| list.map(&:to_s) }.add { |list| list.join("-") }
    assert_equal "1-2", pipeline.call([1, 2])
  end

  def test_the_same_pipeline_can_be_called_more_than_once
    pipeline = Pipeline.new.add { |n| n * 3 }
    assert_equal 6, pipeline.call(2)
    assert_equal 9, pipeline.call(3)
  end
end
