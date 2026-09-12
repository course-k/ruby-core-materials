# frozen_string_literal: true

# 確認課題の雛形。成果リポの rb1-07-collections-enumerable/exercise/lib/feed_digest.rb へ置いて実装する。
# 判定テストは教材リポの exercise/test/feed_digest_test.rb（読んでよい）。
#
# 集めた記事の一覧を正規化・集計する小さな部品。
# 記事 1 件は次の形のハッシュで渡される。
#
#   { title: " Ruby 4.0 released ", source: "Ruby Weekly", tag: "Release", words: 320 }
#
# どのメソッドも、渡された配列とその中のハッシュを書き換えてはいけない。
module FeedDigest
  # 各記事の title の前後の空白を落とし、tag を小文字にした新しい配列を返す。
  # 他のキーはそのまま残す。
  def self.normalize(_entries)
    raise NotImplementedError, "ここを実装する"
  end

  # source が name のものだけを、渡された順のまま返す。
  def self.from_source(_entries, _name)
    raise NotImplementedError, "ここを実装する"
  end

  # 登場する source を重複なく、辞書順の配列で返す。
  def self.sources(_entries)
    raise NotImplementedError, "ここを実装する"
  end

  # source をキー、その source の記事の配列を値とするハッシュを返す。
  def self.by_source(_entries)
    raise NotImplementedError, "ここを実装する"
  end

  # tag をキー、その tag の件数を値とするハッシュを返す。
  def self.tag_counts(_entries)
    raise NotImplementedError, "ここを実装する"
  end

  # words の合計を返す。記事が 0 件なら 0 を返す。
  def self.total_words(_entries)
    raise NotImplementedError, "ここを実装する"
  end
end
