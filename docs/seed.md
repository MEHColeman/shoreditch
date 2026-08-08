# shoreditch — seed

Agent-facing orientation. Read this before exploring.

## What this is

**Shoreditch**, a two-column Bridgetown theme for technical blogging,
distributed as a gem-based plugin. Public, MIT.

Repo: `MEHColeman/shoreditch`. Default branch **`master`** (not `main`).
Demo site: shoreditch.mehcoleman.com, built from `demo/` by GitHub Pages.

## History worth knowing

Shoreditch began as a fork of Mark Otto's **Hyde** (`poole/hyde`, 2013), was
taken over and renamed in April 2020, and reached 0.9.0 as a **Jekyll** theme
before going dormant in September 2022.

Version 1.0.0 is a Bridgetown rewrite, not a port. Nothing upgrades in place
from 0.9.0. The Jekyll implementation is in git history; `_sass/hyde.sass` and
`_sass/poole.sass` no longer exist.

`LICENSE.md` still carries **Copyright (c) 2013 Mark Otto**, and the README
credits Hyde and Flexible Jekyll. That attribution stays regardless of how much
has been rewritten.

The `framework` branch is a historical remnant — identical to an old `master`
— from when the theme and Mark's blog content shared one repository. The blog
now lives separately in `MEHColeman/blog`.

## Layout

```
lib/shoreditch.rb       The initializer. Registers the source manifest and the
                        accent / sidebar_side / logo_legend / logo_shape /
                        logo_legend_shape / comments options, plus the CSS
                        colour validator used for accent.
lib/shoreditch/icons.rb Inline SVG path data for the contact panel. Brand marks
                        vendored from Simple Icons (CC0); email/phone/file/link
                        drawn by hand. GENERATED, but edit by hand — there is no
                        regeneration script.
lib/shoreditch/version.rb
layouts/shoreditch/     default.erb, post.erb, page.erb
components/shoreditch/  Ruby components with sidecar .erb templates:
                        sidebar, head_icons, post_summary, details, comments
content/shoreditch/     shoreditch.css and shoreditch.js — shipped as STATIC
                        FILES through the source manifest
bridgetown.automation.rb  For `bin/bridgetown apply`
demo/                   A Bridgetown site consuming the theme from ..
                        Published to GitHub Pages. Excluded from the gem.
```

## How the frontend reaches a consuming site

Deliberately **not** via npm. Bridgetown's documented route for plugin frontend
assets is to publish a companion NPM package and have users add an import to
their esbuild entry points. For a theme this size that means a second registry
to keep version-synced and a manual step for every user.

Instead the CSS and JS live under `content/`, which the source manifest
publishes as static files, and the layout links them at `/shoreditch/*`. There
is nothing to import and nothing to publish twice. `bundle update shoreditch`
delivers a new version.

Anything themeable is a custom property on `:root`. A consuming site's own
stylesheet loads after the theme's, so overriding never requires a fork.

## Commands

| | |
| --- | --- |
| `gem build shoreditch.gemspec` | Build the gem |
| `cd demo && bin/bridgetown start` | See changes — the fastest loop |
| `cd demo && bin/bridgetown build` | Build the demo |
| `scripts/exercise-automation.sh` | Exercise the install automation against a fresh site |

Requires Ruby 3.3+ and **Node 22** — not advisory. Bridgetown's
`config/esbuild.defaults.js` calls `fs.globSync`, a Node 22 API. On Node 20 the
frontend build throws while `bin/bridgetown start` carries on serving, so
stylesheet edits silently never reach the browser and the old bundle is served
indefinitely. `demo/.nvmrc` pins it; nvm's global default may not.

## Conventions

- **ERB, not Liquid.** Bridgetown 2 is ERB-first.
- **Components take what they need explicitly.** A `Bridgetown::Component` has
  no implicit access to `site`, so `Sidebar` and `HeadIcons` are passed it.
  Forgetting this fails at render with `undefined method for nil`.
- **CSS classes are `sd-` prefixed**, so a consuming site's own classes never
  collide.
- **Namespaced folders** (`layouts/shoreditch/…`) so consumers can override a
  single layout without shadowing the lot.
- **Demo content is placeholder only.** No real contact details — the demo is
  public and is not Mark's CV.

## Docs

| | |
| --- | --- |
| `docs/seed.md` | This file — orientation |
| `docs/TODO.md` | Outstanding work, each item with its own context block |
| `docs/journal.md` | What happened and why, append-only |
| `docs/acceptance.md` | Facts proven by review at merge time |
| `README.md` | Theme documentation for users |
| `CHANGELOG.md` | What changed and what was removed, per release |

## Current state

**1.1.0 is live on RubyGems** (2026-08-08) — the first published version.
1.0.0 stays git-only: the restorations and fixes that followed it (merged via
PR #2, reviewed against agreed criteria — see `docs/acceptance.md`) are what
1.1.0 rolls in, so the registry never serves the known-defective release.
`bundle add shoreditch` works, proven end to end by the no-preseed automation
exercise. `MEHColeman/blog` still consumes the theme from a git source — the
switch to `gem "shoreditch", "~> 1.1"` happens in that repo.

The demo is live at **<https://shoreditch.mehcoleman.com/>** — Pages with
GitHub Actions as the source, HTTPS enforced, deployed on every push to
master.

Release process: bump `lib/shoreditch/version.rb`, roll the changelog, commit
to master, tag (bare version, no `v` — matching `0.9.0`), push, then
`gem push` — Mark runs the push in a real terminal, since the account's API
key demands an OTP per push and the in-session runner has no interactive
stdin.

## Traps worth knowing

- **`HashWithDotAccess::Hash` routes unknown methods to key lookups.** So
  `data.class` returns the class name, and `metadata.author.present?` returns
  `nil` rather than calling ActiveSupport — silently disabling anything guarded
  by it. Only call methods `Hash` genuinely defines on these objects.
- **A site's stylesheet loads after the theme's**, by design, so a consuming
  site can override without forking. The starter CSS that `bridgetown new`
  generates uses that precedence to trample the theme — its `main` rule pulls
  `.sd-main` out of the grid. This cost the demo its entire appearance for
  months and was invisible until someone rendered it.
- **Component `.erb` sidecars are cached.** Editing one needs a server restart;
  content and layout edits hot-reload.
- **ERB output is escaped**, so an attribute injected as a whole string arrives
  as `aria-current=&quot;page&quot;`. Interpolate the *value*, not the attribute.
