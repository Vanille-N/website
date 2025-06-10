#import "/typ2html/_src/mod.typ": html

#let toki(tx) = {
  html.span(class: "sitelen-pona", {
    tx
  })
}
