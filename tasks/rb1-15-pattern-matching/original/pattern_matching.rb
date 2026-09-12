# frozen_string_literal: true

# 手本の底本（Ruby 4.0 の公式ドキュメント）。この課題で出てくる道具はすべて次の 1 節にある。
#   case / in、値パターン、配列パターン、ハッシュパターン、変数束縛、
#   ピン演算子 ^、ガード節 if、deconstruct / deconstruct_keys、=> と in の単独形
#     https://docs.ruby-lang.org/en/4.0/syntax/pattern_matching_rdoc.html
#   NoMatchingPatternKeyError（底本のページ本文には出てこない。例外クラスの側の項を指す）
#     https://docs.ruby-lang.org/en/4.0/NoMatchingPatternKeyError.html

class Point
  def initialize(x, y)
    @x = x
    @y = y
  end

  def deconstruct
    puts "deconstruct called"
    [@x, @y]
  end

  def deconstruct_keys(keys)
    puts "deconstruct_keys called with #{keys.inspect}"
    { x: @x, y: @y }
  end
end

CONFIG = { db: { user: "admin", password: "abc123" } }.freeze

def describe_config(config)
  case config
  in db: { user: }
    "Connect with user '#{user}'"
  in connection: { username: }
    "Connect with user '#{username}'"
  else
    "Unrecognized structure of config"
  end
end

def user_of(config)
  config => { db: { user: } }
  user
end

def integer?(value)
  value in Integer
end

def single_digit?(value)
  value in 0..9
end

def three_integers?(value)
  value in [Integer, Integer, Integer]
end

def starts_with_integer?(value)
  value in [Integer, *]
end

def has_integer_a?(value)
  value in { a: Integer }
end

def only_integer_a?(value)
  value in { a: Integer, **nil }
end

def pinned(expectation, value)
  case value
  in ^expectation, *rest
    "matched: #{rest}"
  else
    "not matched. expectation was: #{expectation}"
  end
end

def doubled?(value)
  case value
  in a, b if b == a * 2
    "matched"
  else
    "not matched"
  end
end

def first_of(point)
  case point
  in px, Integer
    "matched: #{px}"
  end
end

def positive_x_of(point)
  case point
  in x: 0.. => px
    "matched: #{px}"
  end
end
