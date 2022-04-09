---
title: Configuring Your Shoreditch Blog
cover: /public/images/shoreditch/adore_and_endure_cover.png
thumbnail: /public/images/shoreditch/adore_and_endure_cover.png
last_updated: 2022-03-31
last_verified: 2022-04-02
tags: [blogging, config, shoreditch]
---

Here is a quick guide to configuring your Shoreditch blog. <!--more-->

# _config.yml

```_config.yml``` is a good place to start. Here you can configure blog
metadata such as title, tagline, description, default blog post icon, etc.

blog title
: Title shown on the sidebar of each page.

description
: Shown underneath the title in the sidebar.

paginate
: How many posts to show on each index page

default thumbnail image
: This is optional and specifies a placeholder blog post thumbnail to be
displayed if no image is specified in the post's front matter.
If no thumbnail is specified in the `_config.yml` or the front matter of the
post, then no thumbnail will be displayed.

excerpt_separator
: Code used to delineate blog content that will appear in the summary on the
index page from the rest of the content, that will only be displayed on the
full blog post page.

contact info
: A section for social media links is available under the author section. Feel
free to raise a guthub issue or submit a pull request if you wish to add another
site to the template.

  This whole section can be enabled for every page in the
config file, or toggled individually via the page's front matter See the various
examples [
[1]({% link _posts/2022-01-20-example-configuration-full-sidebar.md %}),
[2]({% link _posts/2022-01-21-example-configuration-square-logo.md %}),
[3]({% link _posts/2022-01-22-example-configuration-cv.md %})
] for more info.

  The email address info is split into two sections these are combined with
javascript when the page is rendered to make it a little more difficult for
spambot crawlers to extraxct your email address from the page.

logo
: The logo section can be used to add a logo or portrait to the top of the page.
You can choose a round or square picture, an optional link, a message to go
underneath the logo. There is also a toggle to briefly flash the message a few
times, to highlight it's importance.

  These options can be set in the ```_config.yml``` for the whole site, and also
overidden for individual pages by overwriting the parameters in the page's
front matter.

# Other Configuration Options

Apart from the general config file, you can add your own custom CSS. An empty
file at ```/public/css/custom.css``` is sourced in the header of each page, so
you can add your own CSS there, and it will be picked up automatically.

You can also remove the external links in the navigation menu, and, if you
wish, replace them with other links. Simply edit the content in
```/_includes/additional_items.html```

# Page Options

## Extra date options

Blog posts can have additional information about when the post was last updated,
and when the post was last checked for accuracy. This helps your readers decide
whether old posts are still relevant.
This information is specified in the front matter:
~~~ yaml
last_updated: 2022-03-31
last_verified: 2022-04-02
~~~
If the values are not supplied, the fields are not displayed.

## Page Class

You can provide a ```class``` front matter option to a page, and this value will
be set as the page's ```body``` css class.

This let's you customize css styles on a per-page basis.

/cv.md
{:.code-title}
~~~ yaml
---
class: cv
---
~~~


/public/css/custom.css
{:.code-title}
~~~ css
.cv {
  font-family: "Very Professional", Helvetica, sans-serif;
  }
~~~


disqus
google analytics

&nbsp;

&nbsp;

The cover image on this page is (c) Caroline Bishop. via [wallpaper flare](https://www.wallpaperflare.com/adore-and-endure-street-art-captured-in-shoreditch-east-london-wallpaper-woypo)

* Beautiful looking index, tag, and category pages.
* Optional cover images along the top of the page on all layouts.
* Optional thumbnail images (with a configurable default) for each post.
* Extra date options for indicating how up-to-date your blogs posts are.
* Contact and social media links for other professional resources.
* Easily Configurable google analytics.
* Optional Disqus comments.

