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
