# frozen_string_literal: true

# 完成問題の雛形。成果リポの rb1-16-band/complete/lib/tally_report.rb へ置いて、
# 3 か所の「穴」を埋める。埋めるべき中身は各穴の上のコメントが決めている。
# 判定テストは読めない（判定のときだけ走る）。コメントに書いていない条件は問われない。
Entry = Data.define(:name, :team, :points)

module TallyReport
  # 行の形が違うときに投げる例外。
  class InvalidEntry < StandardError; end

  # "ada/blue/3" の形の 1 行を Entry にする。
  # 区切りは "/" で、項目は必ず 3 つ。3 つでなければ InvalidEntry を投げる
  # （メッセージは "invalid entry: " のうしろに元の行をそのまま付ける）。
  # points は Integer にする。name と team は文字列のまま。
  def self.parse(line)
    parts = line.split("/")
    raise InvalidEntry, "invalid entry: #{line}" unless parts.size == 3

    # 穴 1: parts から Entry を作って返す。
    raise NotImplementedError, "穴 1 を埋める"
  end

  # Entry の配列を受け取り、team をキー・その team の points の合計を値とする Hash を返す。
  # 出てこない team はキーにしない。空の配列を渡したら空の Hash を返す。
  def self.totals(entries)
    # 穴 2
    raise NotImplementedError, "穴 2 を埋める"
  end

  # totals が返した Hash を、"team=合計" の形の文字列の配列にする。
  # 並びは合計の降順。合計が同じときは team の辞書順（昇順）。
  def self.lines(totals)
    # 穴 3
    raise NotImplementedError, "穴 3 を埋める"
  end
end
