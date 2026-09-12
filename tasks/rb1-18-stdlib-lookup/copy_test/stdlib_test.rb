# frozen_string_literal: true

require "minitest/autorun"
require "stringio"
require "csv"
require "logger"

# 写しの照合テスト（教材が配る。読んでよい。写さない）。
# 学習者の写し stdlib.rb（定義だけ）を読み込み、原典が示している呼び出しをここで行って確かめる。
# 出力を捕まえる StringIO は判定のための道具なので、写しには置かずここで使う。
class Rb118StdlibCopyTest < Minitest::Test
  def test_json_parse_turns_text_into_ruby_objects
    ruby = parsed_json('["foo", 1, 1.0, 2.0e2, true, false, null]')

    assert_equal ["foo", 1, 1.0, 200.0, true, false, nil], ruby
    assert_equal Array, ruby.class
  end

  def test_json_parse_can_return_symbol_keys
    assert_equal({ "a" => "foo" }, parsed_json('{"a": "foo"}'))
    assert_equal({ a: "foo" }, parsed_json_with_symbols('{"a": "foo"}'))
  end

  def test_json_generate_turns_ruby_objects_into_text
    assert_equal '{"a":"foo","b":1}', generated_json({ "a" => "foo", "b" => 1 })
  end

  def test_time_can_be_built_and_taken_apart
    t = last_moment_of(2000)

    assert_equal 2000, t.year
    assert_equal 12, t.month
    assert_equal 31, t.mday
    assert_equal "Sun Dec 31 23:59:59 2000", formatted(t)
  end

  def test_erb_fills_a_template_from_the_surrounding_binding
    assert_equal "The magic word is xyzzy.", filled_template("xyzzy")
    assert_equal "Some stuff; more stuff.", template_without_comment
  end

  def test_csv_parses_rows_and_generates_them_back
    string = "foo,0\nbar,1\nbaz,2\n"

    assert_equal [["foo", "0"], ["bar", "1"], ["baz", "2"]], parsed_csv(string)
    assert_equal ["foo", "0"], first_csv_row(string)
    assert_equal string, generated_csv([["foo", 0], ["bar", 1], ["baz", 2]])
  end

  def test_csv_can_read_the_first_row_as_headers
    data = csv_with_headers(<<~ROWS)
      Name,Department,Salary
      Bob,Engineering,1000
    ROWS

    assert_equal CSV::Table, data.class
    assert_equal({ "Name" => "Bob", "Department" => "Engineering", "Salary" => "1000" }, data.first.to_h)
  end

  def test_logger_writes_entries_whose_severity_reaches_the_level
    device = StringIO.new
    logger = logger_for(device)
    logger.info("Non-error information")
    logger.warn("Non-error warning")
    logger.add(Logger::ERROR, "Non-fatal error", "mung")

    assert_equal ["WARN -- : Non-error warning", "ERROR -- mung: Non-fatal error"],
                 device.string.lines.map(&:chomp)
    refute logger.info?
    assert logger.warn?
  end
end

require "stdlib"
