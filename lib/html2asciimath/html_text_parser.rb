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
        skip_ws or scan_entity or scan_number or scan_symbol or
          scan_text or scan_error
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

    def scan_entity
      str = scan(/&\w+;/) or return
      ent_name = str[1..-2]

      if allowed_entity?(ent_name)
        symbol = ENTITY_TRANSLATIONS[ent_name] || ent_name
        push(symbol)
        true
      else
        unscan
        false
      end
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
      str = scan(SYMBOLS_RX) or return
      symb = SYMBOLS[str] || str
      push(symb)
      true
    end

    def allowed_entity?(ent_name)
      ALLOWED_ENTITIES.include?(ent_name) ? ent_name : nil
    end

    # Left side is a HTML math symbol recognized by scanner.  Right side is its
    # AsciiMath equivalent or nil when no translation is needed.
    # @todo Perhaps brackets should be handled separately.
    SYMBOLS = {
      "-" => nil,
      "+" => nil,
      "/" => "//",
      "\u22c5" => "*", # (dot operator)
      "=" => nil,
      "(" => nil,
      ")" => nil,
      "%" => nil,
      "!" => nil,
    }
    .freeze

    # A regular expression which matches every symbol defined in +SYMBOLS+ hash.
    SYMBOLS_RX =
      Regexp.new(SYMBOLS.keys.map { |k| Regexp.escape(k) }.join("|")).freeze

    GREEK_ALPHABET = %w[
      alpha beta gamma delta epsilon zeta eta theta iota kappa lambda mu nu xi
      omicron pi rho sigma tau upsilon phi chi psi omega
    ].freeze

    ENTITY_TRANSLATIONS = {
      "ne" => "!=",
      "lt" => "<",
      "le" => "<=",
      "gt" => ">",
      "ge" => ">=",
      "sdot" => "*",
      "times" => "xx",
      "divide" => "-:",
      "infin" => "oo",
      "forall" => "VV",
      "exist" => "EE",
    }.freeze

    ALLOWED_ENTITIES = [
      *GREEK_ALPHABET,
      *GREEK_ALPHABET.map { |l| l.capitalize },
      *GREEK_ALPHABET.map { |l| "var#{l}" }, # varpi, vartheta, etc.
      *ENTITY_TRANSLATIONS.keys,
      "not",
    ].to_set.freeze
  end
end
