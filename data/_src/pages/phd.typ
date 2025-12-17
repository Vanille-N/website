#import "/typ2html/_src/mod.typ": html, css, js, struct
#import "/_src/utils/mod.typ": global, header, people, links

#global.style("")
#header.navbar-research("phd")

My PhD at Verimag started on September 1st 2024.
You may find below a timeline.


// preprint
// talk
// paper
// artifact
// journal
// project meeting
// accepted
// event

#let event = (
  preprint: (
    title: [Preprint],
    label: "preprint",
    explanation: [Preprints],
    checked: false,
    color: "var(--lt-orange)",
  ),
  talk: (
    title: [Talk],
    label: "talk",
    explanation: [Talks],
    checked: true,
    color: "var(--dk-blue)",
  ),
  paper: (
    title: [Paper],
    label: "paper",
    explanation: [Published papers],
    checked: true,
    color: "var(--dk-orange)",
  ),
  artifact: (
    title: [Artifact],
    label: "artifact",
    explanation: [Code artifacts],
    checked: false,
    color: "var(--dk-orange)",
  ),
  conf: (
    title: [Conference],
    label: "conf",
    explanation: [Conference participations],
    checked: false,
    color: "var(--lt-blue)",
  ),
  pavedys: (
    title: [PaVeDyS],
    label: "pavedys",
    explanation: [PaVeDyS group meetings],
    checked: false,
    color: "var(--lt-blue)",
  ),
  accept: (
    title: [Accepted],
    label: "accept",
    explanation: [Accepted papers],
    checked: false,
    color: "var(--dk-green)",
  ),
  admin: (
    title: [Admin.],
    label: "admin",
    explanation: [Administrative events],
    checked: false,
    color: "var(--lt-yellow)",
  ),
  major: (
    title: [Events],
    label: "major",
    explanation: [Notable dates],
    checked: true,
    color: "var(--lt-red)",
  )
)

#let all-checked = false

#css.elems((
  ".hidden": (display: "none"),
))

#{
  struct.box(width: 10%, {})
  struct.box(width: 85%, {
    struct.align(left, {
      for (_, evt) in event {
        struct.box(stroke: (paint: blue.lighten(70%)), {
          struct.box({
            html.label({
              html.input(
                type: "checkbox",
                id: evt.label,
                ..if evt.checked or all-checked { (checked: "checked") } else { (:) },
              )
            })
            evt.explanation
          })
        })
      }
    })
  })
}

#js.inline(raw({
  ```js
  function toggleVisibility(checkboxId, classname) {
    const checkbox = document.getElementById(checkboxId);
    checkbox.addEventListener('change', () => {
      const elts = document.querySelectorAll(classname);
      elts.forEach(elt => {
        elt.classList.toggle('hidden', !checkbox.checked);
      })
    });
  }

  ```.text
  for (_, evt) in event {
    "toggleVisibility('" + evt.label + "', '.elt-" + evt.label + "'); \n"
  }
}))

