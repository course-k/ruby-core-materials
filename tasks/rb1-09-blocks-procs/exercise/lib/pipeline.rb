# frozen_string_literal: true

# 確認課題の雛形。成果リポの rb1-09-blocks-procs/exercise/lib/pipeline.rb へ置いて実装する。
# 何を満たせばよいかは、教材リポの exercise/test/pipeline_test.rb に書いてある。読んでよい。
#
# 受け取ったブロックを「そのまま Proc として持つ」か「自分で lambda に包んで持つ」かは
# 自分で選んでよい。判定はどちらでも通る。
class Pipeline
  def initialize
    raise NotImplementedError, "ここを実装する"
  end

  def add(&step)
    raise NotImplementedError, "ここを実装する"
  end

  def call(value)
    raise NotImplementedError, "ここを実装する"
  end

  def size
    raise NotImplementedError, "ここを実装する"
  end
end
