---
title: "Example Config: Full Sidebar"
last_updated: 2022-01-14
last_verified: 2022-02-20
cover: /public/images/shoreditch/shoreditch_cover.png
thumbnail: /public/images/1_gear.png
tags: [ info, config ]
round_logo: TRUE
logo_legend: 'Everything turned on here'
logo_location: '/public/images/shoreditch/logo.png'
include_sticky: TRUE
include_logo: TRUE
include_details: TRUE
---

This is an example of a template configuration where all the optional sidebar
elements are enabled.

You can specify the default sidebar configurations in the `_config.yml` file
(remember you need to restart the server to pick up the changes to that file).

~~~ yaml
defaults:
  -
    scope:
      path: ""
    values:
      flashy_logo:    TRUE
      round_logo:     TRUE
      logo_legend: 'Everything turned on here'
      logo_location:  '/public/images/shoreditch/logo.png'
      logo_link:      'https://github.com/MEHColeman/shoreditch'
  -
    scope:
      path: ""
      type: "posts"
    values:
      include_sticky: TRUE
      include_logo:  TRUE
      include_details: TRUE
  -
    scope:
      path: ""
      type: "pages"
    values:
      include_sticky: TRUE
      include_logo:  TRUE
      include_details: TRUE
~~~

And/or you can specify a different sidebar configuration per page by specifying
your requirements in the page's front matter.

~~~ yaml
---
round_logo: TRUE
logo_legend: 'Everything turned on here'
logo_location: '/public/images/shoreditch/logo.png'
include_sticky: TRUE
include_logo: TRUE
include_details: TRUE
---
~~~
