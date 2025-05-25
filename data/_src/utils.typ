#import "xhtml.typ"

#let alert-banner(content) = {
  xhtml.div(class: "alert", {
    content
  })
}

#let navbar(current: none, ..elems) = {
  let found-highlight = false
  xhtml.div(class: "topnav", {
    for elem in elems.pos() {
      let (label, url, title) = elem
      let attrs = if label == current {
        found-highlight = true
        (href: "", class: "active")
      } else {
        (href: url)
      }
      xhtml.a(..attrs, {
        title
      })
    }
  })
  if not found-highlight {
    panic("None of the tabs match " + current)
  }
}

