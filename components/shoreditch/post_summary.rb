# frozen_string_literal: true

# One entry in an index listing — used by both the home page and tag pages.
class Shoreditch::PostSummary < Bridgetown::Component
  def initialize(post:)
    @post = post
  end

  attr_reader :post

  def thumbnail
    post.data.thumbnail
  end

  def date_text
    post.date.strftime("%-d %B %Y")
  end

  def date_attr
    post.date.strftime("%Y-%m-%d")
  end

  # Bridgetown's own summary is the first *source line*. The demo's markdown is
  # hard-wrapped at 80 columns, so that cut three of four excerpts off
  # mid-clause and left the paragraph unclosed. Shoreditch::Excerpt owns the
  # real rule: <!--more--> wins, else the first top-level prose block. Safe to
  # mark html_safe — the input is kramdown's own rendered output.
  def summary
    Shoreditch::Excerpt.extract(post.content).html_safe
  end
end
