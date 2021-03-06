# frozen_string_literal: true

require_relative "lib/html2asciimath/version"

Gem::Specification.new do |spec|
  spec.name          = "html2asciimath"
  spec.version       = HTML2AsciiMath::VERSION
  spec.authors       = ["Ribose"]
  spec.email         = ["open.source@ribose.com"]
  spec.license       = "MIT"

  spec.summary       = "Converts simple math formulae written in pure HTML " +
    "to AsciiMath"

  spec.homepage      = "https://www.plurimath.org/"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/plurimath/html2asciimath"

  all_files_in_git = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0")
  end

  # Specify which files should be added to the gem when it is released.
  spec.files = all_files_in_git.select do |f|
    f.start_with?("exe/", "lib/", "README.", "LICENSE.") ||
      f.end_with?(".gemspec")
  end

  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = Gem::Requirement.new(">= 2.6.0")

  spec.add_runtime_dependency "nokogiri"
  spec.add_runtime_dependency "unicode_scanner", "~> 1.0"
end
