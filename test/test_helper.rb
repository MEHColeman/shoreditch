# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

require "minitest/autorun"
require "kramdown"
require "kramdown-parser-gfm"
require "rouge"
require "shoreditch/excerpt"

module Shoreditch
  module TestHelpers
    # Renders markdown the way Bridgetown feeds it to the components: GFM
    # input, Rouge highlighting. Tests build their fixtures through this so
    # they exercise the real rendered shapes, not hand-written approximations.
    def render_markdown(source)
      Kramdown::Document.new(
        source,
        input: "GFM",
        hard_wrap: false,
        syntax_highlighter: "rouge"
      ).to_html
    end
  end
end
