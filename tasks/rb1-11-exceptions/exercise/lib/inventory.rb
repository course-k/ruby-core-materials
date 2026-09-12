# frozen_string_literal: true

# 確認課題の雛形。成果リポの rb1-11-exceptions/exercise/lib/inventory.rb へ置いて実装する。
# 何を満たせばよいかは、教材リポの exercise/test/inventory_test.rb に書いてある。読んでよい。
class Inventory
  def initialize(stock)
    @stock = stock
  end

  # 品目 name を count 個取り出し、残りの個数を返す。
  def take(name, count)
    raise NotImplementedError, "ここを実装する"
  end
end
