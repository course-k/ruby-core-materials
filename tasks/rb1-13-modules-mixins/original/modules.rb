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
