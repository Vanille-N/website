#let this = "_src/pages/index.typ"
#let common = "_src/common.typ"

// These markers are used to paste pieces of code in the final document.
// See `excerpt.typ`.
// {setup:
#set document(title: "Typ2HTML")
// :setup}

// {prelude:
#import "/_src/t2h/mod.typ": html, css, struct, excerpt
// :prelude}

#include "/_src/common.typ"

= Typst to HTML: playground, tutorial, and showcase

This page, and more broadly all of #link("../index.html")[my website],
are (for the most part) just composed of static HTML and CSS. \
What's interesting is that said HTML is fully generated via
#link("https://typst.app")[Typst]'s experimental
#link("https://typst.app/docs/reference/html/")[HTML export] feature.

In the process of building this website, I found that although experimental,
the feature is already very powerful (though not fully ergonomic yet),
and a bigger obstacle to my development was simply knowing what to do
with the few features available.
This document should make it clear that the issue with Typst's HTML output
currently is not what is *possible*, but what is *convenient*.

This page is intended:
- for current me, a playground where I can test in real time some features;
- for future me, a record of what currently works,
  so that I can see if an update of Typst breaks anything;
- for everyone, a tutorial.
  Not one of what functions are available, mind you
  because that would be #link("https://typst.app/docs/reference/html/elem/")[trivial],
  but rather of how to leverage this one function to obtain nontrivial results.

Via some #link("meta.html#_src/excerpt.typ")[dark magic], I shall embed in this document
not just the output but also the source code that generates it,
helping towards the goal of this being a usable showcase and tutorial.

You can find the full source code of this page #link("meta.html#_src/index.typ")[here].

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
- Bullet lists
  // TODO: highlighting bug here
  // {bullet-list:
  - just
  - like
  - normally

  // :bullet-list}
  #excerpt.incl(this, "bullet-list")
- Enumerations
  // {enum-list:
  1. work
  2. as
  3. well

  // :enum-list}
  #excerpt.incl(this, "enum-list")

== Build process

Before we get into more technical stuff, a small note on my build process.
- `_src/t2h/` contains `html.typ`, `css.typ`, i.e. files that are very generic
  and I expect to be easily reusable;
- `_src/pages/` contains `index.typ`, and I have my `justfile` set to compile
  every `_src/pages/{XYZ}.typ` into `{XYZ}.html`;
- `_highlight/` contains files relevant to syntax highlighting;
- `_assets/` contains additional auxiliary files.
#excerpt.full("justfile", lang: "make")

In other words:
- `just compile index` to compile `index.html` (this file);
- `just watch-all` to dynamically autorecompile the entire directory.

== Non-builtins

// TODO: make all raw display properly

For now Typst only provides the function `elem`,
where to build for example a \
#excerpt.inline(lang: "html", "<div class=\"test\">inner</div>"), you write \
#excerpt.inline("#html.elem(\"div\", attrs: (class: \"test\"), { [inner] })").

I find that it is slighly more convenient to have the following in
#link("meta.html#_src/html.typ")[`html.typ`]:
#excerpt.incl("_src/t2h/html.typ", "func")
and then instanciate it for each element as such:
#excerpt.incl("_src/t2h/html.typ", "apply")

This means that after importing `"/_src/t2h/mod.typ": html`,
for the same `<div class="test">inner</div>`, we can now write
`html.div(class: "test", { [inner] })`

This document imports `html.typ`,
in which more functions of the same shape are defined.
Thus from now on you can assume that whenever you see
a function `html.foo`, it creates a `<foo>...</foo>` html element.

As a concrete example, here is an image that is also a hyperref:

#excerpt.incl(this, "link")
// {link:
#html.a(href: "https://www.example.com", {
  html.img(src: "_assets/link.svg", width: "50px")
})
// :link}

== Prettification

Now we get to more advanced styling options.
There are at least 4 standard ways of doing this in HTML:
- A static CSS file can be imported into a document with a
  `<link rel="stylesheet" ...>` declaration;
- Raw CSS code can be inserted into a regular `.html` file inside a
  `<style>...</style>` block;
- HTML elements support inline styling attributes as `style=...`;
- a `<script>` block can dynamically set some styling options.

All of these methods can be replicated in Typst.

=== Static global

You can import a pre-written CSS that dictates the style of headers
and the color palette that you see in this document as such:
#excerpt.incl(common, "style")
#excerpt.incl("_assets/global.css", "main", lang: "css")
(see #link("meta.html#_assets/global.css")[`global.css`] if you're curious where
the colors are defined)

