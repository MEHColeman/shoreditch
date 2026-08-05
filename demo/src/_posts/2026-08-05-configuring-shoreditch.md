---
title: Configuring Shoreditch
last_updated: 2026-08-05
last_verified: 2026-08-05
tags: [ shoreditch, configuration ]
---

Everything Shoreditch exposes is set in two places: the initializer, for things
that affect the whole site, and front matter, for things that affect one page.

<!--more-->

## Installing

```
bin/bridgetown apply https://github.com/MEHColeman/shoreditch
```

The automation adds the gem, writes the initializer and asks about the accent
colour and badge text. By hand it is `bundle add shoreditch` followed by
`init :shoreditch` in `config/initializers.rb`.

There is nothing to add to your esbuild entry points. The stylesheet and the
theme's one script ship as static files inside the gem, so a `bundle update
shoreditch` is all it takes to move to a new version.

## Site-wide options

```ruby
init :shoreditch do
  accent "#c7254e"
  sidebar_side "right"
  logo_legend "Available for hire"
  logo_shape "square"
end
```

`accent` takes any CSS colour and drives links, tag pills and focus rings.
`sidebar_side` moves the sidebar to the right at desk widths without any change
to the markup — the grid columns simply swap. `logo_legend` is the small badge
under the logo; leave it out and no badge is drawn. `logo_shape` is `round` or
`square`.

## Site metadata

```yaml
title: Your Site
tagline: Shown under the title in the sidebar
description: Used for the meta description and the feed
logo: /images/you.png
logo_link: /about/
author:
  name: Your Name
```

## Per-page front matter

| Key | Effect |
| --- | --- |
| `cover` | Full-width image above the content |
| `thumbnail` | Image in index listings |
| `last_updated` | Shown in the post header |
| `last_verified` | Also shown in the header — see below |
| `credits` | Image attribution: `label`, `name`, `via`, `via_link` |
| `nav_order` | Puts a page in the sidebar nav, in this order |
| `exclude` | Keeps a page out of the sidebar nav |
| `logo_legend` | Overrides the badge for one page; `false` hides it |

`last_verified` is there because technical writing goes stale in a way that
essays do not. A post about Kubernetes from four years ago may still be
correct, or may be actively misleading, and the honest thing is to say when you
last checked rather than let the publication date imply currency.

## Restyling

Every colour and dimension is a custom property on `:root`, and your own
stylesheet loads after the theme's. So you override rather than fork:

```css
:root {
  --sd-accent: rebeccapurple;
  --sd-measure: 52rem;
  --sd-sidebar-width: 20rem;
}
```

The content column is wider than a typical prose measure on purpose: an
80-character code sample should not wrap. That is the one decision in the theme
that everything else bends around.

## Light and dark

Both come from `prefers-color-scheme`, with a toggle in the sidebar that
remembers the reader's choice and beats the system setting in either direction.
An inline script in the head applies the stored preference before first paint,
so there is no flash of the wrong scheme on load.
