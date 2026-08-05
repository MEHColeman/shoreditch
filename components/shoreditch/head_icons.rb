# frozen_string_literal: true

# Favicon and touch-icon links.
#
# Only emitted for files the site actually has. The Jekyll theme hard-coded the
# full apple-touch-icon set, which meant every site using the theme requested a
# dozen icons whether or not they existed.
class Shoreditch::HeadIcons < Bridgetown::Component
  APPLE_SIZES = %w[57x57 60x60 72x72 76x76 114x114 120x120 144x144 152x152 180x180].freeze
  PNG_SIZES = %w[16x16 32x32 96x96 192x192].freeze

  def initialize(site:, prefix: "")
    @site = site
    @prefix = prefix
  end

  def apple_icons
    APPLE_SIZES.filter_map do |size|
      path = "#{@prefix}/apple-icon-#{size}.png"
      [size, path] if exists?(path)
    end
  end

  def png_icons
    PNG_SIZES.filter_map do |size|
      # The 192px icon is named for Android; the rest are plain favicons.
      name = size == "192x192" ? "android-icon-192x192" : "favicon-#{size}"
      path = "#{@prefix}/#{name}.png"
      [size, path] if exists?(path)
    end
  end

  def favicon
    path = "#{@prefix}/favicon.ico"
    path if exists?(path)
  end

  def manifest
    path = "#{@prefix}/manifest.json"
    path if exists?(path)
  end

  private

  def exists?(path)
    File.exist?(File.join(@site.config.source, path))
  end
end
