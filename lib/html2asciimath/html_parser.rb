# frozen_string_literal: true

# (c) 2021 Ribose Inc.

require "forwardable"
require "nokogiri"

module HTML2AsciiMath
  class HTMLParser < Nokogiri::HTML::SAX::Parser
    extend Forwardable

    attr_reader :converter, :string

    def_delegators :@converter, :push, :open_group, :close_group, :variable_mode=

    def initialize(str, converter)
      super(SAXCallbacks.new(self))
      @string = str
      @converter = converter
    end

    def parse
      super(string)
    end

    private

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

    class SAXCallbacks < Nokogiri::XML::SAX::Document
      attr_reader :parser

      def initialize(parser)
        @parser = parser
      end

      def characters(text)
        HTMLTextParser.new(text, parser.converter).parse
        true
      end

      def start_element(elem_name, _attrs = [])
        # TODO maintain some elements stack
        send(ELEMENT_HANDLERS[elem_name], true)
      end

      def end_element(elem_name)
        # TODO auto-close elements which are above this one in elements stack
        send(ELEMENT_HANDLERS[elem_name], false)
      end
    end
  end
end
