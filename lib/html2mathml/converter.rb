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
      scan_number or scan_symbol
    end

    def scan_error
      throw :error
    end

    def scan_number
      number = scan(/\d+(?:\.\d+)?/) or return
      push :number, number
      true
    end

    def scan_symbol
      symb = scan(SYMBOLS_RX) or return
      push :operator, symb
      true
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

    SYMBOLS = [
      "-",
      "+",
      "/",
      "\u22c5", # (dot operator)
      "=",
      "(",
      ")",
      "%",
      "!",
    ].freeze

    # A regular expression which matches every symbol defined in +SYMBOLS+ hash.
    SYMBOLS_RX =
      Regexp.new(SYMBOLS.map { |k| Regexp.escape(k) }.join("|")).freeze
  end
end
