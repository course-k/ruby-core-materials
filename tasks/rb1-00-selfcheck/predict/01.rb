# frozen_string_literal: true

# 出力予測の対象コード。学習者は実行する前に標準出力を predict/01.txt へ書き下す。
numbers = [3, 1, 2]
puts numbers.sort.inspect
puts numbers.map { |n| n * 2 }.join(",")
puts numbers.sum
