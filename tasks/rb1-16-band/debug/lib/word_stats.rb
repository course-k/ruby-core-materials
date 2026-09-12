# frozen_string_literal: true

# デバッグ課題。この 4 つのメソッドのうちいくつかが、意図した動きをしていない。
# 成果リポの rb1-16-band/debug/lib/word_stats.rb へ置き、
# 判定テスト（rb1-16-band/debug/test/word_stats_test.rb、読んでよい）が全部通るように直す。
#
# 各メソッドの意図はすぐ上のコメントが正。コメントの側は直さない。
module WordStats
  # テキストを単語の配列にする。単語は空白で区切られたかたまりで、
  # 大文字と小文字の違いは無視する（すべて小文字にそろえる）。
  def self.words(text)
    text.split(" ")
  end

  # 単語ごとの出現回数を Hash で返す。
  def self.counts(text)
    words(text).each_with_object({}) { |word, acc| acc[word] = 1 }
  end

  # いちばん多く出た単語を返す。同数のときは辞書順で先のものを返す。
  # 単語が 1 つも無ければ nil を返す。
  def self.most_common(text)
    counts(text).max_by { |_word, count| count }&.first
  end

  # 単語の平均の長さを、小数第 2 位までに丸めて返す。単語が 1 つも無ければ 0.0 を返す。
  def self.average_length(text)
    found = words(text)
    return 0.0 if found.empty?

    (found.sum(&:length) / found.size).round(2)
  end
end
