# frozen_string_literal: true

# (c) 2021 Ribose Inc.

# rubocop:disable Layout/LineLength
RSpec.describe "formula conversion" do
  xdescribe "Greek" do
    example "&omega;" do
      expect(translate).to eq("<math><mi>&omega;</mi></math>")
    end

    example "&Omega;" do
      expect(translate).to eq("<math><mi>&Omega;</mi></math>")
    end
  end

  describe "numbers" do
    example "1" do
      expect(translate).to eq("<math><mn>1</mn></math>")
    end

    example "123" do
      expect(translate).to eq("<math><mn>123</mn></math>")
    end

    example "-123" do
      expect(translate).to eq("<math><mn>- 123</mn></math>")
      pending "do not add spacing after unary minus"
      expect(translate).to eq("<math><mn>-123</mn></math>")
    end

    example "1.23" do
      expect(translate).to eq("<math><mn>1.23</mn></math>")
    end

    example "-1.23" do
      expect(translate).to eq("<math><mn>- 1.23</mn></math>")
      pending "do not add spacing after unary minus"
      expect(translate).to eq("<math><mn>-1.23</mn></math>")
    end
  end

  describe "variables" do
    example "<i>a</i>" do
      expect(translate).to eq("<math><mi>a</mi></math>")
    end

    example "<i>a</i><i>b</i>" do
      expect(translate).to eq("<math><mi>a</mi><mi>b</mi></math>")
    end

    example "<i>α</i>" do
      expect(translate).to eq("<math><mi>α</mi></math>")
    end

    example "<i>Ж</i>" do
      expect(translate).to eq("<math><mi>Ж</mi></math>")
    end
  end

  describe "basic operators" do
    # (note that fractions cannot be represented in HTML math)

    example "1 + 2" do
      expect(translate).to eq("<math><mn>1</mn><mo>+</mo><mn>2</mn></math>")
    end

    example "&omega; + &theta;" do
      expect(translate).to eq("<math>omega + theta</math>")
    end

    example "1 - 2" do
      expect(translate).to eq("<math><mn>1</mn><mo>-</mo><mn>2</mn></math>")
    end

    example "1 ⋅ 2" do
      expect(translate).to eq("<math><mn>1</mn><mo>*</mo><mn>2</mn></math>")
    end

    example "1 &sdot; 2" do
      expect(translate).to eq("<math><mn>1</mn><mo>&sdot;</mo><mn>2</mn></math>")
    end

    example "1 &times; 2" do
      expect(translate).to eq("<math><mn>1</mn><mo>&times;</mo><mn>2</mn></math>")
    end

    example "1 / 2" do
      expect(translate).to eq("<math><mn>1</mn><mo>/</mo><mn>2</mn></math>")
    end

    example "1 &divide; 2" do
      expect(translate).to eq("<math>1 -: 2</math>")
    end

    example "4!" do
      expect(translate).to eq("<math><mn>4</mn><mo>!</mo></math>")
    end

    example "<i>a</i> + <i>b</i>" do
      expect(translate).to eq("<math>a + b</math>")
    end

    example "<i>a</i> - <i>b</i>" do
      expect(translate).to eq("<math>a - b</math>")
    end

    example "<i>a</i> &sdot; <i>b</i>" do
      expect(translate).to eq("<math>a * b</math>")
    end

    example "<i>a</i> / <i>b</i>" do
      expect(translate).to eq("<math>a // b</math>")
    end
  end

  describe "logic" do
    example "&not;<i>p</i>" do
      expect(translate).to eq("<math>not p</math>")
    end
  end

  describe "other symbols" do
    example "30%" do
      expect(translate).to eq("<math>30 %</math>")
    end

    example "&infin;" do
      expect(translate).to eq("<math>oo</math>")
    end

    example "&forall;<i>x</i>" do
      expect(translate).to eq("<math>VV x</math>")
    end

    example "&exist;<i>x</i>" do
      expect(translate).to eq("<math>EE x</math>")
    end
  end

  describe "equations and inequations" do
    example "<i>a</i> = 3" do
      expect(translate).to eq("<math>a = 3</math>")
    end

    example "1 + 2 = 3" do
      expect(translate).to eq("<math>1 + 2 = 3</math>")
    end

    example "1 &ne; 2" do
      expect(translate).to eq("<math>1 != 2</math>")
    end

    example "1 &lt; 2" do
      expect(translate).to eq("<math>1 < 2</math>")
    end

    example "1 &le; 2" do
      expect(translate).to eq("<math>1 <= 2</math>")
    end

    example "3 &gt; 2" do
      expect(translate).to eq("<math>3 > 2</math>")
    end

    example "3 &ge; 2" do
      expect(translate).to eq("<math>3 >= 2</math>")
    end
  end

  describe "subscript and superscript" do
    example "<i>a</i><sup>2</sup>" do
      expect(translate).to eq("<math>a ^ 2</math>")
    end

    example "<i>a</i><sub>2</sub>" do
      expect(translate).to eq("<math>a _ 2</math>")
    end

    example "<i>a</i><sup><i>n</i></sup>" do
      expect(translate).to eq("<math>a ^ n</math>")
    end

    example "<i>a</i><sub><i>n</i></sub>" do
      expect(translate).to eq("<math>a _ n</math>")
    end

    example "2<sup>3</sup>" do
      expect(translate).to eq("<math>2 ^ 3</math>")
    end

    example "2<sup>3+4</sup>" do
      expect(translate).to eq("<math>2 ^ ( 3 + 4 )</math>")
    end

    example "<i>a</i><sup><i>b</i>+2</sup>" do
      expect(translate).to eq("<math>a ^ ( b + 2 )</math>")
    end

    example "2<sub>3+4</sub>" do
      expect(translate).to eq("<math>2 _ ( 3 + 4 )</math>")
    end

    example "<i>a</i><sub><i>b</i>+2</sub>" do
      expect(translate).to eq("<math>a _ ( b + 2 )</math>")
    end

    example "<i>a</i><sup>-2</sup>" do
      expect(translate).to eq("<math>a ^ ( - 2 )</math>")
      pending "print unary minus without brackets"
      expect(translate).to eq("<math>a ^ -2</math>")
    end

    example "<i>a</i><sub>-2</sub>" do
      expect(translate).to eq("<math>a _ ( - 2 )</math>")
      pending "print unary minus without brackets"
      expect(translate).to eq("<math>a _ -2</math>")
    end

    example "<i>a</i><sup>-<i>n</i></sup>" do
      expect(translate).to eq("<math>a ^ ( - n )</math>")
      pending "print unary minus without brackets"
      expect(translate).to eq("<math>a ^ -n</math>")
    end

    example "<i>a</i><sub>-<i>n</i></sub>" do
      expect(translate).to eq("<math>a _ ( - n )</math>")
      pending "print unary minus without brackets"
      expect(translate).to eq("<math>a _ -n</math>")
    end

    example "<i>a</i><sub><i>n</i></sub><sup>2</sup>" do
      expect(translate).to eq("<math>a _ n ^ 2</math>")
    end

    example "<i>a</i><sub><i>n+1</i></sub><sup><i>b</i>+<i>c</i></sup>" do
      expect(translate).to eq("<math>a _ ( n + 1 ) ^ ( b + c )</math>")
    end
  end

  describe "functions" do
    example "<i>f</i>(<i>x</x>)" do
      expect(translate).to eq("<math>f ( x )</math>")
    end

    example "<i>f</i>(<i>g</i>(<i>x</x>))" do
      expect(translate).to eq("<math>f ( g ( x ) )</math>")
    end
  end

  describe "regular text" do
    example "fib(<i>n</i>)" do
      expect(translate).to eq('"fib" ( n )')
    end

    example "<i>f</i><sub>max</sub>" do
      expect(translate).to eq('f _ "max"')
    end
  end

  # Mixing it all together

  xexample "<i>f</i><sup>-1</sup>(<i>x</x>)" do
    expect(translate).to eq("<math>f ^ ( - 1 ) ( x )</math>")
    pending "print unary minus without brackets"
    expect(translate).to eq("<math>f ^ -1 ( x )</math>")
  end

  xexample "&Pi;<i>r</i><sup>2</sup>" do
    expect(translate).to eq("<math>Pi r ^ 2</math>")
  end

  xexample "<i>x</i><sup><i>a</i> + <i>b</i></sup> = <i>x</i><sup><i>a</i></sup> &sdot; <i>x</i><sup><i>b</i></sup>" do
    expect(translate).to eq("<math>x ^ ( a + b ) = x ^ a * x ^ b</math>")
  end

  xexample "fib(<i>n</i>) = fib(<i>n</i> - 1) + fib(<i>n</i> - 2)" do
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
    HTML2MathML.convert(src)
  end
end
# rubocop:enable Layout/LineLength
