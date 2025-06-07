// Currently it is not possible to have Typst export the code within
// <script>...</script> properly because it will turn '<' into '&lt;'.
// For lack of a satisfying workaround, we'll be content for now with
// a compilation error if we try to include one of '<', '>', '&'.

#let inline(block) = {
  let raw = block.text
  for c in ("<", ">", "&") {
    if raw.contains("<") {
      panic("The character '" + c + "' is not properly handled by Typst. Change your code to avoid it.")
    }
  }
  html.elem("script", raw)
}

#let external(file) = {
  html.elem("script", attrs: (src: file))
}
