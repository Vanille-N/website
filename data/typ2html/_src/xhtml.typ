// {func:
#let htmlfunc(label) = (..attrs) => {
  html.elem(label, attrs: attrs.named(), ..attrs.pos())
}
// :func}

// {apply:
#let div = htmlfunc("div")
#let a = htmlfunc("a")
#let img = htmlfunc("img")
// :apply}

#let p = htmlfunc("p")
#let span = htmlfunc("span")
#let link = htmlfunc("link")
#let pre = htmlfunc("pre")
#let style = htmlfunc("style")
#let script = htmlfunc("script")
#let code = htmlfunc("code")

