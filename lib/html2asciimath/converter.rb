# frozen_string_literal: true

# (c) 2021 Ribose Inc.

module HTML2AsciiMath
  # This class is responsible for converting HTML math expressions to AsciiMath.
  #
  # It runs two small parsers: first HTMLparser deals with HTML syntax, and then
  # HTMLTextParser processes textual content found between HTML elements.
  # Thanks to this two-phase processing, HTMLTextParser receives input which is
  # already decoded (i.e. without any HTML entities), which in turn allows to
  # keep its grammar simple.
  #
  # @example
  #   html_string = "<i>x</i>+<i>y</i>"
  #   Converter.new(html_string).transform # => "x + y"
  class Converter
    attr_reader :ast, :ast_stack, :html_parser
    attr_accessor :variable_mode

    def initialize(str)
      @html_parser = HTMLParser.new(str, self)
    end

    def transform
      to_asciimath
    end

    def open_group
      ast_stack.push AST.new
    end

    def close_group
      push ast_stack.pop
    end

    def push(*objs)
      ast_stack.last.push(*objs)
    end

    def to_asciimath
      parse
      ast.to_asciimath
    end

    def parse
      return if @ast

      @ast = AST.new
      @ast_stack = [@ast]
      @variable_mode = false
      html_parser.parse
    end
  end
end
