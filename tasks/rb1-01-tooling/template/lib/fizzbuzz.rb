# frozen_string_literal: true

# このファイルは教材が用意した雛形であり、AI が生成したコードである。
# 公式ドキュメントから取った手本ではないので、書き写しの対象にはしない。
# そのまま成果リポへ置いて動かすためのもの。
module FizzBuzz
  # 1 以上の整数を受け取り、規則に従った文字列を返す。
  def self.say(number)
    return "FizzBuzz" if (number % 15).zero?
    return "Fizz" if (number % 3).zero?
    return "Buzz" if (number % 5).zero?

    number.to_s
  end

  # 1 から last までの結果を配列で返す。
  def self.list(last)
    (1..last).map { |number| say(number) }
  end
end
