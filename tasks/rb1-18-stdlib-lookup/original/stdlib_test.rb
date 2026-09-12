# frozen_string_literal: true

# 手本の底本。行に出てくる道具ごとに、それが載っている節を指す。
#   JSON.parse / JSON.generate / symbolize_names
#     https://docs.ruby-lang.org/en/4.0/JSON.html
#   Time.new と部分の取り出し / Time#strftime
#     https://docs.ruby-lang.org/en/4.0/Time.html
#   ERB（式タグ <%= %>・実行タグ <% %>・コメントタグ <%# %>）と ERB#result(binding)
#     https://docs.ruby-lang.org/en/4.0/ERB.html
#   CSV.parse / CSV.parse_line / CSV.generate / headers:（csv は bundled gem。Ruby 4.0.6 同梱は 3.3.5）
#     https://github.com/ruby/csv/tree/v3.3.5
#   Logger.new / severity / Logger#formatter=（logger は bundled gem。Ruby 4.0.6 同梱は 1.7.0）
#     https://github.com/ruby/logger/tree/v1.7.0

require "minitest/autorun"
require "json"
require "csv"
require "erb"
require "logger"
require "stringio"

class StdlibTest < Minitest::Test
  def test_json_parse_turns_text_into_ruby_objects
    json = '["foo", 1, 1.0, 2.0e2, true, false, null]'
    ruby = JSON.parse(json)

    assert_equal ["foo", 1, 1.0, 200.0, true, false, nil], ruby
    assert_equal Array, ruby.class
  end

  def test_json_parse_can_return_symbol_keys
    source = '{"a": "foo"}'

    assert_equal({ "a" => "foo" }, JSON.parse(source))
    assert_equal({ a: "foo" }, JSON.parse(source, { symbolize_names: true }))
  end

  def test_json_generate_turns_ruby_objects_into_text
    ruby = { "a" => "foo", "b" => 1 }

    assert_equal '{"a":"foo","b":1}', JSON.generate(ruby)
  end

  def test_time_can_be_built_and_taken_apart
    t = Time.new(2000, 12, 31, 23, 59, 59)

    assert_equal 2000, t.year
    assert_equal 12, t.month
    assert_equal 31, t.mday
    assert_equal "Sun Dec 31 23:59:59 2000", t.strftime("%a %b %e %T %Y")
  end

  def test_erb_fills_a_template_from_the_surrounding_binding
    magic_word = "xyzzy"
    template = "The magic word is <%= magic_word %>."

    assert_equal "The magic word is xyzzy.", ERB.new(template).result(binding)
    assert_equal "Some stuff; more stuff.",
                 ERB.new("Some stuff;<%# Note to self. %> more stuff.").result
  end

  def test_csv_parses_rows_and_generates_them_back
    string = "foo,0\nbar,1\nbaz,2\n"

    assert_equal [["foo", "0"], ["bar", "1"], ["baz", "2"]], CSV.parse(string)
    assert_equal ["foo", "0"], CSV.parse_line(string)
    generated = CSV.generate do |csv|
      csv << ["foo", 0]
      csv << ["bar", 1]
      csv << ["baz", 2]
    end
    assert_equal string, generated
  end

  def test_csv_can_read_the_first_row_as_headers
    data = CSV.parse(<<~ROWS, headers: true)
      Name,Department,Salary
      Bob,Engineering,1000
    ROWS

    assert_equal CSV::Table, data.class
    assert_equal({ "Name" => "Bob", "Department" => "Engineering", "Salary" => "1000" }, data.first.to_h)
  end

  def test_logger_writes_entries_whose_severity_reaches_the_level
    device = StringIO.new
    logger = Logger.new(device, level: Logger::WARN)
    logger.formatter = proc { |severity, _time, progname, msg| "#{severity} -- #{progname}: #{msg}\n" }
    logger.info("Non-error information")
    logger.warn("Non-error warning")
    logger.add(Logger::ERROR, "Non-fatal error", "mung")

    assert_equal ["WARN -- : Non-error warning", "ERROR -- mung: Non-fatal error"], device.string.lines.map(&:chomp)
    refute logger.info?
    assert logger.warn?
  end
end
