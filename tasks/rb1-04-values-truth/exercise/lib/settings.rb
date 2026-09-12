# frozen_string_literal: true

# 確認課題の雛形。成果リポの rb1-04-values-truth/exercise/lib/settings.rb へ置いて直す。
#
# このコードには欠陥がある。判定テスト（教材リポの exercise/test/settings_test.rb）を
# 走らせると落ちる。落ちたテストの名前と失敗メッセージから、欠陥の所在を自分で突き止めて直す。
module Settings
  DEFAULTS = { "retry" => true, "verbose" => true, "limit" => 10 }.freeze

  # 上書き設定 overrides にその key の指定があればその値を返し、無ければ既定値を返す。
  def self.fetch(overrides, key)
    value = overrides[key]
    return DEFAULTS[key] if !value

    value
  end
end
