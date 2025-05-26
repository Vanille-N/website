#import "@preview/suiji:0.4.0": *
#import "css.typ"
#import "xhtml.typ"

#let my-style = (
  color: "blue",
  background: "gray",
  border-radius: "3pt",
  display: "inline-block",
  padding: "5pt",
)
= Raw

#css.elem(".raw", my-style)
#xhtml.div(class: "raw", {
  [This is a test]
})

= Inlined

#xhtml.div(class: "inlined", style: css.raw-style(my-style), {
  [This is another test]
})

