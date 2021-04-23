# frozen_string_literal: true

# (c) 2021 Ribose Inc.

require "unicode_scanner"

module HTML2AsciiMath
  class Detector < UnicodeScanner
    def initialize(str)
      super(str.dup)
    end

    def replace(&block)
      scan_for_math do |math_start, math_end, score|
        range = (math_start...math_end)
        source_math = string[range]
        target_math = yield source_math
        string[range] = target_math
        self.pos += (target_math.size - source_math.size)
      end
      string
    end

    private

    def scan_for_math
      fast_forward_inline_whitespace

      until eos? do
        assess_candidate
        yield [@start, @end, @score] if good_score?
        fast_forward_to_next_candidate
      end
    end

    def assess_candidate
      init_candidate
      nil while match_candidate_fragment
    end

    def match_candidate_fragment
      fast_forward_inline_whitespace

      case
      when scan(FRAGMENT_WORD_AND_BRACKETS)
        score_sure
      when scan(FRAGMENT_SUB_OR_SUP)
        score_almost_sure
      when scan(FRAGMENT_B_OR_I)
        single_char_or_entity?(self[:inner]) ? score_sure : score_maybe
      when scan(FRAGMENT_OTHER)
        score_maybe
      end

      matched?
    end

    def fast_forward_inline_whitespace
      skip(/\p{Zs}*/)
    end

    def fast_forward_to_next_candidate
      skip(/(?>\p{L}+|.)[[:space:]]*/m)
    end

    def init_candidate
      @score = 0
      @start = pos
    end

    def score_sure
      @score += GOOD_SCORE_THRESHOLD
      @end = pos
    end

    def score_almost_sure
      @score += GOOD_SCORE_THRESHOLD - 1
      @end = pos
    end

    def score_maybe
      @score += 1
      @end = pos
    end

    def good_score?
      @score >= GOOD_SCORE_THRESHOLD
    end

    def single_char_or_entity?(str)
      str.match? /\A(\S|#{RX_ENTITY})\Z/o
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

    GOOD_SCORE_THRESHOLD = 11
  end
end
