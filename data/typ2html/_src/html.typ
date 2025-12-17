// {func:
#let htmlfunc(label) = (..attrs) => {
  let keyvals = attrs.named().pairs().filter(p => p.at(1) != none).to-dict()
  html.elem(label, attrs: keyvals, ..attrs.pos())
}
// :func}

// {apply:
#let div = htmlfunc("div")
#let a = htmlfunc("a")
#let img = htmlfunc("img")
// :apply}

#let h1 = htmlfunc("h1")
#let h2 = htmlfunc("h2")
#let h3 = htmlfunc("h3")
#let p = htmlfunc("p")
#let span = htmlfunc("span")
#let link = htmlfunc("link")
#let pre = htmlfunc("pre")
#let style = htmlfunc("style")
#let button = htmlfunc("button")
#let code = htmlfunc("code")
#let footer = htmlfunc("footer")
#let input = htmlfunc("input")
#let label = htmlfunc("label")

#let script(..any) = {
  panic("Do not emit a <script> element without getting it checked by `js.external` or `js.inline`")
}
