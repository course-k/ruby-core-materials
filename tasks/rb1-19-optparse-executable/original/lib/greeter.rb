# frozen_string_literal: true

module Greeter
  def self.call(name, loud:)
    text = "Hello, #{name}!"
    loud ? text.upcase : text
  end
end
