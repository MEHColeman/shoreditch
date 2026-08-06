# shoreditch — journal

### 2026-08-05 — actions

Rebuilt Shoreditch as a Bridgetown theme gem, version 1.0.0. It had been a
Jekyll theme, dormant since September 2022 at 0.9.0.

The distribution model was the point of the exercise. Previously the only way
to use the theme was to clone or fork the repo and edit in place — the README's
own advice was to keep content on one branch and rebase it onto the theme's,
which is exactly what had entangled this repo with the author's blog. It is now
`bundle add shoreditch` plus `init :shoreditch`.

Chose not to follow Bridgetown's documented route for plugin frontend assets,
which is to publish a companion NPM package and have users add an import to
their esbuild entry points. For a theme this size that means a second registry
to keep version-synced and a manual step for every user. Instead the CSS and JS
live under `content/`, which the source manifest publishes as static files, and
the layout links them at `/shoreditch/*`. Nothing to import, nothing to publish
twice, and `bundle update` delivers a new version.

The design is a rewrite rather than a port. The two-column shape is inherited;
the layered `hyde.sass` / `poole.sass` / `shoreditch.sass` and the Sass
dependency are gone, replaced by one plain CSS file driven by custom properties
so consuming sites can override rather than fork. Light and dark come from
`prefers-color-scheme` plus a sidebar toggle, applied by an inline script before
first paint to avoid a flash of the wrong scheme.

This also finished the flexbox sidebar rewrite announced in `8ace640` and
abandoned four days later when the repo went dormant.

Three things were quietly wrong in the Jekyll version and are fixed: fonts were
pulled from Google Fonts over plain `http`, which was both a privacy leak and
mixed content on an https site; seventeen favicon links were hard-coded whether
or not a site had the files; and the sidebar navigation was a fixed list rather
than something a site could drive from its own content.

The one API surprise worth recording: a `Bridgetown::Component` has no implicit
access to `site`. Both `Sidebar` and `HeadIcons` needed it passed in explicitly,
and the failure mode is an unhelpful `undefined method 'config' for nil` at
render time rather than anything that points at the cause.

Added `demo/`, a Bridgetown site consuming the theme from the parent directory,
published to GitHub Pages. Most of the old demo posts were dropped rather than
migrated — three of the seven documented per-page options the rewrite removed,
so they described a theme that no longer exists.

Enabled Pages with GitHub Actions as the source. The deploy job had been failing
for a reason worth noting: with `build_type: workflow`, GitHub takes the custom
domain from repo settings and ignores a `CNAME` file in the uploaded artifact,
so `demo/src/CNAME` alone was not enough.

Left the default branch as `master` rather than renaming to `main`. Renaming a
public repo's default branch breaks existing clones and links, and the workflow
was pointed at `master` instead.

### 2026-08-06 — the demo had never shown the theme

Mark looked at the rendered theme for the first time and said it did not look
like Shoreditch. He was right, for a reason nobody had found: the demo still
carried the stock `bridgetown new` stylesheet at
`demo/frontend/styles/index.css`, and the theme deliberately loads a site's own
CSS *after* its own so a site can override without forking. The starter file
used that precedence to trample it — `main { max-width: 65rem; margin: auto;
background: white }` matched `.sd-main` and pulled it out of the two-column
grid, `a { color: #d64045 }` masked the accent, and a `body` rule kept dark mode
rendering a white page. **The demo had never once displayed the theme as
designed**, from the day it was added.

Underneath that, a second cause: Bridgetown's `config/esbuild.defaults.js`
calls `fs.globSync`, a Node 22 API. The machine's nvm default was Node 20, so
esbuild had been throwing on every run while `bin/bridgetown start` carried on
serving. Stylesheet edits silently never reached the browser and the bundle
compiled at 18:35 the previous day was still being served. Pinned in
`demo/.nvmrc`. The `Node >= 22` line in `demo/README.md` had been dismissed as
scaffold boilerplate; it was load-bearing.

The `accent` option had never worked. `--sd-accent` was hardcoded in the
stylesheet and the configured value was emitted nowhere, so the demo's crimson
had been rendering slate blue since 1.0.0 — while the automation's first prompt
cheerfully asked users to choose one.

Restoring the dropped features turned up that two of the three were not what
their names implied. `_includes/sticky.html` was the sidebar's title-and-nav
block, not pinned posts, and `include_sticky: false` was a per-page switch to
hide it. The "details panel" was the social links under another name. And the
CV was never a layout — it was `layout: page` plus `class: "cv highlight"` plus
front-matter switches, which is what the broken `data.class` in the layout had
been reaching for all along.

Two bugs shared one cause worth remembering: `HashWithDotAccess::Hash` routes
unknown methods to key lookups. That is why `data.class` put
`HashWithDotAccess::Hash` on every `<body>`, and why `author.present?` returned
`nil` rather than calling ActiveSupport — silently disabling the entire contact
panel with no error anywhere. Only methods `Hash` genuinely defines are safe to
call on those objects.

Comments came back as a slot rather than a provider. Disqus was removed in
1.0.0 on stated principle (third-party trackers), but removed outright rather
than replaced. It now ships Giscus and any site can override
`components/shoreditch/comments.erb` for something else, so the theme stops
taking a side. Brand icons are vendored from Simple Icons (CC0) and inlined
rather than loading a Font Awesome kit from a CDN, keeping the
no-external-dependency promise the rewrite made everywhere else.

The sidebar ended up split rather than anchored either way: identity at the
top, navigation and footer at the bottom. Two whole-block options were built
and shown first; neither was what was wanted, so the option was removed rather
than left offering a worse arrangement.

Also discovered the demo has no working public URL at all. Setting the custom
domain in repo settings makes GitHub 301 the `github.io` address to it, and
`shoreditch.mehcoleman.com` has no DNS record — so both are dead. The TODO
entry claiming the `github.io` URL still worked was wrong and has been fixed.
