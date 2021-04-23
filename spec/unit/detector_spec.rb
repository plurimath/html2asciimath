# frozen_string_literal: true

# (c) 2021 Ribose Inc.

RSpec.describe HTML2AsciiMath::Detector do
  describe "FRAGMENT_WORD_AND_BRACKETS" do
    subject { described_class::FRAGMENT_WORD_AND_BRACKETS }

    it { is_expected.to match_entirely("abc(5)") }
    it { is_expected.to match_entirely("abc[0]") }
    it { is_expected.to match_entirely("abc{0}") }
    it { is_expected.to match_entirely("abc(whatever text [and things])") }
    it { is_expected.to match_entirely("ϑ(t)") } # Unicode
    it { is_expected.to match_entirely("ϑ(t)") } # Unicode
  end

  describe "FRAGMENT_SUB_OR_SUP" do
    subject { described_class::FRAGMENT_SUB_OR_SUP }

    it { is_expected.to match_entirely("<sub>sth</sub>") }
    it { is_expected.to match_entirely("<sup>sth</sup>") }
    it { is_expected.not_to match("<sub>sth</sup>") } # closing element mismatch
    it { is_expected.not_to match("<sup>sth</sub>") } # closing element mismatch
    it { is_expected.not_to match("<sub>sth") }
    it { is_expected.not_to match("<sup>sth") }

    it "has no probem with upper and lower case" do
      is_expected.to match_entirely("<sup>sth</SUP>")
    end
  end

  describe "FRAGMENT_B_OR_I" do
    subject { described_class::FRAGMENT_B_OR_I }

    it { is_expected.to match_entirely("<b>sth</b>") }
    it { is_expected.to match_entirely("<i>sth</i>") }
    it { is_expected.to match_entirely("<b><i>sth</i></b>") }
    it { is_expected.to match_entirely("<i><b>sth</b></i>") }

    it "has no probem with upper and lower case" do
      is_expected.to match_entirely("<b>sth</B>")
      is_expected.to match_entirely("<i>sth</I>")
    end
  end

  describe "FRAGMENT_OTHER" do
    subject { described_class::FRAGMENT_OTHER }

    it "matches integer numbers" do
      is_expected.to match_entirely("123")
    end

    it "matches decimal fractions" do
      is_expected.to match_entirely("123.45")
      is_expected.to match_entirely("123,45")
    end

    it "matches all HTML entities" do
      is_expected.to match_entirely("&thetasym;")
      is_expected.to match_entirely("&minus;")
      is_expected.to match_entirely("&Alpha;")
      is_expected.not_to match("&Alpha")
      is_expected.not_to match("Alpha")
    end

    it "matches math operators as maybe math" do
      # TODO Many of them should be considered a sure math
      is_expected.to match_entirely("+")
      is_expected.to match_entirely("-") # ASCII hyphen-minus
      is_expected.to match_entirely("\u2212") # Unicode minus sign
      is_expected.to match_entirely("±")
      is_expected.to match_entirely("⋅")
      is_expected.to match_entirely("×")
      is_expected.to match_entirely("÷")
      is_expected.to match_entirely("/") # ASCII solidus
      is_expected.to match_entirely("\u2215") # Unicode div slash
      is_expected.to match_entirely("=")
      is_expected.to match_entirely("≡")
      is_expected.to match_entirely("≠")
      is_expected.to match_entirely("≤")
      is_expected.to match_entirely("≥")
    end

    it "does not match < and > characters which have special meaning in HTML" do
      is_expected.not_to match("<")
      is_expected.not_to match(">")
    end
  end

  def match_entirely(str)
    match(str) & satisfy { |rx| rx.match(str)&.string == str }
  end
end
