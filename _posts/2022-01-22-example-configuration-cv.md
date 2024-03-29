---
title: "Example Config: CV"
last_updated: 2022-01-14
last_verified: 2022-02-20
thumbnail: /public/images/3_gears.png
tags: [ info, config ]
logo_shape: round
logo_legend_shape: square
logo_legend: 'Name<br/> Job Title'
logo_location: '/public/images/shoreditch/mark.jpg'
logo_link: '/'
include_sticky: FALSE
include_logo: TRUE
include_details: TRUE
---

This is an example of a template configuration where the sidebar contains a
small logo, the details, but no blog navigation section.

I find that the details section is too verbose to have on every page, and prefer
to switch it off for a cleaner look. I do switch it on for my [professional
blog](https://blog.mehcoleman.com/) for my [CV page](/cv){:target="_blank"}. I
also have the logo section as a profile picture, and if I am currently looking
for work, then the logo text will say "FOR HIRE", otherwise it is turned off.

For my CV page, I switch ON the details section, but switch OFF the navigation
section. This is because I want the extra contact details to be displayed on my
CV, but I want that page to stand alone, independent of the rest of the blog, so
it is better without the blog navigation section. So, I end up with a sidebar
looking like the one on this page.

You can specify a different sidebar configuration per page by specifying
your requirements in the page's front matter.

~~~ yaml
---
logo_shape: round
logo_legend_shape: square
logo_legend: 'Name<br/> Job Title'
logo_location: '/public/images/shoreditch/logo.png'
include_sticky: FALSE
include_logo: TRUE
include_details: TRUE
---
~~~
