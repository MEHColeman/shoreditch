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
end
