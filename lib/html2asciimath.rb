# frozen_string_literal: true

# (c) 2021 Ribose Inc.

require_relative "html2asciimath/version"
require_relative "html2asciimath/ast"
require_relative "html2asciimath/converter"
require_relative "html2asciimath/detector"
require_relative "html2asciimath/html_parser"
require_relative "html2asciimath/html_text_parser"

module HTML2AsciiMath
  class Error < StandardError; end

  def convert(input)
    str = input&.strip
    return str if str.nil? || str.empty?
    Converter.new(str).transform
  end

  def html_replace(input, &block)
    Detector.new(input).replace(&block)
  end

  module_function :convert, :html_replace
end
