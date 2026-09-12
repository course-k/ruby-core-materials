# frozen_string_literal: true

# 確認課題の雛形（ライブラリ側）。成果リポの
# rb1-19-optparse-executable/exercise/lib/counter.rb へ置いて実装する。
module Counter
  # テキストの行数を返す。末尾に改行が無い最後の行も 1 行と数える。
  def self.lines(_text)
    raise NotImplementedError, "ここを実装する"
  end

  # テキストの単語数を返す。単語は空白（改行を含む）で区切られたかたまり。
  def self.words(_text)
    raise NotImplementedError, "ここを実装する"
  end
end
