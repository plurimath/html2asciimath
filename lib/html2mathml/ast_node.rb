# frozen_string_literal: true

# (c) 2021 Ribose Inc.

module HTML2MathML
  # Represents AST node.
  #
  # +label+ describes node semantics (identifier, number, operator, etc.).
  # +value+ is the associated node value.
  class AstNode
    attr_reader :label, :value

    def initialize(label, value)
      @label = label
      @value = value
    end

    def inspect
      "(#{label}: #{value})"
    end

    def to_math_ml
      send("to_math_ml_as_#{label}")
    end

    def to_math_ml_as_identifier
      wrap_in_tag("mi", value)
    end

    def to_math_ml_as_number
      wrap_in_tag("mn", value)
    end

    def to_math_ml_as_operator
      wrap_in_tag("mo", value)
    end

    def to_math_ml_as_subscript
      wrap_in_tag("mtext", value)
    end

    def to_math_ml_as_superscript
      wrap_in_tag("mtext", value)
    end

    def to_math_ml_as_text
      wrap_in_tag("mtext", value)
    end

    def wrap_in_tag(tag_name, content)
      "<#{tag_name}>#{escape_for_xml content}</#{tag_name}>"
    end

    # From https://github.com/asciidoctor/asciimath/blob/3a4bbab7da/lib/asciimath/mathml.rb
    def escape_for_xml(str)
      str.each_codepoint.inject(String.new) do |acc, cp|
        if cp == 38
          acc << "&amp;"
        elsif cp == 60
          acc << "&lt;"
        elsif cp == 62
          acc << "&gt;"
        elsif cp > 127
          acc << "&#x#{cp.to_s(16).upcase};"
        else
          acc << cp
        end
      end
    end
  end
end
