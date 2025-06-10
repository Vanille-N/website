// Typst will translate "<", ">", "&" to "&lt;", "&gt", "&amp;",
// making it impossible to store the JS code in the body of the <script>
// element. Instead we store it in the label which is kept raw.
#let inline(block) = {
  html.elem("script",
    attrs: (src: {
      "data:application/javascript,"
      block.text.replace("\"", "%22").replace("&", "%26")
    }),
  )
}

#let external(file) = {
  html.elem("script", attrs: (src: file))
}
