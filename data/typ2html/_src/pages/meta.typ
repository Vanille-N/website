#import "/_src/mod.typ": html, css, excerpt

#include "/_src/common/highlight.typ"

= Source code of #link("index.html")[Typ2HTML]

Also available directly
#link("https://github.com/vanille-n/website/tree/master/data/typ2html")[on the repo].

#let print(path, lang: "typst") = {
  html.h2(class: "header-link", id: path, raw(path))
  excerpt.full(path, lang: lang)
}

#print("justfile", lang: "make")
#print("_assets/global.css", lang: "css")

#{
  for t2hfile in ("mod", "html", "css", "js", "struct", "excerpt") {
    print("_src/" + t2hfile + ".typ")
  }

  for auxfile in ("highlight", "footer") {
    print("_src/common/" + auxfile + ".typ")
  }

  for pagefile in ("index", "meta") {
    print("_src/pages/" + pagefile + ".typ")
  }
}

#include "/_src/common/footer.typ"

