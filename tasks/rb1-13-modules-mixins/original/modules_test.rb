# frozen_string_literal: true

# 手本の底本（Ruby 4.0 の公式ドキュメント）。行に出てくる道具ごとに、それが載っている節を指す。
#   module / 名前空間 / ネスト / include したモジュールのインスタンスメソッド
#     https://docs.ruby-lang.org/en/4.0/syntax/modules_and_classes_rdoc.html
#   include Comparable と <=>
#     https://docs.ruby-lang.org/en/4.0/Comparable.html
#   include Enumerable と each
#     https://docs.ruby-lang.org/en/4.0/Enumerable.html
#   extend（オブジェクト 1 個にモジュールのメソッドを足す）
#     https://docs.ruby-lang.org/en/4.0/Object.html#method-i-extend

require "minitest/autorun"

module Outer
  module Inner
  end
end

module A
  Z = 1

  def z
    Z
  end
end

include A

class StringSorter
  include Comparable

  attr :str

  def <=>(other)
    str.size <=> other.str.size
  end

  def initialize(str)
    @str = str
  end

  def inspect
    @str
  end
end

class Foo
  include Enumerable

  def each
    yield 1
    yield 1, 2
    yield
  end
end

module Mod
  def hello
    "Hello from Mod.\n"
  end
end

class Klass
  def hello
    "Hello from Klass.\n"
  end
end

class ModulesTest < Minitest::Test
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
