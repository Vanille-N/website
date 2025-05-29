#import "xhtml.typ"

// Generate raw CSS not bound to a class.
// This can be put in a `style=...` parameter.
// The input should have the form of a dictionary of (key, value) pairs
// so that every `key: str(value)` is a valid CSS setting.
#let raw-style(params) = {
  let ans = params.pairs().map(args => {
    let (key, val) = args
    key + ": " + str(val) + ";"
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
