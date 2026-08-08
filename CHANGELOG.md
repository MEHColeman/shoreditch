# Changelog

## 1.1.0

First version published to RubyGems. Restores features the 1.0.0 rewrite
dropped without recording, and fixes a set of defects that only showed up once
the demo rendered the theme correctly.

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
- **An automation-installed site never rendered as the theme.** The scaffold's
  starter layouts beat the theme's for every page whose front matter named
  them — including the scaffold's own welcome post, whose explicit `layout:
  post` also defeated the automation's `_defaults.yml` — and the starter
  stylesheet trampled what remained. The automation now retires a starter
  layout or stylesheet only when it is *exactly* the untouched scaffold
  (whitespace aside), points the pages that named a retired layout at the
  theme's — editing only their front matter, never a `layout:` line in body
  text — and leaves anything a site has changed in place with a note.
- **The automation could execute a prompt answer as code.** Answers were
  interpolated into the generated `config/initializers.rb` verbatim, so an
  answer such as `#{`…`}` ran as Ruby every time the site loaded, and one
  containing a quote produced a file that would not parse. Answers carrying a
  quote, a backslash, a newline or a Ruby interpolation are now rejected with
  a note to set that option by hand — escaping was not enough, because
  Bridgetown's initializer insertion rewrites backslashes.

### Added

- `--sd-rule-strong`, a heavier companion to `--sd-rule`. A hairline separator
  can afford to be almost invisible; a border drawn around something so it reads
  as one object cannot. Index entries use it.
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
- `.sd-archive` styling for a flat post archive — titles left, dates right in
  tabular figures, a hairline rule between entries. The page supplies the
  markup (the demo's Posts page groups by year); the theme ships the style.

### Changed

- **The sidebar becomes a compact header band on narrow screens.** Below 60rem
  it had been the desktop column rendered at phone width with nothing resized —
  a 128px logo, a centred stack, the theme toggle and the copyright all ahead of
  the article. On a 390px phone that was 439px of chrome, putting a post's title
  at 80% of the first screen and its copyright notice above the headline. The
  logo now sits inline with the site title, the navigation runs beneath it, and
  the toggle and copyright drop to the foot of the page: 137px, with the title
  at 45%. No menu to open and no JavaScript — the parts are promoted to items of
  the page shell with `display: contents` and reordered.
- **Index entries are framed again**, as they were up to 0.9.0, rather than
  separated by a hairline rule. The frame is what gives the listing a single
  left edge: a post with no thumbnail began its title at the content edge while
  its neighbours began an image-column in, so the stack read as ragged.
  Thumbnails now sit flush to the frame and fill the card's height instead of
  floating inside it with their own rounded corners, excerpts are clamped to
  three lines at a line boundary, and the date moves above the title, set in the
  mono face.
- **Index excerpts are set as plain text** whatever block the post opens with.
  A post beginning with `{:.message}` or a blockquote put a filled, accent-barred
  box in the listing while its neighbours stayed plain.
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
