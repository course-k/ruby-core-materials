# frozen_string_literal: true

# 手本の原本 — 公式の入門「Ruby in Twenty Minutes」全 4 部のコード。
#
# 底本と、行の文言に現れる識別子が実在する節:
#   puts / 算術演算子 + * ** / Math.sqrt / ローカル変数への代入
#     https://www.ruby-lang.org/en/documentation/quickstart/
#   def / 引数の既定値 / 文字列の式展開 #{} / capitalize /
#   class / initialize / インスタンス変数 @name / say_hi / say_bye
#     https://www.ruby-lang.org/en/documentation/quickstart/2/
#   Greeter.new / instance_methods / respond_to? / attr_accessor / クラスの再オープン /
#   MegaGreeter / names / nil? / each / join / if-elsif-else
#     https://www.ruby-lang.org/en/documentation/quickstart/3/
#   say_hi と say_bye の分岐の読み方
#     https://www.ruby-lang.org/en/documentation/quickstart/4/
#
# 教材がこの手本に加えた編集は commentary.md の「原典との差分」に書いてある。

require "minitest/autorun"

def hi(name = "World")
  puts "Hello #{name.capitalize}!"
end

class Greeter
  def initialize(name = "World")
    @name = name
  end

  def say_hi
    puts "Hi #{@name}!"
  end

  def say_bye
    puts "Bye #{@name}, come back soon."
  end
end

class Greeter
  attr_accessor :name
end

class MegaGreeter
  attr_accessor :names

  # Create the object
  def initialize(names = "World")
    @names = names
  end

  # Say hi to everybody
  def say_hi
    if @names.nil?
      puts "..."
    elsif @names.respond_to?("each")
      # @names is a list of some kind, iterate!
      @names.each do |name|
        puts "Hello #{name}!"
      end
    else
      puts "Hello #{@names}!"
    end
  end

  # Say bye to everybody
  def say_bye
    if @names.nil?
      puts "..."
    elsif @names.respond_to?("join")
      # Join the list elements with commas
      puts "Goodbye #{@names.join(", ")}.  Come back soon!"
    else
      puts "Goodbye #{@names}.  Come back soon!"
    end
  end
end

class TwentyMinutesTest < Minitest::Test
  def test_expressions_evaluated_in_irb
    assert_equal 5, 3 + 2
    assert_equal 9, 3**2
    a = 3**2
    b = 4**2
    assert_equal 5.0, Math.sqrt(a + b)
  end

  def test_hi_capitalizes_the_name_and_falls_back_to_world
    assert_output("Hello Chris!\n") { hi "chris" }
    assert_output("Hello World!\n") { hi }
  end

  def test_greeter_greets_with_the_name_it_was_built_with
    greeter = Greeter.new("Pat")
    assert_output("Hi Pat!\n") { greeter.say_hi }
    assert_output("Bye Pat, come back soon.\n") { greeter.say_bye }
  end

  def test_greeter_answers_for_the_methods_it_has
    greeter = Greeter.new("Andy")
    assert greeter.respond_to?("say_hi")
    assert greeter.respond_to?("name")
    greeter.name = "Betty"
    assert_output("Hi Betty!\n") { greeter.say_hi }
  end

  def test_mega_greeter_handles_one_name_a_list_and_nil
    mg = MegaGreeter.new
    assert_output("Hello World!\n") { mg.say_hi }
    assert_output("Goodbye World.  Come back soon!\n") { mg.say_bye }
    mg.names = ["Albert", "Brenda"]
    assert_output("Hello Albert!\nHello Brenda!\n") { mg.say_hi }
    assert_output("Goodbye Albert, Brenda.  Come back soon!\n") { mg.say_bye }
    mg.names = nil
    assert_output("...\n") { mg.say_hi }
  end
end
