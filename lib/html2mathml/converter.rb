# frozen_string_literal: true

# (c) 2021 Ribose Inc.

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
        scan_next_token or scan_error
      end
    end

    def repeat_until_error_or_eos
      catch(:error) do
        yield until eos?
      end
    end

    def scan_next_token
      # TODO
    end

    def scan_error
      throw :error
    end

    def to_math_ml
      return "Converted expression" # TODO
    end
  end
end
