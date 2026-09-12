# frozen_string_literal: true

# 手本の原本 — Array / Hash / Range と Enumerable。
#
# 底本と、行の文言に現れる識別子が実在する節:
#   配列リテラル / ハッシュリテラルと Symbol キー記法 / 値の省略記法 { x:, y: } /
#   範囲リテラル .. と ...
#     https://docs.ruby-lang.org/en/4.0/syntax/literals_rdoc.html
#   Array のメソッド全般
#     https://docs.ruby-lang.org/en/4.0/Array.html
#   Hash のメソッド全般（任意のオブジェクトをキーにできること）
#     https://docs.ruby-lang.org/en/4.0/Hash.html
#   each / map / select / reject / inject（reduce）/ each_with_object /
#   group_by / tally / sort_by / uniq
#     https://docs.ruby-lang.org/en/4.0/Enumerable.html
#   each がレシーバを返すこと
#     https://docs.ruby-lang.org/en/4.0/Array.html#method-i-each
#
# 教材がこの手本に加えた編集は commentary.md の「原典との差分」に書いてある。

def literal_with_expressions
  [1, 1 + 1, 1 + 2]
end

def nested_literal
  [1, [1 + 1, [1 + 2]]]
end

def inclusive_range
  (1..2).to_a
end

def exclusive_range
  (1...2).to_a
end

def omitted_values
  x = 100
  y = 200
  { x:, y: }
end

def any_key_hash
  { [1, 2] => "pair", :sym => "symbol", "str" => "string" }
end

def each_collects(values)
  seen = []
  result = values.each { |value| seen << value }
  [seen, result]
end

def squares(range)
  range.map { |i| i * i }
end

def doubled_values(hash)
  hash.map { |_key, value| value * 2 }
end

def multiples_of_three(range)
  range.select { |element| element % 3 == 0 }
end

def not_doubled_evens(range)
  range.reject { |i| i * 2 if i.even? }
end

def product_with_inject(values)
  values.inject(1) do |result, next_value|
    result * next_value
  end
end

def product_with_reduce(values)
  values.reduce { |result, next_value| result * next_value }
end

def squares_into_array(range)
  range.each_with_object([]) { |i, a| a.push(i**2) }
end

def inverted(hash)
  hash.each_with_object({}) { |(k, v), h| h[v] = k }
end

def grouped_by_remainder(range)
  range.group_by { |i| i % 3 }
end

def counted(values)
  values.tally
end

def by_length(values)
  values.sort_by { |s| s.size }
end

def by_length_descending(values)
  values.sort_by { |s| -s.size }
end

def unique(values)
  values.uniq
end

def unique_by_evenness(values)
  values.uniq { |i| i.even? ? i : 0 }
end
