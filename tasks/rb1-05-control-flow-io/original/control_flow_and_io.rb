# frozen_string_literal: true

# 手本の原本 — 制御構造と、スクリプトの入出力。
#
# 底本と、行の文言に現れる識別子が実在する節:
#   if / elsif / else / unless / 後置 if と後置 unless / case と when / then /
#   while / until / break / next
#     https://docs.ruby-lang.org/en/4.0/syntax/control_expressions_rdoc.html
#   && || と and or の優先順位の違い
#     https://docs.ruby-lang.org/en/4.0/syntax/precedence_rdoc.html
#   &. （safe navigation operator）
#     https://docs.ruby-lang.org/en/4.0/syntax/calling_methods_rdoc.html
#   puts / warn / exit と SystemExit
#     https://docs.ruby-lang.org/en/4.0/Kernel.html#method-i-puts
#     https://docs.ruby-lang.org/en/4.0/Kernel.html#method-i-warn
#     https://docs.ruby-lang.org/en/4.0/Kernel.html#method-i-exit
#   ARGV
#     https://docs.ruby-lang.org/en/4.0/Object.html#ARGV
#   SystemExit#status（exit に渡した値が載る）
#     https://docs.ruby-lang.org/en/4.0/SystemExit.html#method-i-status
#   $stdin と read
#     https://docs.ruby-lang.org/en/4.0/IO.html
#   StringIO（テストの中で $stdin を差し替えるための入れ物。教材が足した道具）
#     https://docs.ruby-lang.org/en/4.0/StringIO.html
#   begin-less な rescue（メソッド本体がそのまま例外ハンドラになる形）
#     https://docs.ruby-lang.org/en/4.0/language/exceptions_md.html
#
# 教材がこの手本に加えた編集は commentary.md の「原典との差分」に書いてある。

REGEX = /(ruby) is (\w+)/i

def label_for(a)
  if a == 0
    "a is zero"
  elsif a == 1
    "a is one"
  else
    "a is some other value"
  end
end

def unless_label(value)
  unless value
    "the value is false"
  else
    "the value is true"
  end
end

def case_label(a)
  case
  when a == 1, a == 2 then "a is one or two"
  when a == 3 then "a is three"
  else "I don't know what a is"
  end
end

def bumped_if_zero(a)
  a += 1 if a.zero?
  a
end

def count_with_while(limit)
  a = 0
  while a < limit
    a += 1
  end
  a
end

def count_with_until(limit)
  b = 0
  b += 1 until b > limit
  b
end

def and_versus_double_ampersand
  a = true && false
  b = true and false
  [a, b]
end

def safely_joined(text)
  text.match(REGEX)&.values_at(1, 2)&.join(" - ")
end

def joined_without_the_second_guard(text)
  text.match(REGEX)&.values_at(1, 2).join(" - ")
end

def warn_twice
  warn("warning 1", "warning 2")
end

def exit_with(status)
  exit(status)
end

def first_argument
  ARGV[0]
end

def read_all_input
  $stdin.read
end
