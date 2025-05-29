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
#import "struct.typ"
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
- And bullet lists
  // {bullet-list:
  - just
  - like
  - normally

  // :bullet-list}
  #excerpt.incl(this, "bullet-list")

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
and run `just watch index` in the background.

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
There are at least 4 standard ways of doing this in HTML:
- A static CSS file can be imported into a document with a `<link rel="stylesheet" ...>` declaration;
- Raw CSS code can be inserted into a regular `.html` file inside a `<style>...</style>` block;
- HTML elements support inline styling attributes as `style=...`;
- a `<script>` block can dynamically set some styling options.

All of these methods can be replicated in Typst.

=== Static global

You can import a pre-written CSS as such:
#excerpt.incl(common, "style")
#excerpt.incl("_assets/global.css", "main", lang: "css")

This dictates the style of headers and the color palette that you see
in this document.

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

Then we can for example bind it to the `.on-the-fly` class by:
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
See #link("_src/struct.typ")[`struct.typ`] for the definition of these functions.

The goal is that these functions should provide as close an interface to the
real Typst version as possible. One major difference will be that lengths
must be passed as strings, not as length literals.

=== Text

// {todo-text:
#struct.text(fill: "var(--dk-red)", size: "50pt")[*TODO*]
// :todo-text}

#excerpt.incl(this, "todo-text")

=== Box

`struct.box` tries to mimic as possible the behavior of Typst's `box`.
It supports automatic or fixed width and height, rounded corners, background color.
#excerpt.incl(this, "styled-box")

// {styled-box:
#struct.box(width: "500px", inset: "10pt", radius: "10pt", fill: "var(--dk-purple)", {
  struct.text(fill: "var(--black)")[
    Notice the box's style:
    - fixed width,
    - height adapts to content,
    - content is centered,
    - rounded corners,
    - colored background.
  ]
})
// :styled-box}

=== Line

TODO

=== Vertical and horizontal space

TODO

=== Table

Partially mimicking Typst's `table` function, we have `struct.table`.
Note that this version does not have a stroke, it's only a grid layout.

#excerpt.incl(this, "table")

// {table:
#let cell = struct.box(fill: "var(--dk-gray1)", height: "100px")[A cell]
#struct.table(
  columns: 3, gutter: "15px", {
    for elt in range(7).map(_ => cell) { elt }
  },
)
// :table}

=== Side note: style builders

If you look at the generated HTML for the code above, you will see that the
inline style for `cell` is repeated as many times as there are cells.
Here I propose a mechanic to cut down on this repetition.

All functions defined in `struct.typ` offer another behavior when passed
the parameter `inline: false`.
Whereas `box(...)` will construct a box, `box(inline: false, class: "box-name", ...)`
will instead return a pair `(style, box-builder)` of a CSS style for the box
and a function that builds a box. The difference is that the function will reference
the style rather than include its own.

#excerpt.incl(this, "builder-demo")
// {builder-demo:
#let (style, orange-box) = struct.box(
  inline: false, class: "orange-box",
  fill: "var(--dk-orange)", radius: "5pt", width: "fit-content", outset: "5pt",
)
#style
#orange-box[These]
#orange-box[boxes]
#orange-box[share]
#orange-box[the]
#orange-box[same]
#orange-box[style.]
// :builder-demo}
and now the corresponding CSS is not duplicated, resulting in a smaller HTML output!

You can still overwrite on-the-fly some elements:
#excerpt.incl(this, "builder-overwrite")
// {builder-overwrite:
#orange-box(inset: "10pt")[Add margins to existing style.]
#orange-box(radius: "0pt")[Remove the rouded corners.]
// :builder-overwrite}

=== Alignment

This mimics Typst's `align` function.
#excerpt.incl(this, "alignment")

// {alignment:
#let (style, gray-box) = struct.box(
  inline: false, class: "cell",
  fill: "var(--dk-gray1)", height: "100px", outset: "5px", inset: "5pt",
)
#style
#let my-aligned-box(alignment, inner) = {
  gray-box({
    struct.align(alignment)[#inner]
  })
}
#struct.table(columns: 3, gutter: "10px", {
  my-aligned-box(top + left)[Top left]
  my-aligned-box(top)[Top]
  my-aligned-box(top + right)[Top right]
  my-aligned-box(left)[Left]
  my-aligned-box(center)[Center]
  my-aligned-box(right)[Right]
  my-aligned-box(left + bottom)[Bottom left]
  my-aligned-box(bottom)[Bottom]
  my-aligned-box(right + bottom)[Bottom right]
})
// :alignment}

Beware though that the alignment is not relative to the page itself
(this is because the positioning is relative to the parent, and the parent
needs to be `"flex"`, which `box` is but the entire page is not):
#excerpt.incl(this, "align-do-dont")

// {align-do-dont:
#struct.align(center)[This doesn't work]
#struct.box(struct.align(center)[This works])
// :align-do-dont}


#include "footer.typ"
