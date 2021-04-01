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
      # TODO
    end

    def to_math_ml
      "Converted expression" # TODO
    end
  end
end
