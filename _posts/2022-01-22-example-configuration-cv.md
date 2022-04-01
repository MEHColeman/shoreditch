---
title: "Example Config: CV"
last_updated: 2022-01-14
last_verified: 2022-02-20
cover: /public/images/shoreditch/shoreditch_cover.png
thumbnail: /public/images/3_gears.png
tags: [ info, config ]
round_logo: TRUE
logo_legend: ''
logo_location: '/public/images/shoreditch/logo.png'
include_sticky: FALSE
include_logo: TRUE
include_details: TRUE
---

This is an example of a template configuration where the sodebar contains a
small logo, the details, but no blog navigation section.

I find that the details section is too verbose to have on every page, and prefer
to switch it off for a cleaner look. I do switch it on for my [professional
blog](https://textificated.com/) for my CV page. I also have the logo section as
a profile picture, and if I am currently looking for work, then the logo text
will say "FOR HIRE", otherwise it is turned off.

For my CV page, I switch ON the details section, but switch OFF the navigation
section. This is because I want the extra contact details to be displayed on my
CV, but I want that page to stand alone, independent of the rest of the blog, so
it is better without the blog navigation section.

You can specify a different sidebar configuration per page by specifying
your requirements in the page's front matter.

~~~ yaml
---
round_logo: TRUE
logo_legend: ''
logo_location: '/public/images/shoreditch/logo.png'
include_sticky: FALSE
include_logo: TRUE
include_details: TRUE
---
~~~
