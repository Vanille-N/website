#import "xhtml.typ"

// TODO: document and test

#let aux-to-css = (
  pt: (abs) => str(abs) + "pt",
  em: (em) => str(em) + "em"
)

// TODO: find more types that are useful
// - color
// - auto
// - ...
#let type-to-css = (
  string: (elt) => elt,
  integer: (elt) => str(elt),
  float: (elt) => str(elt),
  "auto": (_) => "auto",
  length: (len) => {
    let abs = len.abs.pt()
    let em = len.em
    if em == 0 {
      (aux-to-css.pt)(abs)
    } else if abs == 0 {
      (aux-to-css.em)(em)
    } else {
      "calc(" + (aux-to-css.em)(em) + " + " + (aux-to-css.pt)(abs) + ")"
    }
  },
  ratio: (pct) => repr(pct),
)

#let into-css-str(elt) = {
  let has-trivial-impl = type-to-css.at(str(type(elt)), default: none)
  if has-trivial-impl != none {
    has-trivial-impl(elt)
  } else if type(elt) == relative {
    let len = elt.length
    let abs = len.abs.pt()
    let em = len.em
    let rat = elt.ratio
    let (sign-abs, abs) = if abs < 0 {
      (" - ", -abs)
    } else {
      (" + ", abs)
    }
    let (sign-em, em) = if em < 0 {
      (" - ", -em)
    } else {
      (" + ", em)
    }
    "calc(" + (type-to-css.ratio)(rat) + sign-em + (aux-to-css.em)(em) + sign-abs + (aux-to-css.pt)(abs) + ")"
  } else {
    panic("Unsupported type " + str(type(elt)))
  }
}

// Generate raw CSS not bound to a class.
// This can be put in a `style=...` parameter.
// The input should have the form of a dictionary of (key, value) pairs
// so that every `key: str(value)` is a valid CSS setting.
#let raw-style(params) = {
  let ans = params.pairs().map(args => {
    let (key, val) = args
    key + ": " + into-css-str(val) + ";"
  }).join(" ")
  if ans == none { "" } else { ans }
}

// Bind a style to a class.
#let raw-elem(target, params) = {
  target + " { " + raw-style(params) + " }"
}

// Interpret a dictionary as multiple instances of `raw-elem`.
#let raw-elems(dict) = {
  dict.pairs().map(args => {
    let (key, val) = args
    raw-elem(key, val)
  }).join("\n")
}

// Include the raw CSS for `raw-elem` in a <style> tag.
#let elem(target, params) = {
  xhtml.style(raw-elem(target, params))
}

// Include the raw CSS for `raw-elems` in a <style> element.
#let elems(dict) = {
  xhtml.style(raw-elems(dict))
}

// Include a separately written CSS file into the document.
#let include-file(path) = {
  xhtml.link(rel: "stylesheet", href: path)
}
