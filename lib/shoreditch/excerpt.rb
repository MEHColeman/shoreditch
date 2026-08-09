# frozen_string_literal: true

require "kramdown"

module Shoreditch
  # Extracts an index excerpt from a post's rendered HTML.
  #
  # An explicit <!--more--> marker wins: everything before it is the excerpt.
  # Otherwise the excerpt is the first top-level prose block — a <p> or a
  # <blockquote> — so a post that opens with a code fence or other non-prose
  # block excerpts its first paragraph rather than a code dump. A post with no
  # prose block at all falls back to its first block, balanced.
  #
  # The HTML is parsed with kramdown's own HTML parser rather than cut with a
  # regex (the old first-`</p>` cut landed inside blockquotes and swallowed
  # code blocks whole). Bridgetown 2 has no HTML parser gem in its dependency
  # tree, but kramdown rendered this HTML in the first place, so parsing with
  # it adds no dependency.
  module Excerpt
    MARKER = "<!--more-->"

    # Block types that read as prose in an index listing. A kramdown-attribute
    # paragraph like {:.message} is still a single <p>, so it is covered.
    PROSE = [:p, :blockquote].freeze

    def self.extract(html)
      html = html.to_s
      if (marker = html.index(MARKER))
        return balanced(html[0...marker])
      end

      doc = Kramdown::Document.new(html, input: "html")
      blocks = doc.root.children.reject { |el| [:text, :xml_comment].include?(el.type) }
      pick = blocks.find { |el| prose?(el) } || blocks.first
      pick ? render(doc, [pick]) : html.strip
    end

    # Everything before the marker, re-rendered so a marker placed mid-block
    # still yields closed tags. The content is unchanged; only validity is.
    def self.balanced(html)
      doc = Kramdown::Document.new(html, input: "html")
      render(doc, doc.root.children)
    end
    private_class_method :balanced

    # The HTML parser converts recognised tags to native kramdown elements but
    # leaves ones with markup it will not vouch for as :html_element, so a
    # prose block can arrive either way.
    def self.prose?(el)
      PROSE.include?(el.type) ||
        (el.type == :html_element && PROSE.include?(el.value.to_s.to_sym))
    end
    private_class_method :prose?

    # Conversion needs a :root wrapper — the converter's indent bookkeeping
    # starts below zero on a bare element.
    def self.render(doc, children)
      root = Kramdown::Element.new(:root, nil, nil, doc.root.options)
      root.children = children
      Kramdown::Converter::Html.convert(root, doc.options).first.strip
    end
    private_class_method :render
  end
end
