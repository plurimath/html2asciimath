# frozen_string_literal: true

# (c) 2021 Ribose Inc.

require "cgi"
require "strscan"

module HTML2MathML
  class Converter < StringScanner
    def transform
      scan_input
      to_math_ml
    end

    private

    def scan_input
      repeat_until_error_or_eos do
        scan_html_element or scan_html_text or scan_error
      end
    end

    def repeat_until_error_or_eos
      catch(:error) do
        yield until eos?
      end
    end

    def scan_html_element
      str = scan(%r{</?\w+>}) or return
      # TODO
    end

    def scan_html_text
      str = scan(/[^<]+/) or return
      str = decode_html(str).strip
      # TODO
    end

    def scan_error
      throw :error
    end

    def decode_html(str)
      CGI.unescapeHTML(str)
    end

    def to_math_ml
      "Converted expression" # TODO
    end
  end
end
