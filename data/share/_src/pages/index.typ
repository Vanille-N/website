#import "/_src/t2h/mod.typ": html, css, struct
#import "/_src/utils/mod.typ": global, links, header

#global.style("")
#header.navbar-website("share")

#css.elems((
  ".collapsible": (
    background-color: "var(--dk-gray1)",
    border: "none",
  ),
  ".active, .collapsible:hover": (
    background-color: "var(--dk-gray2)",
  ),
  ".content": (
    display: "none",
    overflow: "hidden",
  )
))
#let section(title, contents) = {
  html.button(type: "button", class: "collapsible", style: "width:100%; text-align:left; margin:1mm")[= #title]
  html.div(class: "content", {
    contents
  })
}

#let entry(..args) = {
  let args = args.named()
  struct.box(
    width: 100% - 5mm,
    fill: "var(--dk-gray1)",
    inset: 2mm,
    outset: 1mm,
    radius: (bottom-left: 5mm, top-right: 5mm),
  {
    struct.box(outset: (x: 5mm))[#links.img-link("_img/pdf.svg", args.url, "pdf", size: "20")]
    struct.box(outset: (x: 1mm))[#strong[#args.title]]
    struct.box(outset: (x: 5mm))[#struct.text(fill: "var(--lt-gray3)")[ \@ #args.where]]
  })
}

#section[Preprints][

#entry(
  title: [Counting Abstraction for the Verification of Structured Parameterized Networks],
  where: [CAV'25],
  url: "phd/preprint-cav25.pdf",
)
#entry(
  title: [Tree Borrows],
  where: [PLDI'25],
  url: "satge/arpe/preprint-pldi25.pdf",
)
#entry(
  title: [Verifying Parameterized Networks Specified by VR Grammars],
  where: [NETYS'25],
  url: "phd/preprint-netys25.pdf",
)
#entry(
  title: [Mending Partial Solutions with Few Changes],
  where: [OPODIS'22],
  url: "satge/m1/paper.pdf",
)

]

#section[Beamers][

#entry(
  title: [Verifying Parameterized Networks Specified by VR Grammars],
  where: [NETYS'25],
  url: "phd/beamer-netys25.pdf",
)
#entry(
  title: [Tree Borrows],
  where: [PLDI'25],
  url: "satge/arpe/pldi.pdf",
)
#entry(
  title: [Tree Borrows],
  where: [ENS Paris-Saclay],
  url: "satge/arpe/ens.pdf",
)
#entry(
  title: [Tree Borrows],
  where: [ETAPS],
  url: "satge/arpe/etaps.pdf",
)
#entry(
  title: [Tree Borrows],
  where: [ETH Zurich],
  url: "satge/arpe/eth.pdf",
)
#entry(
  title: [Tree Borrows],
  where: [LMF],
  url: "satge/arpe/lmf.pdf",
)
#entry(
  title: [Tree Borrows],
  where: [RFMIG],
  url: "satge/arpe/rfmig.pdf",
)
#entry(
  title: [Mending Partial Solutions with Few Changes],
  where: [OPODIS'22],
  url: "satge/l3/beamer.pdf",
)
#entry(
  title: [Properties of Dynamic Unit Disk Graphs],
  where: [ENS Paris-Saclay],
  url: "satge/m1/beamer.pdf",
)

]

#section[Crans][

#entry(
  title: [Technical Report],
  where: [General Assembly (2023)],
  url: "crans/bilantech-23.pdf",
)
#entry(
  title: [Technical Report],
  where: [General Assembly (2024)],
  url: "crans/bilan-tech-2024.pdf",
)

]

#section[School Reports][

#entry(
  title: [Categories],
  where: [MPRI1],
  url: "categories/beamer.pdf",
)
#entry(
  title: [Network Modeling],
  where: [MPRI2],
  url: "netmod/hajek.pdf",
)
#entry(
  title: [Verified Compilation],
  where: [MPRI1],
  url: "compverif/report.pdf",
)
#entry(
  title: [Verified Compilation (beamer)],
  where: [MPRI1],
  url: "compverif/beamer.pdf",
)
#entry(
  title: [Bachelor's Thesis],
  where: [ENS Paris-Saclay],
  url: "satge/l3/report.pdf",
)

]

#html.script("
  var coll = document.getElementsByClassName(\"collapsible\");

  for (var i = coll.length; i--;) {
    coll[i].addEventListener(\"click\", function() {
      this.classList.toggle(\"active\");
      var content = this.nextElementSibling;
      if (content.style.display === \"block\") {
        content.style.display = \"none\";
      } else {
        content.style.display = \"block\";
      }
    });
  }
")
