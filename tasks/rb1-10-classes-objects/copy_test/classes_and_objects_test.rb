# frozen_string_literal: true

require "minitest/autorun"

# 写しの照合テスト（教材が配る。読んでよい。写さない）。
# 学習者の写し classes_and_objects.rb（定義だけ）を読み込み、原典が示している呼び出しをここで行って確かめる。
class Rb110ClassesAndObjectsCopyTest < Minitest::Test
  def test_a_subclass_inherits_methods_and_constants
    assert_equal 1, B.new.z
    assert_equal 1, B::Z
  end

  def test_the_default_inspect_and_to_s_show_the_class_and_the_object_id
    assert_match(/\A#<Foo:0x[0-9a-f]+>\z/, Foo.new.inspect)
    assert_match(/\A#<Bar:0x[0-9a-f]+ @bar=1>\z/, Bar.new.inspect)
    assert_match(/\A#<Foo:0x[0-9a-f]+>\z/, Foo.new.to_s)
  end

  def test_attr_accessor_defines_a_reader_and_a_writer
    assert_equal %i[one one= two two=], Attrs.instance_methods(false).sort
  end

  def test_private_needs_no_receiver_or_a_literal_self
    owner = Owner.new
    assert_equal 1, owner.without
    assert_equal 1, owner.with_self
    assert_raises(NoMethodError) { owner.with_other }
    assert_raises(NoMethodError) { owner.m }
  end

  def test_a_class_can_be_reopened_to_add_an_accessor
    object = Reopened.new(1)
    assert_equal 1, object.one
    object.one = 2
    assert_equal 2, object.one
  end

  def test_a_singleton_class_holds_methods_for_the_class_itself
    assert_equal 2, C.my_method
  end
end

require "classes_and_objects"
