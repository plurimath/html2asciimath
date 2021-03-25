# frozen_string_literal: true

# (c) 2021 Ribose Inc.

require "strscan"

module HTML2AsciiMath
  class Converter < StringScanner
    def transform
      scan_input
      to_asciimath
    end

    private

    def scan_input
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
        # TODO accept symbol
        true
      else
        unscan
        false
      end
    end

    def scan_number
      number = scan(/\d+/) or return # TODO non-integers
      # TODO accept number
      true
    end

    def scan_text
      text = scan(/\w+/) or return
      # TODO distinguish variables (which should be left unquoted), regular
      # text (which should be quoted), and textual operators (e.g. sum).
      # TODO accept text
      true
    end

    def scan_symbol
      # TODO Perhaps brackets should be handled separately
      symb = scan(%r{[-+⋅/=()%!]}) or return
      symb = "//" if symb == "/"
      symb = "*" if symb == "⋅"
      # TODO accept symb
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

    def allowed_entity?(ent_name)
      ALLOWED_ENTITIES.include?(ent_name) ? ent_name : nil
    end

    def to_asciimath
      return "Converted expression" # TODO
    end

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
