#import "excerpt.typ"

#let this = "_src/index.typ"
#let common = "_src/common.typ"

// These markers are used to paste pieces of code in the final document.
// See `excerpt.typ`.
// {setup:
#set document(title: "Typ2HTML")
// :setup}

// {prelude:
#import "xhtml.typ"
#import "css.typ"
// :prelude}

#include "common.typ"

Last build: 2025-05-25 with typst 0.13.1

= Typst to HTML: playground and tutorial

This page, and more broadly all of #link("../index.html")[my website],
are (for the most part) just composed of static HTML and CSS. \
What's interesting is that said HTML is fully generated via
#link("https://typst.app")[Typst]'s experimental
#link("https://typst.app/docs/reference/html/")[HTML export] feature.

In the process of building this website, I found that although experimental,
the feature is already very powerful (though not fully ergonomic yet),
and a bigger obstacle to my development was simply knowing what to do
with the few features available.

This page is intended:
- for current me, a playground where I can test in real time some features;
- for future me, a record of what currently works,
  so that I can see if an update of Typst breaks anything;
- for everyone, a tutorial.
  Not one of what functions are available, mind you
  because that would be #link("https://typst.app/docs/reference/html/elem/")[trivial],
  but rather of how to leverage this one function to obtain nontrivial results.

Via some #link("_src/excerpt.typ")[dark magic], I shall embed in this document
not just the output but also the source code that generates it,
helping towards the goal of this being a usable showcase and tutorial.

// {title:
== Getting started
// :title}

Some stuff just works out of the box.
- setting the title of the page
  #excerpt.incl(this, "setup")
- Putting text in
  // {basic-style:
  *bold*, _italics_, `inline code`
  // :basic-style}
  #excerpt.incl(this, "basic-style")
- Making titles
  #excerpt.incl(this, "title")
- Adding
  // {builtin-link:
  #link("https://example.com")[hyperrefs]
  // :builtin-link}
  #excerpt.incl(this, "builtin-link")

== Build process

Before we get into more technical stuff, a small note on the build process,
because I feel that this is the most nontrivial part of using Typst for HTML
currently.
For the record, I use the following directory layout:
```
Makefile
_src/
  |-- index.typ
  |-- xhtml.typ
  |-- css.typ
  \-- ...
_highlight/
  |-- highlight.min.js
  |-- highlight-typst.js
  \-- ...
```

And I have my `justfile` as such:
#excerpt.incl("justfile", "", lang: "make")

This builds `index.html` in the root directory. \
To watch changes live, I open `index.html` in a browser
and run `just watch-all` in the background.

== Non-builtins

// TODO: make all raw display properly

For now Typst only provides the function `elem`,
where to build for example a \
`<div class="test">inner</div>`, you write \
`html.elem("div", attrs: (class: "test"), { [inner] })`.

I find that it is slighly more convenient to have the following:
#excerpt.incl("_src/xhtml.typ", "func")
and then instanciate it for each element as such:
#excerpt.incl("_src/xhtml.typ", "apply")

This means that now for the same \
`<div class="test">inner</div>`, we can write \
`xhtml.div(class: "test", { [inner] })`

This document imports `xhtml.typ`,
in which more functions of the same shape are defined.
Thus from now on you can assume that whenever you see
a function `xhtml.foo`, it creates a `<foo>...</foo>` html element.

As a concrete example, here is an image that is also a hyperref:

#excerpt.incl(this, "link")
// {link:
#xhtml.a(href: "https://www.example.com", {
  xhtml.img(src: "_assets/link.svg", width: "50px")
})
// :link}

== Prettification

Now we get to more advanced styling options.
There are separate features of html that make this possible:
- CSS can be inserted into a regular `.html` file inside a `<style>...</style>`
  block;
- HTML elements support inline styling attributes as `style=...`.

I will show both.

=== Static global

This document already uses this method.
Through the module `css.typ` I have made it more or less easy to set
document-wide attributes, including background and foreground color,
font size, title color, etc.
You may recognize below something that reads like raw CSS, but formatted as nested Typst dictionaries.

#excerpt.incl(common, "style")

=== On-the-fly global

HTML is not limited to a single global `<style>` declaration,
so this can be used also to set more properties after the fact.
For example let us define `my-style` as such:
#excerpt.incl(this, "my-style")

// {my-style:
#let my-style = (
  color: "var(--black)",
  background: "var(--dk-blue)",
  border-radius: "3pt",
  display: "inline-block",
  padding: "5pt",
)
// :my-style}

and then we can for example bind it to the `.on-the-fly` class as such:
#excerpt.incl(this, "my-style-fly")

// {my-style-fly:
#css.elem(".on-the-fly", my-style)
#xhtml.div(class: "on-the-fly", {
  [Black on blue (on the fly)]
})
// :my-style-fly}

=== Inline style

Additionally, HTML elements accept a `style` parameter in which you can put CSS.
#excerpt.incl(this, "my-style-inline")

// {my-style-inline:
#xhtml.div(class: "inlined", style: css.raw-style(my-style), {
  [Black on blue (inlined)]
})
// :my-style-inline}

=== Dynamic 

As for much more complex styling, you can always resort to calling external JS code.
In this document, this is the method I use to provide syntax highlighting for code
snippets through #link("https://highlightjs.org/")[`highlight.js`]:

#excerpt.incl(common, "highlight")


== Document layout

Here I offer some very common functions that help set the layout.
I've found that often the appearance is easy to set as just raw CSS,
but the layout (centered / horizontal / vertical / grid / ...) is cumbersome.
Here are functions that should help!

=== Box

#let htmlbox(class: none, center: false, width: "100pt", inner) = {
  let class-key = if class == none { (:) } else {
    (class: class)
  }
  let align-key = if not center { (:) } else {
    (justify-content: "center", align-items: "center")
  }
  xhtml.div(..class-key, style: css.raw-style((display: "flex", width: width, ..align-key)),
    xhtml.div(inner)
  )
}

#css.elem(".test", (
  background-color: "var(--dk-gray2)",
))
#htmlbox(class: "test", width: "300px", center: true)[
  Text in the box \
  spanning multiple lines \
  to test fit-to-width and alignment
]


/*
=== Align

=== Line

=== Column

=== Grid

=== Box
*/
