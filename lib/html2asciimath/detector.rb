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

    # HTML entity
    RX_ENTITY = /&#?\w{,8};/

    # Word immediately followed with brackets.
    FRAGMENT_WORD_AND_BRACKETS = %r{
      (?> \p{L}+)
      (?: \( .*? \) | \[ .*? \] | \{ .*? \} )
    }x

    FRAGMENT_SUB_OR_SUP = %r{
      \< sub \> .*? \< / sub \> |
      \< sup \> .*? \< / sup \>
    }xi

    FRAGMENT_B_OR_I = %r{
      (?<b_or_i>
        (?> \< b \> ) (?: \g<b_or_i> | (?<inner> [^<>\p{Z}\p{C}]*?)) \< / b \>
        |
        (?> \< i \> ) (?: \g<b_or_i> | (?<inner> [^<>\p{Z}\p{C}]*?)) \< / i \>
      )
    }xi

    FRAGMENT_OTHER = %r{
      # numbers
      \d+[,.]\d+ |
      \d+ |
      # entities
      #{RX_ENTITY} |
      # math symbols with exception of angle brackets which are part of HTML
      # syntax
      (?![<>]) \p{Sm} |
      # some ASCII characters used as operators which do not belong to Sm
      [-/()]
    }xo
  end
end
