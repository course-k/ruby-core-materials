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