#let published = (
  (
    event: event.admin,
    date: [Nov. 2023],
    title: [Application accepted for an M2 internship at Verimag],
    info: [],
  ),
  (
    event: event.pavedys,
    date: [Jan. 2024],
    title: [Project launch reunion],
    info: [],
  ),
  (
    event: event.major,
    date: [Mar. 2024],
    title: [Beginning of internship],
    info: [],
  ),
  (
    event: event.admin,
    date: [Jun. 2024],
    title: [CDSN funding granted],
    info: [],
  ),
  (
    event: event.major,
    date: [Sep. 2024],
    title: [Beginning of PhD],
    info: [],
  ),
  (
    event: event.pavedys,
    date: [Oct. 2024],
    title: [Second project meeting],
    info: [Presented early work that would become the CAV paper.],
  ),
  (
    event: event.preprint,
    date: [Jan. 2025],
    title: [Paper submitted to CAV],
    info: [Title: "Counting Abstraction and Decidability for the Verification
      of Structured Parameterized Networks". Includes work from the internship
      and the beginning of the PhD.],
    urls: (
      arxiv: links.url-arxiv("2502.15391"),
    ),
  ),
  (
    event: event.preprint,
    date: [Feb. 2025],
    title: [Paper submitted to NETYS],
    info: [Title: "Verifying Parameterized Networks Specified by Vertex
      Replacement Graph Grammars". Generalizes some results from the CAV
      paper to a more general class of graphs via a translation.],
    urls: (
      arxiv: links.url-arxiv("2505.01269"),
    ),
  ),
  (
    event: event.accept,
    date: [Mar. 2025],
    title: [Paper accepted at CAV],
    info: [],
  ),
  (
    event: event.accept,
    date: [Apr. 2025],
    title: [Paper accept at NETYS],
    info: [],
  ),
  (
    event: event.artifact,
    date: [Apr. 2025],
    title: [Artifact published for CAV],
    info: [Implementation programmed during the internship and improved
      during the beginning of the PhD. Written in OCaml, solves standard examples.],
    urls: (
      cav3: "https://zenodo.org/records/15223051",
    ),
  ),
  (
    event: event.pavedys,
    date: [May 2025],
    title: [Third project meeting],
    info: [Presented the same content as the NETYS talk.],
  ),
  (
    event: event.conf,
    date: [May 2025],
    title: [NETYS],
    info: [5 days in Rabat (Morocco).],
  ),
  (
    event: event.talk,
    date: [May 2025],
    title: [Verifying Parameterized Networks
      Specified by Vertex Replacement Graph Grammars],
    info: [At NETYS. Presents the contents of the paper of the same name.],
    urls: (
      beamer: "share/phd/beamer-netys25.pdf",
    ),
  ),
  (
    event: event.conf,
    date: [Jul. 2025],
    title: [CAV],
    info: [4 days in Zagreb (Croatia).],
  ),
  (
    event: event.talk,
    date: [Jul. 2025],
    title: [Counting Abstraction and Decidability
      for the Verification of Structured Parameterized Networks],
    info: [At CAV. Presents the contents of the paper of the same name.],
    urls: (
      beamer: "share/phd/beamer-cav25.pdf",
    ),
  ),
  (
    event: event.paper,
    date: [Aug. 2025],
    title: [CAV Proceedings],
    info: [Volume 37, Part III, page 238],
    urls: (
      book: "https://link.springer.com/book/10.1007/978-3-031-98682-6",
    ),
  ),
  (
    event: event.conf,
    date: [Sep. 2025],
    title: [AVM],
    info: [3 days in Timișoara (Romania).],
  ),
  (
    event: event.talk,
    date: [Sep. 2025],
    title: [On the Verification of Structured Parameterized Networks],
    info: [At AVM. Synthesis of CAV and NETYS works.],
    urls: (
      beamer: "share/phd/beamer-avm25.pdf",
    ),
  ),
  (
    event: event.paper,
    date: [Sep 2025],
    title: [NETYS Proceedings],
    info: [Volume 13, page 57],
    urls: (
      book: "https://link.springer.com/book/10.1007/978-3-032-00347-8",
    ),
  ),
)

#{
  for paper in published.rev() {
    // Format one paper entry
    html.div(class: "elt-" + paper.event.label + if paper.event.checked or all-checked { "" } else { " hidden" }, {
    struct.box(class: "paper", inset: (y: 2mm), outset: 1mm, width: 100%, fill: "var(--dk-gray1)", struct.align(left, {
      // Left region with date, kind
      struct.box(class: "paper", width: 3cm)[
        #struct.align(center)[
          #struct.box(width: 100%)[#struct.align(center)[
            #struct.text(fill: paper.event.color)[*#paper.event.title*]
          ]]
          #paper.date
        ]
      ]
      // Right region with title, coauthors, links
      struct.box(class: "paper", width: 100% - 6cm)[#struct.align(left)[
        #struct.box(width: 100%)[#struct.align(left)[*#paper.title*]]
        #struct.box(width: 100%)[#struct.align(left)[#struct.text(fill: "var(--lt-gray3)")[#paper.info]]]
      ]]
      struct.box(width: 3cm, {
        struct.align(right, {
          for (key, url) in paper.at("urls", default: ()) {
            let image = (
              arxiv: "_img/logos/arxiv.svg",
              article: "_img/generic/journal.svg",
              preprint: "_img/logos/pdf.svg",
              home: "_img/generic/home.svg",
              beamer: "_img/generic/beamer.svg",
              video: "_img/generic/video.svg",
              book: "_img/generic/book.svg",
              cav3: "_img/artifacts/cav-reusable.svg",
            ).at(key)
            struct.box(outset: (x: 1mm), {
              links.img-link(image, url, key, size: "30")
            })
          }
        })
      })
    }))
  })
  }
}
