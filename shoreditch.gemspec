# frozen_string_literal: true

require_relative "lib/shoreditch/version"

Gem::Specification.new do |spec|
  spec.name     = "shoreditch"
  spec.version  = Shoreditch::VERSION
  spec.author   = "Mark Coleman"
  spec.email    = "shoreditch@protected.mehcoleman.com"
  spec.summary  = "A two-column Bridgetown theme for technical blogging"
  spec.description = <<~TEXT
    Shoreditch is a Bridgetown theme built for technical writing: a fixed
    sidebar, optional cover images, a content column wide enough for
    80-character code samples, and light/dark support. Adapted from Mark
    Otto's Hyde theme for Jekyll.
  TEXT
  spec.homepage = "https://github.com/MEHColeman/shoreditch"
  spec.license  = "MIT"

  spec.metadata = {
    "source_code_uri" => "https://github.com/MEHColeman/shoreditch",
    "changelog_uri"   => "https://github.com/MEHColeman/shoreditch/blob/master/CHANGELOG.md",
    "homepage_uri"    => "https://shoreditch.mehcoleman.com",
  }

  # `content` is included deliberately: it carries the stylesheet, which the
  # source manifest publishes as a static file. `demo` and `test` are the
  # theme's own development site, `docs` and `scripts` its working notes and
  # tooling — none of them part of the gem.
  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(demo|test|scripts?|spec|features|docs)/|^\.git})
  end
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 3.3"

  spec.add_dependency "bridgetown", "~> 2.0"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "rake", "~> 13.0"
end
