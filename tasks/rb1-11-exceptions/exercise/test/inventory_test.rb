# frozen_string_literal: true

require "minitest/autorun"
require "inventory"

# 確認課題の判定テスト。読んでよい（これが実装の仕様そのものになっている）。
class Rb111InventoryExerciseTest < Minitest::Test
  def setup
    @inventory = Inventory.new({ "apple" => 3, "pear" => 0 })
  end

  def test_taking_what_is_there_returns_what_is_left
    assert_equal 1, @inventory.take("apple", 2)
    assert_equal 0, @inventory.take("apple", 1)
  end

  def test_the_two_failures_share_one_parent_exception
    assert_operator Inventory::Error, :<, StandardError
    assert_operator Inventory::UnknownItem, :<, Inventory::Error
    assert_operator Inventory::OutOfStock, :<, Inventory::Error
  end

  def test_an_unknown_item_raises_unknown_item
    error = assert_raises(Inventory::UnknownItem) { @inventory.take("banana", 1) }
    assert_equal "unknown item: banana", error.message
  end

  def test_taking_more_than_is_left_raises_out_of_stock
    error = assert_raises(Inventory::OutOfStock) { @inventory.take("apple", 5) }
    assert_equal "out of stock: apple (asked 5, left 3)", error.message
  end

  def test_taking_from_an_empty_shelf_raises_out_of_stock
    error = assert_raises(Inventory::OutOfStock) { @inventory.take("pear", 1) }
    assert_equal "out of stock: pear (asked 1, left 0)", error.message
  end

  def test_a_failed_take_leaves_the_stock_untouched
    assert_raises(Inventory::OutOfStock) { @inventory.take("apple", 5) }
    assert_equal 1, @inventory.take("apple", 2)
  end

  def test_rescuing_the_parent_catches_both_kinds
    caught = []
    ["banana", "pear"].each do |name|
      @inventory.take(name, 1)
    rescue Inventory::Error => e
      caught << e.class
    end
    assert_equal [Inventory::UnknownItem, Inventory::OutOfStock], caught
  end
end
