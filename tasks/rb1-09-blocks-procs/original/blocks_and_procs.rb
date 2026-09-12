# frozen_string_literal: true

# 手本の原本 — ブロックと Proc と lambda。
#
# 底本と、行の文言に現れる識別子が実在する節:
#   Proc.new / call / .() / [] / クロージャであること（gen_times）/
#   proc / lambda / ->(x) { } / lambda? /
#   lambda と非 lambda の引数の厳しさの違い / return の違い /
#   & による Symbol から Proc への変換（to_proc）/ & を通しても lambda の性質が残ること
#     https://docs.ruby-lang.org/en/4.0/Proc.html
#   & でブロックを受け取る / yield
#     https://docs.ruby-lang.org/en/4.0/syntax/methods_rdoc.html
#   block_given?
#     https://docs.ruby-lang.org/en/4.0/Kernel.html#method-i-block_given-3F
#
# 教材がこの手本に加えた編集は commentary.md の「原典との差分」に書いてある。

def gen_times(factor)
  Proc.new { |n| n * factor } # remembers the value of factor at the moment of creation
end

def make_proc(&block)
  block
end

def returns_from_the_enclosing_method
  -> { return 3 }.call   # just returns from lambda into method body
  proc { return 4 }.call # returns from method
  return 5
end

def try
  if block_given?
    yield
  else
    "no block"
  end
end
