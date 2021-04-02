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
      @html_scanner = Nokogiri::HTML::SAX::Parser.new(HTMLScannerCallbacks.new)
      @html_text_scanner = HTMLTextScanner.new(self)
    end

    def transform
      html_scanner.parse
      to_math_ml
    end

    # def parse_html



    # def parse_html_text(str)
    #   str = decode_html(str)

    #   while MATH_ITEM_RX =~ str

    #   end

    #   # TODO check if end

    #   # str.scan(FORMULA_TOKEN_RX) do
    #   # end
    #   # text_scanner = StringScanner.new(decode_html(str))


    #   interpret_token(token) while token = text_scanner.scan(FORMULA_TOKEN_RX)
    # end

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
      def characters(str)
        converter.html_text_scanner.string = str
        converter.html_text_scanner.parse
      end
      # def parse
      #   repeat_until_error_or_eos do
      #     scan_html_element or scan_html_text or scan_error
      #   end
      # end

      # def scan_html_element
      #   str = scan(%r{</?\w+>}) or return
      #   # TODO
      # end

      # def scan_html_text
      #   str = scan(/[^<]+/) or return
      #   parse_html_text(str)
      # end

      # def parse_html_text(str)
      # end

      # def decode_html(str)
      #   CGI.unescapeHTML(str) # TODO CGI handles only some entities
      # end
    end

    class HTMLTextScanner < AbstractScanner
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
        push_to_ast :text, text unless text.empty?
        true
      end
    end
  end
end
