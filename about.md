---
layout: page
title: About This Theme
cover: /public/images/shoreditch/shoreditch_cover.png
credits:
  -
    label: "Cover Image"
    name: "Mark Coleman"
    via: "flickr"
    via_link: https://www.flickr.com/MEHColeman
---

Hey there! This page is included as an example. Feel free to customize it for
your own use upon downloading, or delete it entirely. Carry on!
{:.message}

Welcome! This is *Shoreditch*. A clean, responsive, two-column
[Jekyll](http://jekyllrb.com) theme optimised for technical blogging.

See an example of this site at
[shoreditch-example.mehcoleman.com](https://blog-example.mehcoleman.com/){:target='_blank'},
or the author's own blog, [blog.mehcoleman.com](https://blog.mehcoleman.com/){:target='_blank'}

Shoreditch is adapted from the very excellent [Hyde](http://hyde.getpoole.com)
theme by [@mdo](https://twitter.com/mdo). Check it out. <br>
It is also heavily inspired by the [Flexible
Jekyll](https://github.com/artemsheludko/flexible-jekyll) theme by Artem
Sheludko. Also check that out!

## Features
* Updated for Jekyll 4.0.
* Responsive layout for small, medium and large screens.
* Beautiful index, tag, and category pages.
* Optional cover images along the top of the page on all layouts.
* Optional thumbnail images (with a configurable default) for each post.
* Extra date options for indicating how up-to-date your blogs posts are.
* Wider content section, so that code samples fit 80 characters across.
* Contact and social media links for other professional resources.
* Social media sharing buttons
* Easily Configurable Google analytics.
* Optional Disqus comments.

![Shoreditch Custom Colour](/public/images/shoreditch/shoreditch_index_screen.png) ![Shoreditch Custom Colour](/public/images/shoreditch/shoreditch_post_screen.png)

Learn more and contribute on [GitHub](https://github.com/MEHColeman/shoreditch).

## Use
Here's how I use this theme:

I use the master branch only for framework changes - changes that you as a user
would take on if you wanted to keep up-to-date with version updates.

I use a branch called `content` for my blog content. When I make changes to
the framework, I then rebase my entire content branch on top of the master
branch I find that it's easier to do that cleanly if I delete the existing pages
(like the `about` page in a single git commit, then add a new `about` page in a
separate commit. That way, there are fewer conflicts when rebasing.

If you are submitting a pull request, please do so against the master branch.

## Setup

### Config options

Various page options, design, image and logo settings can be configured, either
globally or per-page.

See [the config post]({% post_url 2022-02-23-shoreditch-configuration %}) and
various [other posts](/tag/config/) for full details.

*Shoreditch* has blog post content, stored in the `_posts` directory, and
viewable via the [index page](/), or [tag indexes](/tag/info). It also has
static pages, like this one, which are automatically added to the sidebar
(unless you choose to exclude them, like the [quick-reference]({% link
quick-reference.md %}) page).

### Common styles

See the [quick reference]({% link quick-reference.md %}) for full details.

Jekyll 4.0 uses kramdown by default. See [this
reference](https://kramdown.gettalong.org/syntax.html) for more info.

Code sample blocks span 80 characters. A `code-title` css
class can be used to give a code section a nice looking
title.

```
directory/filename.txt
{:.code-title}
~~~ markdown
12345678901234567890123456789012345678901234567890123456789012345678901234567890

Hey, there! This is a message.
{:.message}

Hello again. This is a callout.
{:.callout}

Warning! This is an alert!
{:.alert}

DANGER! This is an alarm!
{:.alarm}
~~~
```

Code samples can also be `inline` using backticks `` ` ``

### Extra Front Matter

Additional front matter variables are supported by this theme.

/extra_front_matter.md
{:.code-title}
~~~yaml
---
last_modified: 2020-04-20
last_verified: 2020-05-20
cover: images/cover.png
thumbnail: images/thumbnail.png
credits:
  -
    label: "Cover Image"
    name: "Mark Coleman"
    via: "flickr"
    via_link: https://www.flickr.com/MEHColeman
---
~~~

`last_modified` and `last_verified` give extra
information about how up-to-date the page is. See [my blog
post](https://blog.mehcoleman.com/2015/10/11/what-day-is-it/) for more
info.

`cover` indicates that the page should be rendered with the specified
header image.
`thumbnail` indicates that the specified thumbnail should be used for
index pages.

All these variables will work on both pages and posts, and are entirely
optional.

The `credits` section, if provided will append an attribution note at the bottom
of the page.

### Sidebar Options

The navigation menu and set of social links can be toggled on or off in the
_config, and customized on any individual page or post via front matter.

See [2022-02-23-shoreditch-configuration]({% post_url
2022-02-23-shoreditch-configuration %}) for more details.

### Themes

Shoreditch inherits eight optional themes based on the [base16 color
scheme](https://github.com/chriskempson/base16). Apply a theme to change the
color scheme (mostly applies to sidebar and links).

![Hyde in red](https://f.cloud.github.com/assets/98681/1831229/42b0b354-7384-11e3-8462-31b8df193fe5.png)

There are eight themes available at this time.

![Hyde theme classes](https://f.cloud.github.com/assets/98681/1817044/e5b0ec06-6f68-11e3-83d7-acd1942797a1.png)

To use a theme, add anyone of the available theme classes to the `<body>`
element in the `default.html` layout, like so:

```html
<body class="theme-base-08">
  ...
</body>
```

To customise CSS to your heart's content, add custom CSS to the `/public/css/custom.css` file.

### Reverse layout

![Hyde with reverse layout](https://f.cloud.github.com/assets/98681/1831230/42b0d3ac-7384-11e3-8d54-2065afd03f9e.png)

Hyde's page orientation can be reversed with a single class.

```html
<body class="layout-reverse">
  ...
</body>
```

## License

Released under the [MIT license](LICENSE.md).