=== On-the-fly global

HTML is not limited to a single global `<style>` declaration,
so this can be used also to set more properties after the fact.
For example let us define `my-style` as such:
#excerpt.incl(this, "my-style")

// {my-style:
#let my-style = (
  color: "var(--black)",
  background: "var(--dk-blue)",
  border-radius: 3pt,
  display: "inline-block",
  padding: 5pt,
)
// :my-style}

Then we can for example bind it to the `.on-the-fly` class by:
#excerpt.incl(this, "my-style-fly")

// {my-style-fly:
#css.elem(".on-the-fly", my-style)
#html.div(class: "on-the-fly", {
  [Black on blue (on the fly)]
})
// :my-style-fly}

=== Inline style

Additionally, HTML elements accept a `style` parameter in which you can put CSS.
#excerpt.incl(this, "my-style-inline")

// {my-style-inline:
#html.div(class: "inlined", style: css.raw-style(my-style), {
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
real Typst version as possible.

#excerpt.incl(this, "import-struct")

// {import-struct:
#import struct: text, box, table, align
// :import-struct}

=== Text

#{let cc(shade, t) = text(fill: "var(--dk-" + shade + ")", t)
[
  #cc("red")[You can] #cc("purple")[control] #cc("blue")[the style] #cc("aqua")[of text]
  #cc("green")[just like] #cc("yellow")[you would] #cc("orange")[in Typst:]
]
}
#excerpt.incl(this, "todo-text")

// {todo-text:
#text(fill: "var(--dk-red)", size: 50pt)[*Some text*]
// :todo-text}

(reminder: you can do color definitions #link("meta.html#_assets/global.css")[like this])

=== Box

`struct.box` tries to mimic to some extent the behavior of Typst's `box`.
It supports automatic or fixed width and height, rounded corners, background color.
#excerpt.incl(this, "styled-box")

// {styled-box:
#box(width: 60%, inset: 10pt, outset: 2mm, radius: 10pt, fill: "var(--dk-purple)", {
  text(fill: "var(--black)")[
    A box \
    with round corners
  ]
})
// :styled-box}

You can even specify corners, margins, and stroke as dictionaries the same way you would
do for a regular Typst `box`.
#excerpt.incl(this, "rounded-corners")

// {rounded-corners:
#box(fill: "var(--dk-gray3)",
  radius: (bottom-left: 1cm, bottom: 3mm),
  stroke: 3pt,
)[
  #box(fill: "var(--dk-aqua)",
    inset: (x: 5mm, y: 2mm), outset: (x: 1cm, y: 2mm),
    radius: (top-left: 5mm, bottom-right: 0, rest: 2mm),
    stroke: (top: green, left: 3pt, right: (paint: red, thickness: 4pt)),
  )[Inner]
]
// :rounded-corners}

=== Table

Partially mimicking Typst's `table` function, we have `struct.table`.
Note that this version does not have a stroke, it's only a grid layout.

#excerpt.incl(this, "table")

// {table:
#let cell = box(fill: "var(--dk-gray1)", height: "100px")[A cell]
#table(
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
will instead return a `box-builder` function that will lazily declare the required
CSS *at most once*.

#excerpt.incl(this, "builder-demo")
// {builder-demo:
#let orange-box = box(
  inline: false, class: "orange-box",
  fill: "var(--dk-orange)", radius: 5pt, width: "fit-content", outset: 5pt,
)
#orange-box[These]
#orange-box[boxes]
#orange-box[share]
#orange-box[the]
#orange-box[same]
#orange-box[style.]
// :builder-demo}
and now the corresponding CSS is not duplicated, resulting in a smaller HTML output!
In fact, the CSS style is included only if necessary, and at most once.

You can still overwrite on-the-fly some elements:
#excerpt.incl(this, "builder-overwrite")
// {builder-overwrite:
#orange-box(inset: 10pt)[Add margins to existing style.]
#orange-box(radius: 0pt)[Remove the rouded corners.]
// :builder-overwrite}

=== Alignment

This mimics Typst's `align` function.
#excerpt.incl(this, "alignment")

// {alignment:
#let gray-box = box(
  inline: false, class: "cell",
  fill: "var(--dk-gray1)", height: 3cm, outset: 3pt, inset: 5pt,
)
#let my-aligned-box(alignment, inner) = {
  gray-box({
    align(alignment)[#inner]
  })
}
#table(columns: 3, gutter: 3mm, {
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

