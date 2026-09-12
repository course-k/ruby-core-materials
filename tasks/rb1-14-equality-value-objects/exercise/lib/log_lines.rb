# frozen_string_literal: true

# 確認課題の雛形。成果リポの rb1-14-equality-value-objects/exercise/lib/log_lines.rb へ
# 置いて実装する。判定テストは教材リポの exercise/test/log_lines_test.rb（読んでよい）。
#
# 行の書式は "2026-01-01T09:00:00 INFO サーバを起動した" のように
# 「時刻」「レベル」「メッセージ」を半角空白で区切ったもの。
#
# 値オブジェクトの型（Data.define に渡す項目）は自分で決める。
# 「何をもって同じ行とみなすか」がこの課題で自分が決めるところで、判定はその選択に中立にしてある。
module LogLines
  # 1 行を値オブジェクトへ変換する。level と message は必ず読めるようにする。
  def self.parse(_line)
    raise NotImplementedError, "ここを実装する"
  end

  # 行の配列を値オブジェクトの配列へ変換し、重複を取り除く。最初に現れた順序を保つ。
  def self.unique(_lines)
    raise NotImplementedError, "ここを実装する"
  end
end
