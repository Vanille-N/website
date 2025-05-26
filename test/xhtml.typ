#let htmlfunc(label) = (..attrs) => {
  html.elem(label, attrs: attrs.named(), ..attrs.pos())
}
#let div = htmlfunc("div")
#let a = htmlfunc("a")
#let img = htmlfunc("img")
#let p = htmlfunc("p")
#let span = htmlfunc("span")
#let link = htmlfunc("link")
#let style = htmlfunc("style")

