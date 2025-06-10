#import "/typ2html/_src/mod.typ": html
#import "pona.typ"

#let alert-banner(content) = {
  html.div(class: "alert", {
    content
  })
}

#let make-navbar(current: none, ..elems) = {
  let found-highlight = false
  html.div(class: "topnav", {
    for elem in elems.pos() {
      let (label, url, title) = elem
      let attrs = if label == current {
        found-highlight = true
        (href: "", class: "active")
      } else {
        (href: url)
      }
      html.a(..attrs, {
        title
      })
    }
  })
  if not found-highlight {
    panic("None of the tabs match " + current)
  }
}

#let navbar-website(current) = {
  set document(title: "Vanille's Homepage")
  make-navbar(
    current: current,
    ("home", "index.html", [*Home*]),
    ("projects", "projects.html", [*Projects*]),
    ("research", "research.html", [*Research*]),
    ("tools", "tools.html", [*Tools*]),
    ("share", "share/index.html", [*Documents*]),
    ("pbm", "better-pbm-viewer/index.html", [*PBM Viewer*]),
    ("pona", "lipu.html", [#pona.toki("o kama pona lon lipu mi")]),
    ("typ2html", "typ2html/index.html", [*Typ2HTML*]),
  )
}

#let navbar-research(current) = {
  navbar-website("research")
  make-navbar(
    current: current,
    ("home", "research.html", [Overview]),
    ("talks", "talks.html", [Talks]),
    ("papers", "papers.html", [Publications]),
    ("treebor", "treebor/index.html", [Tree Borrows]),
    ("phd", "phd.html", [PhD]),
  )
}

#let under-reconstruction() = {
  alert-banner[
    *Under reconstruction* \
    This webpage is being refactored, sorry for the disturbance.
  ]
}

