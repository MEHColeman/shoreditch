# frozen_string_literal: true

require "bridgetown"
require "shoreditch/version"

# Shoreditch is a two-column Bridgetown theme aimed at technical blogging.
#
# A site opts in with `init :shoreditch` in config/initializers.rb. Everything
# the theme provides — layouts, components and its stylesheet — arrives through
# the source manifest below, so `bundle update shoreditch` is enough to take a
# new version.
module Shoreditch
  # Defaults a site can override in config/initializers.rb:
  #
  #   init :shoreditch do
  #     accent "#c7254e"
  #     sidebar_side "right"
  #   end
  DEFAULTS = {
    # Any CSS colour. Drives links, tag pills and focus rings.
    accent: "#4c7a9c",
    # "left" or "right" — which side the sidebar sits on at desk widths.
    sidebar_side: "left",
    # Shown under the logo. Set to nil to hide the badge entirely.
    logo_legend: nil,
    # "round" or "square".
    logo_shape: "round",
  }.freeze
end

# @param config [Bridgetown::Configuration::ConfigurationDSL]
Bridgetown.initializer :shoreditch do |config, **options|
  config.shoreditch ||= {}
  Shoreditch::DEFAULTS.each do |key, value|
    config.shoreditch[key] = options.fetch(key, config.shoreditch[key] || value)
  end

  # `content` ships the stylesheet as a static file, which is why the theme
  # needs no npm package and no esbuild wiring in the consuming site. The
  # layout links it directly.
  config.source_manifest(
    origin: Shoreditch,
    components: File.expand_path("../components", __dir__),
    layouts: File.expand_path("../layouts", __dir__),
    content: File.expand_path("../content", __dir__)
  )
end
