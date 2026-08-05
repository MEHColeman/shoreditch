# Shoreditch

A two-column [Bridgetown](https://www.bridgetownrb.com) theme built for
technical blogging: a fixed sidebar, optional cover images, and a content
column deliberately wide enough that 80-character code samples do not wrap.

See it at [shoreditch.mehcoleman.com](https://shoreditch.mehcoleman.com).

Shoreditch is adapted from the excellent [Hyde](http://hyde.getpoole.com) theme
by [@mdo](https://github.com/mdo), and was also inspired by [Flexible
Jekyll](https://github.com/artemsheludko/flexible-jekyll) by Artem Sheludko.
Both are worth a look.

## Install

```
bin/bridgetown apply https://github.com/MEHColeman/shoreditch
```

Or by hand:

```
bundle add shoreditch
```

then in `config/initializers.rb`:

```ruby
init :shoreditch
```

There is nothing to add to your esbuild entry points. The theme's stylesheet
and script ship as static files through the gem's source manifest, so
`bundle update shoreditch` is all it takes to move to a new version.

## Options

```ruby
init :shoreditch do
  accent "#c7254e"        # any CSS colour; drives links, tags, focus rings
  sidebar_side "right"    # "left" (default) or "right"
  logo_legend "For hire"  # badge under the logo; omit for none
  logo_shape "square"     # "round" (default) or "square"
end
```

## Site metadata

In `src/_data/site_metadata.yml`:

```yaml
title: Your Site
tagline: Shown under the title in the sidebar
description: Used for meta description and the feed
logo: /images/you.png
logo_link: /about/
author:
  name: Your Name
```

## Layouts

| Layout | Use |
| --- | --- |
| `shoreditch/default` | Wraps everything. Index pages use it directly. |
| `shoreditch/post` | Posts. Adds dates, tags, related posts and image credits. |
| `shoreditch/page` | Standalone pages. |

## Front matter

| Key | Effect |
| --- | --- |
| `cover` | Full-width image above the content |
| `thumbnail` | Image in index listings |
| `last_updated` | Shown in the post header |
| `last_verified` | Shown in the post header — for saying how stale a technical post may be |
| `credits` | List of `label` / `name` / `via` / `via_link` for image attribution |
| `nav_order` | Puts a page in the sidebar nav, in this order |
| `exclude` | Keeps a page out of the sidebar nav |
| `logo_legend` | Overrides the badge for one page; `false` hides it |

## Customising

Every colour and dimension is a custom property on `:root`, and your site's own
stylesheet loads after the theme's. To restyle, override what you need:

```css
:root {
  --sd-accent: rebeccapurple;
  --sd-measure: 52rem;
  --sd-sidebar-width: 20rem;
}
```

Light and dark both come from `prefers-color-scheme`, with a toggle in the
sidebar that stores the reader's choice and wins over the OS setting. The
choice is applied by an inline script before first paint, so there is no flash
of the wrong scheme.

The markdown classes the Jekyll version defined — `.message`, `.callout`,
`.alert`, `.alarm` — still work, so posts carrying them keep rendering.

## Development

The `demo/` directory is a Bridgetown site that uses the theme from the parent
directory. It is what gets published to
[shoreditch.mehcoleman.com](https://shoreditch.mehcoleman.com), and it is the
quickest way to see a change:

```
cd demo
bundle install
bin/bridgetown start
```

## Licence

MIT. See [LICENSE.md](LICENSE.md) — the original copyright is Mark Otto's and
stays.
