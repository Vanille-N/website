#import "xhtml.typ"

#let incl(src, label, lang: "typst") = {
  let lines = read("../" + src).split("\n")
  let start = -1
  let end = lines.len()
  for (idx, line) in lines.enumerate() {
    if line.contains("{" + label + ":") {
      start = idx
    } else if line.contains(":" + label + "}") {
      end = idx
    }
  }
  let comment-style = (
    typst: (t) => "/* " + t + " */",
    css: (t) => "/* " + t + " */",
    make: (t) => "# " + t,
    "none": (t) => "# " + t,
  )
  let fstline = comment-style.at(lang)(src + " @ ll. " + str(start + 2) + "-" + str(end))
  xhtml.pre({
    xhtml.code(class: "language-" + lang, {
      fstline + "\n" + lines.slice(start + 1, end).join("\n")
    })
  })
}
