# frozen_string_literal: true

# 手本の底本。行に出てくる道具ごとに、それが載っている節を指す。
#   OptionParser.new / on（短い名前・長い名前・必須引数）/ parse! / into: / help
#     https://docs.ruby-lang.org/en/4.0/optparse/tutorial_rdoc.html
#   OptionParser のクラス全体（例外 InvalidOption / MissingArgument）
#     https://docs.ruby-lang.org/en/4.0/OptionParser.html
#   スクリプトとして直接実行されたときだけ動かす書き方（__FILE__ == $0）
#     https://www.ruby-lang.org/en/documentation/quickstart/4/
#   実行権限とファイルの起動を確かめるために教材が足した道具:
#   Dir.mktmpdir（一時ディレクトリ）
#     https://docs.ruby-lang.org/en/4.0/Dir.html#method-c-mktmpdir
#   FileUtils.chmod（実行権限を付ける）
#     https://docs.ruby-lang.org/en/4.0/FileUtils.html#method-c-chmod
#   File.executable?（実行権限があるか）
#     https://docs.ruby-lang.org/en/4.0/File.html#method-c-executable-3F
#   IO.popen（別プロセスとして起動して標準出力を読む）
#     https://docs.ruby-lang.org/en/4.0/IO.html#method-c-popen

require "optparse"

def basic_parser
  parser = OptionParser.new
  parser.on("-x", "--xxx", "Short and long, no argument")
  parser.on("-yYYY", "--yyy", "Short and long, required argument")
  parser.on("-z [ZZZ]", "--zzz", "Short and long, optional argument")
  parser
end

def parse_into(parser, argv, options)
  rest = parser.parse!(argv, into: options)
  [options, rest]
end

def described_parser
  parser = OptionParser.new
  parser.banner = "Usage: basic [options]"
  parser.on("-x", "Whether to X")
  parser
end
