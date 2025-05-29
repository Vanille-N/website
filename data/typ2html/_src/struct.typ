#import "xhtml.typ"
#import "css.typ"

#let class-key(class) = {
  if class == none { (:) } else {
    (class: class)
  }
}

#let align(where, inner) = {
  let style = (:)
  if where.y == top {
    style.margin-bottom = "auto"
  } else if where.y == bottom {
    style.margin-top = "auto"
  }
  if where.x == right {
    style.margin-left = "auto"
  } else if where.x == left {
    style.margin-right = "auto"
  }
  xhtml.div(style: css.raw-style(style), {
    inner
  })
}

#let structural(base-style, style-func, elem-func) = {
  let func(inline: true, class: none, ..args) = {
    let style = style-func(base: base-style, ..args.named())
    if inline {
      elem-func(..class-key(class), style: css.raw-style(style), ..args.pos())
    } else {
      assert(class != none)
      let css-elem = css.elem("." + class, style)
      let html-elem-builder(..extra-args) = {
        let extra-style = style-func(..extra-args.named())
        elem-func(..class-key(class), style: css.raw-style(extra-style), ..extra-args.pos())
      }
      (css-elem, html-elem-builder)
    }
  }
  func
}

#let text-base = (:)

#let text-style(base: (:), size: none, fill: none) = {
  let style = base
  if size != none { style.font-size = size }
  if fill != none { style.color = fill }
  style
}

#let text-elem(class: none, style: none, inner) = {
  xhtml.span(..class-key(class), style: style, inner)
}

#let text = structural(text-base, text-style, text-elem)


#let box-base = (display: "flex", flex-direction: "column", justify-content: "center", align-items: "center")

#let box-style(base: (:), inset: none, width: none, height: none, radius: none, fill: none, outset: none) = {
  let style = base
  if width != none { style.width = width }
  if height != none { style.height = height }
  if radius != none { style.border-radius = radius }
  if fill != none { style.background-color = fill }
  if inset != none { style.padding = inset }
  if outset != none { style.margin = outset }
  style
}

#let box-elem(class: none, style: none, inner) = {
  xhtml.div(..class-key(class), style: style, inner)
}

#let box = structural(box-base, box-style, box-elem)

#let table-base = (display: "grid", )

#let table-style(base: (:), class: none, columns: none, gutter: none, column-gutter: none, row-gutter: none, ..elts, style-only: none) = {
  let style = base
  if columns != none { style.grid-template-columns = "repeat(" + str(columns) + ", 1fr)" }
  if gutter != none { style.gap = gutter }
  if column-gutter != none { style.column-gap = column-gutter }
  if row-gutter != none { style.row-gap = row-gutter }
  style
}

#let table-elem(class: none, style: none, inner) = {
  xhtml.div(..class-key(class), style: style, inner)
}

#let table = structural(table-base, table-style, table-elem)

