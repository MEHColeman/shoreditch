# Changelog

## Unreleased

Restores features the 1.0.0 rewrite dropped without recording, and fixes a set
of defects that only showed up once the demo rendered the theme correctly.

### Fixed

- **The `accent` option did nothing.** `--sd-accent` was hardcoded in the
  stylesheet and the configured value was never emitted. It is now applied from
  the initializer, after the theme's CSS and before the site's own, and
  validated so a site's config cannot inject CSS.
- **Index listings reserved a thumbnail column whether or not there was a
  thumbnail**, squeezing every title and excerpt of a post without one into a
  128px ribbon.
- **Syntax highlighting is now owned by the theme.** It sets the code
  background, so a site shipping the light-only Rouge palette that
  `bridgetown new` generates rendered keywords black on near-black in dark
  mode.
- `aria-current` was HTML-escaped, so the current nav item was never
  highlighted.
- `<body>` carried `HashWithDotAccess::Hash`, from `data.class` resolving to
  Ruby's `Object#class` rather than the front-matter `class` key.
- Excerpts were the first *source line*, so hard-wrapped markdown was cut
  mid-sentence. `<!--more-->` is honoured, otherwise the first paragraph.
- Every generated tag page shared one `<title>`.
- Code blocks were padded twice, Rouge nesting `pre.highlight` inside
  `div.highlight` and both matching the same rule.
- Pagination rendered an empty nav, and its margin, when there was one page.

### Added

- **Comments**, off unless configured. Giscus ships as the default provider;
  overriding `components/shoreditch/comments.erb` swaps in any other. Replaces
  the Disqus support removed in 1.0.0, without the third-party trackers.
- **The contact panel**, restored from the Jekyll `details.html` include. Brand
  marks are vendored from Simple Icons (CC0) and inlined, rather than loading a
  Font Awesome kit from a CDN on every page.
- **Per-page sidebar overrides** — `include_sticky`, `include_details`,
  `include_logo`, `logo_location`, `logo_shape`, `logo_legend_shape` and
  `flashy_logo`, as the Jekyll version had them.
- **CV styling**, opted into with `class: cv`. Not a layout: a CV is an
  ordinary page whose front matter reshapes the sidebar and whose body class
  tightens the type.
- `.pullquote` and `.code-title` styling, both of which the documentation
  demonstrated but the stylesheet never defined.

### Changed

- **The sidebar splits top and bottom.** The logo, badge, site title and
  tagline stay at the top of the column; the navigation and footer drop to the
  bottom. Previously everything stacked from the top, leaving the empty space
  below the nav with nothing to do.
- **Node 22 is now required** for the frontend build. Bridgetown's esbuild
  configuration calls `fs.globSync`, added in Node 22; on Node 20 the build
  fails while the site still serves, so CSS changes silently never appear.
  Pinned in `demo/.nvmrc`.

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
