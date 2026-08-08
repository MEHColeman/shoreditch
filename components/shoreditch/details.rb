# frozen_string_literal: true

# The contact panel: how to reach the author, and where else they are.
#
# Restored from the Jekyll theme's `_includes/details.html`, with two changes.
# Icons are inlined from the vendored Simple Icons set rather than pulled from
# a Font Awesome CDN kit on every page load, and the markup is a definition of
# links rather than a list of hard-coded network blocks, so adding a network is
# one entry in ENTRIES.
#
# Everything is driven by `author` in src/_data/site_metadata.yml. A page opts
# in with `include_details: true` in its front matter — off elsewhere, since a
# blog post has no use for a phone number.
class Shoreditch::Details < Bridgetown::Component
  # network key => [icon, url template, label]. `%s` takes the handle.
  ENTRIES = [
    [:github,     :github,     "https://github.com/%s",         "%s"],
    [:mastodon,   :mastodon,   "%s",                            "Mastodon"],
    [:linkedin,   :link,       "https://linkedin.com/in/%s",    "%s"],
    [:twitter,    :x,          "https://x.com/%s",              "@%s"],
    [:instagram,  :instagram,  "https://instagram.com/%s",      "%s"],
    [:reddit,     :reddit,     "https://reddit.com/user/%s",    "%s"],
    [:youtube,    :youtube,    "%s",                            "YouTube"],
    [:tiktok,     :tiktok,     "https://tiktok.com/@%s",        "%s"],
    [:lastfm,     :lastfm,     "https://last.fm/user/%s",       "%s"],
    [:deviantart, :deviantart, "https://deviantart.com/%s",     "%s"],
    [:artstation, :artstation, "https://artstation.com/%s",     "%s"],
  ].freeze

  def initialize(site:, resource:)
    @site = site
    @resource = resource
  end

  attr_reader :site, :resource

  # Not `author.present?`: site.metadata is a HashWithDotAccess::Hash, which
  # routes unknown methods to key lookups, so `present?` returns nil for a
  # missing "present" key rather than calling ActiveSupport. Only methods Hash
  # genuinely defines are safe to call on it.
  def render?
    resource.data.include_details == true && author.is_a?(Hash) && !author.empty?
  end

  def author
    site.metadata.author
  end

  # [key, icon, href, text] for each network the site actually filled in. The
  # key and the icon are separate because they diverge: LinkedIn is styled as
  # linkedin but drawn with the generic `link` mark.
  def links
    ENTRIES.filter_map do |key, icon, url, label|
      handle = author[key.to_s].to_s.strip
      next if handle.empty?

      [key, icon, format(url, handle), format(label, handle)]
    end
  end

  def phone = author["phone"].to_s.strip

  def file_url = author["file_url"].to_s.strip

  def file_link_text
    text = author["file_link_text"].to_s.strip
    text.empty? ? "Download" : text
  end

  # Kept split across two metadata keys, as the Jekyll version had it, so the
  # address never appears whole in the HTML for a crawler to lift. Assembled by
  # shoreditch.js. Without JavaScript the address is simply not shown, which is
  # the trade the original made too.
  def email_parts
    [author["email_1"].to_s.strip, author["email_2"].to_s.strip]
  end

  def email? = email_parts.none?(&:empty?)

  def icon(name)
    Shoreditch::ICONS[name]
  end
end
