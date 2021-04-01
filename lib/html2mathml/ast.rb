# frozen_string_literal: true

# (c) 2021 Ribose Inc.

module HTML2AsciiMath
  # Abstract syntax tree implemented as array of arrays and other objects.
  class AST < Array
    module Refinements
      refine Object do
        def to_asciimath(**)
          itself
        end
      end
    end

    using Refinements

    def to_asciimath(child: false)
      result = map { |item| item.to_asciimath(child: true) }.join(" ")
      child && size > 1 ? "( #{result} )" : result
    end
  end
end
