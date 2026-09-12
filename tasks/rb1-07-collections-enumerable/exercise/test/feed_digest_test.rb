# frozen_string_literal: true

require "minitest/autorun"
require "feed_digest"

# 確認課題の判定テスト（正本）。学習者が読んでよい。
class FeedDigestTest < Minitest::Test
  def entries
    [
      { title: " Ruby 4.0 released ", source: "Ruby Weekly", tag: "Release", words: 320 },
      { title: "Pattern matching tips", source: "Ruby Weekly", tag: "Tips", words: 540 },
      { title: "  Bundler 3 preview", source: "The Changelog", tag: "release", words: 180 }
    ]
  end

  def test_normalize_trims_titles_and_downcases_tags
    result = FeedDigest.normalize(entries)

    assert_equal ["Ruby 4.0 released", "Pattern matching tips", "Bundler 3 preview"],
                 result.map { |entry| entry[:title] }
    assert_equal %w[release tips release], result.map { |entry| entry[:tag] }
    assert_equal [320, 540, 180], result.map { |entry| entry[:words] }
  end

  def test_normalize_does_not_change_what_it_was_given
    given = entries
    FeedDigest.normalize(given)

    assert_equal " Ruby 4.0 released ", given.first[:title]
    assert_equal "Release", given.first[:tag]
  end

  def test_from_source_keeps_only_that_source_in_order
    result = FeedDigest.from_source(entries, "Ruby Weekly")

    assert_equal [" Ruby 4.0 released ", "Pattern matching tips"],
                 result.map { |entry| entry[:title] }
    assert_empty FeedDigest.from_source(entries, "Nobody")
  end

  def test_sources_are_unique_and_sorted
    assert_equal ["Ruby Weekly", "The Changelog"], FeedDigest.sources(entries)
    assert_empty FeedDigest.sources([])
  end

  def test_by_source_groups_the_entries
    grouped = FeedDigest.by_source(entries)

    assert_equal ["Ruby Weekly", "The Changelog"], grouped.keys.sort
    assert_equal 2, grouped["Ruby Weekly"].size
    assert_equal "  Bundler 3 preview", grouped["The Changelog"].first[:title]
  end

  def test_tag_counts_counts_each_tag_as_it_is
    assert_equal({ "Release" => 1, "Tips" => 1, "release" => 1 }, FeedDigest.tag_counts(entries))
    assert_equal({ "release" => 2, "tips" => 1 },
                 FeedDigest.tag_counts(FeedDigest.normalize(entries)))
  end

  def test_total_words_adds_them_up
    assert_equal 1040, FeedDigest.total_words(entries)
    assert_equal 0, FeedDigest.total_words([])
  end
end