=== Side note: lengths

Thanks to a #link("meta.html#_src/css.typ")[type-based translation from Typst to CSS],
you can actually use any of Typst's length types wherever the CSS expects a length.
In addition, you can also directly use whatever string is valid CSS for a length,
e.g. in pixels which is not a valid Typst unit of length.
#excerpt.incl(this, "lengths")

// {lengths:
#let as-len(l) = if type(l) == array { l.at(0) } else { l }
#let as-repr(l) = if type(l) == array { l.at(1) } else { raw(repr(l)) }
#let lengths = (
  100%, 25%, 100pt, (5cm, `5cm`), (50% + 1cm, `50% + 1cm`),
  50%, (50% - 1cm, `50% - 1cm`), 50% + 3em, (50% + 3em + 1cm, `50% + 3em + 1cm`),
  "300px", "calc(50% + 200px)",
)
#box(fill: "var(--dk-gray2)", width: 100%,
  align(left, {
    for l in lengths {
      orange-box(width: as-len(l))[#as-repr(l)]
      struct.box-linebreak // A regular linebreak wouldn't work here, unfortunately.
    }
  })
)
// :lengths}

=== Side note: colors

In the same way, there are multiple methods to define colors
- Typst colors, including `rgb`, `cmyk`, `luma`,
  and #link("https://typst.app/docs/reference/visualize/color")[more]
- whatever is supported natively by CSS, including standard named colors,
  hexadecimal, CSS global variables and
  #link("https://www.w3schools.com/cssref/css_colors.php")[more]

#excerpt.incl(this, "colors")

// {colors:
#let as-color(c) = if type(c) == array { c.at(0) } else { c }
#let as-repr(c) = if type(c) == array { c.at(1) } else { raw(repr(c)) }
#let colors = (
  (aqua, `aqua`), (rgb(10, 50, 200), `rgb(10, 50, 200)`),
  (rgb(80%, 50%, 5%), `rgb(80%, 50%, 5%)`), rgb("#aaaaff"),
  (luma(50%), `luma(50%)`), (color.hsv(60deg, 50%, 30%), `color.hsv(60deg, 50%, 30%)`),
  (red.negate(), `red.negate()`),
  (red.darken(50%), `red.darken(50%)`), (blue.transparentize(80%), `blue.transparentize(80%)`),
  "#fa1419", "blue", "YellowGreen", "var(--dk-orange)", "rgb(200, 30, 10)",
  "rgba(200, 30, 10, 0.5)", "hsl(110, 80%, 30%)",
)
#let cbox = box(inline: false, class: "cbox", inset: 1mm, outset: 1mm, radius: 1mm)
#box(fill: "var(--black)", width: 100%,
  for c in colors {
    cbox(fill: as-color(c))[#as-repr(c)]
  }
)
// :colors}

=== Side note: hover

When you bind a style to a class, you can manually insert `:hover` properties:
#excerpt.incl(this, "hover-demo")

// TODO: let box dictate the style of the inner text
// TODO: allow the :hover to be included in the box style
// {hover-demo:
#let gray-box = box(inline: false, class: "highlightable",
  fill: "var(--dk-gray2)", inset: 5mm,
)
#css.elems((
  ".highlightable": (
    transition: "0.3s",
  ),
  ".highlightable:hover": struct.box-style((:),
    fill: "var(--dk-red)",
    radius: (top-left: 5mm),
  )
))

#gray-box[Hover over me]
// :hover-demo}

== Spacing

#box(width: 100%)[#align(left)[
This is #html.div(style: css.raw-style((min-width: 5cm, background: red)))[] a test
]]

#box(width: 100%)[#align(left)[
This is #html.div(style: css.raw-style((width: 100%, min-height: 1cm, background: red)))[] another test.
]]

== More coming soon...

I will keep updating this page occasionally if I find an interesting trick,
or simply to implement more features. I have plans for:
- more options on already implemented elements
- justified text
- horizontal and vertical spaces
- images
- hrule

Don't hesitate to browse the source code in more detail, either #link("meta.html")[here]
or #link("https://github.com/vanille-n/website/tree/master/data/typ2html")[on the repo].

If you have suggestions you can open an
#link("https://github.com/login?return_to=https://github.com/Vanille-N/website/issues")[issue]
or #link("https://github.com/Vanille-N/website/compare")[pull request].

// TODO: there's something to do with links in general.

#include "/_src/footer.typ"

