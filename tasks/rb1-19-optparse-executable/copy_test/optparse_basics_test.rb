# frozen_string_literal: true

require "minitest/autorun"
require "optparse"

# 写しの照合テスト（教材が配る。読んでよい。写さない）。
# 学習者の写し optparse_basics.rb・lib/greeter.rb・exe/greet を読み込み、原典が示している
# 呼び出しをここで行って確かめる。exe/greet は実行可能ファイルとして起動する。
class Rb119OptparseBasicsCopyTest < Minitest::Test
  EXE = File.join(Dir.pwd, "rb1-19-optparse-executable", "exe", "greet")

  def test_a_parser_collects_the_options_into_a_hash
    options, rest = parse_into(basic_parser, ["--xxx", "--yyy", "FOO", "bam"], {})

    assert_equal({ xxx: true, yyy: "FOO" }, options)
    assert_equal ["bam"], rest
  end

  def test_defaults_come_from_the_hash_the_parser_writes_into
    options, = parse_into(basic_parser, ["--yyy", "FOO"], { yyy: "AAA", zzz: "BBB" })

    assert_equal({ xxx: nil, yyy: "FOO", zzz: "BBB" }.compact, options.compact)
  end

  def test_the_parser_builds_its_own_help_text_and_reports_bad_input
    parser = described_parser

    assert_includes parser.help, "Usage: basic [options]"
    assert_includes parser.help, "Whether to X"
    assert_raises(OptionParser::InvalidOption) { parser.parse!(["--nope"]) }
  end

  def test_a_file_with_a_shebang_and_the_executable_bit_runs_on_its_own
    assert_path_exists EXE, "exe/greet がまだありません"
    assert_equal "#!/usr/bin/env ruby", File.readlines(EXE).first.chomp
    assert File.executable?(EXE), "chmod +x exe/greet がまだです（手順 2 を見る）"
    assert_equal "Hello, world!\n", IO.popen([EXE], &:read)
    assert_equal "HELLO, ADA!\n", IO.popen([EXE, "--name", "Ada", "--loud"], &:read)
  end
end

require "optparse_basics"
