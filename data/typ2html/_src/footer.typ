#import "css.typ"
#import "xhtml.typ"
#import "struct.typ"

// Define and style the footer.

#css.elems((
  footer: (
    // Follows the bottom of the page
    position: "fixed",
    bottom: 0,
    // Same width as body, see `_assets/global.css`
    width: "100%",
    max-width: "1200px",
  )
))

#xhtml.footer[
  #struct.box(width: "100%", inset: 1pt, radius: 3pt, fill: "var(--dk-gray2)")[
    #struct.table(columns: 3, gutter: 70pt, [
      #struct.box(
        struct.text(size: 10pt)[
          Last build: #datetime.today().display()
        ]
      )
      #struct.box(
        struct.text(size: 10pt)[
          Written by Vanille-N using Typst #sys.version
        ]
      )
      #struct.box(
        struct.text(size: 10pt)[
          #link("https://github.com/Vanille-N/website/tree/master/data/typ2html/_src")[
            `github:vanille-n/website`
          ]
        ]
      )
    ])
  ]
]
