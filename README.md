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

The automation asks for an accent colour and a badge text, installs the gem,
and points your posts and pages at the theme's layouts. On a fresh site it
also retires the scaffold's starter stylesheet and layouts, which would
otherwise override the theme — but only files that are *exactly* the untouched
`bridgetown new` scaffold; anything you have edited is left alone with a note.
An accent or badge answer that contains a quote, a backslash or a `#{…}` is
declined rather than written into your config, since it would otherwise land
in generated Ruby — set those options by hand if you need such characters.

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
  accent "#c7254e"          # any CSS colour; drives links, tags, focus rings
  sidebar_side "right"      # "left" (default) or "right"
  logo_legend "For hire"    # badge under the logo; omit for none
  logo_shape "square"       # "round" (default) or "square"
  logo_legend_shape "straight"  # "round" (default) or "straight"
end
```

`accent` is validated before it reaches the stylesheet — a value that is not a
recognisable CSS colour falls back to the default rather than emitting broken
CSS.

## Comments

Off unless configured. The theme ships [Giscus](https://giscus.app), which
stores comments as GitHub Discussions:

```ruby
init :shoreditch do
  comments({
    repo: "you/your-repo", repo_id: "R_...",
    category: "Comments",  category_id: "DIC_...",
  })
end
```

The four values come from giscus.app once Discussions is enabled on the
repository. A single post opts out with `comments: false` in its front matter.

For any other provider, override `components/shoreditch/comments.erb` in your
own site — your files take precedence over the gem's, so there is no need to
fork the theme or copy the post layout. The thread follows the reader's theme
toggle, not just their OS setting.

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

  # All optional, and all used only by the contact panel — see below.
  github: yourhandle
  mastodon: https://example.social/@you   # a full URL, unlike the others
  linkedin: yourhandle
  twitter: yourhandle
  instagram: yourhandle
  reddit: yourhandle
  youtube: https://youtube.com/@you       # a full URL
  tiktok: yourhandle
  lastfm: yourhandle
  deviantart: yourhandle
  artstation: yourhandle
  phone: "+44 20 7946 0000"
  file_url: /files/cv.pdf
  file_link_text: Download as PDF

  # Split in two on purpose. The halves are only joined in the browser, so the
  # address never appears whole in the HTML for a crawler to lift.
  email_1: hello@examp
  email_2: le.com
```

## The contact panel

A page opts in with `include_details: true`. It lists whichever of the author
fields above are filled in, with an inline icon each — brand marks are vendored
from [Simple Icons](https://simpleicons.org) (CC0), so the theme still loads
nothing from a third party.

It is off by default because a blog post has no use for a phone number; a CV or
an about page does.

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
| `noindex` | Emits `robots: noindex, nofollow` |
| `class` | Extra CSS class on `<body>` — `class: cv` opts into the CV styling |
| `comments` | `false` turns comments off for one post |

These reshape the sidebar for a single page — useful when one page should
introduce a person rather than the site:

| Key | Effect |
| --- | --- |
| `include_sticky` | `false` drops the site title, tagline and navigation |
| `include_details` | `true` shows the contact panel |
| `include_logo` | `false` hides the logo entirely |
| `logo_location` | A different logo image for this page |
| `logo_shape` | `round` or `square`, overriding the site setting |
| `logo_legend` | Overrides the badge; `false` hides it |
| `logo_legend_shape` | `round` or `straight` — the badge, shaped independently |
| `flashy_logo` | `true` gives the logo a pulsing accent glow |

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

Syntax highlighting is one of those properties. The theme sets the code
background, so it also sets the token colours — otherwise a light-only Rouge
palette renders keywords black on near-black as soon as dark mode flips the
background. Override `--sd-code-keyword`, `--sd-code-string`,
`--sd-code-comment`, `--sd-code-number`, `--sd-code-fn`, `--sd-code-tag` and
`--sd-code-punct` to use your own.

Rules come in two weights. `--sd-rule` is the hairline used for separators and
table borders; `--sd-rule-strong` is the heavier one used where a border encloses
something that has to read as a single object, as an index entry does. Override
them together if you are changing the palette.

Do not style `body`, `main` or bare `a` from your site's stylesheet — those
belong to the theme, and because your CSS loads last you will win by accident.
Override custom properties instead.

Light and dark both come from `prefers-color-scheme`, with a toggle in the
sidebar that stores the reader's choice and wins over the OS setting. The
choice is applied by an inline script before first paint, so there is no flash
of the wrong scheme.

Below 60rem the two columns stack, and the sidebar becomes a compact header
band: the logo shrinks and sits inline with the site title, the navigation runs
along under it, and the theme toggle and copyright move to the foot of the page
so a reader arriving on a post meets the masthead rather than the small print.
There is no menu to open — everything stays on screen, and no JavaScript is
involved.

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

Ruby 3.3+ and **Node 22 or newer** — Bridgetown's esbuild configuration calls
`fs.globSync`, which does not exist before Node 22. On an older Node the
frontend build fails while the site itself still serves, so stylesheet changes
silently never reach the browser. `demo/.nvmrc` pins it.

## Licence

MIT. See [LICENSE.md](LICENSE.md) — the original copyright is Mark Otto's and
stays.
