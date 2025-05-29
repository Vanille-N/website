#import "xhtml.typ"

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
// If you want the entire file, just write `excerpt.incl("path/to/file", "")`
// and make sure the tags `{: ... :}` are used nowhere.
//
// You can specify a language with `lang: ...` (Typst by default).
#let incl(src, label, lang: "typst") = {
  let lines = read("../" + src).split("\n")
  // Find the begin and end tags
  let start = -1
  let end = lines.len()
  for (idx, line) in lines.enumerate() {
    if line.contains("{" + label + ":") {
      start = idx
    } else if line.contains(":" + label + "}") {
      end = idx
    }
  }
  // TODO: maybe print a warning if the tags look malformed ?
  // e.g. end found but not beginning, multiple instances, not found, etc.

  // Based on the language, choose what style of comments to use.
  let comment-style = (
    typst: (t) => "/* " + t + " */",
    css: (t) => "/* " + t + " */",
    make: (t) => "# " + t,
    markdown: (t) => "<!-- " + t + " -->",
    "none": (t) => "# " + t,
  )
  // TODO: allow disabling the header.
  let fstline = comment-style.at(lang)(src + " @ ll. " + str(start + 2) + "-" + str(end))
  // Construct the block.
  // The parameter `class: "language-xyz"` allows it to be targeted by highlight.js
  xhtml.pre({
    xhtml.code(class: "language-" + lang, {
      fstline + "\n" + lines.slice(start + 1, end).join("\n")
    })
  })
}
