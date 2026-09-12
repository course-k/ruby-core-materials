# frozen_string_literal: true

require "minitest/autorun"
require "stringio"

# 写しの照合テスト（教材が配る。読んでよい。写さない）。
# 学習者の写し twenty_minutes.rb を 1 度だけ読み込み、表示された行を手本の節ごとに確かめる。
# 1 行につき 1 つの assert なので、落ちたときは「どの節の・何行目が・何を出すべきか」が
# Expected / Actual で出る。OUTPUT[n] は表示の n + 1 行目。
class Rb102TwentyMinutesCopyTest < Minitest::Test
  OUTPUT = begin
    saved = $stdout
    $stdout = StringIO.new
    require "twenty_minutes"
    $stdout.string.lines.map(&:chomp)
  ensure
    $stdout = saved
  end

  def test_part1_expressions_evaluated_in_irb
    assert_equal "Hello World", OUTPUT[0]
    assert_equal "5", OUTPUT[1]
    assert_equal "6", OUTPUT[2]
    assert_equal "9", OUTPUT[3]
    assert_equal "3.0", OUTPUT[4]
    assert_equal "5.0", OUTPUT[5]
  end

  def test_part2_hi_capitalizes_the_name_and_falls_back_to_world
    assert_equal "Hello Chris!", OUTPUT[6]
    assert_equal "Hello World!", OUTPUT[7]
  end

  def test_part2_greeter_greets_with_the_name_it_was_built_with
    assert_equal "Hi Pat!", OUTPUT[8]
    assert_equal "Bye Pat, come back soon.", OUTPUT[9]
  end

  def test_part3_respond_to_and_attr_accessor
    assert_equal "true", OUTPUT[10]
    assert_equal "true", OUTPUT[11]
    assert_equal '"Betty"', OUTPUT[12]
    assert_equal "Hi Betty!", OUTPUT[13]
  end

  def test_part3_mega_greeter_handles_one_name_a_list_and_nil
    assert_equal "Hello World!", OUTPUT[14]
    assert_equal "Goodbye World.  Come back soon!", OUTPUT[15]
    assert_equal "Hello Zeke!", OUTPUT[16]
    assert_equal "Goodbye Zeke.  Come back soon!", OUTPUT[17]
    assert_equal "Hello Albert!", OUTPUT[18]
    assert_equal "Hello Brenda!", OUTPUT[19]
    assert_equal "Hello Charles!", OUTPUT[20]
    assert_equal "Hello Dave!", OUTPUT[21]
    assert_equal "Hello Engelbert!", OUTPUT[22]
    assert_equal "Goodbye Albert, Brenda, Charles, Dave, Engelbert.  Come back soon!", OUTPUT[23]
    assert_equal "...", OUTPUT[24]
    assert_equal "...", OUTPUT[25]
  end

  def test_total_number_of_output_lines
    assert_equal 26, OUTPUT.size
  end
end
