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
lib/shoreditch.rb       The initializer. Registers the source manifest and
                        the accent / sidebar_side / logo_legend / logo_shape
                        options.
lib/shoreditch/version.rb
layouts/shoreditch/     default.erb, post.erb, page.erb
components/shoreditch/  Ruby components with sidecar .erb templates:
                        sidebar, head_icons, post_summary
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

Requires Ruby 3.3+ and Node 22.

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

## Current state

1.0.0, building, consumed by `MEHColeman/blog` from a git source. **Not yet
published to RubyGems**, and the Pages demo has not been deployed — the repo's
Pages source needs setting to GitHub Actions first. See `docs/TODO.md`.
