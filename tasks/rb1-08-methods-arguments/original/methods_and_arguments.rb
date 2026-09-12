# frozen_string_literal: true

# 手本の原本 — メソッドの定義と引数。
#
# 底本と、行の文言に現れる識別子が実在する節:
#   def / メソッド名の規約（? と ! と =）/ 暗黙の戻り値と return /
#   位置引数 / 引数の既定値（既定値が左の引数を参照できること）/
#   * による可変長引数 / キーワード引数 / ** による残りのキーワード / & によるブロック引数 / yield
#     https://docs.ruby-lang.org/en/4.0/syntax/methods_rdoc.html
#   キーワード引数は順不同であること
#     https://docs.ruby-lang.org/en/4.0/syntax/methods_rdoc.html
#   既定値が左から順に埋まること / 既定値が中ほどにある場合の埋まり方
#     https://docs.ruby-lang.org/en/4.0/syntax/calling_methods_rdoc.html
#   empty? / upcase!（! が付く版は変更が無いと nil を返す）
#     https://docs.ruby-lang.org/en/4.0/String.html
#
# 教材がこの手本に加えた編集は commentary.md の「原典との差分」に書いてある。

def add_one(value)
  value + 1
end

def one_plus_one
  return 1 + 1
end

def two_plus_two
  return 2 + 2
  1 + 1 # this expression is never evaluated
end

def sum_with_default(a, b = 1)
  a + b
end

def sum_referring_to_earlier(a = 1, b = a)
  a + b
end

def fill_in_the_middle(a, b = 2, c = 3, d)
  [a, b, c, d]
end

def gather_arguments(*arguments)
  arguments
end

def gather_middle(first_arg, *middle_arguments, last_arg)
  [first_arg, middle_arguments, last_arg]
end

def add_keywords(first: 1, second: 2)
  first + second
end

def require_keywords(first:, second:)
  first + second
end

def gather_keywords(first: nil, **rest)
  [first, rest]
end

def call_the_block(value, &my_block)
  my_block.call(value)
end

def yields_once(value)
  yield value
end
