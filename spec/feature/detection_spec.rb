# frozen_string_literal: true

# (c) 2021 Ribose Inc.

# rubocop:disable Layout/LineLength
RSpec.describe "math detection" do
  example "3 + <i>a</i> &cdot; <i>&Pi;</i> = 7" do
    expect(html_replace).to eq("MATH")
  end

  example "<i>f</i>(<i>x</i>)" do
    expect(html_replace).to eq("MATH")
  end

  example "ISO 80000-2:2009" do
    expect(html_replace).to eq(RSpec.current_example.description) # no math here
  end

  example do
    from = <<~HERE
      This is a text which includes some 1 + 2 = 3 equation.
    HERE
    to = <<~HERE
      This is a text which includes some MATH equation.
    HERE
    expect(html_replace(from)).to eq(to)
  end

  example "The angular frequency is <i>&omega;</i>." do
    expect(html_replace).to eq("The angular frequency is MATH.")
  end

  example do # 103-03-01
    from = <<~HERE
      &epsilon;(<i>x</i> &minus; <i>x</i><sub>0</sub>) denotes a unit step
      at the value <i>x</i><sub>0</sub> of the independent variable <i>x</i>.
    HERE
    to = <<~HERE
      MATH denotes a unit step
      at the value MATH of the independent variable MATH.
    HERE
    expect(html_replace(from)).to eq(to)
  end

  example do # 103-03-01
    from = <<~HERE
      Notation H(<i>x</i>) is also used. Notation &thetasym;(<i>t</i>) is used
      for the unit step function of time. Notation &upsih;(<i>x</i>) has also
      been used.
    HERE
    to = <<~HERE
      Notation MATH is also used. Notation MATH is used
      for the unit step function of time. Notation MATH has also
      been used.
    HERE
    expect(html_replace(from)).to eq(to)
  end

  example do # 102-01-01
    from = <<~HERE
      relation between two entities <i>a</i> and <i>b</i> having the following
      properties:
      <p><ul>
      <li>reflexivity: <i>a</i> = <i>a</i>, </li>
      <li>symmetry: if <i>a</i> = <i>b</i> then <i>b</i> = <i>a</i>, </li> </ul>
    HERE
    to = <<~HERE
      relation between two entities MATH and MATH having the following
      properties:
      <p><ul>
      <li>reflexivity: MATH, </li>
      <li>symmetry: if MATH then MATH, </li> </ul>
    HERE
    expect(html_replace(from)).to eq(to)
  end

  example do # 102-01-07
    from = <<~HERE
      A binary relation between elements <i>a</i> and <i>b</i> is denoted
      by <i>a</i><i>ℛ</i><i>b</i>.
    HERE
    to = <<~HERE
      A binary relation between elements MATH and MATH is denoted
      by MATH.
    HERE
  end

  example do # 121-11-37
    from = <<~HERE
      at a given point within a domain of quasi-infinitesimal volume <i>V</i>,
      vector quantity equal to the electric dipole moment <i><b>p</b></i>  of
      the substance contained within the domain divided by the volume <i>V</i>
    HERE
    to = <<~HERE
      at a given point within a domain of quasi-infinitesimal volume MATH,
      vector quantity equal to the electric dipole moment MATH  of
      the substance contained within the domain divided by the volume MATH
    HERE
    expect(html_replace(from)).to eq(to)
  end

  example do # 112-01-31
    from = <<~HERE
      <li><i>n</i> = <i>I</i>&middot;<i>t</i>/<i>F</i>,
      where <i>n</i> is the amount of substance of a univalent component,
      <i>I</i> is the electric current and <i>t</i> the duration of
      the electrolysis, and where <i>F</i> is the Faraday constant.
    HERE
    to = <<~HERE
      <li>MATH,
      where MATH is the amount of substance of a univalent component,
      MATH is the electric current and MATH the duration of
      the electrolysis, and where MATH is the Faraday constant.
    HERE
    expect(html_replace(from)).to eq(to)
  end

  # Runs described_class#scan on given HTML math string
  def html_replace(src = RSpec.current_example.description)
    HTML2AsciiMath.html_replace(src) { |m| "MATH" }
  end
end
