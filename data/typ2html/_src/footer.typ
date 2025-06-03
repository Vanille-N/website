#import "/_src/t2h/mod.typ": css, html, struct

#import struct: *

// Define and style the footer.

#css.elems((
  footer: (
    // Follows the bottom of the page
    position: "fixed",
    bottom: 0,
    // Same width as body, see `_assets/global.css`
    width: 100%,
    max-width: "1200px",
  )
))

#html.footer[
  #box(width: "100%", inset: 1pt, radius: 3pt, fill: "var(--dk-gray2)")[
    #box(inset: (x: 5mm),
      text(size: 10pt)[
        Last build: #datetime.today().display()
      ]
    )
    #box(inset: (x: 5mm),
      text(size: 10pt)[
        Written by Vanille-N using Typst #sys.version
      ]
    )
    #box(inset: (x: 5mm),
      text(size: 10pt)[
        #link("https://github.com/Vanille-N/website/tree/master/data/typ2html/_src")[
          `github:vanille-n/website`
        ]
      ]
    )
  ]
]
