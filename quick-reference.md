---
title: Quick Reference
layout: page
exclude: TRUE
last_updated: 2022-11-14
last_verified: 2021-11-14
cover: /public/images/shoreditch/shoreditch_cover.png
thumbnail: /public/images/shoreditch/shoreditch_cover.png
credits:
  -
    label: "Cover Image"
    name: "Mark Coleman"
    via: "on flickr"
    via_link: https://www.flickr.com/photos/mehcoleman/
tags: [ info, reference ]
class: any_css_class_name_you_want
include_details: FALSE
include_logo: FALSE
include_sticky: TRUE
logo_location: "/public/images/shoreditch/mark.jpg"
logo_shape: round
logo_legend_shape: straight
logo_legend: "Legend"
flashy_logo: FALSE

---

This is a quick reference page that can be used as a cheatsheet for all the
markdown elements and style features you can use with _Shoreditch_.
<!--more-->

This page is excluded from being indexed (specified in the front matter), and
therefore will never be displayed in the side menu. So, you can leave it
in place to serve as a handy reference document, if you like.

This is _italics_, **bold**, ***bold and italics***, and ~~strikethrough~~. Also
<u>underline</u>, <sup>superscript</sup> and <sub>subscript</sub>

This is a message block
{:.message}

This [sentence](https://en.wikipedia.org/wiki/Sentence_(linguistics)) contains a
reference to a footnote.[^1]

[^1]: This is the footnote text.

The title, cover photo, thumbnail image, date information, sidebar styles and
tags are all specified in the header data. header image at the top of the page
is specified with the cover property in the front matter.

> A quote: Curabitur blandit tempus porttitor. Nullam quis risus eget urna mollis ornare vel eu leo. Nullam id dolor id nibh ultricies vehicula ut id elit.

<div class="pullquote">
<div class="quotation">
I really like Shoreditch, its great.</div>
<div class="attribution">Mark Coleman</div>
</div>

# Heading 1
## Heading 2
### Heading 3
#### Heading 4
##### Heading 5
###### Heading 6

Code can be indicated with `backticks` or code blocks.

/optional/title.rb
{:.code-title}
~~~ruby
def method (arg1, arg2)
  @good_proc.call(arg1)
  @fast_proc.call(arg2, "string")
end
~~~

Hidden Comment below:

{% comment %}
You can't see this.
{% endcomment %}

* list item 1
* list item 2
* list item 3

1. list item 1
2. list item 2
3. list item 3

- [ ] Item needs to be done.
- [x] Item has been done.

Definition Term
: Definition description text

<textarea>
If you want to insert arbitrary HTML not supported by a markdown shorthand, you
can simply insert it into the document.
</textarea>

![placeholder](https://via.placeholder.com/800x400 "Large example image")
![placeholder](https://via.placeholder.com/400x200 "Medium example image")
![placeholder](https://via.placeholder.com/200x200 "Small example image")

Heading | Heading 2 | Heading 3
--- | --- | ---
a | b | c
d | e | f

Hey, there! This is a message.
{:.message}

Hello again. This is a callout.
{:.callout}

Warning! This is an alert!
{:.alert}

DANGER! This is an alarm!
{:.alarm}

[Link](#heading-1) to a heading anchor. All markdown headings are automatically
associated with an anchor point that is a sluggified version of the heading
text.

Internal [link]({% link _posts/2022-01-22-example-configuration-cv.md %})

