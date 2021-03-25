# frozen_string_literal: true

# (c) 2021 Ribose Inc.

require "strscan"

module HTML2AsciiMath
  class Converter < StringScanner
    attr_reader :ast, :ast_stack

    def initialize(str)
      super
      @ast = AST.new
      @ast_stack = [@ast]
      @variable_mode = false
    end

    def transform
      scan_input
      to_asciimath
    end

    private

    def scan_input # rubocop:disable Metrics/CyclomaticComplexity
      repeat_until_error_or_eos do
        skip_ws or scan_entity or scan_number or scan_element or scan_symbol or
          scan_text or scan_error
      end
    end

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

    def scan_element
      str = scan(%r{</?\w+>}) or return
      opening = str[1] != "/"
      elem_name = opening ? str[1..-2] : str[2..-2]

      # TODO else unscan and return false
      if ELEMENT_HANDLERS.key? elem_name
        opening ? open_element(elem_name) : close_element(elem_name)
      end

      true
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
      number = scan(/\d+(?:[.,]\d+)?/) or return
      push(number)
      true
    end

    def scan_text
      text = scan(/\p{Letter}+/) or return
      # TODO distinguish variables (which should be left unquoted), regular
      # text (which should be quoted), and textual operators (e.g. sum).
      push(@variable_mode ? text : %["#{text}"])
      true
    end

    def scan_symbol
      str = scan(SYMBOLS_RX) or return
      symb = SYMBOLS[str] || str
      push(symb)
      true
    end

    def open_element(elem_name)
      # TODO maintain some elements stack
      send(ELEMENT_HANDLERS[elem_name], true)
    end

    def close_element(elem_name)
      # TODO auto-close elements which are above this one in elements stack
      send(ELEMENT_HANDLERS[elem_name], false)
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

    def allowed_entity?(ent_name)
      ALLOWED_ENTITIES.include?(ent_name) ? ent_name : nil
    end

    def on_i(opening)
      @variable_mode = opening
    end

    def on_sub(opening)
      if opening
        push "_"
        open_group
      else
        close_group
      end
    end

    def on_sup(opening)
      if opening
        push "^"
        open_group
      else
        close_group
      end
    end

    def to_asciimath
      ast.to_asciimath
    end

    # Left side is a HTML math symbol recognized by scanner.  Right side is its
    # AsciiMath equivalent or nil when no translation is needed.
    # @todo Perhaps brackets should be handled separately.
    SYMBOLS = {
      "-" => nil,
      "\u2013" => "-",
      "+" => nil,
      "/" => "//",
      "\u22c5" => "*", # (dot operator)
      "=" => nil,
      "(" => nil,
      ")" => nil,
      "%" => nil,
      "!" => nil,
      ";" => nil,
      "," => nil,
      "..." => nil,
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
      "middot" => "*",
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

    # Associates element names with element handlers.
    #
    # Example: <code>{ "some_tag_name" => :on_some_tag_name }</code>
    ELEMENT_HANDLERS = (instance_methods + private_instance_methods)
      .grep(/\Aon_/)
      .map { |h| [h.to_s[3..].freeze, h] }
      .to_h
      .freeze
  end
end
