---
title: Example Content
last_updated: 2021-11-14
last_verified: 2021-11-14
cover: /public/images/shoreditch/shoreditch_cover.png
thumbnail: /public/images/shoreditch/shoreditch_cover.png
tags: [ info ]
---

Howdy! This is an example blog post that shows several types of HTML content
supported in this theme.
{:.message}
<!--more-->
A quick reference version of all the common markdown and front matter options
available with _Shoreditch_ is available [here]({% link quick-reference.md %}).
That file won't be indexed, so you can keep it in your repo to refer to in
future without worrying about it polluting your blog.


Cum sociis natoque penatibus et magnis <a href="#">dis parturient montes</a>,
nascetur ridiculus mus. *Aenean eu leo quam.* Pellentesque ornare sem lacinia
quam venenatis vestibulum. Sed posuere consectetur est at lobortis. Cras mattis
consectetur purus sit amet fermentum. [^1]

[^1]: footnote.

The header image at the top of the page is specified by the cover property in
the front matter.

> A quote: Curabitur blandit tempus porttitor. Nullam quis risus eget urna mollis ornare vel eu leo. Nullam id dolor id nibh ultricies vehicula ut id elit.

Etiam porta **sem malesuada magna** mollis euismod. Cras mattis consectetur
purus sit amet fermentum. Aenean lacinia bibendum nulla sed consectetur.

To get even nicer quotations, you'll need to do a bit more work, as markdown by
itself can't handle it.

~~~html
<div class="pullquote">
<div class="quotation"> I have a dream that one day this nation will rise
up and live out the true meaning of its creed: We hold these truths to be
self-evident, that all men are created equal... I have a dream that my four
little children will one day live in a nation where they will not be judged by
the color of their skin but by the content of their character.</div>
<div class="attribution">Martin Luther King</div>
</div>
~~~
<div class="pullquote">
<div class="quotation"> I have a dream that one day this nation will rise
up and live out the true meaning of its creed: We hold these truths to be
self-evident, that all men are created equal... I have a dream that my four
little children will one day live in a nation where they will not be judged by
the color of their skin but by the content of their character.</div>
<div class="attribution">Martin Luther King</div>
</div>

## Heading

Vivamus sagittis lacus vel augue rutrum faucibus dolor auctor. Duis mollis, est
non commodo luctus, nisi erat porttitor ligula, eget lacinia odio sem nec elit.
Morbi leo risus, porta ac consectetur ac, vestibulum at eros.

### Code

Cum sociis natoque penatibus et magnis dis `code element` montes, nascetur
ridiculus mus.

~~~ js
// Example can be run directly in your JavaScript console

// Create a function that takes two arguments and returns the sum of those arguments
var adder = new Function("a", "b", "return a + b");

// Call the function
adder(2, 6);
// > 8
~~~

Aenean lacinia bibendum nulla sed consectetur. Etiam porta sem malesuada
magna mollis euismod. Fusce dapibus, tellus ac cursus commodo, tortor mauris
condimentum nibh, ut fermentum massa.

### Gists via GitHub Pages

This requires adding the jekyll-gist gem - then uncomment, and it should work.
{% comment %} {% gist 5555251 gist.md %} {% endcomment %}

Vestibulum id ligula porta felis euismod semper. Nullam quis risus eget urna
mollis ornare vel eu leo. Donec sed odio dui.

### Extra Styles

Hey, there! This is a message.
{:.message}

Hello again. This is a callout.
{:.callout}

Warning! This is an alert!
{:.alert}

DANGER! This is an alarm!
{:.alarm}

### Lists

Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus
mus. Aenean lacinia bibendum nulla sed consectetur. Etiam porta sem malesuada
magna mollis euismod. Fusce dapibus, tellus ac cursus commodo, tortor mauris
condimentum nibh, ut fermentum massa justo sit amet risus.

* Praesent commodo cursus magna, vel scelerisque nisl consectetur et.
* Donec id elit non mi porta gravida at eget metus.
* Nulla vitae elit libero, a pharetra augue.

Donec ullamcorper nulla non metus auctor fringilla. Nulla vitae elit libero, a
pharetra augue.

1. Vestibulum id ligula porta felis euismod semper.
2. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.
3. Maecenas sed diam eget risus varius blandit sit amet non magna.

Cras mattis consectetur purus sit amet fermentum. Sed posuere consectetur est at lobortis.

- [ ] Item needs to be done.
- [x] Item has been done.

### Definitions
HyperText Markup Language (HTML)
: The language used to describe and define the content of a Web page

Cascading Style Sheets (CSS)
: Used to describe the appearance of Web content

JavaScript (JS)
: The programming language used to build advanced Web sites and applications

### Arbitrary HTML
<textarea>
If you want to insert HTML not supported by a markdown shorthand, you can
simply insert it into the document.
</textarea>

### Images

![placeholder](https://via.placeholder.com/800x400 "Large example image")
![placeholder](https://via.placeholder.com/400x200 "Medium example image")
![placeholder](https://via.placeholder.com/200x200 "Small example image")

### Tables

Aenean lacinia bibendum nulla sed consectetur. Lorem ipsum dolor sit amet,
consectetur adipiscing elit.

Person | Fruit | Count
--- | --- | ---
Xena | Cherry | 12
Yvette | Banana | 3
Zachary | Apple | 17

-----

Want to see something else added? <a href="https://github.com/MEHColeman/shoreditch/issues/new">Open an issue.</a>
