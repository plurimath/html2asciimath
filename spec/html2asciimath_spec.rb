# frozen_string_literal: true

# (c) 2021 Ribose Inc.

# rubocop:disable Layout/LineLength
RSpec.describe HTML2AsciiMath do
  it "has a version number" do
    expect(HTML2AsciiMath::VERSION).not_to be nil
  end

  describe "Greek" do
    example "&omega;" do
      expect(translate).to eq("omega")
    end

    example "&Omega;" do
      expect(translate).to eq("Omega")
    end
  end

  describe "numbers" do
    example "1" do
      expect(translate).to eq("1")
    end

    example "123" do
      expect(translate).to eq("123")
    end

    example "-123" do
      expect(translate).to eq("- 123")
      pending "do not add spacing after unary minus"
      expect(translate).to eq("-123")
    end

    example "1.23" do
      expect(translate).to eq("1.23")
    end

    example "-1.23" do
      expect(translate).to eq("- 1.23")
      pending "do not add spacing after unary minus"
      expect(translate).to eq("-1.23")
    end
  end

  describe "variables" do
    example "<i>a</i>" do
      expect(translate).to eq("a")
    end

    example "<i>a</i><i>b</i>" do
      expect(translate).to eq("a b")
    end

    example "<i>α</i>" do
      expect(translate).to eq("α")
    end

    example "<i>Ж</i>" do
      expect(translate).to eq("Ж")
    end
  end

  describe "basic operators" do
    # (note that fractions cannot be represented in HTML math)

    example "1 + 2" do
      expect(translate).to eq("1 + 2")
    end

    example "&omega; + &theta;" do
      expect(translate).to eq("omega + theta")
    end

    example "1 - 2" do
      expect(translate).to eq("1 - 2")
    end

    example "1 ⋅ 2" do
      expect(translate).to eq("1 * 2")
    end

    example "1 &sdot; 2" do
      expect(translate).to eq("1 * 2")
    end

    example "1 &times; 2" do
      expect(translate).to eq("1 xx 2")
    end

    example "1 / 2" do
      expect(translate).to eq("1 // 2")
    end

    example "1 &divide; 2" do
      expect(translate).to eq("1 -: 2")
    end

    example "4!" do
      expect(translate).to eq("4 !")
    end

    example "<i>a</i> + <i>b</i>" do
      expect(translate).to eq("a + b")
    end

    example "<i>a</i> - <i>b</i>" do
      expect(translate).to eq("a - b")
    end

    example "<i>a</i> &sdot; <i>b</i>" do
      expect(translate).to eq("a * b")
    end

    example "<i>a</i> / <i>b</i>" do
      expect(translate).to eq("a // b")
    end
  end

  describe "logic" do
    example "&not;<i>p</i>" do
      expect(translate).to eq("not p")
    end
  end

  describe "other symbols" do
    example "30%" do
      expect(translate).to eq("30 %")
    end

    example "&infin;" do
      expect(translate).to eq("oo")
    end

    example "&forall;<i>x</i>" do
      expect(translate).to eq("VV x")
    end

    example "&exist;<i>x</i>" do
      expect(translate).to eq("EE x")
    end
  end

  describe "equations and inequations" do
    example "<i>a</i> = 3" do
      expect(translate).to eq("a = 3")
    end

    example "1 + 2 = 3" do
      expect(translate).to eq("1 + 2 = 3")
    end

    example "1 &ne; 2" do
      expect(translate).to eq("1 != 2")
    end

    example "1 &lt; 2" do
      expect(translate).to eq("1 < 2")
    end

    example "1 &le; 2" do
      expect(translate).to eq("1 <= 2")
    end

    example "3 &gt; 2" do
      expect(translate).to eq("3 > 2")
    end

    example "3 &ge; 2" do
      expect(translate).to eq("3 >= 2")
    end
  end

  describe "subscript and superscript" do
    example "<i>a</i><sup>2</sup>" do
      expect(translate).to eq("a ^ 2")
    end

    example "<i>a</i><sub>2</sub>" do
      expect(translate).to eq("a _ 2")
    end

    example "<i>a</i><sup><i>n</i></sup>" do
      expect(translate).to eq("a ^ n")
    end

    example "<i>a</i><sub><i>n</i></sub>" do
      expect(translate).to eq("a _ n")
    end

    example "2<sup>3</sup>" do
      expect(translate).to eq("2 ^ 3")
    end

    example "2<sup>3+4</sup>" do
      expect(translate).to eq("2 ^ ( 3 + 4 )")
    end

    example "<i>a</i><sup><i>b</i>+2</sup>" do
      expect(translate).to eq("a ^ ( b + 2 )")
    end

    example "2<sub>3+4</sub>" do
      expect(translate).to eq("2 _ ( 3 + 4 )")
    end

    example "<i>a</i><sub><i>b</i>+2</sub>" do
      expect(translate).to eq("a _ ( b + 2 )")
    end

    example "<i>a</i><sup>-2</sup>" do
      expect(translate).to eq("a ^ ( - 2 )")
      pending "print unary minus without brackets"
      expect(translate).to eq("a ^ -2")
    end

    example "<i>a</i><sub>-2</sub>" do
      expect(translate).to eq("a _ ( - 2 )")
      pending "print unary minus without brackets"
      expect(translate).to eq("a _ -2")
    end

    example "<i>a</i><sup>-<i>n</i></sup>" do
      expect(translate).to eq("a ^ ( - n )")
      pending "print unary minus without brackets"
      expect(translate).to eq("a ^ -n")
    end

    example "<i>a</i><sub>-<i>n</i></sub>" do
      expect(translate).to eq("a _ ( - n )")
      pending "print unary minus without brackets"
      expect(translate).to eq("a _ -n")
    end

    example "<i>a</i><sub><i>n</i></sub><sup>2</sup>" do
      expect(translate).to eq("a _ n ^ 2")
    end

    example "<i>a</i><sub><i>n+1</i></sub><sup><i>b</i>+<i>c</i></sup>" do
      expect(translate).to eq("a _ ( n + 1 ) ^ ( b + c )")
    end
  end

  describe "functions" do
    example "<i>f</i>(<i>x</x>)" do
      expect(translate).to eq("f ( x )")
    end

    example "<i>f</i>(<i>g</i>(<i>x</x>))" do
      expect(translate).to eq("f ( g ( x ) )")
    end
  end

  describe "regular text" do
    example "fib(<i>n</i>)" do
      expect(translate).to eq('"fib" ( n )')
    end

    example "<i>f</i><sub>max</sub>" do
      expect(translate).to eq('f _ "max"')
    end

    example "αβγ" do
      expect(translate).to eq('"αβγ"')
    end

    example "абг" do
      expect(translate).to eq('"абг"')
    end
  end

  # Mixing it all together

  example "<i>f</i><sup>-1</sup>(<i>x</x>)" do
    expect(translate).to eq("f ^ ( - 1 ) ( x )")
    pending "print unary minus without brackets"
    expect(translate).to eq("f ^ -1 ( x )")
  end

  example "&Pi;<i>r</i><sup>2</sup>" do
    expect(translate).to eq("Pi r ^ 2")
  end

  example "<i>x</i><sup><i>a</i> + <i>b</i></sup> = <i>x</i><sup><i>a</i></sup> &sdot; <i>x</i><sup><i>b</i></sup>" do
    expect(translate).to eq("x ^ ( a + b ) = x ^ a * x ^ b")
  end

  example "fib(<i>n</i>) = fib(<i>n</i> - 1) + fib(<i>n</i> - 2)" do
    expect(translate).to eq('"fib" ( n ) = "fib" ( n - 1 ) + "fib" ( n - 2 )')
  end

  # Real-life examples from Electropedia

  pending "<i>a</i><i>ℛ</i><i>b</i>"
  pending "<i>T</i> = (1/2) <i>m</i><i>v</i><sup>2</sup>"
  pending "<i>n</i> = <i>I</i>&middot;<i>t</i>/<i>F</i>"
  pending "<i>f</i>(<i>Q</i><sub>1</sub>, <i>Q</i><sub>2</sub>, ... <i>Q<sub>n</sub></i>) = 0" # 112-01-31
  pending "{<i>Q</i>}[[<i>Q</i>]]" # 112-01-28
  pending "(<i>F</i><sub><i>x</i></sub>; <i>F</i><sub><i>y</i></sub>; <i>F</i><sub><i>z</i></sub>) = (–31,5; 43,2; 17,0) N" # 112-01-28
  pending "dim(refractive index <i>n</i> = <i>c</i><sub>0</sub>/<i>c</i>) = (LT<sup>–1</sup>)<sup>0</sup>" # 112-01-13
  pending "H(<i>x</i>)" # 103-03-01
  pending "(<b><i>U</i></b><sup>H</sup><b><i>AU</i></b>)<sub>11</sub> &gt; 0" # 102-06-29
  pending "<b><i>U</i></b><sup>H</sup><b><i>AU</i></b>" # 102-06-29
  pending "<b><i>AA</i></b><sup>&minus;1</sup> = <b><i>A</i></b><sup>&minus;1</sup><b><i>A</i></b> = <b><i>E</i></b>" # 102-06-16
  pending "<b><i>A</i></b><sup>&minus;1</sup> = (<i>A<sub>ij</i></sub>)<sup>&minus;1</sup>" # 102-06-16

  # Runs described_class#convert on given HTML math string
  def translate(src = RSpec.current_example.description)
    described_class.convert(src)
  end
end
# rubocop:enable Layout/LineLength
