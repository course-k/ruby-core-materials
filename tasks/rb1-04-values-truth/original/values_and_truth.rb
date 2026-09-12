# frozen_string_literal: true

# 手本の原本 — 値と真偽の規則。
#
# 底本と、行の文言に現れる識別子が実在する節:
#   nil と false だけが偽であること
#     https://docs.ruby-lang.org/en/4.0/syntax/literals_rdoc.html （Boolean and Nil Literals）
#   すべての式が値を持つこと（if の結果を代入できる）/ 0 が真であること
#     https://www.ruby-lang.org/en/documentation/ruby-from-other-languages/
#     （Everything has a value / The universal truth）
#   if / else / elsif / case / when と、その結果が値になること /
#   case が === で照合すること
#     https://docs.ruby-lang.org/en/4.0/syntax/control_expressions_rdoc.html
#   puts の戻り値が nil であること
#     https://docs.ruby-lang.org/en/4.0/Kernel.html#method-i-puts
#     https://www.ruby-lang.org/en/documentation/quickstart/
#   nil? / ===
#     https://docs.ruby-lang.org/en/4.0/Object.html#method-i-nil-3F
#     https://docs.ruby-lang.org/en/4.0/Object.html#method-i-3D-3D-3D
#   nil と true がオブジェクトであること
#     https://docs.ruby-lang.org/en/4.0/NilClass.html
#     https://docs.ruby-lang.org/en/4.0/TrueClass.html
#   Module#=== がクラスの所属を見ること
#     https://docs.ruby-lang.org/en/4.0/Module.html#method-i-3D-3D-3D
#
# 教材がこの手本に加えた編集は commentary.md の「原典との差分」に書いてある。

def bigger?(x, y)
  if x < y
    true
  else
    false
  end
end

def zero_is_true
  if 0
    "0 is true"
  else
    "0 is false"
  end
end

FALSEY = [nil, false, 0, "", [], {}, "0"].freeze

def falsey_values
  FALSEY.reject { |value| value }
end

def print_hello_world
  puts "Hello World"
end

def starts_with_one(text)
  case text
  when /^1/
    "the string starts with one"
  else
    "I don't know what the string starts with"
  end
end

def label_for(a)
  case a
  when 1, 2 then "a is one or two"
  when 3 then "a is three"
  else "I don't know what a is"
  end
end
