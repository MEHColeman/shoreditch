# Changelog

## 1.0.0

First Bridgetown release. Shoreditch was a Jekyll theme up to 0.9.0; this is a
rewrite rather than a port, so nothing upgrades in place from the Jekyll
version.

### Changed

- Distributed as a gem-based Bridgetown plugin. Previously the only way to use
  it was to clone or fork the repo and edit in place; now `bundle add
  shoreditch` and `init :shoreditch` is enough, and updates arrive through
  `bundle update`.
- Templates are ERB rather than Liquid, as components and layouts served
  through a source manifest.
- Stylesheet rewritten. The inherited `hyde.sass` and `poole.sass` layers are
  gone, along with the Sass dependency; it is now one plain CSS file driven by
  custom properties.
- The sidebar is flexbox, finishing the rewrite announced but abandoned in the
  Jekyll version's final week.
- Fonts are the system stack. The Jekyll version loaded Roboto and Rosario from
  Google Fonts over plain HTTP, which was both a privacy leak and mixed
  content.
- Favicon links are emitted only for files that exist. The Jekyll version
  hard-coded seventeen icon links whether or not the site had them.

### Added

- Light and dark themes, from `prefers-color-scheme` plus a sidebar toggle that
  remembers the reader's choice. Applied before first paint, so no flash.
- Configuration through the initializer: `accent`, `sidebar_side`,
  `logo_legend`, `logo_shape`.
- `bridgetown.automation.rb`, so `bin/bridgetown apply` installs and configures
  the theme in one step.
- Open Graph and Twitter card metadata.
- A skip link, `aria-current` on the active nav item, and visible focus rings.
- `prefers-reduced-motion` support.

### Removed

- Disqus comments. Add them from your own layout override if you want them.
- The Google Analytics hook. Use a privacy-preserving analytics script from
  your site's own head if you need it.
- The `jekyll-paginate-v2` and `classifier-reborn` dependencies — Bridgetown
  paginates natively, and related-posts is a site concern rather than a theme
  one.
- The version badge in the sidebar.
