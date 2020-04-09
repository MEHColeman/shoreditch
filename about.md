---
layout: page
title: About This Theme
---

Hey there! This page is included as an example. Feel free to customize it for your own use upon downloading. Carry on!
{:.message}

Welcome! This is *Shoreditch*. A clean, two-column jekyll theme optimised for technical blogging.

*Shoreditch* is adapted from the very excellent [Hyde](http://hyde.getpoole.com) theme by [@mdo](https://twitter.com/mdo). Check it out.

It is also heavily inspired by the [Flexible Jekyll](https://github.com/artemsheludko/flexible-jekyll) theme by Artem Sheludko. Also check that out!

## Features
* Updated for Jekyll 4.0
* Content section wider, so that code samples fit 80 characters across.
* Beautiful looking index, tag, and category pages.
* Optional cover images on all layouts.
* Extra date options for indicating how up-to-date your blogs posts are.
* Contact and social media links for other professional resources.
* Easily Configurable google analytics
* Optional Disqus comments

Learn more and contribute on [GitHub](https://github.com/poole).

## Setup

### Config options

### Common styles

Jekyll 4.0 uses kramdown by default. See [this
reference](https://kramdown.gettalong.org/syntax.html) for more info.

Code sample blocks span 80 characters. A `code-title` css
class can be used to give a code section a nice looking
title.

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

Code samples can also be `inline` using backticks `` ` ``

### Extra Front Matter

The following front matter variables are supported by this theme.
~~~ yaml
last_modified: 2020-04-20
last_verified: 2020-05-20
cover: images/cover.png
thumbnail: images/thumbnail.png
~~~

```last_modified``` and ```last_verified``` give extra information about how
up-to-date the page is. See [my blog post](https://mehcoleman.com/) for more
info.

```cover``` indicates that the page should be rendered with the specified
header image.
```thumnail``` indicates that the specified thumbnail should be used for
index pages.

The thumbnail image can be the same as the cover image - it will be scaled to
fit a smaller frame. It might also be any other image used on the page.

All these variables will work on both pages and posts, and are entirely
optional.



### Extra Styles

Hey, there! This is a message.
{:.message}

Hello again. This is a callout.
{:.callout}

Warning! This is an alert!
{:.alert}

DANGER! This is an alarm!
{:.alarm}
