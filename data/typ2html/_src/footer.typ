#import "css.typ"
#import "xhtml.typ"
#import "struct.typ"

#css.elems((
  footer: (
    position: "fixed",
    bottom: 0,
    width: "100%"
  )
))

#xhtml.footer[
  #struct.box(inset: "1pt", radius: "3pt", fill: "var(--dk-gray2)")[
    #struct.align(left)[
      #struct.box(
        struct.align(left)[
          #struct.text(size: "10pt")[
            Written in Typst by Vanille-N;
            see source code at #link("https://github.com/Vanille-N/website/tree/master/data/typ2html/_src")[`github:vanille-n/website`]
          ]
        ]
      )
    ]
  ]
]
