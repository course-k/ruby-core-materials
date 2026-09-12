# frozen_string_literal: true

# 確認課題の雛形。成果リポの rb1-02-twenty-minutes/exercise/lib/greeter.rb へ置いて直す。
# 手本の Greeter を持ってきたもの（挨拶を puts する代わりに文字列で返す形にしてある）。
# 変えるのは 1 箇所だけ。何をどう変えるかは README.md の「確認課題」節に書いてある。
class Greeter
  attr_accessor :name

  def initialize(name = "World")
    @name = name
  end

  def say_hi
    "Hi #{@name}!"
  end
end
