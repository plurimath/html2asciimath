# frozen_string_literal: true

# (c) 2021 Ribose Inc.

require "strscan"

module HTML2MathML
  class Converter < StringScanner
    attr_reader :ast

    def initialize(str)
      super
      @ast = Array.new
    end

    def transform
      scan_input
      to_math_ml
    end

    private

    def scan_input
      repeat_until_error_or_eos do
        skip_ws or scan_next_token or scan_error
      end
    end

    def repeat_until_error_or_eos
      catch(:error) do
        yield until eos?
      end
    end

    def scan_next_token
      # TODO
    end

    def scan_error
      throw :error
    end

    def skip_ws
      skip(/\s+/)
    end

    def push(label, value)
      ast << AstNode.new(label, value)
    end

    def to_math_ml
      [
        "<math>",
        *ast.map(&:to_math_ml),
        "</math>",
      ].join
    end
  end
end
