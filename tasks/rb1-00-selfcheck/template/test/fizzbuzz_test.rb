# frozen_string_literal: true

require "minitest/autorun"
require "fizzbuzz"

class FizzBuzzTest < Minitest::Test
  def test_plain_number
    assert_equal "1", FizzBuzz.say(1)
  end

  def test_fizz
    assert_equal "Fizz", FizzBuzz.say(3)
  end

  def test_buzz
    assert_equal "Buzz", FizzBuzz.say(5)
  end

  def test_fizzbuzz
    assert_equal "FizzBuzz", FizzBuzz.say(15)
  end
end
