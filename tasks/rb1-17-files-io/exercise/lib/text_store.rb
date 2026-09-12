# frozen_string_literal: true

# 確認課題の雛形。成果リポの rb1-17-files-io/exercise/lib/text_store.rb へ置いて実装する。
# 判定テストは教材リポの exercise/test/text_store_test.rb（読んでよい）。
#
# 1 つのディレクトリの下に "<name>.txt" というファイルを置いて出し入れする小さな置き場。
module TextStore
  # dir が無ければ途中のディレクトリごと作り、dir/<name>.txt へ text を書く。書いたバイト数を返す。
  def self.save(_dir, _name, _text)
    raise NotImplementedError, "ここを実装する"
  end

  # dir/<name>.txt の中身を丸ごと返す。無ければ nil を返す。
  def self.load(_dir, _name)
    raise NotImplementedError, "ここを実装する"
  end

  # dir の中の .txt ファイルの名前（拡張子を除く）を、辞書順の配列で返す。
  def self.names(_dir)
    raise NotImplementedError, "ここを実装する"
  end

  # dir/<name>.txt の行数を返す。無ければ 0 を返す。
  def self.line_count(_dir, _name)
    raise NotImplementedError, "ここを実装する"
  end
end
