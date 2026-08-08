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

### 2026-08-06 — the index listing gets its frame back

Light and dark were both looked at properly for the first time, on the index, a
post, the CV page and a tag page. Nothing was illegible; the light Rouge
palette, the half that had never been seen by anyone, is fine. Worth recording
how, because it cost time: headless Chrome on this machine requests dark no
matter what, and there is no CLI flag that changes it — `--force-dark-mode` is
about Chrome's own auto-darkening, not the media query, and `GTK_THEME` does
nothing. `Emulation.setEmulatedMedia` over the DevTools protocol is what works.
Forcing `data-theme="light"` into the layout as a probe does *not* work either:
the demo reads the theme's layouts through the gem's source manifest, so they
are not hot-reloaded the way `demo/src` layouts are.

With that cleared, the front page listing was rejected on sight. The 1.0.0
rewrite had turned it into rows separated by a hairline rule, and the complaint
was that 0.9.0's bordered box had been better. It had been. The reason is
structural rather than nostalgic: a post with no `thumbnail` began its title at
the content edge while its neighbours began an image-column in, so the stack had
no shared left edge. A border supplies one edge that every entry has whether or
not it carries an image, which is why the box worked and the rule did not.

So the frame is back, but the 2013 execution is not. That version clipped the
text block with `overflow: hidden` at a fixed height, cutting sentences
mid-word; this one clamps to three lines at a line boundary. The thumbnail is
flush to the frame and stretches to the card's height rather than floating
inside it with its own rounded corners — that flush plate is the thing that made
the old listing read as a designed object, and it was the specific quality the
rewrite lost. Deliberately no fill: `--sd-code-bg` is already spent on code and
callouts, so leaving cards unfilled keeps exactly one filled surface on the page
and it always means machine text.

Two things fell out of building it. The excerpt is whatever block the post opens
with, so a post beginning with `{:.message}` was putting a filled, accent-barred
box inside the card while its neighbours stayed plain — an index preview has to
read the same whatever the source. And `--sd-rule` turned out to be too faint to
draw a box with in light mode: at roughly 1.26:1 against white it is right for a
hairline separator and wrong for a border that has to make something read as one
object. Hence `--sd-rule-strong`, given explicit per-scheme values rather than
being derived from `--sd-rule`, because light and dark needed different amounts
of help to land at the same apparent weight.

One CSS trap worth keeping. `:is()` takes the specificity of its most specific
argument, so `.sd-content .sd-post-excerpt :is(p, …, .message)` is (0,3,0), not
(0,2,0). A follow-up rule written at (0,2,0) silently lost, and the mistake was
invisible in the demo because no post uses `<!--more-->` across two paragraphs.
Reading computed styles out of the browser caught it where reading the file had
not.

The date also moved above the title and into the mono face. That one is a
judgement call rather than a restoration — the listing spans 2012 to 2026, where
how stale a post is happens to be the first thing worth knowing — but it was not
part of what was asked for, and is the easiest piece to drop.

### 2026-08-07 — the sidebar was never designed for the horizontal axis

The portrait layout came up next: on a phone the sidebar stacks above the
content, and there was too much of it before the article. Measuring first was
worth it. At 390×844 the band was 439px, which put a post's title at 80% of the
first screen — and the screenshot showed the real indictment, which is that you
read the copyright notice before the headline.

The diagnosis that mattered: the band was not badly designed, it was *not
designed*. It was the desktop column rendered at phone width with nothing
reconsidered — 128px logo, centred stack, everything sized for an 18rem column
with 100vh of room to spend. So this was a proportion problem wearing the
costume of a placement problem, which is why both of the obvious fixes were
wrong. Moving the sidebar below the article breaks arrival: most phone readers
land on a post from a search result or a shared link, and they would get no
identity and no navigation until they had scrolled past 4,300px. A collapsible
drawer is the conventional answer but costs the theme its one-script restraint,
and a collapsed drawer still needs a visible bar with a button — ~56px, against
~72px for a bar that just shows everything.

So: compact it. Small logo inline with the title, nav beneath, toggle and
copyright to the foot of the page. 439px → 137px, title from 80% to 45% of the
first screen. `.sd-nav` turned out to already be a horizontal row below the
breakpoint, so the nav was never part of the problem.

Getting the footer below the article without touching the markup needed
`display: contents` on the sidebar and on its bottom group, promoting their
children to items of the shell so `order` could put the footer after `.sd-main`.
That discards the sidebar's own box, so the background and padding it used to
provide had to be redistributed to each promoted part; they butt into one
continuous band because the shell has no gap. The shell also switches from grid
to flex below the breakpoint so `.sd-main` can take the slack — otherwise a
short page strands the footer mid-screen with empty space beneath it.

`display: contents` used to drop elements from the accessibility tree, so that
was checked rather than assumed: `Accessibility.getFullAXTree` reports the same
landmarks at 390px as at 1400px — complementary, main, navigation "Main". The
breakpoint was checked at 959/960/961px for a gap, and desktop was screenshotted
against the previous build to confirm it was untouched, which it is.

Left alone deliberately: the 219px cover image, which is the post's own content
earning its space rather than chrome. Noted but not acted on: the CV's band is
343px, because the contact panel is nine stacked rows. On a CV the contact
details arguably *are* the header, so that is defensible — but it is the one
page where the band is still tall.

### 2026-08-08 — the branch goes through the gate and lands

`fix-theme-regressions` was reviewed and merged as PR #2. The branch predated
the plan-doc workflow, so acceptance criteria were agreed retroactively with
Mark, derived from the CHANGELOG Unreleased section, and written to a plan doc
before the review ran. Two bounded blind passes (standard + security lens, the
diff being ~1,700 lines), 16 tool calls each, plus the verification commands
run for real: production build clean on Node 22, theme CSS linked, no Giscus
in the built output.

Verdict: pass, after one remediation — the reverse direction of the changelog
check caught `.sd-archive` entering the diff under no entry, which the forward
check during the work had missed. No blockers or majors. Three minors became
TODO items: the excerpt regex mishandles posts opening with a blockquote or
code fence, the contact fields want a URL-scheme check (a `javascript:` value
in site metadata renders a clickable script link — self-XSS, but beneath the
standard `accent` sets) plus the `data-network="twitter"`-vs-`"x"` mismatch,
and four orphaned demo starter files survived the layout deletion. The
security pass confirmed the accent validation cannot be escaped and found no
unescaped ERB output anywhere.

Verified criteria are distilled into `docs/acceptance.md` (new); the plan doc
is deleted in the closeout, recoverable via
`git log -- docs/tasks/fix-theme-regressions.md`.
