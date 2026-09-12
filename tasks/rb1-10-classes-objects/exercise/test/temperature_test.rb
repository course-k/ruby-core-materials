# frozen_string_literal: true

require "minitest/autorun"
require "temperature"

# 確認課題の判定テスト。読んでよい（これが実装の仕様そのものになっている）。
class Rb110TemperatureExerciseTest < Minitest::Test
  def test_degrees_can_be_read_but_not_written
    temperature = Temperature.new(20)
    assert_equal 20, temperature.degrees
    refute temperature.respond_to?(:degrees=)
  end

  def test_from_fahrenheit_is_a_class_method_that_builds_an_instance
    temperature = Temperature.from_fahrenheit(212)
    assert_instance_of Temperature, temperature
    assert_in_delta 100.0, temperature.degrees
    assert_in_delta 0.0, Temperature.from_fahrenheit(32).degrees
  end

  def test_to_s_puts_the_unit_after_the_number
    assert_equal "20C", Temperature.new(20).to_s
    assert_equal "20C", "#{Temperature.new(20)}"
  end

  def test_warmer_than_compares_two_temperatures
    assert Temperature.new(30).warmer_than?(Temperature.new(20))
    refute Temperature.new(20).warmer_than?(Temperature.new(30))
    refute Temperature.new(20).warmer_than?(Temperature.new(20))
  end

  def test_the_unit_is_a_private_method
    assert_raises(NoMethodError) { Temperature.new(20).unit }
  end
end
