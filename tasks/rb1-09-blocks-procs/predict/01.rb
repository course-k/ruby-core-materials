# frozen_string_literal: true

# 出力予測の対象コード。
# 実行する前に、標準出力へ何が出るかを成果リポの predict/01.txt へ書き下す。

def collect_with_next
  kept = []
  [1, 2, 3, 4].each do |n|
    next if n.even?

    kept << n
  end
  kept
end

def stop_with_break
  [1, 2, 3, 4].each do |n|
    break n * 10 if n == 3
  end
end

def leave_with_return
  [1, 2, 3, 4].each do |n|
    return n * 100 if n == 3
  end
  :never_reached
end

def return_inside_a_lambda
  result = -> { return :from_lambda }.call
  [result, :the_method_kept_going]
end

mapped = [1, 2, 3, 4].map do |n|
  next 0 if n.odd?

  n
end

puts collect_with_next.join(",")
puts stop_with_break
puts leave_with_return
puts return_inside_a_lambda.join(",")
puts mapped.join(",")
puts [1, 2, 3, 4].each { |n| n }.join(",")
