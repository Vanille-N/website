#import "html.typ"

#let code(text, lang: "typst") = {
  html.pre({
    html.code(class: "language-" + lang, {
      text
    })
  })
}

#let inline(text, lang: "typst") = {
  html.span({
    html.code(class: "language-" + lang, {
      text
    })
  })
}

// Based on the language, choose what style of comments to use.
#let comment-style = (
  typst: (t) => "/* " + t + " */",
  css: (t) => "/* " + t + " */",
  make: (t) => "# " + t,
  markdown: (t) => "<!-- " + t + " -->",
  "none": (t) => "# " + t,
)

// This function allows one to insert pieces of source code in the final document.
// This is useful for tutorials because it guarantees that the version
// of the code that is shown is definitionally the latest version.
//
// To use, put in your source code the tags
//   {snippet-name:
//   ...
//   :snippet-name}
// before and after the region you want to copy,
// and invoke `excerpt.incl("path/to/file", "snippet-name")`
//
// The tags work anywhere on the line, so you can wrap them in any comment
// format that is appropriate for the filetype.
//
// If you want the entire file, use instead the companion function `excerpt.full("path/to/file")`
//
// You can optionally specify a language with `lang: ...` (Typst by default).
#let incl(src, label, lang: "typst") = {
  let lines = read("/" + src).split("\n")
  // Find the begin and end tags
  let start = none
  let end = none
  for (idx, line) in lines.enumerate() {
    if line.contains("{" + label + ":") {
      if start == none {
        start = idx
      } else {
        panic("Found the starting tag twice: at l. " + str(start + 1) + ", then at l. " + str(idx + 1))
      }
    }
    if line.contains(":" + label + "}") {
      if end == none {
        end = idx
      } else {
        panic("Found the ending tag twice: at l. " + str(end + 1) + ", then at l. " + str(idx + 1))
      }
    }
  }
  if start == none {
    panic("Did not find the starting tag {" + label + ":")
  }
  if end == none {
    panic("Did not find the ending tag :" + label + "}")
  }
  if start == end {
    panic("The start and and tags are on the same line " + str(idx + 1))
  }
  // TODO: allow disabling the header.
  let fstline = if start + 2 == end {
    comment-style.at(lang)(src + " @ l. " + str(end))
  } else {
    comment-style.at(lang)(src + " @ ll. " + str(start + 2) + "-" + str(end))
  }
  // Construct the block.
  // The parameter `class: "language-xyz"` allows it to be targeted by highlight.js
  code(lang: lang, fstline + "\n" + lines.slice(start + 1, end).join("\n"))
}

#let full(src, lang: "typst") = {
  let lines = read("/" + src)
  // TODO: allow disabling the header.
  let fstline = comment-style.at(lang)(src)
  code(lang: lang, fstline + "\n" + lines)
}
