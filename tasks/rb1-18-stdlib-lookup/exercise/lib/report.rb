# frozen_string_literal: true

# 確認課題の雛形。成果リポの rb1-18-stdlib-lookup/exercise/lib/report.rb へ置いて実装する。
# 判定テストは教材リポの exercise/test/report_test.rb（読んでよい）。
#
# 使うメソッドは README が名指ししている。引数と戻り値は公式ドキュメントを自分で引いて読む。
module Report
  # 行（Symbol キーの Hash の配列）を、人が読める形に整形した JSON 文字列にする。
  def self.to_json(_rows)
    raise NotImplementedError, "ここを実装する"
  end

  # 行を CSV 文字列にする。1 行目に列名の行を置く。列名は最初の行のキーから取る。
  def self.to_csv(_rows)
    raise NotImplementedError, "ここを実装する"
  end

  # Time を "YYYY-MM-DD HH:MM:SS" の形の文字列にする。
  def self.stamp(_time)
    raise NotImplementedError, "ここを実装する"
  end
end
