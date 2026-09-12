# frozen_string_literal: true

require "minitest/autorun"

# 写しの照合テスト（教材が配る。読んでよい。写さない）。
# 学習者の写し twenty_minutes.rb（定義だけ）を読み込み、原典「Ruby in Twenty Minutes」が irb や
# スクリプトで試している呼び出しをここで行って、出力と戻り値を確かめる。
# 落ちたときは「どのメソッドの・どの呼び出しが・何を出すべきか」が Expected / Actual で出る。
class Rb102TwentyMinutesCopyTest < Minitest::Test
  # 第 1 部: irb で評価した式。定義を経由しないので、写しには現れない
  def test_part1_expressions_evaluated_in_irb
    assert_equal "Hello World", printed { puts "Hello World" }
    assert_equal 5, 3 + 2
    assert_equal 6, 3 * 2
    assert_equal 9, 3**2
    assert_equal 3.0, Math.sqrt(9)
    a = 3**2
    b = 4**2
    assert_equal 5.0, Math.sqrt(a + b)
  end

  # 第 2 部: hi は名前を大文字始まりにし、省くと World になる
  def test_part2_hi_capitalizes_the_name_and_falls_back_to_world
    assert_equal "Hello Chris!", printed { hi "chris" }
    assert_equal "Hello World!", printed { hi }
  end

  # 第 2 部: Greeter は作ったときの名前で挨拶する
  def test_part2_greeter_greets_with_the_name_it_was_built_with
    greeter = Greeter.new("Pat")
    assert_equal "Hi Pat!", printed { greeter.say_hi }
    assert_equal "Bye Pat, come back soon.", printed { greeter.say_bye }
  end

  # 第 3 部: respond_to? で持っているメソッドを確かめ、attr_accessor で足した name= で名前を変える
  def test_part3_greeter_responds_to_its_methods_and_name_can_be_changed
    greeter = Greeter.new("Andy")
    assert_equal true, greeter.respond_to?("say_hi")
    assert_equal true, greeter.respond_to?("name")
    greeter.name = "Betty"
    assert_equal "Betty", greeter.name
    assert_equal "Hi Betty!", printed { greeter.say_hi }
  end

  # 第 3 部: MegaGreeter は既定の名前・1 つの名前・名前の配列・nil のそれぞれに応じる
  def test_part3_mega_greeter_with_the_default_name
    mg = MegaGreeter.new
    assert_equal "Hello World!", printed { mg.say_hi }
    assert_equal "Goodbye World.  Come back soon!", printed { mg.say_bye }
  end

  def test_part3_mega_greeter_with_one_name
    mg = MegaGreeter.new
    mg.names = "Zeke"
    assert_equal "Hello Zeke!", printed { mg.say_hi }
    assert_equal "Goodbye Zeke.  Come back soon!", printed { mg.say_bye }
  end

  def test_part3_mega_greeter_with_a_list_of_names
    mg = MegaGreeter.new
    mg.names = ["Albert", "Brenda", "Charles", "Dave", "Engelbert"]
    lines = printed { mg.say_hi }.lines.map(&:chomp)
    assert_equal 5, lines.size
    assert_equal "Hello Albert!", lines[0]
    assert_equal "Hello Brenda!", lines[1]
    assert_equal "Hello Charles!", lines[2]
    assert_equal "Hello Dave!", lines[3]
    assert_equal "Hello Engelbert!", lines[4]
    assert_equal "Goodbye Albert, Brenda, Charles, Dave, Engelbert.  Come back soon!", printed { mg.say_bye }
  end

  def test_part3_mega_greeter_with_nil
    mg = MegaGreeter.new
    mg.names = nil
    assert_equal "...", printed { mg.say_hi }
    assert_equal "...", printed { mg.say_bye }
  end

  private

  # ブロックの中で標準出力に書かれた文字列（末尾の改行を除く）を返す
  def printed(&)
    out, = capture_io(&)
    out.chomp
  end
end

require "twenty_minutes"
