# frozen_string_literal: true

require "minitest/autorun"

# 写しの照合テスト（教材が配る。読んでよい。写さない）。
# 学習者の写し strings_and_symbols.rb（定義だけ）を読み込み、原典が示している呼び出しをここで行って確かめる。
# encoding / force_encoding / encode は B2 の「説明できる」側なので、写しには置かずここで見せる。
class Rb106StringsAndSymbolsCopyTest < Minitest::Test
  def test_double_quoted_strings_interpolate
    assert_equal "One plus one is two: 2", interpolated
  end

  def test_single_quoted_strings_do_not_interpolate
    assert_equal "\#{1 + 1}", not_interpolated
  end

  def test_adjacent_string_literals_are_concatenated
    assert_equal "concatenation", adjacent
  end

  def test_percent_w_builds_an_array_of_strings
    assert_equal ["ada", "grace", "linus"], names
  end

  def test_frozen_string_literal_freezes_the_literals_in_this_file
    var = frozen_literal
    assert var.frozen?
    assert_raises(FrozenError) { var << " world" }
  end

  def test_an_unfrozen_string_can_be_changed_in_place
    buffer = built_buffer
    assert_equal "ABC", buffer
    refute buffer.frozen?
  end

  def test_common_string_methods
    assert_equal "RUBY", shouted("ruby")
    assert_equal 4, length_of("ruby")
    assert_equal "ruby", trimmed("  ruby  ")
    assert_equal ["a", "b", "c"], split_on_commas("a,b,c")
    assert_equal "a-b-c", dashed("a,b,c")
    assert starts_with?("ruby", "ru")
  end

  def test_symbols_are_identities_and_strings_are_contents
    assert_equal :george.object_id, :george.object_id
    refute_equal "george".dup.object_id, "george".dup.object_id
  end

  def test_symbols_and_strings_convert_to_each_other
    assert_equal "name", symbol_to_string(:name)
    assert_equal :name, string_to_symbol("name")
  end

  def test_a_hash_written_with_symbol_keys
    h = symbol_keyed
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

require "strings_and_symbols"
