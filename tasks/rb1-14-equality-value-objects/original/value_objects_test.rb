# frozen_string_literal: true

# 手本の底本（Ruby 4.0 の公式ドキュメント）。行に出てくる道具ごとに、それが載っている節を指す。
#   == / equal? / eql?（同一性と等価性の違い）
#     https://docs.ruby-lang.org/en/4.0/Object.html#method-i-eql-3F
#   hash（eql? を上書きしたら hash も上書きする。[self.class, ...].hash の型）
#     https://docs.ruby-lang.org/en/4.0/Object.html#method-i-hash
#   Struct（書き換えられる値の入れ物）
#     https://docs.ruby-lang.org/en/4.0/Struct.html
#   Data（書き換えられない値オブジェクト）
#     https://docs.ruby-lang.org/en/4.0/Data.html
#   Set（eql? と hash で重複を判定する集合）
#     https://docs.ruby-lang.org/en/4.0/Set.html

require "minitest/autorun"

Customer = Struct.new("Customer", :name, :address, :zip)

Measure = Data.define(:amount, :unit)

class Measurement
  attr_reader :amount, :unit

  def initialize(amount, unit)
    @amount = amount
    @unit = unit
  end

  def ==(other)
    other.is_a?(self.class) && amount == other.amount && unit == other.unit
  end

  alias eql? ==

  def hash
    [self.class, amount, unit].hash
  end
end

class ValueObjectsTest < Minitest::Test
  def test_equal_asks_whether_it_is_the_same_object
    obj = "a"
    other = obj.dup

    assert_equal obj, other
    refute obj.equal?(other)
    assert obj.equal?(obj)
  end

  def test_eql_does_not_convert_types_while_equal_operator_does
    assert_equal 1, 1.0
    refute 1.eql?(1.0)
  end

  def test_a_class_that_overrides_eql_must_override_hash_too
    a = Measurement.new(100, "km")
    b = Measurement.new(100, "km")

    assert_equal a, b
    assert a.eql?(b)
    assert_equal a.hash, b.hash
    refute a.equal?(b)
    assert_equal 1, { a => :first, b => :second }.size
  end

  def test_struct_stores_and_fetches_values_and_lets_them_change
    joe = Customer.new("Joe Smith", "123 Maple, Anytown NC", 12345)

    assert_equal "Struct::Customer", Customer.name
    assert_equal "Joe Smith", joe.name
    joe.name = "Joseph Smith"
    assert_equal "Joseph Smith", joe[:name]
    assert_equal Customer.new("Joseph Smith", "123 Maple, Anytown NC", 12345), joe
  end

  def test_data_defines_an_immutable_value_object
    distance = Measure.new(100, "km")
    weight = Measure.new(amount: 50, unit: "kg")
    speed = Measure[10, "mPh"]

    assert_equal 100, distance.amount
    assert_equal "kg", weight.unit
    assert_equal 10, speed.amount
    assert_equal Measure[100, "km"], distance
    assert_equal({ amount: 100, unit: "km" }, distance.to_h)
    refute_respond_to distance, :amount=
  end

  def test_set_keeps_no_duplicates_and_decides_them_by_eql_and_hash
    s1 = Set[1, 2]
    s2 = [1, 2].to_set

    assert_equal s1, s2
    s1.add("foo")
    s1.merge([2, 6])
    refute s1.subset?(s2)
    assert s2.subset?(s1)
    assert_equal 1, Set[Measurement.new(1, "m"), Measurement.new(1, "m")].size
  end
end
