#import "xhtml.typ"

#let raw-elem(target, params) = {
  target + " { " + params.pairs().map(args => {
    let (key, val) = args
    key + ": " + str(val) + ";"
  }).join(" ") + " }"
}

#let raw-elems(dict) = {
  dict.pairs().map(args => {
    let (key, val) = args
    raw-elem(key, val)
  }).join("\n")
}

#let elem(target, params) = {
  xhtml.style(raw-elem(target, params))
}

#let elems(dict) = {
  xhtml.style(raw-elems(dict))
}
