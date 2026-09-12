# frozen_string_literal: true

# 雛形（AI 生成物であり、書き写しの手本ではない）。そのまま成果リポへ置いて動かす。
module FizzBuzz
  def self.say(number)
    return "FizzBuzz" if (number % 15).zero?
    return "Fizz" if (number % 3).zero?
    return "Buzz" if (number % 5).zero?

    number.to_s
  end
end
