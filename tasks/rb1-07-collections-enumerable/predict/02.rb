# frozen_string_literal: true

# 出力予測の対象コード（その 2）。
# 実行する前に、標準出力へ何が出るかを成果リポの predict/02.txt へ書き下す。
scores = { "ada" => 90, "grace" => 72, "linus" => 90, "matz" => 58 }

puts scores.select { |_name, score| score >= 70 }.map { |name, _score| name }.join(",")
puts scores.sort_by { |name, score| [-score, name] }.map { |name, score| "#{name}=#{score}" }.join(" ")
puts scores.map { |_name, score| score }.reduce(0) { |total, score| total + score }
puts scores.each_with_object([]) { |(name, score), list| list.push("#{name}:#{score}") }.size
puts scores.reject { |_name, score| score >= 70 }.map { |name, score| "#{name}=#{score}" }.join(",")
puts scores.map { |_name, score| score }.tally.map { |score, count| "#{score}x#{count}" }.join(" ")
