# frozen_string_literal: true

# 手本の原本 — 例外。
#
# 底本と、行の文言に現れる識別子が実在する節:
#   begin / rescue / else / ensure / end の並び / メソッド本体やブロックが
#   そのまま例外ハンドラになる形 / rescue が既定で StandardError を捕まえること /
#   複数の rescue 節と最初に当たった節だけが実行されること /
#   rescue => 変数 で例外を受けること / $! / raise の引数なし再送出 / retry /
#   自作例外クラス / message
#     https://docs.ruby-lang.org/en/4.0/language/exceptions_md.html
#   rescue の構文と retry の位置の制約
#     https://docs.ruby-lang.org/en/4.0/syntax/exceptions_rdoc.html
#   組み込みの例外クラス階層
#     https://docs.ruby-lang.org/en/4.0/Exception.html
#   Errno::ENOENT
#     https://docs.ruby-lang.org/en/4.0/Errno.html
#
# 教材がこの手本に加えた編集は commentary.md の「原典との差分」に書いてある。

class MyException < StandardError
end

def foo(boom: false)
  puts "Begin."
  raise "Boom!" if boom
rescue
  puts "Rescued an exception!"
else
  puts "No exception raised."
ensure
  puts "Always do this."
end

def capture_the_exception
  1 / 0
rescue => x
  [x.class, x.message]
end

def first_matching_clause
  Dir.open("nosuch")
rescue Errno::ENOTDIR
  "Rescued #{$!.class} as a directory error"
rescue Errno::ENOENT
  "Rescued #{$!.class}"
end

def retried
  retries = 0
  begin
    raise "Boom"
  rescue
    if (retries += 1) < 3
      retry
    else
      raise
    end
  end
end

def re_raised
  1 / 0
rescue ZeroDivisionError
  # Do needful things (like logging).
  raise # Raised exception will be ZeroDivisionError, not RuntimeError.
end
