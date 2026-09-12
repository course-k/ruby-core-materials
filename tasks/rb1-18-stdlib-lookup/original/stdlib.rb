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

require "json"
require "csv"
require "erb"
require "logger"

def parsed_json(json)
  JSON.parse(json)
end

def parsed_json_with_symbols(json)
  JSON.parse(json, { symbolize_names: true })
end

def generated_json(ruby)
  JSON.generate(ruby)
end

def last_moment_of(year)
  Time.new(year, 12, 31, 23, 59, 59)
end

def formatted(time)
  time.strftime("%a %b %e %T %Y")
end

def filled_template(magic_word)
  template = "The magic word is <%= magic_word %>."
  ERB.new(template).result(binding)
end

def template_without_comment
  ERB.new("Some stuff;<%# Note to self. %> more stuff.").result
end

def parsed_csv(string)
  CSV.parse(string)
end

def first_csv_row(string)
  CSV.parse_line(string)
end

def generated_csv(rows)
  CSV.generate do |csv|
    rows.each { |row| csv << row }
  end
end

def csv_with_headers(string)
  CSV.parse(string, headers: true)
end

def logger_for(device)
  logger = Logger.new(device, level: Logger::WARN)
  logger.formatter = proc { |severity, _time, progname, msg| "#{severity} -- #{progname}: #{msg}\n" }
  logger
end
