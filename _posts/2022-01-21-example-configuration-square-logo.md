---
title: "Example Config: Square Logo"
last_updated: 2022-01-15
last_verified: 2022-02-21
cover: /public/images/shoreditch/shoreditch_cover.png
thumbnail: /public/images/2_gears.png
tags: [ info, config ]
flashy_logo: FALSE
logo_shape: square
logo_legend_shape: straight
logo_legend: 'Square Logo'
logo_location: '/public/images/shoreditch/logo.png'
include_sticky: TRUE
include_logo: TRUE
include_details: FALSE
---

This is an example of a template configuration where all the logo is square, the
details section is removed, and the navigation menu is present.

You can specify the default sidebar configurations in the `_config.yml` file
(remember you need to restart the server to pick up the changes to that file).

~~~ yaml
defaults:
  -
    scope:
      path: ""
    values:
      flashy_logo:    FALSE
      logo_shape: square
      logo_legend_shape: straight
      logo_legend:    'Square Logo'
      logo_location:  '/public/images/shoreditch/logo.png'
      logo_link:      'https://github.com/MEHColeman/shoreditch'
  -
    scope:
      path: ""
      type: "posts"
    values:
      include_sticky: TRUE
      include_logo:  TRUE
      include_details: FALSE
  -
    scope:
      path: ""
      type: "pages"
    values:
      include_sticky: TRUE
      include_logo:  TRUE
      include_details: FALSE
~~~

And/or you can specify a different sidebar configuration per page by specifying
your requirements in the page's front matter.

~~~ yaml
---
flashy_logo: FALSE
logo_shape: square
logo_legend_shape: straight
logo_legend: 'Square Logo'
logo_location: '/public/images/shoreditch/logo.png'
include_sticky: TRUE
include_logo: TRUE
include_details: FALSE
---
~~~

