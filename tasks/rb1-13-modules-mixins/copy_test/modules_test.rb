# frozen_string_literal: true

require "minitest/autorun"

# 写しの照合テスト（教材が配る。読んでよい。写さない）。
# 学習者の写し modules.rb（定義だけ）を読み込み、原典が示している呼び出しをここで行って確かめる。
class Rb113ModulesCopyTest < Minitest::Test
  def test_module_gives_a_namespace_to_the_names_inside_it
    assert_equal "Outer::Inner", Outer::Inner.name
    assert_kind_of Module, Outer::Inner
  end

  def test_instance_methods_of_a_module_are_callable_once_included
    assert_includes self.class.ancestors, A
    assert_equal 1, z
  end

  def test_comparable_builds_the_operators_out_of_the_spaceship
    s1 = StringSorter.new("Z")
    s2 = StringSorter.new("YY")
    s3 = StringSorter.new("XXX")
    s4 = StringSorter.new("WWWW")
    s5 = StringSorter.new("VVVVV")

    assert_operator s1, :<, s2
    refute s4.between?(s1, s3)
    assert s4.between?(s3, s5)
    assert_equal [s1, s2, s3, s4, s5], [s3, s2, s5, s4, s1].sort
  end

  def test_enumerable_builds_its_methods_out_of_each
    elements = []
    Foo.new.each_entry { |element| elements << element }

    assert_equal [1, [1, 2], nil], elements
    assert_includes Foo.ancestors, Enumerable
  end

  def test_extend_adds_the_methods_to_one_object_only
    k = Klass.new

    assert_equal "Hello from Klass.\n", k.hello
    k.extend(Mod)
    assert_equal "Hello from Mod.\n", k.hello
    assert_equal "Hello from Klass.\n", Klass.new.hello
  end
end

require "modules"
