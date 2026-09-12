# frozen_string_literal: true

# 手本の原本 — 文字列と Symbol、そしてエンコーディング。
#
# 底本と、行の文言に現れる識別子が実在する節:
#   二重引用符と式展開 #{} / 単一引用符 / 隣り合う文字列リテラルの連結 / %w / Symbol リテラル /
#   Hash の Symbol キー記法
#     https://docs.ruby-lang.org/en/4.0/syntax/literals_rdoc.html
#   frozen_string_literal マジックコメント / frozen?
#     https://docs.ruby-lang.org/en/4.0/syntax/comments_rdoc.html
#   upcase / upcase! / length / strip / split / gsub / start_with? / << / dup / +@ /
#   encoding / force_encoding / encode / ascii_only? / valid_encoding? / bytes
#     https://docs.ruby-lang.org/en/4.0/String.html
#   Symbol が識別子であること / to_s / to_sym / object_id
#     https://docs.ruby-lang.org/en/4.0/Symbol.html
#     https://www.ruby-lang.org/en/documentation/ruby-from-other-languages/
#     （Symbols are not lightweight Strings）
#   文字列リテラルの既定のエンコーディングと、force_encoding が解釈だけを変えること
#     https://docs.ruby-lang.org/en/4.0/language/encodings_rdoc.html
#
# 教材がこの手本に加えた編集は commentary.md の「原典との差分」に書いてある。

def interpolated
  "One plus one is two: #{1 + 1}"
end

def not_interpolated
  '#{1 + 1}'
end

def adjacent
  "con" "cat" "en" "at" "ion"
end

def names
  %w[ada grace linus]
end

def frozen_literal
  "hello"
end

def built_buffer
  buffer = +""
  buffer << "abc"
  buffer.upcase!
  buffer
end

def shouted(text)
  text.upcase
end

def length_of(text)
  text.length
end

def trimmed(text)
  text.strip
end

def split_on_commas(text)
  text.split(",")
end

def dashed(text)
  text.gsub(",", "-")
end

def starts_with?(text, prefix)
  text.start_with?(prefix)
end

def symbol_to_string(symbol)
  symbol.to_s
end

def string_to_symbol(text)
  text.to_sym
end

def symbol_keyed
  { a: 1, b: 2 }
end
