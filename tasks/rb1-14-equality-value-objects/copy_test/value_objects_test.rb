# frozen_string_literal: true

require "minitest/autorun"

# 写しの照合テスト（教材が配る。読んでよい。写さない）。
# 学習者の写し value_objects.rb（定義だけ）を読み込み、原典が示している呼び出しをここで行って確かめる。
class Rb114ValueObjectsCopyTest < Minitest::Test
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

require "value_objects"
