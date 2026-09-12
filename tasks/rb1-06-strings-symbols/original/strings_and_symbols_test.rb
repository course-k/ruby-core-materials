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

require "minitest/autorun"

class StringsAndSymbolsTest < Minitest::Test
  def test_double_quoted_strings_interpolate
    assert_equal "One plus one is two: 2", "One plus one is two: #{1 + 1}"
  end

  def test_single_quoted_strings_do_not_interpolate
    assert_equal '#{1 + 1}', "\#{1 + 1}"
  end

  def test_adjacent_string_literals_are_concatenated
    assert_equal "concatenation", "con" "cat" "en" "at" "ion"
  end

  def test_percent_w_builds_an_array_of_strings
    assert_equal ["ada", "grace", "linus"], %w[ada grace linus]
  end

  def test_frozen_string_literal_freezes_the_literals_in_this_file
    var = "hello"
    assert var.frozen?
    assert_raises(FrozenError) { var << " world" }
  end

  def test_an_unfrozen_string_can_be_changed_in_place
    buffer = +""
    buffer << "abc"
    buffer.upcase!
    assert_equal "ABC", buffer
    refute buffer.frozen?
  end

  def test_common_string_methods
    assert_equal "RUBY", "ruby".upcase
    assert_equal 4, "ruby".length
    assert_equal "ruby", "  ruby  ".strip
    assert_equal ["a", "b", "c"], "a,b,c".split(",")
    assert_equal "a-b-c", "a,b,c".gsub(",", "-")
    assert "ruby".start_with?("ru")
  end

  def test_symbols_are_identities_and_strings_are_contents
    assert_equal :george.object_id, :george.object_id
    refute_equal "george".dup.object_id, "george".dup.object_id
  end

  def test_symbols_and_strings_convert_to_each_other
    assert_equal "name", :name.to_s
    assert_equal :name, "name".to_sym
  end

  def test_a_hash_written_with_symbol_keys
    h = { a: 1, b: 2 }
    assert_equal 1, h[:a]
    assert_nil h["a"]
  end

  def test_string_literals_carry_the_script_encoding
    assert_equal Encoding::UTF_8, "s".encoding
    assert_equal "UTF-8", "s".encoding.name
  end

  def test_force_encoding_changes_the_interpretation_not_the_bytes
    s = "R\xC3\xA9sum\xC3\xA9".dup
    bytes = s.bytes
    assert_equal Encoding::UTF_8, s.encoding
    s.force_encoding(Encoding::ISO_8859_1)
    assert_equal Encoding::ISO_8859_1, s.encoding
    assert_equal bytes, s.bytes
  end

  def test_encode_really_converts_the_content
    assert_equal Encoding::UTF_16, "abc".encode(Encoding::UTF_16).encoding
    assert "abc".ascii_only?
    refute "abc\u{6666}".ascii_only?
    assert "\xc2\xa1".dup.force_encoding(Encoding::UTF_8).valid_encoding?
    refute "\xc2".dup.force_encoding(Encoding::UTF_8).valid_encoding?
  end
end
