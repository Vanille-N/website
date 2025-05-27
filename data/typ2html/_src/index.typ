#import "excerpt.typ"
#import "css.typ"

#let this = "_src/index.typ"
#let css = "_assets/style.css"

// These markers are used to paste pieces of code in the final document.
// See `excerpt.typ`.
// {setup:
#set document(title: "Typ2HTML")
// :setup}

// {prelude:
#import "xhtml.typ"
#import "css.typ"
// :prelude}

#css.elem(":root", (
  "--black": "#1d2021",
  "--dk-gray0": "#282828",
  "--dk-gray1": "#3c3836",
  "--dk-gray2": "#504945",
  "--dk-gray3": "#665c54",
  "--dk-gray4": "#7c6f64",
  "--gray": "#928374",
  "--white": "#fbf1c7",
  "--lt-gray0": "#ebdbb2",
  "--lt-gray1": "#d5c4a1",
  "--lt-gray2": "#bdae93",
  "--lt-gray3": "#a89984",
  "--dk-red": "#cc241d",
  "--dk-green": "#98971a",
  "--dk-yellow": "#d79921",
  "--dk-blue": "#458588",
  "--dk-purple": "#b16286",
  "--dk-aqua": "#689d6a",
  "--dk-orange": "#d65d0e",
  "--lt-red": "#fb4934",
  "--lt-green": "#b8bb26",
  "--lt-yellow": "#fabd2f",
  "--lt-blue": "#83a598",
  "--lt-purple": "#d3869b",
  "--lt-aqua": "#8ec07c",
  "--lt-orange": "#fe8019",
))

// {style:
#css.elems((
  html: (
    background-color: "var(--black)",
  ),
  body: (
    margin: "40px auto",
    max-width: "1200px",
    line-height: 1.5,
    font-size: "18px",
    font-weight: 350,
    color: "#fbf1c7",
    background: "var(--dk-gray0)",
    padding: "0 10px",
  ),
  "h1,h2,h3,h4": (
    line-weight: 1.2,
    color: "var(--lt-green)",
  ),
  h1: ( font-weight: 800 ),
  h2: ( font-weight: 700 ),
  h3: ( font-weight: 600 ),
  a: ( color: "var(--dk-aqua)" ),
  "a:visited": ( color: "var(--lt-purple)" ),
))
// :style}

// {highlight:
// Unpacked the archive from https://highlightjs.org/download to _highlight/
#xhtml.script(src: "_highlight/highlight.min.js")
#xhtml.link(rel: "stylesheet", href: "_highlight/styles/base16/gruvbox-dark-soft.css")

// Copied from https://www.npmjs.com/package/@myriaddreamin/highlighter-typst
// the "cjs, js bundled, wasm bundled" script
#xhtml.script(src: "_highlight/highlight-typst.js")

#xhtml.script("
  const run = window.$typst$parserModule.then(() => {
    hljs.registerLanguage('typst', window.hljsTypst({}))
    hljs.highlightAll();
  });
")
// :highlight}

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

And I have my `Makefile` as such:
#excerpt.incl("Makefile", "", lang: "make")

This builds `index.html` in the root directory. \
To watch changes live, I open `index.html` in a browser
and `watch make` in the background.

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

=== Global style

This document already uses this method.
Through the module `css.typ` I have made it more or less easy to set
document-wide attributes, including background and foreground color,
font size, title color, etc.
You may recognize below something that reads like raw CSS, but formatted as nested Typst dictionaries.

#excerpt.incl(this, "style")

There is also a way to call some external `.js` code,
the use-case for this document is for syntax highlighing through
#link("https://highlightjs.org/")[`highlight.js`]

#excerpt.incl(this, "highlight")

=== Inline style


/*
== Prettification

A default HTML page is quite sad.
And a strain on the eyes.
Luckily Typst is already capable of including a CSS stylesheet,
simply by virtue of it being a builtin html element.

So we can have for example
#excerpt.incl(this, "style")

== Advanced layout

=== Styled text

Here's one possible approach that keeps everything locally
so you don't have to edit the global css too much:

#excerpt.incl(this, "alert")
// {alert:
#let add-css(target, ..params) = {
  let style = target + " { " + params.named().pairs().map(args => {
      let (key, val) = args
      key + ": " + val + ";"
    }).join(" ") + " }"
  xhtml.style(style)
}

#add-css(".alert",
  font-size: "30px",
  color: "var(--black)",
  background: "var(--lt-red)"
)
#xhtml.span(class: "alert")[Important]
// :alert}

=== Box

=== Line

=== Column

=== Grid
*/
