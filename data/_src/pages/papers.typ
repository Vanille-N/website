#import "/_src/lib/mod.typ": xhtml, css, struct
#import "/_src/utils/mod.typ": global, header, people, links

#global.style("")
#header.navbar-research("papers")

#let published = (
  (
    journal: [OPODIS],
    location: [Brussels],
    title: [Mending Partial Solutions with Few Changes],
    coauthors: (people.d-melnyk, people.j-suomela),
    urls: (
      article: "drops.dagstuhl.de/entities/document/10.4230/LIPIcs.OPODIS.2022.21",
      arxiv: "2209.05363",
    ),
  ),

  2022,

  (
    journal: [NETYS],
    location: [Rabat],
    title: [Verifying Parameterized Networks
      Specified by Vertex Replacement Graph Grammars],
    coauthors: (people.m-bozga, people.a-sangnier, people.r-iosif),
    urls: (
      arxiv: "2505.01269",
    )
  ),

  (
    journal: [PLDI],
    location: [Seoul],
    title: [Tree Borrows],
    coauthors: (people.d-dreyer, people.j-hostert, people.r-jung),
    urls: (
      home: "plf.inf.ethz.ch/research/pldi25-tree-borrows.html",
      preprint: "perso.crans.org/vanille/treebor/aux/preprint.pdf",
    )
  ),

  (
    journal: [CAV],
    location: [Zagreb],
    title: [Counting Abstraction and Decidability
      for the Verification of Structured Parameterized Networks],
    coauthors: (people.a-sangnier, people.r-iosif),
    urls: (
      arxiv: "2502.15391",
    )
  ),

  2025,
)

#{
  for paper in published.rev() {
    if type(paper) == int {
      struct.box(width: 100%, struct.align(center + horizon, {
        struct.box(width: 45%, height: 1pt, fill: "var(--lt-orange)")[]
        struct.box(width: 10%)[#struct.align(center + horizon)[
          #struct.text(fill: "var(--lt-orange)", size: 20pt)[*#paper*]
        ]]
        struct.box(width: 45%, height: 1pt, fill: "var(--lt-orange)")[]
      }))
      continue
    }
    struct.box(inset: (y: 2mm), outset: 1mm, width: 100%, fill: "var(--dk-gray1)", struct.align(left, {
      struct.box(width: 3cm, struct.align(center, {
        struct.text(fill: "var(--lt-gray2)")[*#paper.journal* \ (#paper.location)]
      }))
      struct.box(width: 100% - 3cm)[#struct.align(left)[
        #struct.box(width: 100%)[*#paper.title*]
        #struct.box(width: 100%)[with #{paper.coauthors.map(people.fmt-full-name).join(", ")}]
        #struct.box(width: 100%, {
          for (key, url) in paper.urls {
            let image = (
              arxiv: "_img/arxiv.svg",
              article: "_img/journal.svg",
              preprint: "_img/pdf.svg",
              home: "_img/home.svg",
            ).at(key)
            let url-interp = (
              arxiv: links.url-arxiv,
            ).at(key, default: links.url-default)
            struct.box(outset: (x: 1mm), {
              links.img-link(image, url-interp(url), key, size: "30")
            })
          }
        })
      ]]
    }))
  }
}
