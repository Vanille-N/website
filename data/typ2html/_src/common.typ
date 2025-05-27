#import "css.typ"
#import "xhtml.typ"

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
