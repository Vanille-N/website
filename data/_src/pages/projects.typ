#import "/typ2html/_src/mod.typ": html, css
#import "/_src/utils/mod.typ": global, header

#global.style("")
#header.navbar-website("projects")
#header.under-reconstruction()

#let link-generic(base) = "https://" + base
#let link-arch(base) = link-generic("wiki.archlinux.org/title/" + base)
#let link-github(base) = link-generic("github.com/Vanille-N/" + base)
#let link-gitlab(base) = link-generic("gitlab.com/Vanille-N/" + base)
#let link-gricad(base) = link-generic("gricad-gitlab.univ-grenoble-alpes.fr/neven/" + base)
#let link-crates(base) = link-generic("crates.io/crates/" + base)

#let interpret-link(key, val) = {
  let as-url = (
    github: link-github,
    gitlab: link-gitlab,
    gricad: link-gricad,
  )
  let as-icon = (
    github: "_img/github.svg",
    gitlab: "_img/gitlab.svg",
    gricad: "_img/gitlab.svg",
  )
  html.a(href: as-url.at(key)(val), {
    html.img(src: as-icon.at(key), width: "15px", height: "15px")
  })
}

#let badge(name, lang: "", urls: (:), what: "") = {
  html.div(class: "badge", {
    html.div(class: "badge-left", {
      html.img(src: "_img/" + lang + ".svg", width: "64px", height: "64px")
      html.div(class: "badge-title", { name })
      html.div(class: "badge-links", {
        for (key, val) in urls {
          interpret-link(key, val)
        }
      })
    })
    html.div(class: "badge-right", {
      what
    })
  })
}

#css.elems((
  ".badge-grid": (
    display: "grid",
    grid-template-columns: "repeat(auto-fill, minmax(250px, 1fr))",
    gap: "0.8rem",
  ),
  ".badge": (
    background: "var(--black)",
    border-radius: "2px",
    padding: "0.7rem",
    display: "flex",
    flex-direction: "row",
    align-items: "center",
    transition: "0.2s",
    color: "var(--lt-purple)",
  ),
  ".badge:hover": (
    border-radius: "2px 2px 60px 2px",
    background: "var(--white)",
    color: "var(--black)",
  ),
  ".badge-title": (
    font-size: "1.2rem",
    font-weight: "bold",
    margin-bottom: "0.5rem",
    text-align: "center",
  ),
  ".badge-left": (
    width: "450px",
    display: "flex",
    align-items: "center",
    flex-direction: "column",
  ),
  ".badge-right": (
    flex-grow: 1,
    width: "500px",
    font-size: "10pt",
    color: "var(--black)",
    padding: "1mm",
  ),
  ".badge-links": (
    display: "flex",
    flex-wrap: "wrap",
    justify-content: "center",
    gap: "0.2rem",
  ),
  ".badge-links a": (
    background: "var(--dk-gray0)",
    padding: "0.1rem 0.5rem",
    border-radius: "8px",
    transition: "background 0.2s",
  ),
  ".badge-links a:hover": (
    background: "var(--dk-gray2)",
  ),
))

#html.div(class: "badge-grid", {
  badge([Pytrace],
    lang: "rust",
    urls: (
      github: "ray_tracer",
    ),
    what: [A ray tracer to render scenes with accurate shadows.
    Includes a Python API.],
  )
  
  badge([COCass],
    lang: "ocaml",
    urls: (
      github: "cocass",
    ),
    what: [A compiler from a toy version of C to x86 64-bit assembly.],
  )

  badge([Forklang],
    lang: "c",
    urls: (
      github: "forklang",
    ),
    what: [A toy language with nondeterminism, to implement and verify distributed protocols.],
  )

  badge([Billig],
    lang: "rust",
    urls: (
      github: "billig",
    ),
    what: [Expense tracker with a feature to amortize purchases over the relevant period.],
  )

  badge([Chandeliers],
    lang: "rust",
    urls: (
      github: "chandeliers",
    ),
    what: [Inline Lustre code in Rust via a compiler written in procedural macros.],
  )

  badge([Minihell],
    lang: "ocaml",
    urls: (
      gitlab: "mpri-2.4-project-2023-2024",
    ),
    what: [Type inference for a lambda-calculus-like language with algebraic datatypes and recursivity.],
  )

  badge([ParCoSys],
    lang: "ocaml",
    urls: (
      gricad: "parcosys",
    ),
    what: [Parameterized coverability solver for systems specified by HR-style graph grammars.],
  )

  badge([Wallrnd],
    lang: "rust",
    urls: (
      github: "wallrnd",
    ),
    what: [Generator of random geometric wallpapers depending on the time of the day.],
  )

  badge([Roguelike],
    lang: "scala",
    urls: (
      github: "roguelike",
    ),
    what: [A small 2-player game.],
  )

  badge([Thermohaline],
    lang: "cpp",
    urls: (
      github: "TIPE",
    ),
    what: [Simulation of the thermohaline oceanic circulation for the TIPE.],
  )

  badge([Rask],
    lang: "rust",
    urls: (
      github: "rask",
    ),
    what: [A small interpreted Scheme-like language.],
  )

  badge([CTM],
    lang: "c",
    urls: (
      github: "turing_machine",
    ),
    what: [Turing machines in the C preprocessor.],
  )

  badge([Mandelbrot],
    lang: "cpp",
    urls: (
      github: "mandelbrot",
    ),
    what: [Navigate and make screenshots of the Mandelbrot set.],
  )

  badge([Sorts],
    lang: "cpp",
    urls: (
      github: "sorts_visualization",
    ),
    what: [Visualize several sorting algorithms in the style of "The Sound of Sorting".],
  )
})

