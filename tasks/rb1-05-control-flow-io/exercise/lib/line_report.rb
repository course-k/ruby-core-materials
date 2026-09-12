# frozen_string_literal: true

# 確認課題の雛形。成果リポの rb1-05-control-flow-io/exercise/lib/line_report.rb へ置いて直す。
#
# このコードには欠陥がある。判定テスト（教材リポの exercise/test/line_report_test.rb）を
# 走らせると落ちる。落ちたテストの名前と失敗メッセージから、欠陥の所在を自分で突き止めて直す。
module LineReport
  # text の各行を検査する。
  #   ・空行（空白だけの行を含む）は不正行とし、"line <行番号>: empty" の形で報告する。
  #   ・正常行は前後の空白を落として標準出力へ出す。
  #   ・戻り値は終了コード。不正行が 1 行でもあれば 1、無ければ 0。
  def self.run(text)
    status = 0
    text.each_line.with_index(1) do |line, number|
      if line.strip.empty?
        puts "line #{number}: empty"
        status = 0
      else
        puts line.strip
      end
    end
    status
  end
end
