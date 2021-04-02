# frozen_string_literal: true

# (c) 2021 Ribose Inc.

require "cgi"
require "strscan"
require "nokogiri"

module HTML2MathML
  class Converter < StringScanner
    attr_reader :ast, :string, :html_scanner, :html_text_scanner

    def initialize(str)
      @string = str
      @ast = Array.new
      @html_scanner = Nokogiri::HTML::SAX::Parser.new(HTMLScannerCallbacks.new(self))
      @html_text_scanner = HTMLTextScanner.new(self)
    end

    def transform
      html_scanner.parse(string)
      to_math_ml
    end

    def to_math_ml
      [
        "<math>",
        *ast.map(&:to_math_ml),
        "</math>",
      ].join
    end

    class AbstractScanner < StringScanner
      attr_reader :converter

      def initialize(converter, string = "")
        super(string)
        @converter = converter
      end

      def repeat_until_error_or_eos
        catch(:error) do
          yield until eos?
        end
      end

      def scan_error
        throw :error
      end

      def push_to_ast(label, value)
        converter.ast << AstNode.new(label, value)
      end
    end

    class HTMLScannerCallbacks < Nokogiri::XML::SAX::Document
      attr_reader :converter

      def initialize(converter)
        super()
        @converter = converter
        @variable_mode = false
      end

      def characters(str)
        converter.html_text_scanner.string = str
        converter.html_text_scanner.variable_mode = @variable_mode
        converter.html_text_scanner.parse
      end

      def start_element name, attrs = []
        handler = "on_#{name}"
        send(handler, true) if respond_to?(handler, true)
      end

      def end_element name
        handler = "on_#{name}"
        send(handler, false) if respond_to?(handler, true)
      end

      private

      def on_i(opening)
        @variable_mode = opening
      end
    end

    class HTMLTextScanner < AbstractScanner
      attr_accessor :variable_mode

      def parse
        repeat_until_error_or_eos do
          scan_number or scan_text or scan_operator or scan_error
        end
      end

      def scan_number
        number = scan(/\d+(?:\.\d+)?/) or return
        push_to_ast :number, number
        true
      end

      def scan_operator
        symb = scan(/./) or return
        push_to_ast :operator, symb
        true
      end

      def scan_text
        text = scan(/[[:word:]]+|[[:space:]]+|[[:cntrl:]]+/) or return
        text.strip! # TODO preserve spaces inside text
        push_to_ast(variable_mode ? :identifier : :text, text) unless text.empty?
        true
      end
    end
  end
end
