# frozen_string_literal: true

# 出力予測の対象コード（その 1）。
# 実行する前に、標準出力へ何が出るかを成果リポの predict/01.txt へ書き下す。
words = %w[ruby rails rack ruby rake rails ruby]

puts words.tally.map { |word, count| "#{word}=#{count}" }.join(" ")
puts words.uniq.sort_by { |word| word }.join(",")
puts words.group_by { |word| word.length }.map { |size, group| "#{size}:#{group.size}" }.join(" ")
puts words.map { |word| word.length }.reduce(0) { |total, size| total + size }
puts words.select { |word| word.start_with?("ra") }.join(",")
puts words.reject { |word| word.start_with?("ra") }.uniq.join(",")
