# frozen_string_literal: true

# (c) 2021 Ribose Inc.

require "forwardable"
require "strscan"

module HTML2AsciiMath
  class HTMLTextParser < StringScanner
    extend Forwardable

    attr_reader :converter

    def_delegators :@converter, :push, :open_group, :close_group, :variable_mode

    def initialize(str, converter)
      super(str)
      @converter = converter
    end

    def parse # rubocop:disable Metrics/CyclomaticComplexity
      repeat_until_error_or_eos do
        skip_ws or scan_number or scan_text or scan_symbol or scan_error
      end
    end

    private

    def repeat_until_error_or_eos
      catch(:error) do
        yield until eos?
      end
    end

    def scan_error
      throw :error
    end

    def skip_ws
      skip(/\s+/)
    end

    def scan_number
      number = scan(/\d+(?:\.\d+)?/) or return
      push(number)
      true
    end

    def scan_text
      text = scan(/\p{Letter}+/) or return
      # TODO distinguish variables (which should be left unquoted), regular
      # text (which should be quoted), and textual operators (e.g. sum).
      push(variable_mode ? text : %["#{text}"])
      true
    end

    def scan_symbol
      # Any character that does not belong to Control category.
      str = scan(/\p{^C}/) or return
      symb = SYMBOLS[str] || str
      push(symb)
      true
    end

    # Left side is a HTML math symbol recognized by scanner.  Right side is its
    # AsciiMath equivalent or nil when no translation is needed.
    # @todo Perhaps brackets should be handled separately.
    SYMBOLS = {
      "-" => nil,
      "+" => nil,
      "×" => "xx",
      "/" => "//",
      "÷" => "-:",
      "\u22c5" => "*", # (dot operator)
      "=" => nil,
      "≤" => "<=",
      "≥" => ">=",
      "≠" => "!=",
      "¬" => "not",
      "∧" => "and",
      "∨" => "or",
      "(" => nil,
      ")" => nil,
      "%" => nil,
      "!" => nil,
      "∃" => "EE",
      "∀" => "AA",
      "∞" => "oo"
    }
    .freeze

    # A regular expression which matches every symbol defined in +SYMBOLS+ hash.
    SYMBOLS_RX =
      Regexp.new(SYMBOLS.keys.map { |k| Regexp.escape(k) }.join("|")).freeze
  end
end
