# frozen_string_literal: true

require "minitest/autorun"
require "word_stats"

# デバッグ課題の判定テスト（正本）。学習者が読んでよい。
class WordStatsTest < Minitest::Test
  TEXT = "Ruby ruby rails RUBY rails go on"

  def test_words_are_lowercased
    assert_equal %w[ruby ruby rails ruby rails go on], WordStats.words(TEXT)
    assert_empty WordStats.words("   ")
  end

  def test_counts_counts_every_occurrence
    assert_equal({ "ruby" => 3, "rails" => 2, "go" => 1, "on" => 1 }, WordStats.counts(TEXT))
  end

  def test_most_common_returns_the_top_word
    assert_equal "ruby", WordStats.most_common(TEXT)
    assert_nil WordStats.most_common("")
  end

  def test_most_common_breaks_ties_in_dictionary_order
    assert_equal "alpha", WordStats.most_common("beta alpha beta alpha gamma")
  end

  def test_average_length_is_a_rounded_float
    assert_in_delta 3.71, WordStats.average_length(TEXT), 0.001
    assert_in_delta 0.0, WordStats.average_length(""), 0.001
  end
end
