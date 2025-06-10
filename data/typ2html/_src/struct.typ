#import "html.typ"
#import "css.typ"
#import "once.typ"

#let builtin-stroke = stroke

// Easy way to optionally pass `class: class` to a function.
#let class-key(class) = {
  if class == none { (:) } else {
    (class: class)
  }
}

// Implement alignment, simulating Typst's `align`.
#let align(where, inner) = {
  let style = (
    width: 100%,
    display: "flex",
    flex-wrap: "wrap",
    flex-direction: "row",
  )
  // Vertical handling.
  if where.y == top {
    style.margin-bottom = "auto"
  } else if where.y == bottom {
    style.margin-top = "auto"
  }
  // Horizontal handling.
  if where.x == right {
    style.text-align = "right"
    style.justify-content = "flex-end"
  } else if where.x == left {
    style.text-align = "left"
    style.justify-content = "flex-start"
  } else {
    style.text-align = "center"
    style.justify-content = "center"
  }
  // Make the div.
  html.div(style: css.raw-style(style), {
    inner
  })
}

// Some of the constructors that follow provide one of two behaviors:
// - create the element right now; or
// - create a builder that lazily declares a CSS style and binds it to the element.
// The first is easier, but might result in a larger HTML file.
//
// - `base-style` should be the default style
// - `style-func` takes named parameters and optionally generates more style
// - `elem-func` takes
//    - optionally, a class name to fetch the defaults from
//    - optionally, more style to override the defaults
//    - the inner contents
#let structural(base-style, style-func, elem-func) = {
  // Resulting function is capable of returning either the element
  // or a builder for the element
  let func(inline: true, class: none, ..args) = {
    // Build the default style from all named arguments
    let style = style-func(base-style, ..args.named())
    if inline {
      // In inline mode, build the element directly
      elem-func(..class-key(class), style: css.raw-style(style), ..args.pos())
    } else {
      // In non-inline mode, there must be a class specified.
      assert(class != none)
      // We return a builder that will on-demand...
      let html-elem-builder(..extra-args) = {
        // ...declare the default style at most once
        once.once("style:" + class, css.elem("." + class, style))
        // ...bind the defaults and any overriding values to the specific element
        let extra-style = style-func((:), ..extra-args.named())
        elem-func(..class-key(class), style: css.raw-style(extra-style), ..extra-args.pos())
      }
      html-elem-builder
    }
  }
  func
}

// `text` simulates Typst's function of the same name.
#let text-base = (:)
#let text-style(
  base,
  size: none, fill: none,
  // TODO: font
) = {
  let style = base
  if size != none { style.font-size = size }
  if fill != none { style.color = fill }
  style
}
#let text-elem(class: none, style: none, inner) = {
  html.span(..class-key(class), style: style, inner)
}
#let text = structural(text-base, text-style, text-elem)


// `box` simulates Typst's function of the same name.
// TODO: comment
#let box-base = (
  display: "inline-flex", flex-direction: "line",
  //justify-content: "center", align-items: "center",
  flex-wrap: "wrap",
)
#let box-style(
  base,
  inset: none, width: none, height: none, radius: none,
  fill: none, outset: none, stroke: none,
  // TODO: stroke
) = {
  let style = base
  if width != none { style.width = width }
  if height != none { style.height = height }
  if radius != none {
    if type(radius) == dictionary {
      let precedence = (
        ("top-left", ("top-left",)),
        ("top-right", ("top-right",)),
        ("bottom-left", ("bottom-left",)),
        ("bottom-right", ("bottom-right",)),
        ("top", ("top-left", "top-right")),
        ("bottom", ("bottom-left", "bottom-right")),
        ("left", ("top-left", "bottom-left")),
        ("right", ("top-right", "bottom-right")),
        ("rest", ("top-left", "top-right", "bottom-left", "bottom-right")),
      )
      let radii = (:)
      for (key, targets) in precedence {
        if key in radius {
          for target in targets {
            if target not in radii {
              radii.insert(target, radius.at(key))
            }
          }
        }
      }
      style.border-radius = (radii.at("top-left", default: 0), radii.at("top-right", default: 0),
        radii.at("bottom-right", default: 0), radii.at("bottom-left", default: 0)).map(css.into-css-str).join(" ")
    } else {
      style.border-radius = radius
    }
  }
  if fill != none { style.background-color = fill }
  if inset != none {
    if type(inset) == dictionary {
      if "y" in inset {
        style.padding-top = inset.y
        style.padding-bottom = inset.y
      }
      if "x" in inset {
        style.padding-left = inset.x
        style.padding-right = inset.x
      }

    } else {
      style.padding = inset
    }
  }
  if outset != none {
    if type(outset) == dictionary {
      if "y" in outset {
        style.margin-top = outset.y
        style.margin-bottom = outset.y
      }
      if "x" in outset {
        style.margin-left = outset.x
        style.margin-right = outset.x
      }
    } else {
      style.margin = outset
    }
  }
  if stroke != none {
    if type(stroke) == dictionary {
      if "top" in stroke or "bottom" in stroke or "left" in stroke or "right" in stroke or "rest" in stroke {
        for key in ("top", "bottom", "left", "right") {
          if key in stroke {
            style.insert("border-" + key, builtin-stroke(stroke.at(key)))
          }
        }
        if "rest" in stroke {
          style.border = builtin-stroke(stroke.rest)
        }
      } else {
        style.border = builtin-stroke(stroke)
      }
    } else {
      style.border = builtin-stroke(stroke)
    }
  }
  style
}
#let box-elem(class: none, style: none, inner) = {
  html.div(..class-key(class), style: style, inner)
}
#let box = structural(box-base, box-style, box-elem)

// `table` simulates Typst's function of the same name.
#let table-base = (display: "grid", )
#let table-style(
  base,
  class: none, columns: none, gutter: none, column-gutter: none,
  row-gutter: none,
  // TODO: stroke
  // TODO: more options for column width control.
) = {
  let style = base
  if columns != none { style.grid-template-columns = "repeat(" + str(columns) + ", 1fr)" }
  if gutter != none { style.gap = gutter }
  if column-gutter != none { style.column-gap = column-gutter }
  if row-gutter != none { style.row-gap = row-gutter }
  style
}
#let table-elem(class: none, style: none, inner) = {
  html.div(..class-key(class), style: style, inner)
}
#let table = structural(table-base, table-style, table-elem)

#let box-linebreak = {
  html.div(style: css.raw-style((flex-basis: 100%, height: 0)))
}

