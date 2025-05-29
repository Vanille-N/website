#import "css.typ"
#import "xhtml.typ"
#import "excerpt.typ"

#include "common.typ"

= Source code of #link("index.html")[Typ2HTML]

Also available directly
#link("https://github.com/vanille-n/website/tree/master/data/typ2html")[on the repo].

#{
  for line in read("../list:all").split("\n") {
    if line != "" {
      let (file, lang) = line.split(" ")
      xhtml.h2(class: "header-link", id: file, raw(file))
      excerpt.incl(file, none, lang: lang)
    }
  }
}

#include "footer.typ"
