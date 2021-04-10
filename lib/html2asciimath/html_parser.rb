# frozen_string_literal: true

# (c) 2021 Ribose Inc.

require "forwardable"
require "strscan"

module HTML2AsciiMath
  class HTMLParser < StringScanner
    extend Forwardable

    attr_reader :converter

    def_delegators :@converter, :push, :open_group, :close_group, :variable_mode=

    def initialize(str, converter)
      super(str)
      @converter = converter
    end

    def parse # rubocop:disable Metrics/CyclomaticComplexity
      repeat_until_error_or_eos do
        scan_element or scan_html_text
      end
    end

    private

    def repeat_until_error_or_eos
      catch(:error) do
        yield until eos?
      end
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

    def scan_html_text
      text = scan(/[^<]+/) or return
      HTMLTextParser.new(text, converter).parse
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

    def on_i(opening)
      self.variable_mode = opening
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
