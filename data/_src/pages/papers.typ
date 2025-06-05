#import "/_src/t2h/mod.typ": html, css, struct
#import "/_src/utils/mod.typ": global, header, people, links

#global.style("")
#header.navbar-research("papers")

#let status = (
  published: struct.box(width: 100%)[],
  occurred: struct.box(width: 100%)[#struct.align(center)[#struct.text(fill: "var(--lt-blue)")[*Soon*]]],
  accepted: struct.box(width: 100%)[#struct.align(center)[#struct.text(fill: "var(--lt-green)")[*Accepted*]]],
  submitted: struct.box(width: 100%)[#struct.align(center)[#struct.text(fill: "var(--lt-orange)")[*Submitted*]]],
)

#let published = (
  (
    status: status.published,
    journal: [OPODIS],
    location: [Brussels],
    title: [Mending Partial Solutions with Few Changes],
    coauthors: (people.d-melnyk, people.j-suomela),
    urls: (
      article: "drops.dagstuhl.de/entities/document/10.4230/LIPIcs.OPODIS.2022.21",
      arxiv: "2209.05363",
    ),
    abstract: "In this paper, we study the notion of mending, i.e. given a partial solution to a graph problem, we investigate how much effort is needed to turn it into a proper solution. For example, if we have a partial coloring of a graph, how hard is it to turn it into a proper coloring?",
  ),

  2022,

  (
    status: status.occurred,
    journal: [NETYS],
    location: [Rabat],
    title: [Verifying Parameterized Networks
      Specified by Vertex Replacement Graph Grammars],
    coauthors: (people.m-bozga, people.a-sangnier, people.r-iosif),
    urls: (
      arxiv: "2505.01269",
    ),
    abstract: "We consider the parametric reachability problem (PRP) for families of networks described by vertex-replacement (VR) graph grammars, where network nodes run replicas of finite-state processes that communicate via binary handshaking. We show that the PRP problem for VR grammars can be effectively reduced to the PRP problem for hyperedge-replacement (HR) grammars at the cost of introducing extra edges for routing messages.",
  ),

  (
    status: status.accepted,
    journal: [PLDI],
    location: [Seoul],
    title: [Tree Borrows],
    coauthors: (people.d-dreyer, people.j-hostert, people.r-jung),
    urls: (
      home: "plf.inf.ethz.ch/research/pldi25-tree-borrows.html",
      preprint: "perso.crans.org/vanille/treebor/aux/preprint.pdf",
    ),
    abstract: "The Rust programming language is well known for its ownership-based
    type system, which offers strong guarantees like memory safety and data race freedom.
    However, Rust also provides unsafe escape hatches, for which safety is not guaranteed 
    automatically and must instead be manually upheld by the programmer.
    This creates a tension. On the one hand, compilers would like to exploit the strong 
    guarantees of the type system in order to unlock powerful intraprocedural optimizations.
    On the other hand, those optimizations are easily invalidated by “badly behaved” unsafe code.
    To ensure correctness of such optimizations, it thus becomes necessary to clearly define what 
    unsafe code is “badly behaved”.
    We present Tree Borrows, a set of rules improving on prior work to achieve this goal.",
  ),

  (
    status: status.accepted,
    journal: [CAV],
    location: [Zagreb],
    title: [Counting Abstraction and Decidability
      for the Verification of Structured Parameterized Networks],
    coauthors: (people.a-sangnier, people.r-iosif),
    urls: (
      arxiv: "2502.15391",
    ),
    abstract: "We consider the verification of parameterized networks of replicated
processes whose architecture is described by hyperedge-replacement
graph grammars. We present a counting abstraction able to produce,
from a graph grammar describing a parameterized system,
a finite set of Petri nets that over-approximate the behaviors of the original
system. Moreover, we identify a decidable fragment,
for which the coverability problem is in 2EXPTIME and PSPACE-hard.",
  ),

  2025,
)

// This is a trick to display the abstract when we hover over the paper.
// See below
// (1) what we put in <div class="abstract">
// (2) some JS code to pilot the movement according to mouse events.
#css.elems((
  ".paper:hover .abstract": (
    display: "block",
  ),
  ".abstract": (
    display: "none",
    margin-left: 1cm,
    position: "absolute",
    z-index: 1000,
  )
))

#{
  for paper in published.rev() {
    // Ints represent year separators, not actual papers
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
    // Format one paper entry
    struct.box(class: "paper", inset: (y: 2mm), outset: 1mm, width: 100%, fill: "var(--dk-gray1)", struct.align(left, {
      // Floating abstract follows mouse
      html.div(class: "abstract", {
        struct.box(
          width: 12cm,
          fill: "var(--dk-gray2)",
          radius: (top-left: 0mm, rest: 5mm),
          inset: 5mm,
          struct.align(left)[#struct.text(size: 11pt)[
            #paper.abstract
        ]])
      })
      // Left region with paper, location, status
      struct.box(width: 3cm, struct.align(center + top, {
        struct.box[
          #struct.text(fill: "var(--lt-gray2)")[*#paper.journal* \ (#paper.location)]
        ]
        paper.status
      }))
      // Right region with title, coauthors, links
      struct.box(class: "paper", width: 100% - 3cm)[#struct.align(left)[
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

#html.script("
  var tooltip = document.querySelectorAll('.abstract');

  document.addEventListener('mousemove', movetooltip, false);

  function movetooltip(e) {
    for (var i=tooltip.length; i--;) {
        tooltip[i].style.left = e.pageX + 'px';
        tooltip[i].style.top = e.pageY + 'px';
    }
  }"
)
