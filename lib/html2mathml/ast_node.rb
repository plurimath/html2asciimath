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

    def to_math_ml_as_number
      wrap_in_tag("mn", value)
    end

    def to_math_ml_as_operator
      wrap_in_tag("mo", value)
    end

    def wrap_in_tag(tag_name, content)
      "<#{tag_name}>#{content}</#{tag_name}>"
    end
  end
end
