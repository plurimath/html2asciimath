## RETIRED — superseded by Plurimath

This repository was archived on 2026-11-02 and is no longer maintained. Its
functionality — extracting math from HTML and converting it to AsciiMath — is
fully subsumed by https://github.com/plurimath/plurimath[Plurimath], which
parses HTML documents containing MathML and writes AsciiMath (and every other
supported format).

Gem usage:

[source,ruby]
----
require "plurimath"

html = '<html><body><math><msup><mi>x</mi><mn>2</mn></msup></math></body></html>'
formula = Plurimath::Math.parse(html, :html)
formula.to_asciimath  # => "x^2"
----

Documentation: the formal specifications for every supported format live at
https://plurimath.github.io/docs/ .
