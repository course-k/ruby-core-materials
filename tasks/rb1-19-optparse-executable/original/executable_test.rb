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

require "minitest/autorun"
require "optparse"
require "tmpdir"
require "fileutils"

LIB_SOURCE = <<~RUBY
  # frozen_string_literal: true

  module Greeter
    def self.call(name, loud:)
      text = "Hello, \#{name}!"
      loud ? text.upcase : text
    end
  end
RUBY

EXE_SOURCE = <<~RUBY
  #!/usr/bin/env ruby
  # frozen_string_literal: true

  require "optparse"
  require_relative "../lib/greeter"

  if __FILE__ == $0
    options = { name: "world", loud: false }
    OptionParser.new do |parser|
      parser.banner = "Usage: greet [options]"
      parser.on("-n NAME", "--name NAME", "Who to greet")
      parser.on("-l", "--loud", "Shout the greeting")
    end.parse!(into: options)

    puts Greeter.call(options[:name], loud: options[:loud])
  end
RUBY

class ExecutableTest < Minitest::Test
  def test_a_parser_collects_the_options_into_a_hash
    parser = OptionParser.new
    parser.on("-x", "--xxx", "Short and long, no argument")
    parser.on("-yYYY", "--yyy", "Short and long, required argument")
    parser.on("-z [ZZZ]", "--zzz", "Short and long, optional argument")
    options = {}
    rest = parser.parse!(["--xxx", "--yyy", "FOO", "bam"], into: options)

    assert_equal({ xxx: true, yyy: "FOO" }, options)
    assert_equal ["bam"], rest
  end

  def test_defaults_come_from_the_hash_the_parser_writes_into
    parser = OptionParser.new
    parser.on("-yYYY", "--yyy", "Short and long, required argument")
    parser.on("-z [ZZZ]", "--zzz", "Short and long, optional argument")
    options = { yyy: "AAA", zzz: "BBB" }
    parser.parse!(["--yyy", "FOO"], into: options)

    assert_equal({ yyy: "FOO", zzz: "BBB" }, options)
  end

  def test_the_parser_builds_its_own_help_text_and_reports_bad_input
    parser = OptionParser.new
    parser.banner = "Usage: basic [options]"
    parser.on("-x", "Whether to X")

    assert_includes parser.help, "Usage: basic [options]"
    assert_includes parser.help, "Whether to X"
    assert_raises(OptionParser::InvalidOption) { parser.parse!(["--nope"]) }
  end

  def test_a_file_with_a_shebang_and_the_executable_bit_runs_on_its_own
    Dir.mktmpdir do |dir|
      FileUtils.mkdir_p(File.join(dir, "lib"))
      FileUtils.mkdir_p(File.join(dir, "exe"))
      File.write(File.join(dir, "lib", "greeter.rb"), LIB_SOURCE)
      exe = File.join(dir, "exe", "greet")
      File.write(exe, EXE_SOURCE)

      refute File.executable?(exe)
      FileUtils.chmod("+x", exe)
      assert File.executable?(exe)
      assert_equal "#!/usr/bin/env ruby", File.readlines(exe).first.chomp
      assert_equal "Hello, world!\n", IO.popen([exe], &:read)
      assert_equal "HELLO, ADA!\n", IO.popen([exe, "--name", "Ada", "--loud"], &:read)
    end
  end
end
