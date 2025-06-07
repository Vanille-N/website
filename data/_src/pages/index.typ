#import "/_src/t2h/mod.typ": html, css, js, struct
#import "/_src/utils/mod.typ": global, header, links, people

#global.style("")
#header.navbar-website("home")

= Neven Villani
a.k.a. Vanille, jan Newen

#html.img(src: "_img/portrait.jpg")

#links.github-link("Vanille-N")
#links.email-link("Personnal: neven (dot) villani (at) crans.org")
#links.email-link("Professional: neven (dot) villani (at) univ-grenoble-alpes.fr")

// TODO: Put a horizontal line here

#let timeline-date(date) = {
  let (year, month) = date
  let month-name = (
    "",
    "Jan", "Feb", "Mar", "Apr",
    "May", "Jun", "Jul", "Aug",
    "Sep", "Oct", "Nov", "Dec",
  )
  [#month-name.at(month) #year]
}

#let timeline-dates(start, end) = {
  [#timeline-date(start) --- #{if end != none { timeline-date(end) }}]
}

#let timeline-transform(elem) = {
  let dates = timeline-dates(elem.start, elem.at("end", default: none))
  let collab = elem.at("collab", default: ())
  let details = elem.at("details", default: none)
  let title = [#elem.what at #elem.where]
  let hover-text = {
    let collab-is-empty = if type(collab) == str {
      collab == ""
    } else if type(collab) == array {
      collab.len() == 0
    } else if type(collab) == none {
      true
    } else {
      panic("Unsupported type for collab: " + str(type(collab)))
    }
    let collab-as-str = collab.map(people.fmt-full-name).join(", ")
    if collab-is-empty { "" } else {
      "joint work with: " + collab-as-str
    }
  }
  let inner = elem.at("inner", default: ())
  (dates: dates, title: title, hover-text: hover-text, inner: inner, collab: collab, details: details)
}

#let timeline-entry(dates: [], title: [], hover-text: "", inner: (), collab: none, details: none) = {
  html.div(class: "entry", title: hover-text, {
    html.div(class: "date", { dates })
    html.div(class: "title", { title })
    html.div(class: "details", { details })
    for elem in inner {
      timeline-entry(..timeline-transform(elem))
    }
  })
}

#let timeline(elems) = {
  html.div(class: "timeline", {
    for elem in elems.rev() {
      timeline-entry(..timeline-transform(elem))
    }
  })
}

#css.elems((
  ".timeline": (
    display: "flex",
    flex-direction: "column",
  ),

  ".timeline .entry": (
    background: "var(--black)",
    border-radius: "10px",
    padding: "3px",
    border: "1px solid var(--dk-gray0)",
    border-left: "2px solid var(--dk-orange)",
    transition: "background 0.2s",
    margin-left: "1rem",
    margin-top: "0.2rem",
    padding-left: "1rem",
  ),

  ".timeline .entry:hover": (
    background: "var(--dk-gray1)",
  ),

  ".timeline .entry .date": (
    font-size: "1rem",
    font-weight: "bold",
    color: "var(--lt-orange)",
  ),

  ".timeline .entry .title": (
    font-size: "1rem",
    margin-top: "3px",
  ),

  ".timeline .entry .details": (
    font-size: "0.9rem",
    color: "var(--lt-gray3)",
  ),
))

#timeline((
  (
    start: (2018, 09),
    end: (2020, 08),
    what: [Classe Préparatoire],
    where: [Lycée Louis-le-Grand],
    details: [Filière MPSI puis MP\*],
  ),
  (
    start: (2020, 09),
    end: (2024, 08),
    what: [Student],
    where: [ENS Paris-Saclay],
    details: [Dpt of Computer Science],
    inner: (
      (
        start: (2021, 05),
        end: (2021, 06),
        what: [Internship],
        where: [LaBRI (Bordeaux)],
        details: [Properties of Dynamic Unit Disk Graphs],
        collab: (people.a-casteigts,),
      ),
      (
        start: (2022, 02),
        end: (2022, 07),
        what: [Internship],
        where: [Aalto Univ. (Finland)],
        details: [Mending Volume Complexity of Locally Checkable Labelings],
        collab: (people.d-melnyk, people.j-suomela),
      ),
      (
        start: (2022, 10),
        end: (2023, 07),
        what: [Predoctorate],
        where: [MPI-SWS (Germany)],
        details: [Tree Borrows, a New Aliasing Model for Rust],
        collab: (people.r-jung, people.j-hostert, people.d-dreyer),
      ),
      (
        start: (2023, 09),
        end: (2024, 02),
        what: [Master's degree],
        where: [Univ. Paris Cité],
        details: [MPRI2, oriented Verification and Type Systems],
      ),
      (
        start: (2024, 03),
        end: (2024, 07),
        what: [Internship],
        where: [Verimag (Grenoble)],
        details: [A Counting Abstraction for Parameterized Systems],
        collab: (people.r-iosif, people.a-sangnier, people.m-bozga),
      ),
    ),
  ),
  (
    start: (2024, 09),
    what: [PhD in Computer Science],
    where: [Verimag (Grenoble)],
    details: [Automated Verification of Parameterized Reconfigurable Systems],
    collab: (people.r-iosif, people.a-sangnier, people.m-bozga),
  )
))

