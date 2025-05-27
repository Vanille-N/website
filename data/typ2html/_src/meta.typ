#import "css.typ"
#import "xhtml.typ"
#import "excerpt.typ"

#include "common.typ"

= Browse the source code of #link("index.html")[Typ2HTML]

#{
  for line in read("../list:all").split("\n") {
    if line != "" {
      let (file, lang) = line.split(" ")
      excerpt.incl(file, "", lang: lang)
    }
  }
}
