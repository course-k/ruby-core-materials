# frozen_string_literal: true

# このファイルも教材が用意した雛形（AI 生成物）である。書き写しの対象ではない。
require "minitest/autorun"
require "fizzbuzz"

class FizzBuzzTemplateTest < Minitest::Test
  def test_plain_number_is_returned_as_a_string
    assert_equal "1", FizzBuzz.say(1)
    assert_equal "7", FizzBuzz.say(7)
  end

  def test_multiples_of_three_are_fizz
    assert_equal "Fizz", FizzBuzz.say(3)
    assert_equal "Fizz", FizzBuzz.say(9)
  end

  def test_multiples_of_five_are_buzz
    assert_equal "Buzz", FizzBuzz.say(5)
    assert_equal "Buzz", FizzBuzz.say(20)
  end

  def test_multiples_of_fifteen_are_fizzbuzz
    assert_equal "FizzBuzz", FizzBuzz.say(15)
    assert_equal "FizzBuzz", FizzBuzz.say(30)
  end

  def test_list_returns_every_result_in_order
    assert_equal %w[1 2 Fizz 4 Buzz], FizzBuzz.list(5)
  end
end
