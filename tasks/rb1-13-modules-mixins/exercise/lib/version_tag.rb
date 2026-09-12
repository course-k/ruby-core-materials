# frozen_string_literal: true

# 確認課題の雛形。成果リポの rb1-13-modules-mixins/exercise/lib/version_tag.rb へ
# 置いて実装する。判定テストは教材リポの exercise/test/version_tag_test.rb（読んでよい）。
class VersionTag
  def initialize(major, minor, patch)
    @major = major
    @minor = minor
    @patch = patch
  end

  attr_reader :major, :minor, :patch

  def <=>(_other)
    raise NotImplementedError, "ここを実装する"
  end
end
