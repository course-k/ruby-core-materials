# frozen_string_literal: true

# 手本の原本 — 公式の入門「Ruby in Twenty Minutes」全 4 部のコード。
# 手本に置くのは定義（hi / Greeter / Greeter の再オープン / MegaGreeter）だけ。
# 定義を呼び出して動きを確かめるコードは写しの照合テスト copy_test/twenty_minutes_test.rb に
# ある（教材が配る。読んでよい。写さない）。
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
