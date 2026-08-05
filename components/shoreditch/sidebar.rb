# frozen_string_literal: true

# The fixed left column: logo, site identity, navigation and footer.
#
# Navigation is drawn from pages that opt in with `nav_order` in their front
# matter, so a site controls the menu from its content rather than from theme
# configuration. Pages with `exclude: true` never appear.
class Shoreditch::Sidebar < Bridgetown::Component
  def initialize(site:, resource:)
    @site = site
    @resource = resource
  end

  # Components get no implicit access to the site, so it is passed in and
  # exposed for the template.
  attr_reader :site

  def options
    @site.config.shoreditch
  end

  def nav_pages
    @site.collections.pages.resources
      .reject { |page| page.data.exclude }
      .select { |page| page.data.nav_order }
      .sort_by { |page| [page.data.nav_order, page.data.title.to_s] }
  end

  def current?(page)
    page.relative_url == @resource.relative_url
  end

  def logo_source
    @resource.data.logo_location || @site.metadata.logo
  end

  def logo_legend
    # A page can override the badge, or suppress it by setting it to false.
    return @resource.data.logo_legend if @resource.data.key?("logo_legend")

    options[:logo_legend]
  end
end
