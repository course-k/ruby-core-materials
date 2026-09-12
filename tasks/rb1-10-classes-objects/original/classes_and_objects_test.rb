# frozen_string_literal: true

# 手本の原本 — クラスとオブジェクト。
#
# 底本と、行の文言に現れる識別子が実在する節:
#   class / 継承 < / 定数の継承 / クラスの再オープン /
#   可視性 public・protected・private とその効き方
#     https://docs.ruby-lang.org/en/4.0/syntax/modules_and_classes_rdoc.html
#   inspect の既定の表示（クラス名・アドレス・インスタンス変数）
#     https://docs.ruby-lang.org/en/4.0/Object.html#method-i-inspect
#   to_s
#     https://docs.ruby-lang.org/en/4.0/Object.html#method-i-to_s
#   特異クラス（class << self でクラス自身のメソッドを定義する）
#     https://docs.ruby-lang.org/en/4.0/syntax/modules_and_classes_rdoc.html
#   attr_accessor が読み書き 2 つのメソッドを定義すること
#     https://docs.ruby-lang.org/en/4.0/Module.html#method-i-attr_accessor
#   self（メソッドの中でのレシーバ。private なメソッドを self 付きで呼べる範囲）
#     https://docs.ruby-lang.org/en/4.0/syntax/modules_and_classes_rdoc.html
#   initialize と new / インスタンス変数 @name / 再オープンで attr_accessor を足す
#     https://www.ruby-lang.org/en/documentation/quickstart/2/
#     https://www.ruby-lang.org/en/documentation/quickstart/3/
#
# 教材がこの手本に加えた編集は commentary.md の「原典との差分」に書いてある。

require "minitest/autorun"

class A
  Z = 1

  def z
    Z
  end
end

class B < A
end

class Foo
end

class Bar
  def initialize
    @bar = 1
  end
end

class Attrs
  attr_accessor :one, :two
end

class Owner
  def without
    m
  end

  def with_self
    self.m
  end

  def with_other
    Owner.new.m
  end

  def m
    1
  end

  private :m
end

class Reopened
  def initialize(one)
    @one = one
  end
end

class Reopened
  attr_accessor :one
end

class C
  class << self
    def my_method
      1 + 1
    end
  end
end

class ClassesAndObjectsTest < Minitest::Test
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
