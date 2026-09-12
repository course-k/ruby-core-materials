# frozen_string_literal: true

# 手本の原本 — minitest の README（Ruby 4.0.6 同梱版 v6.0.0）の "Unit tests" 節と、
# 同じタグの lib/minitest/assertions.rb に載っている用例。
#
# 底本と、行の文言に現れる識別子が実在する節:
#   require "minitest/autorun" / Minitest::Test / setup / test_ で始まるメソッド名 /
#   assert_equal / refute_match / skip / Meme・i_can_has_cheezburger?・will_it_blend?
#     https://github.com/minitest/minitest/blob/v6.0.0/README.rdoc
#   assert / assert_equal / assert_nil / assert_raises / refute の定義と用例
#     https://github.com/minitest/minitest/blob/v6.0.0/lib/minitest/assertions.rb
#   StandardError を継承する自作の例外クラス
#     https://docs.ruby-lang.org/en/4.0/language/exceptions_md.html
#   minitest が Ruby に同梱される gem であること
#     https://docs.ruby-lang.org/en/4.0/standard_library_md.html
#
# 教材がこの手本に加えた編集は commentary.md の「原典との差分」に書いてある。

require "minitest/autorun"

class Meme
  def i_can_has_cheezburger?
    "OHAI!"
  end

  def will_it_blend?
    "YES!"
  end
end

class CustomError < StandardError
end

class TestMeme < Minitest::Test
  def setup
    @meme = Meme.new
  end

  def test_that_kitty_can_eat
    assert_equal "OHAI!", @meme.i_can_has_cheezburger?
  end

  def test_that_it_will_not_blend
    refute_match(/^no/i, @meme.will_it_blend?)
  end

  def test_that_will_be_skipped
    skip "test this later"
  end

  def test_assert_and_refute_are_about_truthiness
    assert @meme.respond_to?(:will_it_blend?)
    refute @meme.respond_to?(:will_it_fold?)
  end

  def test_assert_nil_says_what_it_means
    assert_nil @meme.instance_variable_get(:@not_set_yet)
  end

  def test_assert_raises_returns_the_exception
    error = assert_raises(CustomError) do
      raise CustomError, "This is really bad"
    end
    assert_equal "This is really bad", error.message
  end
end
