# frozen_string_literal: true

# 確認課題の雛形。成果リポの rb1-15-pattern-matching/exercise/lib/event_router.rb へ
# 置いて実装する。判定テストは教材リポの exercise/test/event_router_test.rb（読んでよい）。
#
# 受け取るのは、形の違う「できごと」を表す Hash か Array。case / in で形を見分けて
# 1 行の説明文を返す。分岐の条件は判定テストが決めているので、そこを読んで実装する。
module EventRouter
  def self.describe(_event)
    raise NotImplementedError, "ここを実装する"
  end
end
