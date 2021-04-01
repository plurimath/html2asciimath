# frozen_string_literal: true

# (c) 2021 Ribose Inc.

require_relative "html2mathml/version"
require_relative "html2mathml/ast_node"
require_relative "html2mathml/converter"

module HTML2MathML
  class Error < StandardError; end

  def convert(input)
    str = input&.strip
    return str if str.nil? || str.empty?
    Converter.new(str).transform
  end

  module_function :convert
end
