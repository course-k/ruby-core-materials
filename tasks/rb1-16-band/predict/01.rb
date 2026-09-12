# frozen_string_literal: true

# 出力予測の対象コード。実行する前に、標準出力に出る行を成果リポの
# rb1-16-band/predict/01.txt へ書き下す。
Book = Struct.new(:title, :pages, :tag)

books = [
  Book.new("Eloquent", 240, :ruby),
  Book.new("Poignant", 180, :ruby),
  Book.new("Practical", 240, :ops),
  Book.new("Pickaxe", 900, :ruby)
]

puts books.map(&:pages).reduce(0) { |total, pages| total + pages }
puts books.group_by(&:tag).map { |tag, group| "#{tag}:#{group.size}" }.join(" ")
puts books.select { |b| b.pages > 200 }.map(&:title).sort.join(",")
puts books.map(&:pages).tally.map { |pages, count| "#{pages}x#{count}" }.join(" ")

by_tag = books.each_with_object({}) { |b, acc| acc[b.tag] = (acc[b.tag] || 0) + b.pages }
puts by_tag.map { |tag, pages| "#{tag}=#{pages}" }.join(" ")

puts books.sort_by(&:pages)[0].title
puts books.sort_by { |b| [-b.pages, b.title] }[0].title
puts [books.select { |b| b.tag == :ruby }.size, books.reject { |b| b.tag == :ruby }.size].join(",")

def describe(book)
  return "long" if book.pages > 500

  book.pages > 200 ? "medium" : "short"
end

puts books.map { |b| describe(b) }.uniq.join(",")
puts books.reduce(0) { |acc, b| acc + b.title.length }
