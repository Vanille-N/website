#import "xhtml.typ"
#import "css.typ"

// This is a trick to declare the CSS for a class at most once.
// We use `state` to store the styles that were already declared,
// so that we know which ones not to include twice.
#let registered-styles = state("registered-styles", (:))
#let maybe-generate-style(label, style) = {
  context {
    let styles = registered-styles.get()
    if not styles.at(label, default: false) {
      // Run this code only if not declared yet.
      css.elem(label, style) // Declare.
      registered-styles.update(styles => {
        styles.insert(label, true) // Record in the state as declared.
        styles
      })
    }
  }
}

// Easy way to optionally pass `class: class` to a function.
#let class-key(class) = {
  if class == none { (:) } else {
    (class: class)
  }
}

// Implement alignment, simulating Typst's `align`.
#let align(where, inner) = {
  let style = (:)
  // Vertical handling.
  if where.y == top {
    style.margin-bottom = "auto"
  } else if where.y == bottom {
    style.margin-top = "auto"
  }
  // Horizontal handling.
  if where.x == right {
    style.margin-left = "auto"
  } else if where.x == left {
    style.margin-right = "auto"
  }
  // Make the div.
  xhtml.div(style: css.raw-style(style), {
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
        maybe-generate-style("." + class, style)
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
  xhtml.span(..class-key(class), style: style, inner)
}
#let text = structural(text-base, text-style, text-elem)


// `box` simulates Typst's function of the same name.
#let box-base = (
  display: "inline-flex", flex-direction: "line",
  justify-content: "center", align-items: "center",
)
#let box-style(
  base,
  inset: none, width: none, height: none, radius: none,
  fill: none, outset: none,
  // TODO: stroke
  // TODO: per-corner radius
  // TODO: per-border inset and margin
) = {
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
  xhtml.div(..class-key(class), style: style, inner)
}
#let table = structural(table-base, table-style, table-elem)

