# frozen_string_literal: true

# (c) 2021 Ribose Inc.

require "unicode_scanner"

module HTML2AsciiMath
  class Detector < UnicodeScanner
    def initialize(str)
      super(str.dup)
    end

    def replace(&block)
      # TODO
    end
  end
end
